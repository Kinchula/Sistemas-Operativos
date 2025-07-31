#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 2) { // check if the user wrote 2 arguments
    fprintf(2, "ERROR: NO HAY SUFICIENTES ARGUMENTOS.\n" ); 
    fprintf(2, "Modo de uso: pingpong <número>\n");
    exit(1);
  }
  int N = atoi(argv[1]); //It will read the second argument (in this case the one following “pingpong”), and pass it to int. if it is not a number, it returns 0.
  if(N<=0) {
    fprintf(2, "ERROR: INGRESE UN VALOR POSITIVO.\n");
    exit(1);
  }
  int rc = fork();
  int i = 0;
  int j = 0;
  int id_sem_child = 0;
  int id_sem_parent = 1;
  if(rc < 0){
    fprintf(2, "ERROR: falló el fork del pingpong\n", argv[i]);
    exit(1);
  }
  // Init semaphores
  sem_open(id_sem_child,1);
  sem_open(id_sem_parent,0);
  if(rc == 0){  // child
    while(i < N){
      sem_down(id_sem_child); 
      printf("ping\n");
      sem_up(id_sem_parent);
      i++;
    }
    sem_close(id_sem_child);
    exit(0);
  } else {  // parent
    while(j < N){
      sem_down(id_sem_parent); 
      printf("pong\n");
      sem_up(id_sem_child);
      j++;
    }
    wait(0);
    sem_close(id_sem_parent);
    sem_close(id_sem_child);
    }
    return 0;
}