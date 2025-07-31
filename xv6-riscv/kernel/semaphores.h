#ifndef SEMAPHORES_H
#define SEMAPHORES_H
#include "stdbool.h"
#include "spinlock.h"

struct semaphore;
// Each semaphore has a "name" that identifies it with the kernel; in our case, 
// the names are integer numbers between 0 and a maximum limit. 
// Maximum limit = 128

void semaphores_init();

int sem_open(int sem, int value);
int sem_close(int sem);
int sem_up(int sem);
int sem_down(int sem);

#endif 
