#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"

#define MAX_SEMAPHORES 128

struct semaphore {
  int value;
  int in_use;
  struct spinlock lock;
};

struct semaphore semaphores[MAX_SEMAPHORES]; 

void
semaphores_init()
{
  for(unsigned int i = 0u; i < MAX_SEMAPHORES; i++) {
    semaphores[i].value = 0;
    semaphores[i].in_use = 0;
    initlock(&semaphores[i].lock, "semaphore");
  }
}

int
sem_open(int sem, int value)
{
  if (sem < 0 || value < 0 || sem >= MAX_SEMAPHORES) {
    return -1;
  }

  acquire(&semaphores[sem].lock); 
  // Attempts to acquire the lock of the semaphore at position sem.
  // This prevents other processes from working with that semaphore while sem_open is using it.

  if (semaphores[sem].in_use) { // If it was already in use, return error.
    release(&semaphores[sem].lock);
    return -1;
  } 

  semaphores[sem].in_use = 1; // Activates the semaphore so it can be modified by sem_up and sem_down.
  semaphores[sem].value = value;
  release(&semaphores[sem].lock); // Releases the lock, allowing other programs to use it.
  
  return 0;
}

int
sem_close(int sem)
{
  // Verify that the semaphore is valid.
  if (sem < 0 || sem >= MAX_SEMAPHORES) {
  	printf("ERROR: Invalid semaphore. Please ensure that the process ID is correct.\n");
  	return -1;
  }
  // Acquire the lock to protect access to the semaphore structure.
  acquire(&(semaphores[sem].lock));
  // Verify that the semaphore can be freed in the correct way.
  semaphores[sem].value = 0u;
  semaphores[sem].in_use = 0u;
  if (semaphores[sem].value != semaphores[sem].in_use) {
  	printf("ERROR: Could not free the semaphore as expected. Please verify that it is at its initial value.\n");
  	release(&(semaphores[sem].lock));
  	return -1;
  }
  
  release(&(semaphores[sem].lock)); // Release the lock.
  return 0; // Semaphore closed successfully.
}

int
sem_up(int sem)
{
 if (sem < 0 || sem >= MAX_SEMAPHORES) { // Ensure that the semaphore is valid.
    return -1;  // Error code if the semaphore is not valid.
  }

  acquire(&semaphores[sem].lock); // Acquire the semaphore's lock.
  semaphores[sem].value++; // Increment the semaphore.
  
  if (semaphores[sem].value > 0) { // Check if any processes need to be awakened.
    wakeup(&semaphores[sem]);  // Unblock processes that are waiting.
  }

  release(&semaphores[sem].lock); // Release the lock.

  return 0;
}

int
sem_down(int sem)
{
  if (sem < 0 || sem >= MAX_SEMAPHORES) {
    return -1;
  }

  acquire(&semaphores[sem].lock); 

  if(semaphores[sem].value < 0) { //
    release(&semaphores[sem].lock);
    return -1;
  }

  // By convention: 0 indicates that this semaphore is shared among threads of the same process.
  while(semaphores[sem].value == 0) {
    sleep(&semaphores[sem], &semaphores[sem].lock); // Blocks the process until the semaphore is free.
  }
  semaphores[sem].value--; // sem_down when the semaphore is free.

  release(&semaphores[sem].lock);

  return 0;
}