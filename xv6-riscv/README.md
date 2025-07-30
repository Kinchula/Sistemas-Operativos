# Laboratorio 2: Semáforos en XV6  

## Introducción
En este laboratorio se implementó un sistema de semáforos para espacio de usuario, que sirven como mecanismo de sincronización entre procesos. Se implementaron en la versión RISC-V de XV6 (sistema operativo con fines académicos) en espacio de kernel, y son syscalls accesibles desde espacio de usuario.  
Los semáforos implementados son del tipo *semáforos nombrados*, inspirados en los semáforos definidos por POSIX.  
A continuación, se listan sus características principales:  

- Son administrados por el kernel.
- Están disponibles globalmente para todos los procesos del sistema operativo (no hay semáforos privados).
- Su estado se preserva mientras el SO esté activo (se pierden entre reinicios).
- Cada semáforo tiene un "nombre" que lo identifica con el kernel, en nuestro caso los nombres son números enteros entre 0 y un límite máximo (idea similar a los file descriptors).
### 1. Syscalls:
- `sem_open(int sem, int value)`: Abre y/o inicializa el semáforo `sem` con un valor arbitrario `value`.  
- `sem_close(int sem)`: Libera el semáforo `sem`.  
- `sem_up(int sem)`: Incrementa el semáforo `sem`, desbloqueando los procesos cuando su valor es 0.  
- `sem_down(int sem)`: Decrementa el semáforo `sem`, bloqueando los procesos cuando su valor es 0 (el valor del semáforo nunca puede ser menor a 0).  
### 2. Programa `pingpong`
El programa sincroniza la escritura en pantalla de la cadena "ping" y "pong" utilizando semáforos. Este comando toma un argumento `N` (rally), que indicará cuántas veces aparecerán "ping" y "pong" intercalados.  

- Un proceso imprime "ping" N veces, pero nunca dos "ping" seguidos sin que haya un "pong" intermedio.  
- El otro proceso imprime "pong" N veces, sin repetir "pong" dos veces consecutivas sin un "ping" en medio.  
- La secuencia siempre comienza con "ping".  

![Programa](https://i.ibb.co/strBHdP/f0f55cf5-471e-4af5-9f19-22319528fbab.gif)
## Instalación de XV6 y puesta en marcha

1. Instalar QEMU:
  
  ```bash
  sudo apt-get install qemu-system-riscv64 gcc-riscv64-linux-gnu
  ```
  
2. Compilar e iniciar XV6:  
  (Dentro del directorio `xv6-riscv`)
  
  ```bash
  make qemu
  ```
  
3. Opcional: Usar Docker para evitar instalación local de dependencias:
  
  ```bash
  docker build --tag 'xv6-env-so' - < Dockerfile.xv6
  docker run -it --rm -v $(pwd):/home/xv6/xv6-riscv xv6-env-so
  ```
  
## Integrantes
- Beretta, José María
- Kühn, Matías Ezequiel
- Patrón, Carlos Antonio
- Yorbandi, Selien Xavier
## Modalidad de Trabajo
Realizamos *división de tareas* para cada uno de los semáforos y trabajamos en *pair programming* para la función pingpong y para resolver problemas.
Utilizamos la herramienta **Jira** para organizar las tareas mediante un **Kanban**. También mantuvimos comunicación por **Discord** y **Whatsapp**.
Hicimos uso de ramas para evitar conflictos.
## Entrega
Tag: v0.0.3
## Decisiones de diseño

### Semáforos

Implementamos los semáforos en el área del **kernel**:  

- `semaphores.h`: firma de las funciones y tipo opaco.
- `semaphores.c`: definimos el `struct semaphore` y el arreglo de semáforos, además de las funciones:
    - `int sem_open(int sem, int value)`: abre un semáforo con el valor `value`.
    - `int sem_close(int sem)`: libera un semáforo en uso.
    - `int sem_up(int sem)`: incrementa el semáforo desbloqueando los procesos cuando su valor es 0.
    - `int sem_down(int sem)`: decrementa el semáforo bloqueando los procesos cuando su valor es 0.
    - `void semaphores_init()`: inicializa el arreglo de semáforos, todos con el valor 0 y sin uso.
Estas funciones siguen la convención estandar en XV6 y Unix para el **tratamiento de errores**. Específicamente en nuestro caso estas funciones retornan 0 en caso de éxito y -1 en caso de error. Nos pareció más adecuado seguir con este patrón para facilitar la claridad y entendimiento de estos semáforos en el marco de XV6.  

- `defs.h `: aquí incluimos la firma de los semáforos para poder ser usados entre funciones del kernel.  
- `sysproc.c` : dentro tenemos las syscalls para cada semáforo, cada una funciona como una envoltura para las funciones modularizadas en semaphore.c, siguiendo el estilo de xv6 para este archivo.  
- `syscall.c `: incluimos las syscalls de los semáforos en el arreglo de syscalls con su respectivo prototipo, para que así sean accesibles por las demás funciones del espacio del kernel.  
- `main.c` : llamamos la función que inicializa el arreglo de semáforos.  
### Pingpong
Implementamos esta función en el área de usuario (**user**):  

- `user.h `: incluímos aquí la firma de las funciones de los semáforos para poder utilizarlas en pingpong.c, dado que esta es la manera que utiliza XV6 para poner a disposición funciones del kernel en user.  
- `pingpong.c `: hacemos uso de los semáforos para coordinar la ejecución de un proceso padre y otro proceso hijo. Se crea un semáforo para el hijo inicializado en 1 y otro para el padre inicializado en 0. El hijo imprime "ping" y el padre "pong", alternando entre sí usando *sem_down* y *sem_up* para sincronizarse. Cada proceso cierra su semáforo al terminar y se espera que ambos terminen con *wait*.  
## Errores
Notamos que durante ciclos de ejecución de **make** *grade* el test de chequeo de concurrencia falla.
Con base en lo que aprendimos en el *lab 0*, utilizamos la siguiente linea en el bash para realizar las observaciones:
```
for i in {0..99}; do make grade | grep "Score:" >> resultados.out; done `
```
Hemos observado que, al ejecutar esta linea en los distintos ordenadores de los integrantes de este grupo, se presentaron una cantidad variable de errores. (~0-10% observados).  

El error consiste en una desincronización entre el último **"pong"** y el **"done"**.  

``` bash
hart 1 starting
hart 2 starting
init: starting sh
$ pingpong 10 & ; pingpong 10 & ; pingpong 20 ; echo DONE
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pong
ping
pDONEo
ng
$ qemu-system-riscv64: terminating on signal 15 from pid 109421 (make)
```  

Algunas de las cosas que probamos:

- Inicializar los semáforos con números al "azar". (Basados en el PID)  
- Inicializar el siguiente semáforo "libre", del arreglo de semáforos.  
- Cambiar el momento en el que cerrábamos los semáforos. ("Solo en el Hijo", "Solo en el Padre", "Ambos")  
- Cambiar el valor de inicialización del arreglo de semáforos.  
