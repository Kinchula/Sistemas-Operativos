# Laboratorio 3: Planificador de procesos  

## Primera parte: Estudiando el planificador xv6-riscv  

1. ¿Qué política de planificación utiliza xv6-riscv para elegir el próximo proceso a ejecutarse?
Round Robin: tiene switch e interrupciones. Se puede ver el código de scheduler en proc.c. Además, en trap.c aparece la función clockintr, que maneja las interrupciones del temporizador. Pocas políticas interrumpen un proceso a mitad de camino: RR, STCF y MLFQ. Si fuese STCF debería tener una forma de contar cuánto dura cada proceso, pero no lo hace. También sé que no es un multilevel feedback queue, pues no hay división por prioridad, sino que hay una sola lista donde están todos (struct proc proc[NPROC]).

2. ¿Cuáles son los estados en los que un proceso puede permanecer en xv6-riscv y qué los hace cambiar de estado?
Estados:
UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE.

    UNUSED: al inicializar la tabla de procesos, cada uno se inicializa con estado UNUSED.

    USED: la función allocproc() busca procesos con estado UNUSED y les asigna un PID. Así inicializa el estado requerido para correr en el kernel, y su estado cambia a USED.

     RUNNABLE: la función procinit() cambia el estado del primer proceso de usuario inicializado a RUNNABLE. Ese primer proceso puede generar otros procesos mediante llamadas a fork(), los cuales se generarán con el estado RUNNABLE. Además, si un proceso estaba en estado SLEEPING por esperar algún recurso o evento, la función wakeup() lo reactiva y actualiza su estado a RUNNABLE.

    RUNNING: el scheduler revisa la tabla de procesos, y al encontrar uno en estado RUNNABLE, adquiere el lock y cambia su estado a RUNNING, guardando el contexto del proceso a ejecutar, luego de lo cual se ejecuta.
    
    SLEEPING: la función sleep(void *chan, struct spinlock *lk) cambia el estado de RUNNABLE a SLEEPING. Es usada
cuando se espera por eventos específicos.

    ZOMBIE: la función exit() se usa cuando un proceso ha terminado su ejecución. El proceso pasa al estado ZOMBIE, y la información del mismo sigue existiendo en la tabla de procesos, pudiendo ser recogida por el padre, el cual puede estar esperando gracias a la función wait() a que el hijo termine. Los hijos de este proceso se reasignan al primer proceso inicializado.

3. ¿Qué es un quantum? ¿Dónde se define en el código? ¿Cuánto dura un quantum en xv6-riscv?
Quantum es el tiempo fijo que tiene asignado un proceso para usar el cpu. Está definido en start.c, en la función timerinit(), como 1000000 de ciclos de reloj, lo que equivale a 100ms en el simulador. 
Como estamos virtualizando xv6, el tiempo REAL es relativo, ya que al estar emulando el codigo, este no corre directamente sobre el cpu, sino que tambien se estan ejecutando otros procesos dentro de la maquina (por ejemplo: visual studio code, terminal,etc)
si bien la medida de 100 ms, llamarlo una "medida de tiempo" no estaría siendo una definición muy acertada ya que, como hemos mencionado, el tiempo dependerá de varíos factores.

4. ¿En qué parte del código ocurre el cambio de contexto en xv6-riscv? ¿En qué funciones un proceso deja de ser ejecutado? ¿En qué funciones se elige el nuevo proceso a ejecutar?
El cambio de contexto ocurre en la función swtch(), que se encuentra aplicada en las funciones scheduler() y sched(). En scheduler, se busca constantemente programas que estén en estado RUNNABLE. Al encontrar uno, se cambia su estado a RUNNING y se hace un context switch con swtch(), luego de esta función parece ser que el proceso ya no está ejecutando. En sched() también se da un cambio de contexto, y esta función parece ser llamada cuando un programa cambia su estado de RUNNING a otro estado, ya sea por esperar I/O, por esperar la finalización de un evento u otra razón.

Funciones en las que un proceso deja de ser ejecutado:

    yield(): cambia el estado del proceso en ejecución a RUNNABLE y llama a otro proceso con sched().

    sleep(void *chan, struct spinlock *lk): pone un proceso en espera, cambiando su estado a SLEEPING. Libera los recursos acaparados por el proceso que está SLEEPING y llama a otro proceso usando sched().Podemos observar que sched() se usa para un cambio de contexto entre un programa que debe dejar de ejecutarse y un programa que puede ejecutarse.

    exit(int status): sale del proceso, convirtiéndolo en ZOMBIE. Deja la información en la tabla de procesos para que el padre la recoja. Se hace wakeup() en la función exit() para despertar a un padre que esté en espera (wait), y así recopile la información.

5. ¿El cambio de contexto consume tiempo de un quantum?
Sí, el cambio de contexto consume una parte del quantum, por lo tanto mientras menor sea el quantum, más porcentaje de él será usado para el cambio de contexto.

## Segunda Parte: Medir operaciones de cómputo y de entrada/salida  

### Experimento 1

[Tablas de Datos de Experimento 1](./tests/experimento1.md)

[Gráficas análiticas de los resultados](./tests/graph-exp-metrics-xv6/graph-exp1/)

1. Describa los parámetros de los programas cpubench e iobench para este experimento (o sea, los define al principio y el valor de N. Tener en cuenta que podrían cambiar en experimentos futuros, pero que si lo hacen los resultados ya no serán comparables).

Métrica de Cpubench = total_cpu_kops / elapsed_ticks. N = 20.  
Métrica de IObench = total_iops / elapsed_ticks. N = 20.  

2. ¿Los procesos se ejecutan en paralelo? ¿En promedio, qué proceso o procesos se ejecutan primero? Hacer una observación cualitativa.

Al ejecutar xv6 en un único procesador mediante el comando make CPU=1 qemu, no hay paralelismo en el sentido de que los procesos no pueden ejecutarse simultáneamente; un solo CPU puede manejar únicamente un proceso a la vez. Sin embargo, el planificador de tipo Round Robin (RR) permite que la ejecución de estos procesos se multiplexe en el tiempo. Esto significa que el CPU alterna entre los procesos, asignando a cada uno un quantum de tiempo igual. Como el CPU se distribuye entre varios procesos, da la impresión de que varios procesos están activos al mismo tiempo, es decir que son paralelos.

Los procesos se ejecutan por orden de llegada. Esto puede verse en el start tick de cada proceso en los tests. 
Al ejecutar cpubench e iobench en segundo plano, el iobench queda en espera -en estado sleeping- hasta que cpubench termina su ejecucion. Además, si hay otros procesos iobench en segundo plano, como el archivo de lectura y escritura es el mismo para cada llamada iobench N &, deben esperar a que el primero libere dicho archivo para ejecutarse. Esto se evidencia en los tests, ya que el primer proceso iobound planificado se queda esperando la disponibilidad del recurso IO, por lo que devuelve un número alto de interrupciones (representado por todos los demás procesos que fueron planificados después de que comenzó la ejecución del proceso IO de marras).

3. ¿Cambia el rendimiento de los procesos iobound con respecto a la cantidad y tipo de procesos que se estén ejecutando en paralelo? ¿Por qué?

Según los tests realizados, los procesos iobound aumentan su rendimiento cuando están en simultáneo a otros procesos iobound. Cuando se ejecuta en paralelo a otros procesos cpubound, espera a que estos últimos terminen antes de continuar su ejecución.

4. ¿Cambia el rendimiento de los procesos cpubound con respecto a la cantidad y tipo de procesos que se estén ejecutando en paralelo? ¿Por qué?

Si cambia, pues el cpu distribuye el quantum entre los procesos simultáneos actuales, sobre todo si son cpubound.  

5. ¿Es adecuado comparar la cantidad de operaciones de cpu con la cantidad de operaciones iobound?

No, pues las operaciones IO consumen otros recursos además del cpu y tienen tiempos más largos, pues para estos otros recursos deben pedir permiso de acceso al kernel, lo cual las demora más que las operaciones de cpu, que no requieren permiso previo.

### Experimento 2

[Tablas de Datos de Experimento 2](./tests/experimento2.md)

[Gráficas análiticas de los resultados](./tests/graph-exp-metrics-xv6/graph-exp2/)

1. ¿Fue necesario modificar las métricas para que los resultados fueran
comparables? ¿Por qué?
Sí, pues el quantum era demasiado pequeño como para que iobench mostrara la cantidad de operaciones por tick. En el quantum de 10000 mostraba 0 operaciones por tick, lo que nos llevó a multiplicar la métrica por 100 en iobench, de manera que mostrara la cantidad de operaciones IO cada 100 ticks y así tuviesemos más información para comparar. Lo mismo ocurrió en el quantum de 1000: tuvimos que multiplicar por 1000 para obtener la cantidad de operacione IO cada 1000 ticks. En cpubench también multiplicamos por 10 la métrica para obtener cantidad de operaciones cpu cada 10 ticks, pues el número se hizo muy pequeño.
En resumen:
-Quantum de 10000: multiplicamos métrica de iobench * 100, obteniendo operaciones IO cada 100 ticks.
-Quantum de 1000: métrica de iobench * 1000 (operaciones IO cada 1000 ticks), metrica de cpubench * 10 (kilo operaciones de CPU cada 10 ticks).
Como el iobench 20 demoraba mucho en el quantum de 1000, decidimos repetir los experimentos pero con un N menor. Así, optamos por usar un N=4. También modificamos las métricas iniciales: en vez de cantidad de operaciones por tick, ahora mediremos cantidad de operaciones cada 1000 ticks tanto en cpubench como iobench.

2. ¿Qué cambios se observan con respecto al experimento anterior? ¿Qué
comportamientos se mantienen iguales?
Cambios: 
-En iobench podemos observar que a pesar de ser el quantum 10 veces menor al experimento 1, la cantidad de ticks totales aumenta más de 10 veces. pasa de 120-190 a 2085-2400. Esto nos indica que tiene que hacer más interrupciones que antes con un quantum más pequeño, por ende también ocurrirán más context switch, lo cual aumentará el tiempo total. Una de las razones de esto es que no llega a terminar la petición para I/O en un solo quantum por ser muy pequeño, por lo que debe esperar al siguiente quantum para terminar dicha petición y luego esperar a que le den acceso a I/O. Esto explicaría el por qué tiene menos operaciones de I/O cada 1000 ciclos comparado al experimento 1, teniendo en cuenta que para que sea "equivalente" deberíamos multiplicar la métrica por 10 (debido a que usamos un quantum 10 veces más chico que antes).
-Algo similar a lo escrito anteriormente ocurrió en cpubench. Al durar menos el quantum, hay más cambios de contexto y esto disminuye el tiempo de cada quantum, por lo que el quantum pierde buena parte de su tiempo en ese cambio de contexto. Se evidencia en la cantidad total de ticks ocurridos, cada uno de los cuales representa 1 quantum. Esta cantidad es mayor a la esperada, pues si dividimos por 10, entonces deberíamos tener 10 veces más ticks pero en este caso tenemos una cantidad aún mayor.

Notamos que no cambió la priorización de procesos cpubound por sobre iobound cuando se corren simultaneamente cpubench e iobench.

3. ¿Con un quatum más pequeño, se ven beneficiados los procesos iobound o los
procesos cpubound?
En este caso ninguno de los dos tipos de procesos se ve beneficiado, pero los iobound son los que peor responden a un quantum más pequeño, por lo que un quantum chico puede llegar a beneficiar a los procesos cpubound.

### Experimento 4  

[Tablas de Datos de Experimento 4](./tests/experimento4.md)  

[Gráficas análiticas de los resultados](./tests/graph-exp-metrics-xv6/graph-exp4/)  

1. Para análisis responda: ¿Se puede producir starvation en el nuevo planificador?
Justifique su respuesta.  

Sí se puede producir, pues si un proceso se ejecuta 1 o 2 veces, su prioridad bajará a 1 o 0, y cada nuevo proceso tendrá prioridad 2, por lo tanto si se ejecuta un gran numero de procesos nuevos constantemente, siempre se le dará prioridad a los nuevos, y los procesos con prioridad 1 o 0 no se ejecutarán.
