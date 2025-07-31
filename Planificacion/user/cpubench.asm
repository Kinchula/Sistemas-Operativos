
user/_cpubench:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <cpu_ops_cycle>:
#define MEASURE_PERIOD 1000


// Multiplica dos matrices de tamaño CPU_MATRIX_SIZE x CPU_MATRIX_SIZE
// y devuelve la cantidad de operaciones realizadas / 1000
int cpu_ops_cycle() {
   0:	1141                	add	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	add	s0,sp,16
   6:	08000793          	li	a5,128
   a:	08000693          	li	a3,128
   e:	8736                	mv	a4,a3
  float B[CPU_MATRIX_SIZE][CPU_MATRIX_SIZE];
  float C[CPU_MATRIX_SIZE][CPU_MATRIX_SIZE];

  // Inicializar matrices con valores arbitrarios
  for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
    for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
  10:	377d                	addw	a4,a4,-1
  12:	ff7d                	bnez	a4,10 <cpu_ops_cycle+0x10>
  for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
  14:	37fd                	addw	a5,a5,-1
  16:	ffe5                	bnez	a5,e <cpu_ops_cycle+0xe>
  18:	10000613          	li	a2,256
int cpu_ops_cycle() {
  1c:	08000693          	li	a3,128
  20:	85b6                	mv	a1,a3
  22:	8736                	mv	a4,a3
  24:	87b6                	mv	a5,a3
  // Multiplicar matrices N veces
  for (int n = 0; n < CPU_EXPERIMENT_LEN; n++) {
    for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
      for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
        C[i][j] = 0.0f;
        for (int k = 0; k < CPU_MATRIX_SIZE; k++) {
  26:	37fd                	addw	a5,a5,-1
  28:	fffd                	bnez	a5,26 <cpu_ops_cycle+0x26>
      for (int j = 0; j < CPU_MATRIX_SIZE; j++) {
  2a:	377d                	addw	a4,a4,-1
  2c:	ff65                	bnez	a4,24 <cpu_ops_cycle+0x24>
    for (int i = 0; i < CPU_MATRIX_SIZE; i++) {
  2e:	35fd                	addw	a1,a1,-1
  30:	f9ed                	bnez	a1,22 <cpu_ops_cycle+0x22>
  for (int n = 0; n < CPU_EXPERIMENT_LEN; n++) {
  32:	367d                	addw	a2,a2,-1
  34:	f675                	bnez	a2,20 <cpu_ops_cycle+0x20>
      }
    }
  }

  return (kops_matmul * CPU_EXPERIMENT_LEN);
}
  36:	00083537          	lui	a0,0x83
  3a:	10050513          	add	a0,a0,256 # 83100 <base+0x820f0>
  3e:	6422                	ld	s0,8(sp)
  40:	0141                	add	sp,sp,16
  42:	8082                	ret

0000000000000044 <cpubench>:

void cpubench(int N, int pid) {
  44:	7139                	add	sp,sp,-64
  46:	fc06                	sd	ra,56(sp)
  48:	f822                	sd	s0,48(sp)
  4a:	f426                	sd	s1,40(sp)
  4c:	f04a                	sd	s2,32(sp)
  4e:	ec4e                	sd	s3,24(sp)
  50:	e852                	sd	s4,16(sp)
  52:	e456                	sd	s5,8(sp)
  54:	e05a                	sd	s6,0(sp)
  56:	0080                	add	s0,sp,64
  58:	84aa                	mv	s1,a0
  5a:	8aae                	mv	s5,a1
  uint64 start_tick, end_tick, elapsed_ticks, total_cpu_kops, metric;
  int *measurements = malloc(sizeof(int) * N);
  5c:	0025151b          	sllw	a0,a0,0x2
  60:	00000097          	auipc	ra,0x0
  64:	766080e7          	jalr	1894(ra) # 7c6 <malloc>

  // Realizar N ciclos de medicion
  for(int i = 0; i < N; ++i) {
  68:	04905863          	blez	s1,b8 <cpubench+0x74>
  6c:	89aa                	mv	s3,a0
  6e:	048a                	sll	s1,s1,0x2
  70:	00950a33          	add	s4,a0,s1
    end_tick = uptime();
    elapsed_ticks = end_tick - start_tick;

    metric = total_cpu_kops / elapsed_ticks; // primeramente podriamos tomar la cantidad de lectoesctirutas por tick transcurrido
    measurements[i] = metric;
    printf("%d\t[cpubench]\t%d\t%d\t%d\n",
  74:	00001b17          	auipc	s6,0x1
  78:	83cb0b13          	add	s6,s6,-1988 # 8b0 <malloc+0xea>
    start_tick = uptime();
  7c:	00000097          	auipc	ra,0x0
  80:	3c2080e7          	jalr	962(ra) # 43e <uptime>
  84:	892a                	mv	s2,a0
    total_cpu_kops = cpu_ops_cycle();
  86:	00000097          	auipc	ra,0x0
  8a:	f7a080e7          	jalr	-134(ra) # 0 <cpu_ops_cycle>
  8e:	84aa                	mv	s1,a0
    end_tick = uptime();
  90:	00000097          	auipc	ra,0x0
  94:	3ae080e7          	jalr	942(ra) # 43e <uptime>
    elapsed_ticks = end_tick - start_tick;
  98:	41250733          	sub	a4,a0,s2
    metric = total_cpu_kops / elapsed_ticks; // primeramente podriamos tomar la cantidad de lectoesctirutas por tick transcurrido
  9c:	02e4d633          	divu	a2,s1,a4
    measurements[i] = metric;
  a0:	00c9a023          	sw	a2,0(s3)
    printf("%d\t[cpubench]\t%d\t%d\t%d\n",
  a4:	86ca                	mv	a3,s2
  a6:	85d6                	mv	a1,s5
  a8:	855a                	mv	a0,s6
  aa:	00000097          	auipc	ra,0x0
  ae:	664080e7          	jalr	1636(ra) # 70e <printf>
  for(int i = 0; i < N; ++i) {
  b2:	0991                	add	s3,s3,4
  b4:	fd4994e3          	bne	s3,s4,7c <cpubench+0x38>
           pid, metric, start_tick, elapsed_ticks);
  }
}
  b8:	70e2                	ld	ra,56(sp)
  ba:	7442                	ld	s0,48(sp)
  bc:	74a2                	ld	s1,40(sp)
  be:	7902                	ld	s2,32(sp)
  c0:	69e2                	ld	s3,24(sp)
  c2:	6a42                	ld	s4,16(sp)
  c4:	6aa2                	ld	s5,8(sp)
  c6:	6b02                	ld	s6,0(sp)
  c8:	6121                	add	sp,sp,64
  ca:	8082                	ret

00000000000000cc <main>:

int
main(int argc, char *argv[])
{
  cc:	1101                	add	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	1000                	add	s0,sp,32
  int N, pid;
  if (argc != 2) {
  d6:	4789                	li	a5,2
  d8:	00f50f63          	beq	a0,a5,f6 <main+0x2a>
    printf("Uso: benchmark N\n");
  dc:	00000517          	auipc	a0,0x0
  e0:	7ec50513          	add	a0,a0,2028 # 8c8 <malloc+0x102>
  e4:	00000097          	auipc	ra,0x0
  e8:	62a080e7          	jalr	1578(ra) # 70e <printf>
    exit(1);
  ec:	4505                	li	a0,1
  ee:	00000097          	auipc	ra,0x0
  f2:	2b8080e7          	jalr	696(ra) # 3a6 <exit>
  }

  N = atoi(argv[1]);  // Número de repeticiones para los benchmarks
  f6:	6588                	ld	a0,8(a1)
  f8:	00000097          	auipc	ra,0x0
  fc:	1b4080e7          	jalr	436(ra) # 2ac <atoi>
 100:	84aa                	mv	s1,a0
  pid = getpid();
 102:	00000097          	auipc	ra,0x0
 106:	324080e7          	jalr	804(ra) # 426 <getpid>
 10a:	85aa                	mv	a1,a0
  cpubench(N, pid);
 10c:	8526                	mv	a0,s1
 10e:	00000097          	auipc	ra,0x0
 112:	f36080e7          	jalr	-202(ra) # 44 <cpubench>

  exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	28e080e7          	jalr	654(ra) # 3a6 <exit>

0000000000000120 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 120:	1141                	add	sp,sp,-16
 122:	e406                	sd	ra,8(sp)
 124:	e022                	sd	s0,0(sp)
 126:	0800                	add	s0,sp,16
  extern int main();
  main();
 128:	00000097          	auipc	ra,0x0
 12c:	fa4080e7          	jalr	-92(ra) # cc <main>
  exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	274080e7          	jalr	628(ra) # 3a6 <exit>

000000000000013a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 13a:	1141                	add	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 140:	87aa                	mv	a5,a0
 142:	0585                	add	a1,a1,1
 144:	0785                	add	a5,a5,1
 146:	fff5c703          	lbu	a4,-1(a1)
 14a:	fee78fa3          	sb	a4,-1(a5)
 14e:	fb75                	bnez	a4,142 <strcpy+0x8>
    ;
  return os;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	add	sp,sp,16
 154:	8082                	ret

0000000000000156 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 156:	1141                	add	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cb91                	beqz	a5,174 <strcmp+0x1e>
 162:	0005c703          	lbu	a4,0(a1)
 166:	00f71763          	bne	a4,a5,174 <strcmp+0x1e>
    p++, q++;
 16a:	0505                	add	a0,a0,1
 16c:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 16e:	00054783          	lbu	a5,0(a0)
 172:	fbe5                	bnez	a5,162 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 174:	0005c503          	lbu	a0,0(a1)
}
 178:	40a7853b          	subw	a0,a5,a0
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	add	sp,sp,16
 180:	8082                	ret

0000000000000182 <strlen>:

uint
strlen(const char *s)
{
 182:	1141                	add	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cf91                	beqz	a5,1a8 <strlen+0x26>
 18e:	0505                	add	a0,a0,1
 190:	87aa                	mv	a5,a0
 192:	86be                	mv	a3,a5
 194:	0785                	add	a5,a5,1
 196:	fff7c703          	lbu	a4,-1(a5)
 19a:	ff65                	bnez	a4,192 <strlen+0x10>
 19c:	40a6853b          	subw	a0,a3,a0
 1a0:	2505                	addw	a0,a0,1
    ;
  return n;
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	add	sp,sp,16
 1a6:	8082                	ret
  for(n = 0; s[n]; n++)
 1a8:	4501                	li	a0,0
 1aa:	bfe5                	j	1a2 <strlen+0x20>

00000000000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	1141                	add	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b2:	ca19                	beqz	a2,1c8 <memset+0x1c>
 1b4:	87aa                	mv	a5,a0
 1b6:	1602                	sll	a2,a2,0x20
 1b8:	9201                	srl	a2,a2,0x20
 1ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c2:	0785                	add	a5,a5,1
 1c4:	fee79de3          	bne	a5,a4,1be <memset+0x12>
  }
  return dst;
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	add	sp,sp,16
 1cc:	8082                	ret

00000000000001ce <strchr>:

char*
strchr(const char *s, char c)
{
 1ce:	1141                	add	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	add	s0,sp,16
  for(; *s; s++)
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	cb99                	beqz	a5,1ee <strchr+0x20>
    if(*s == c)
 1da:	00f58763          	beq	a1,a5,1e8 <strchr+0x1a>
  for(; *s; s++)
 1de:	0505                	add	a0,a0,1
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	fbfd                	bnez	a5,1da <strchr+0xc>
      return (char*)s;
  return 0;
 1e6:	4501                	li	a0,0
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	add	sp,sp,16
 1ec:	8082                	ret
  return 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strchr+0x1a>

00000000000001f2 <gets>:

char*
gets(char *buf, int max)
{
 1f2:	711d                	add	sp,sp,-96
 1f4:	ec86                	sd	ra,88(sp)
 1f6:	e8a2                	sd	s0,80(sp)
 1f8:	e4a6                	sd	s1,72(sp)
 1fa:	e0ca                	sd	s2,64(sp)
 1fc:	fc4e                	sd	s3,56(sp)
 1fe:	f852                	sd	s4,48(sp)
 200:	f456                	sd	s5,40(sp)
 202:	f05a                	sd	s6,32(sp)
 204:	ec5e                	sd	s7,24(sp)
 206:	1080                	add	s0,sp,96
 208:	8baa                	mv	s7,a0
 20a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20c:	892a                	mv	s2,a0
 20e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 210:	4aa9                	li	s5,10
 212:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 214:	89a6                	mv	s3,s1
 216:	2485                	addw	s1,s1,1
 218:	0344d863          	bge	s1,s4,248 <gets+0x56>
    cc = read(0, &c, 1);
 21c:	4605                	li	a2,1
 21e:	faf40593          	add	a1,s0,-81
 222:	4501                	li	a0,0
 224:	00000097          	auipc	ra,0x0
 228:	19a080e7          	jalr	410(ra) # 3be <read>
    if(cc < 1)
 22c:	00a05e63          	blez	a0,248 <gets+0x56>
    buf[i++] = c;
 230:	faf44783          	lbu	a5,-81(s0)
 234:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 238:	01578763          	beq	a5,s5,246 <gets+0x54>
 23c:	0905                	add	s2,s2,1
 23e:	fd679be3          	bne	a5,s6,214 <gets+0x22>
  for(i=0; i+1 < max; ){
 242:	89a6                	mv	s3,s1
 244:	a011                	j	248 <gets+0x56>
 246:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 248:	99de                	add	s3,s3,s7
 24a:	00098023          	sb	zero,0(s3)
  return buf;
}
 24e:	855e                	mv	a0,s7
 250:	60e6                	ld	ra,88(sp)
 252:	6446                	ld	s0,80(sp)
 254:	64a6                	ld	s1,72(sp)
 256:	6906                	ld	s2,64(sp)
 258:	79e2                	ld	s3,56(sp)
 25a:	7a42                	ld	s4,48(sp)
 25c:	7aa2                	ld	s5,40(sp)
 25e:	7b02                	ld	s6,32(sp)
 260:	6be2                	ld	s7,24(sp)
 262:	6125                	add	sp,sp,96
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	add	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e426                	sd	s1,8(sp)
 26e:	e04a                	sd	s2,0(sp)
 270:	1000                	add	s0,sp,32
 272:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 274:	4581                	li	a1,0
 276:	00000097          	auipc	ra,0x0
 27a:	170080e7          	jalr	368(ra) # 3e6 <open>
  if(fd < 0)
 27e:	02054563          	bltz	a0,2a8 <stat+0x42>
 282:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 284:	85ca                	mv	a1,s2
 286:	00000097          	auipc	ra,0x0
 28a:	178080e7          	jalr	376(ra) # 3fe <fstat>
 28e:	892a                	mv	s2,a0
  close(fd);
 290:	8526                	mv	a0,s1
 292:	00000097          	auipc	ra,0x0
 296:	13c080e7          	jalr	316(ra) # 3ce <close>
  return r;
}
 29a:	854a                	mv	a0,s2
 29c:	60e2                	ld	ra,24(sp)
 29e:	6442                	ld	s0,16(sp)
 2a0:	64a2                	ld	s1,8(sp)
 2a2:	6902                	ld	s2,0(sp)
 2a4:	6105                	add	sp,sp,32
 2a6:	8082                	ret
    return -1;
 2a8:	597d                	li	s2,-1
 2aa:	bfc5                	j	29a <stat+0x34>

00000000000002ac <atoi>:

int
atoi(const char *s)
{
 2ac:	1141                	add	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b2:	00054683          	lbu	a3,0(a0)
 2b6:	fd06879b          	addw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	4625                	li	a2,9
 2c0:	02f66863          	bltu	a2,a5,2f0 <atoi+0x44>
 2c4:	872a                	mv	a4,a0
  n = 0;
 2c6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c8:	0705                	add	a4,a4,1
 2ca:	0025179b          	sllw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	sllw	a5,a5,0x1
 2d4:	9fb5                	addw	a5,a5,a3
 2d6:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	00074683          	lbu	a3,0(a4)
 2de:	fd06879b          	addw	a5,a3,-48
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	fef671e3          	bgeu	a2,a5,2c8 <atoi+0x1c>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	add	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x3e>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	add	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	sll	a2,a2,0x20
 304:	9201                	srl	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	add	a1,a1,1
 30e:	0705                	add	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	add	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addw	a5,a2,-1
 330:	1782                	sll	a5,a5,0x20
 332:	9381                	srl	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	add	a1,a1,-1
 33c:	177d                	add	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	add	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addw	a3,a2,-1
 358:	1682                	sll	a3,a3,0x20
 35a:	9281                	srl	a3,a3,0x20
 35c:	0685                	add	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	add	a0,a0,1
    p2++;
 36e:	0585                	add	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	add	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	add	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	add	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 446:	1101                	add	sp,sp,-32
 448:	ec06                	sd	ra,24(sp)
 44a:	e822                	sd	s0,16(sp)
 44c:	1000                	add	s0,sp,32
 44e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 452:	4605                	li	a2,1
 454:	fef40593          	add	a1,s0,-17
 458:	00000097          	auipc	ra,0x0
 45c:	f6e080e7          	jalr	-146(ra) # 3c6 <write>
}
 460:	60e2                	ld	ra,24(sp)
 462:	6442                	ld	s0,16(sp)
 464:	6105                	add	sp,sp,32
 466:	8082                	ret

0000000000000468 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 468:	7139                	add	sp,sp,-64
 46a:	fc06                	sd	ra,56(sp)
 46c:	f822                	sd	s0,48(sp)
 46e:	f426                	sd	s1,40(sp)
 470:	f04a                	sd	s2,32(sp)
 472:	ec4e                	sd	s3,24(sp)
 474:	0080                	add	s0,sp,64
 476:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 478:	c299                	beqz	a3,47e <printint+0x16>
 47a:	0805c963          	bltz	a1,50c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 47e:	2581                	sext.w	a1,a1
  neg = 0;
 480:	4881                	li	a7,0
 482:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 486:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 488:	2601                	sext.w	a2,a2
 48a:	00000517          	auipc	a0,0x0
 48e:	4b650513          	add	a0,a0,1206 # 940 <digits>
 492:	883a                	mv	a6,a4
 494:	2705                	addw	a4,a4,1
 496:	02c5f7bb          	remuw	a5,a1,a2
 49a:	1782                	sll	a5,a5,0x20
 49c:	9381                	srl	a5,a5,0x20
 49e:	97aa                	add	a5,a5,a0
 4a0:	0007c783          	lbu	a5,0(a5)
 4a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a8:	0005879b          	sext.w	a5,a1
 4ac:	02c5d5bb          	divuw	a1,a1,a2
 4b0:	0685                	add	a3,a3,1
 4b2:	fec7f0e3          	bgeu	a5,a2,492 <printint+0x2a>
  if(neg)
 4b6:	00088c63          	beqz	a7,4ce <printint+0x66>
    buf[i++] = '-';
 4ba:	fd070793          	add	a5,a4,-48
 4be:	00878733          	add	a4,a5,s0
 4c2:	02d00793          	li	a5,45
 4c6:	fef70823          	sb	a5,-16(a4)
 4ca:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4ce:	02e05863          	blez	a4,4fe <printint+0x96>
 4d2:	fc040793          	add	a5,s0,-64
 4d6:	00e78933          	add	s2,a5,a4
 4da:	fff78993          	add	s3,a5,-1
 4de:	99ba                	add	s3,s3,a4
 4e0:	377d                	addw	a4,a4,-1
 4e2:	1702                	sll	a4,a4,0x20
 4e4:	9301                	srl	a4,a4,0x20
 4e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ea:	fff94583          	lbu	a1,-1(s2)
 4ee:	8526                	mv	a0,s1
 4f0:	00000097          	auipc	ra,0x0
 4f4:	f56080e7          	jalr	-170(ra) # 446 <putc>
  while(--i >= 0)
 4f8:	197d                	add	s2,s2,-1
 4fa:	ff3918e3          	bne	s2,s3,4ea <printint+0x82>
}
 4fe:	70e2                	ld	ra,56(sp)
 500:	7442                	ld	s0,48(sp)
 502:	74a2                	ld	s1,40(sp)
 504:	7902                	ld	s2,32(sp)
 506:	69e2                	ld	s3,24(sp)
 508:	6121                	add	sp,sp,64
 50a:	8082                	ret
    x = -xx;
 50c:	40b005bb          	negw	a1,a1
    neg = 1;
 510:	4885                	li	a7,1
    x = -xx;
 512:	bf85                	j	482 <printint+0x1a>

0000000000000514 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 514:	715d                	add	sp,sp,-80
 516:	e486                	sd	ra,72(sp)
 518:	e0a2                	sd	s0,64(sp)
 51a:	fc26                	sd	s1,56(sp)
 51c:	f84a                	sd	s2,48(sp)
 51e:	f44e                	sd	s3,40(sp)
 520:	f052                	sd	s4,32(sp)
 522:	ec56                	sd	s5,24(sp)
 524:	e85a                	sd	s6,16(sp)
 526:	e45e                	sd	s7,8(sp)
 528:	e062                	sd	s8,0(sp)
 52a:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52c:	0005c903          	lbu	s2,0(a1)
 530:	18090c63          	beqz	s2,6c8 <vprintf+0x1b4>
 534:	8aaa                	mv	s5,a0
 536:	8bb2                	mv	s7,a2
 538:	00158493          	add	s1,a1,1
  state = 0;
 53c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53e:	02500a13          	li	s4,37
 542:	4b55                	li	s6,21
 544:	a839                	j	562 <vprintf+0x4e>
        putc(fd, c);
 546:	85ca                	mv	a1,s2
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	efc080e7          	jalr	-260(ra) # 446 <putc>
 552:	a019                	j	558 <vprintf+0x44>
    } else if(state == '%'){
 554:	01498d63          	beq	s3,s4,56e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 558:	0485                	add	s1,s1,1
 55a:	fff4c903          	lbu	s2,-1(s1)
 55e:	16090563          	beqz	s2,6c8 <vprintf+0x1b4>
    if(state == 0){
 562:	fe0999e3          	bnez	s3,554 <vprintf+0x40>
      if(c == '%'){
 566:	ff4910e3          	bne	s2,s4,546 <vprintf+0x32>
        state = '%';
 56a:	89d2                	mv	s3,s4
 56c:	b7f5                	j	558 <vprintf+0x44>
      if(c == 'd'){
 56e:	13490263          	beq	s2,s4,692 <vprintf+0x17e>
 572:	f9d9079b          	addw	a5,s2,-99
 576:	0ff7f793          	zext.b	a5,a5
 57a:	12fb6563          	bltu	s6,a5,6a4 <vprintf+0x190>
 57e:	f9d9079b          	addw	a5,s2,-99
 582:	0ff7f713          	zext.b	a4,a5
 586:	10eb6f63          	bltu	s6,a4,6a4 <vprintf+0x190>
 58a:	00271793          	sll	a5,a4,0x2
 58e:	00000717          	auipc	a4,0x0
 592:	35a70713          	add	a4,a4,858 # 8e8 <malloc+0x122>
 596:	97ba                	add	a5,a5,a4
 598:	439c                	lw	a5,0(a5)
 59a:	97ba                	add	a5,a5,a4
 59c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b8913          	add	s2,s7,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	ebc080e7          	jalr	-324(ra) # 468 <printint>
 5b4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b745                	j	558 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b8913          	add	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ea0080e7          	jalr	-352(ra) # 468 <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b751                	j	558 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b8913          	add	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e84080e7          	jalr	-380(ra) # 468 <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b7a5                	j	558 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b8c13          	add	s8,s7,8
 5f6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fa:	03000593          	li	a1,48
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e46080e7          	jalr	-442(ra) # 446 <putc>
  putc(fd, 'x');
 608:	07800593          	li	a1,120
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e38080e7          	jalr	-456(ra) # 446 <putc>
 616:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	00000b97          	auipc	s7,0x0
 61c:	328b8b93          	add	s7,s7,808 # 940 <digits>
 620:	03c9d793          	srl	a5,s3,0x3c
 624:	97de                	add	a5,a5,s7
 626:	0007c583          	lbu	a1,0(a5)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e1a080e7          	jalr	-486(ra) # 446 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	sll	s3,s3,0x4
 636:	397d                	addw	s2,s2,-1
 638:	fe0914e3          	bnez	s2,620 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 63c:	8be2                	mv	s7,s8
      state = 0;
 63e:	4981                	li	s3,0
 640:	bf21                	j	558 <vprintf+0x44>
        s = va_arg(ap, char*);
 642:	008b8993          	add	s3,s7,8
 646:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64a:	02090163          	beqz	s2,66c <vprintf+0x158>
        while(*s != 0){
 64e:	00094583          	lbu	a1,0(s2)
 652:	c9a5                	beqz	a1,6c2 <vprintf+0x1ae>
          putc(fd, *s);
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	df0080e7          	jalr	-528(ra) # 446 <putc>
          s++;
 65e:	0905                	add	s2,s2,1
        while(*s != 0){
 660:	00094583          	lbu	a1,0(s2)
 664:	f9e5                	bnez	a1,654 <vprintf+0x140>
        s = va_arg(ap, char*);
 666:	8bce                	mv	s7,s3
      state = 0;
 668:	4981                	li	s3,0
 66a:	b5fd                	j	558 <vprintf+0x44>
          s = "(null)";
 66c:	00000917          	auipc	s2,0x0
 670:	27490913          	add	s2,s2,628 # 8e0 <malloc+0x11a>
        while(*s != 0){
 674:	02800593          	li	a1,40
 678:	bff1                	j	654 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 67a:	008b8913          	add	s2,s7,8
 67e:	000bc583          	lbu	a1,0(s7)
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	dc2080e7          	jalr	-574(ra) # 446 <putc>
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	b5e1                	j	558 <vprintf+0x44>
        putc(fd, c);
 692:	02500593          	li	a1,37
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	dae080e7          	jalr	-594(ra) # 446 <putc>
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd5d                	j	558 <vprintf+0x44>
        putc(fd, '%');
 6a4:	02500593          	li	a1,37
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	d9c080e7          	jalr	-612(ra) # 446 <putc>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d90080e7          	jalr	-624(ra) # 446 <putc>
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd61                	j	558 <vprintf+0x44>
        s = va_arg(ap, char*);
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bd49                	j	558 <vprintf+0x44>
    }
  }
}
 6c8:	60a6                	ld	ra,72(sp)
 6ca:	6406                	ld	s0,64(sp)
 6cc:	74e2                	ld	s1,56(sp)
 6ce:	7942                	ld	s2,48(sp)
 6d0:	79a2                	ld	s3,40(sp)
 6d2:	7a02                	ld	s4,32(sp)
 6d4:	6ae2                	ld	s5,24(sp)
 6d6:	6b42                	ld	s6,16(sp)
 6d8:	6ba2                	ld	s7,8(sp)
 6da:	6c02                	ld	s8,0(sp)
 6dc:	6161                	add	sp,sp,80
 6de:	8082                	ret

00000000000006e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e0:	715d                	add	sp,sp,-80
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	add	s0,sp,32
 6e8:	e010                	sd	a2,0(s0)
 6ea:	e414                	sd	a3,8(s0)
 6ec:	e818                	sd	a4,16(s0)
 6ee:	ec1c                	sd	a5,24(s0)
 6f0:	03043023          	sd	a6,32(s0)
 6f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fc:	8622                	mv	a2,s0
 6fe:	00000097          	auipc	ra,0x0
 702:	e16080e7          	jalr	-490(ra) # 514 <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6161                	add	sp,sp,80
 70c:	8082                	ret

000000000000070e <printf>:

void
printf(const char *fmt, ...)
{
 70e:	711d                	add	sp,sp,-96
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	add	s0,sp,32
 716:	e40c                	sd	a1,8(s0)
 718:	e810                	sd	a2,16(s0)
 71a:	ec14                	sd	a3,24(s0)
 71c:	f018                	sd	a4,32(s0)
 71e:	f41c                	sd	a5,40(s0)
 720:	03043823          	sd	a6,48(s0)
 724:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	00840613          	add	a2,s0,8
 72c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 730:	85aa                	mv	a1,a0
 732:	4505                	li	a0,1
 734:	00000097          	auipc	ra,0x0
 738:	de0080e7          	jalr	-544(ra) # 514 <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6125                	add	sp,sp,96
 742:	8082                	ret

0000000000000744 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 744:	1141                	add	sp,sp,-16
 746:	e422                	sd	s0,8(sp)
 748:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74e:	00001797          	auipc	a5,0x1
 752:	8b27b783          	ld	a5,-1870(a5) # 1000 <freep>
 756:	a02d                	j	780 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 758:	4618                	lw	a4,8(a2)
 75a:	9f2d                	addw	a4,a4,a1
 75c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 760:	6398                	ld	a4,0(a5)
 762:	6310                	ld	a2,0(a4)
 764:	a83d                	j	7a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 766:	ff852703          	lw	a4,-8(a0)
 76a:	9f31                	addw	a4,a4,a2
 76c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76e:	ff053683          	ld	a3,-16(a0)
 772:	a091                	j	7b6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 774:	6398                	ld	a4,0(a5)
 776:	00e7e463          	bltu	a5,a4,77e <free+0x3a>
 77a:	00e6ea63          	bltu	a3,a4,78e <free+0x4a>
{
 77e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 780:	fed7fae3          	bgeu	a5,a3,774 <free+0x30>
 784:	6398                	ld	a4,0(a5)
 786:	00e6e463          	bltu	a3,a4,78e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78a:	fee7eae3          	bltu	a5,a4,77e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78e:	ff852583          	lw	a1,-8(a0)
 792:	6390                	ld	a2,0(a5)
 794:	02059813          	sll	a6,a1,0x20
 798:	01c85713          	srl	a4,a6,0x1c
 79c:	9736                	add	a4,a4,a3
 79e:	fae60de3          	beq	a2,a4,758 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a6:	4790                	lw	a2,8(a5)
 7a8:	02061593          	sll	a1,a2,0x20
 7ac:	01c5d713          	srl	a4,a1,0x1c
 7b0:	973e                	add	a4,a4,a5
 7b2:	fae68ae3          	beq	a3,a4,766 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b8:	00001717          	auipc	a4,0x1
 7bc:	84f73423          	sd	a5,-1976(a4) # 1000 <freep>
}
 7c0:	6422                	ld	s0,8(sp)
 7c2:	0141                	add	sp,sp,16
 7c4:	8082                	ret

00000000000007c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c6:	7139                	add	sp,sp,-64
 7c8:	fc06                	sd	ra,56(sp)
 7ca:	f822                	sd	s0,48(sp)
 7cc:	f426                	sd	s1,40(sp)
 7ce:	f04a                	sd	s2,32(sp)
 7d0:	ec4e                	sd	s3,24(sp)
 7d2:	e852                	sd	s4,16(sp)
 7d4:	e456                	sd	s5,8(sp)
 7d6:	e05a                	sd	s6,0(sp)
 7d8:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7da:	02051493          	sll	s1,a0,0x20
 7de:	9081                	srl	s1,s1,0x20
 7e0:	04bd                	add	s1,s1,15
 7e2:	8091                	srl	s1,s1,0x4
 7e4:	0014899b          	addw	s3,s1,1
 7e8:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7ea:	00001517          	auipc	a0,0x1
 7ee:	81653503          	ld	a0,-2026(a0) # 1000 <freep>
 7f2:	c515                	beqz	a0,81e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	02977f63          	bgeu	a4,s1,836 <malloc+0x70>
  if(nu < 4096)
 7fc:	8a4e                	mv	s4,s3
 7fe:	0009871b          	sext.w	a4,s3
 802:	6685                	lui	a3,0x1
 804:	00d77363          	bgeu	a4,a3,80a <malloc+0x44>
 808:	6a05                	lui	s4,0x1
 80a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 812:	00000917          	auipc	s2,0x0
 816:	7ee90913          	add	s2,s2,2030 # 1000 <freep>
  if(p == (char*)-1)
 81a:	5afd                	li	s5,-1
 81c:	a895                	j	890 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 81e:	00000797          	auipc	a5,0x0
 822:	7f278793          	add	a5,a5,2034 # 1010 <base>
 826:	00000717          	auipc	a4,0x0
 82a:	7cf73d23          	sd	a5,2010(a4) # 1000 <freep>
 82e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 830:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 834:	b7e1                	j	7fc <malloc+0x36>
      if(p->s.size == nunits)
 836:	02e48c63          	beq	s1,a4,86e <malloc+0xa8>
        p->s.size -= nunits;
 83a:	4137073b          	subw	a4,a4,s3
 83e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 840:	02071693          	sll	a3,a4,0x20
 844:	01c6d713          	srl	a4,a3,0x1c
 848:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84e:	00000717          	auipc	a4,0x0
 852:	7aa73923          	sd	a0,1970(a4) # 1000 <freep>
      return (void*)(p + 1);
 856:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 85a:	70e2                	ld	ra,56(sp)
 85c:	7442                	ld	s0,48(sp)
 85e:	74a2                	ld	s1,40(sp)
 860:	7902                	ld	s2,32(sp)
 862:	69e2                	ld	s3,24(sp)
 864:	6a42                	ld	s4,16(sp)
 866:	6aa2                	ld	s5,8(sp)
 868:	6b02                	ld	s6,0(sp)
 86a:	6121                	add	sp,sp,64
 86c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 86e:	6398                	ld	a4,0(a5)
 870:	e118                	sd	a4,0(a0)
 872:	bff1                	j	84e <malloc+0x88>
  hp->s.size = nu;
 874:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 878:	0541                	add	a0,a0,16
 87a:	00000097          	auipc	ra,0x0
 87e:	eca080e7          	jalr	-310(ra) # 744 <free>
  return freep;
 882:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 886:	d971                	beqz	a0,85a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 888:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88a:	4798                	lw	a4,8(a5)
 88c:	fa9775e3          	bgeu	a4,s1,836 <malloc+0x70>
    if(p == freep)
 890:	00093703          	ld	a4,0(s2)
 894:	853e                	mv	a0,a5
 896:	fef719e3          	bne	a4,a5,888 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 89a:	8552                	mv	a0,s4
 89c:	00000097          	auipc	ra,0x0
 8a0:	b92080e7          	jalr	-1134(ra) # 42e <sbrk>
  if(p == (char*)-1)
 8a4:	fd5518e3          	bne	a0,s5,874 <malloc+0xae>
        return 0;
 8a8:	4501                	li	a0,0
 8aa:	bf45                	j	85a <malloc+0x94>
