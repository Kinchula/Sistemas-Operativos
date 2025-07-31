
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	98013103          	ld	sp,-1664(sp) # 80008980 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	99070713          	add	a4,a4,-1648 # 800089e0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	b9e78793          	add	a5,a5,-1122 # 80005c00 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb9af>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	38a080e7          	jalr	906(ra) # 800024b4 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	99c50513          	add	a0,a0,-1636 # 80010b20 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	98c48493          	add	s1,s1,-1652 # 80010b20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	a1c90913          	add	s2,s2,-1508 # 80010bb8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7fa080e7          	jalr	2042(ra) # 800019ae <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	142080e7          	jalr	322(ra) # 800022fe <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	e8c080e7          	jalr	-372(ra) # 80002056 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	94270713          	add	a4,a4,-1726 # 80010b20 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	24e080e7          	jalr	590(ra) # 8000245e <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	8f850513          	add	a0,a0,-1800 # 80010b20 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	8e250513          	add	a0,a0,-1822 # 80010b20 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	94f72523          	sw	a5,-1718(a4) # 80010bb8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	85850513          	add	a0,a0,-1960 # 80010b20 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	21c080e7          	jalr	540(ra) # 8000250a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	82a50513          	add	a0,a0,-2006 # 80010b20 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	80670713          	add	a4,a4,-2042 # 80010b20 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	7dc78793          	add	a5,a5,2012 # 80010b20 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	8467a783          	lw	a5,-1978(a5) # 80010bb8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	79a70713          	add	a4,a4,1946 # 80010b20 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	78a48493          	add	s1,s1,1930 # 80010b20 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	74e70713          	add	a4,a4,1870 # 80010b20 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	7cf72c23          	sw	a5,2008(a4) # 80010bc0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	71278793          	add	a5,a5,1810 # 80010b20 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	78c7a523          	sw	a2,1930(a5) # 80010bbc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	77e50513          	add	a0,a0,1918 # 80010bb8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c78080e7          	jalr	-904(ra) # 800020ba <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	6c450513          	add	a0,a0,1732 # 80010b20 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	84478793          	add	a5,a5,-1980 # 80020cb8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	6807ac23          	sw	zero,1688(a5) # 80010be0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	add	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	42f72223          	sw	a5,1060(a4) # 800089a0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	628dad83          	lw	s11,1576(s11) # 80010be0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	5d250513          	add	a0,a0,1490 # 80010bc8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	47450513          	add	a0,a0,1140 # 80010bc8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	45848493          	add	s1,s1,1112 # 80010bc8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	41850513          	add	a0,a0,1048 # 80010be8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	1a47a783          	lw	a5,420(a5) # 800089a0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	1747b783          	ld	a5,372(a5) # 800089a8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	17473703          	ld	a4,372(a4) # 800089b0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	38aa0a13          	add	s4,s4,906 # 80010be8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	14248493          	add	s1,s1,322 # 800089a8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	14298993          	add	s3,s3,322 # 800089b0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	82a080e7          	jalr	-2006(ra) # 800020ba <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	31c50513          	add	a0,a0,796 # 80010be8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0c47a783          	lw	a5,196(a5) # 800089a0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	0ca73703          	ld	a4,202(a4) # 800089b0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	0ba7b783          	ld	a5,186(a5) # 800089a8 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	2ee98993          	add	s3,s3,750 # 80010be8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	0a648493          	add	s1,s1,166 # 800089a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	0a690913          	add	s2,s2,166 # 800089b0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	73c080e7          	jalr	1852(ra) # 80002056 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	2b848493          	add	s1,s1,696 # 80010be8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	06e7b623          	sd	a4,108(a5) # 800089b0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	23248493          	add	s1,s1,562 # 80010be8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	45878793          	add	a5,a5,1112 # 80022e50 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	20890913          	add	s2,s2,520 # 80010c20 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	16a50513          	add	a0,a0,362 # 80010c20 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	38650513          	add	a0,a0,902 # 80022e50 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	13448493          	add	s1,s1,308 # 80010c20 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	11c50513          	add	a0,a0,284 # 80010c20 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	0f050513          	add	a0,a0,240 # 80010c20 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e26080e7          	jalr	-474(ra) # 80001992 <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	df4080e7          	jalr	-524(ra) # 80001992 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de8080e7          	jalr	-536(ra) # 80001992 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dd0080e7          	jalr	-560(ra) # 80001992 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d90080e7          	jalr	-624(ra) # 80001992 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d64080e7          	jalr	-668(ra) # 80001992 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc1b1>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b08080e7          	jalr	-1272(ra) # 80001982 <cpuid>
    userinit();      // first user process
    semaphores_init(); // semaphores
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	b3670713          	add	a4,a4,-1226 # 800089b8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	aec080e7          	jalr	-1300(ra) # 80001982 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e0080e7          	jalr	224(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	794080e7          	jalr	1940(ra) # 8000264c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	d80080e7          	jalr	-640(ra) # 80005c40 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fdc080e7          	jalr	-36(ra) # 80001ea4 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	add	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	add	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	32e080e7          	jalr	814(ra) # 80001246 <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	070080e7          	jalr	112(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9a6080e7          	jalr	-1626(ra) # 800018ce <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	6f4080e7          	jalr	1780(ra) # 80002624 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	714080e7          	jalr	1812(ra) # 8000264c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	cea080e7          	jalr	-790(ra) # 80005c2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	cf8080e7          	jalr	-776(ra) # 80005c40 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	ef6080e7          	jalr	-266(ra) # 80002e46 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	594080e7          	jalr	1428(ra) # 800034ec <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	50a080e7          	jalr	1290(ra) # 8000446a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	de0080e7          	jalr	-544(ra) # 80005d48 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d16080e7          	jalr	-746(ra) # 80001c86 <userinit>
    semaphores_init(); // semaphores
    80000f78:	00005097          	auipc	ra,0x5
    80000f7c:	29e080e7          	jalr	670(ra) # 80006216 <semaphores_init>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	a2f72923          	sw	a5,-1486(a4) # 800089b8 <started>
    80000f8e:	bf2d                	j	80000ec8 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	add	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f96:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f9a:	00008797          	auipc	a5,0x8
    80000f9e:	a267b783          	ld	a5,-1498(a5) # 800089c0 <kernel_pagetable>
    80000fa2:	83b1                	srl	a5,a5,0xc
    80000fa4:	577d                	li	a4,-1
    80000fa6:	177e                	sll	a4,a4,0x3f
    80000fa8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000faa:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fae:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb2:	6422                	ld	s0,8(sp)
    80000fb4:	0141                	add	sp,sp,16
    80000fb6:	8082                	ret

0000000080000fb8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb8:	7139                	add	sp,sp,-64
    80000fba:	fc06                	sd	ra,56(sp)
    80000fbc:	f822                	sd	s0,48(sp)
    80000fbe:	f426                	sd	s1,40(sp)
    80000fc0:	f04a                	sd	s2,32(sp)
    80000fc2:	ec4e                	sd	s3,24(sp)
    80000fc4:	e852                	sd	s4,16(sp)
    80000fc6:	e456                	sd	s5,8(sp)
    80000fc8:	e05a                	sd	s6,0(sp)
    80000fca:	0080                	add	s0,sp,64
    80000fcc:	84aa                	mv	s1,a0
    80000fce:	89ae                	mv	s3,a1
    80000fd0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd2:	57fd                	li	a5,-1
    80000fd4:	83e9                	srl	a5,a5,0x1a
    80000fd6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fda:	04b7f263          	bgeu	a5,a1,8000101e <walk+0x66>
    panic("walk");
    80000fde:	00007517          	auipc	a0,0x7
    80000fe2:	0f250513          	add	a0,a0,242 # 800080d0 <digits+0x90>
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	556080e7          	jalr	1366(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fee:	060a8663          	beqz	s5,8000105a <walk+0xa2>
    80000ff2:	00000097          	auipc	ra,0x0
    80000ff6:	af0080e7          	jalr	-1296(ra) # 80000ae2 <kalloc>
    80000ffa:	84aa                	mv	s1,a0
    80000ffc:	c529                	beqz	a0,80001046 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffe:	6605                	lui	a2,0x1
    80001000:	4581                	li	a1,0
    80001002:	00000097          	auipc	ra,0x0
    80001006:	ccc080e7          	jalr	-820(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000100a:	00c4d793          	srl	a5,s1,0xc
    8000100e:	07aa                	sll	a5,a5,0xa
    80001010:	0017e793          	or	a5,a5,1
    80001014:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001018:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc1a7>
    8000101a:	036a0063          	beq	s4,s6,8000103a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101e:	0149d933          	srl	s2,s3,s4
    80001022:	1ff97913          	and	s2,s2,511
    80001026:	090e                	sll	s2,s2,0x3
    80001028:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000102a:	00093483          	ld	s1,0(s2)
    8000102e:	0014f793          	and	a5,s1,1
    80001032:	dfd5                	beqz	a5,80000fee <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001034:	80a9                	srl	s1,s1,0xa
    80001036:	04b2                	sll	s1,s1,0xc
    80001038:	b7c5                	j	80001018 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000103a:	00c9d513          	srl	a0,s3,0xc
    8000103e:	1ff57513          	and	a0,a0,511
    80001042:	050e                	sll	a0,a0,0x3
    80001044:	9526                	add	a0,a0,s1
}
    80001046:	70e2                	ld	ra,56(sp)
    80001048:	7442                	ld	s0,48(sp)
    8000104a:	74a2                	ld	s1,40(sp)
    8000104c:	7902                	ld	s2,32(sp)
    8000104e:	69e2                	ld	s3,24(sp)
    80001050:	6a42                	ld	s4,16(sp)
    80001052:	6aa2                	ld	s5,8(sp)
    80001054:	6b02                	ld	s6,0(sp)
    80001056:	6121                	add	sp,sp,64
    80001058:	8082                	ret
        return 0;
    8000105a:	4501                	li	a0,0
    8000105c:	b7ed                	j	80001046 <walk+0x8e>

000000008000105e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srl	a5,a5,0x1a
    80001062:	00b7f463          	bgeu	a5,a1,8000106a <walkaddr+0xc>
    return 0;
    80001066:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001068:	8082                	ret
{
    8000106a:	1141                	add	sp,sp,-16
    8000106c:	e406                	sd	ra,8(sp)
    8000106e:	e022                	sd	s0,0(sp)
    80001070:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001072:	4601                	li	a2,0
    80001074:	00000097          	auipc	ra,0x0
    80001078:	f44080e7          	jalr	-188(ra) # 80000fb8 <walk>
  if(pte == 0)
    8000107c:	c105                	beqz	a0,8000109c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001080:	0117f693          	and	a3,a5,17
    80001084:	4745                	li	a4,17
    return 0;
    80001086:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001088:	00e68663          	beq	a3,a4,80001094 <walkaddr+0x36>
}
    8000108c:	60a2                	ld	ra,8(sp)
    8000108e:	6402                	ld	s0,0(sp)
    80001090:	0141                	add	sp,sp,16
    80001092:	8082                	ret
  pa = PTE2PA(*pte);
    80001094:	83a9                	srl	a5,a5,0xa
    80001096:	00c79513          	sll	a0,a5,0xc
  return pa;
    8000109a:	bfcd                	j	8000108c <walkaddr+0x2e>
    return 0;
    8000109c:	4501                	li	a0,0
    8000109e:	b7fd                	j	8000108c <walkaddr+0x2e>

00000000800010a0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a0:	715d                	add	sp,sp,-80
    800010a2:	e486                	sd	ra,72(sp)
    800010a4:	e0a2                	sd	s0,64(sp)
    800010a6:	fc26                	sd	s1,56(sp)
    800010a8:	f84a                	sd	s2,48(sp)
    800010aa:	f44e                	sd	s3,40(sp)
    800010ac:	f052                	sd	s4,32(sp)
    800010ae:	ec56                	sd	s5,24(sp)
    800010b0:	e85a                	sd	s6,16(sp)
    800010b2:	e45e                	sd	s7,8(sp)
    800010b4:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b6:	c639                	beqz	a2,80001104 <mappages+0x64>
    800010b8:	8aaa                	mv	s5,a0
    800010ba:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010bc:	777d                	lui	a4,0xfffff
    800010be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c2:	fff58993          	add	s3,a1,-1
    800010c6:	99b2                	add	s3,s3,a2
    800010c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010cc:	893e                	mv	s2,a5
    800010ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    800010d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4605                	li	a2,1
    800010da:	85ca                	mv	a1,s2
    800010dc:	8556                	mv	a0,s5
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	eda080e7          	jalr	-294(ra) # 80000fb8 <walk>
    800010e6:	cd1d                	beqz	a0,80001124 <mappages+0x84>
    if(*pte & PTE_V)
    800010e8:	611c                	ld	a5,0(a0)
    800010ea:	8b85                	and	a5,a5,1
    800010ec:	e785                	bnez	a5,80001114 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ee:	80b1                	srl	s1,s1,0xc
    800010f0:	04aa                	sll	s1,s1,0xa
    800010f2:	0164e4b3          	or	s1,s1,s6
    800010f6:	0014e493          	or	s1,s1,1
    800010fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fc:	05390063          	beq	s2,s3,8000113c <mappages+0x9c>
    a += PGSIZE;
    80001100:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfc9                	j	800010d4 <mappages+0x34>
    panic("mappages: size");
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fd450513          	add	a0,a0,-44 # 800080d8 <digits+0x98>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	430080e7          	jalr	1072(ra) # 8000053c <panic>
      panic("mappages: remap");
    80001114:	00007517          	auipc	a0,0x7
    80001118:	fd450513          	add	a0,a0,-44 # 800080e8 <digits+0xa8>
    8000111c:	fffff097          	auipc	ra,0xfffff
    80001120:	420080e7          	jalr	1056(ra) # 8000053c <panic>
      return -1;
    80001124:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001126:	60a6                	ld	ra,72(sp)
    80001128:	6406                	ld	s0,64(sp)
    8000112a:	74e2                	ld	s1,56(sp)
    8000112c:	7942                	ld	s2,48(sp)
    8000112e:	79a2                	ld	s3,40(sp)
    80001130:	7a02                	ld	s4,32(sp)
    80001132:	6ae2                	ld	s5,24(sp)
    80001134:	6b42                	ld	s6,16(sp)
    80001136:	6ba2                	ld	s7,8(sp)
    80001138:	6161                	add	sp,sp,80
    8000113a:	8082                	ret
  return 0;
    8000113c:	4501                	li	a0,0
    8000113e:	b7e5                	j	80001126 <mappages+0x86>

0000000080001140 <kvmmap>:
{
    80001140:	1141                	add	sp,sp,-16
    80001142:	e406                	sd	ra,8(sp)
    80001144:	e022                	sd	s0,0(sp)
    80001146:	0800                	add	s0,sp,16
    80001148:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114a:	86b2                	mv	a3,a2
    8000114c:	863e                	mv	a2,a5
    8000114e:	00000097          	auipc	ra,0x0
    80001152:	f52080e7          	jalr	-174(ra) # 800010a0 <mappages>
    80001156:	e509                	bnez	a0,80001160 <kvmmap+0x20>
}
    80001158:	60a2                	ld	ra,8(sp)
    8000115a:	6402                	ld	s0,0(sp)
    8000115c:	0141                	add	sp,sp,16
    8000115e:	8082                	ret
    panic("kvmmap");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	f9850513          	add	a0,a0,-104 # 800080f8 <digits+0xb8>
    80001168:	fffff097          	auipc	ra,0xfffff
    8000116c:	3d4080e7          	jalr	980(ra) # 8000053c <panic>

0000000080001170 <kvmmake>:
{
    80001170:	1101                	add	sp,sp,-32
    80001172:	ec06                	sd	ra,24(sp)
    80001174:	e822                	sd	s0,16(sp)
    80001176:	e426                	sd	s1,8(sp)
    80001178:	e04a                	sd	s2,0(sp)
    8000117a:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	966080e7          	jalr	-1690(ra) # 80000ae2 <kalloc>
    80001184:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001186:	6605                	lui	a2,0x1
    80001188:	4581                	li	a1,0
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	b44080e7          	jalr	-1212(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001192:	4719                	li	a4,6
    80001194:	6685                	lui	a3,0x1
    80001196:	10000637          	lui	a2,0x10000
    8000119a:	100005b7          	lui	a1,0x10000
    8000119e:	8526                	mv	a0,s1
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	fa0080e7          	jalr	-96(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	100015b7          	lui	a1,0x10001
    800011b4:	8526                	mv	a0,s1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	f8a080e7          	jalr	-118(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011be:	4719                	li	a4,6
    800011c0:	004006b7          	lui	a3,0x400
    800011c4:	0c000637          	lui	a2,0xc000
    800011c8:	0c0005b7          	lui	a1,0xc000
    800011cc:	8526                	mv	a0,s1
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f72080e7          	jalr	-142(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d6:	00007917          	auipc	s2,0x7
    800011da:	e2a90913          	add	s2,s2,-470 # 80008000 <etext>
    800011de:	4729                	li	a4,10
    800011e0:	80007697          	auipc	a3,0x80007
    800011e4:	e2068693          	add	a3,a3,-480 # 8000 <_entry-0x7fff8000>
    800011e8:	4605                	li	a2,1
    800011ea:	067e                	sll	a2,a2,0x1f
    800011ec:	85b2                	mv	a1,a2
    800011ee:	8526                	mv	a0,s1
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f50080e7          	jalr	-176(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f8:	4719                	li	a4,6
    800011fa:	46c5                	li	a3,17
    800011fc:	06ee                	sll	a3,a3,0x1b
    800011fe:	412686b3          	sub	a3,a3,s2
    80001202:	864a                	mv	a2,s2
    80001204:	85ca                	mv	a1,s2
    80001206:	8526                	mv	a0,s1
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f38080e7          	jalr	-200(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001210:	4729                	li	a4,10
    80001212:	6685                	lui	a3,0x1
    80001214:	00006617          	auipc	a2,0x6
    80001218:	dec60613          	add	a2,a2,-532 # 80007000 <_trampoline>
    8000121c:	040005b7          	lui	a1,0x4000
    80001220:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001222:	05b2                	sll	a1,a1,0xc
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f1a080e7          	jalr	-230(ra) # 80001140 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122e:	8526                	mv	a0,s1
    80001230:	00000097          	auipc	ra,0x0
    80001234:	608080e7          	jalr	1544(ra) # 80001838 <proc_mapstacks>
}
    80001238:	8526                	mv	a0,s1
    8000123a:	60e2                	ld	ra,24(sp)
    8000123c:	6442                	ld	s0,16(sp)
    8000123e:	64a2                	ld	s1,8(sp)
    80001240:	6902                	ld	s2,0(sp)
    80001242:	6105                	add	sp,sp,32
    80001244:	8082                	ret

0000000080001246 <kvminit>:
{
    80001246:	1141                	add	sp,sp,-16
    80001248:	e406                	sd	ra,8(sp)
    8000124a:	e022                	sd	s0,0(sp)
    8000124c:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	f22080e7          	jalr	-222(ra) # 80001170 <kvmmake>
    80001256:	00007797          	auipc	a5,0x7
    8000125a:	76a7b523          	sd	a0,1898(a5) # 800089c0 <kernel_pagetable>
}
    8000125e:	60a2                	ld	ra,8(sp)
    80001260:	6402                	ld	s0,0(sp)
    80001262:	0141                	add	sp,sp,16
    80001264:	8082                	ret

0000000080001266 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001266:	715d                	add	sp,sp,-80
    80001268:	e486                	sd	ra,72(sp)
    8000126a:	e0a2                	sd	s0,64(sp)
    8000126c:	fc26                	sd	s1,56(sp)
    8000126e:	f84a                	sd	s2,48(sp)
    80001270:	f44e                	sd	s3,40(sp)
    80001272:	f052                	sd	s4,32(sp)
    80001274:	ec56                	sd	s5,24(sp)
    80001276:	e85a                	sd	s6,16(sp)
    80001278:	e45e                	sd	s7,8(sp)
    8000127a:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127c:	03459793          	sll	a5,a1,0x34
    80001280:	e795                	bnez	a5,800012ac <uvmunmap+0x46>
    80001282:	8a2a                	mv	s4,a0
    80001284:	892e                	mv	s2,a1
    80001286:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	0632                	sll	a2,a2,0xc
    8000128a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	6b05                	lui	s6,0x1
    80001292:	0735e263          	bltu	a1,s3,800012f6 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001296:	60a6                	ld	ra,72(sp)
    80001298:	6406                	ld	s0,64(sp)
    8000129a:	74e2                	ld	s1,56(sp)
    8000129c:	7942                	ld	s2,48(sp)
    8000129e:	79a2                	ld	s3,40(sp)
    800012a0:	7a02                	ld	s4,32(sp)
    800012a2:	6ae2                	ld	s5,24(sp)
    800012a4:	6b42                	ld	s6,16(sp)
    800012a6:	6ba2                	ld	s7,8(sp)
    800012a8:	6161                	add	sp,sp,80
    800012aa:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e5450513          	add	a0,a0,-428 # 80008100 <digits+0xc0>
    800012b4:	fffff097          	auipc	ra,0xfffff
    800012b8:	288080e7          	jalr	648(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e5c50513          	add	a0,a0,-420 # 80008118 <digits+0xd8>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	278080e7          	jalr	632(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e5c50513          	add	a0,a0,-420 # 80008128 <digits+0xe8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	268080e7          	jalr	616(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e6450513          	add	a0,a0,-412 # 80008140 <digits+0x100>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	258080e7          	jalr	600(ra) # 8000053c <panic>
    *pte = 0;
    800012ec:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f0:	995a                	add	s2,s2,s6
    800012f2:	fb3972e3          	bgeu	s2,s3,80001296 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f6:	4601                	li	a2,0
    800012f8:	85ca                	mv	a1,s2
    800012fa:	8552                	mv	a0,s4
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	cbc080e7          	jalr	-836(ra) # 80000fb8 <walk>
    80001304:	84aa                	mv	s1,a0
    80001306:	d95d                	beqz	a0,800012bc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001308:	6108                	ld	a0,0(a0)
    8000130a:	00157793          	and	a5,a0,1
    8000130e:	dfdd                	beqz	a5,800012cc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001310:	3ff57793          	and	a5,a0,1023
    80001314:	fd7784e3          	beq	a5,s7,800012dc <uvmunmap+0x76>
    if(do_free){
    80001318:	fc0a8ae3          	beqz	s5,800012ec <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131c:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    8000131e:	0532                	sll	a0,a0,0xc
    80001320:	fffff097          	auipc	ra,0xfffff
    80001324:	6c4080e7          	jalr	1732(ra) # 800009e4 <kfree>
    80001328:	b7d1                	j	800012ec <uvmunmap+0x86>

000000008000132a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000132a:	1101                	add	sp,sp,-32
    8000132c:	ec06                	sd	ra,24(sp)
    8000132e:	e822                	sd	s0,16(sp)
    80001330:	e426                	sd	s1,8(sp)
    80001332:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	7ae080e7          	jalr	1966(ra) # 80000ae2 <kalloc>
    8000133c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133e:	c519                	beqz	a0,8000134c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001340:	6605                	lui	a2,0x1
    80001342:	4581                	li	a1,0
    80001344:	00000097          	auipc	ra,0x0
    80001348:	98a080e7          	jalr	-1654(ra) # 80000cce <memset>
  return pagetable;
}
    8000134c:	8526                	mv	a0,s1
    8000134e:	60e2                	ld	ra,24(sp)
    80001350:	6442                	ld	s0,16(sp)
    80001352:	64a2                	ld	s1,8(sp)
    80001354:	6105                	add	sp,sp,32
    80001356:	8082                	ret

0000000080001358 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001358:	7179                	add	sp,sp,-48
    8000135a:	f406                	sd	ra,40(sp)
    8000135c:	f022                	sd	s0,32(sp)
    8000135e:	ec26                	sd	s1,24(sp)
    80001360:	e84a                	sd	s2,16(sp)
    80001362:	e44e                	sd	s3,8(sp)
    80001364:	e052                	sd	s4,0(sp)
    80001366:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001368:	6785                	lui	a5,0x1
    8000136a:	04f67863          	bgeu	a2,a5,800013ba <uvmfirst+0x62>
    8000136e:	8a2a                	mv	s4,a0
    80001370:	89ae                	mv	s3,a1
    80001372:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001374:	fffff097          	auipc	ra,0xfffff
    80001378:	76e080e7          	jalr	1902(ra) # 80000ae2 <kalloc>
    8000137c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137e:	6605                	lui	a2,0x1
    80001380:	4581                	li	a1,0
    80001382:	00000097          	auipc	ra,0x0
    80001386:	94c080e7          	jalr	-1716(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000138a:	4779                	li	a4,30
    8000138c:	86ca                	mv	a3,s2
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	8552                	mv	a0,s4
    80001394:	00000097          	auipc	ra,0x0
    80001398:	d0c080e7          	jalr	-756(ra) # 800010a0 <mappages>
  memmove(mem, src, sz);
    8000139c:	8626                	mv	a2,s1
    8000139e:	85ce                	mv	a1,s3
    800013a0:	854a                	mv	a0,s2
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	988080e7          	jalr	-1656(ra) # 80000d2a <memmove>
}
    800013aa:	70a2                	ld	ra,40(sp)
    800013ac:	7402                	ld	s0,32(sp)
    800013ae:	64e2                	ld	s1,24(sp)
    800013b0:	6942                	ld	s2,16(sp)
    800013b2:	69a2                	ld	s3,8(sp)
    800013b4:	6a02                	ld	s4,0(sp)
    800013b6:	6145                	add	sp,sp,48
    800013b8:	8082                	ret
    panic("uvmfirst: more than a page");
    800013ba:	00007517          	auipc	a0,0x7
    800013be:	d9e50513          	add	a0,a0,-610 # 80008158 <digits+0x118>
    800013c2:	fffff097          	auipc	ra,0xfffff
    800013c6:	17a080e7          	jalr	378(ra) # 8000053c <panic>

00000000800013ca <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013ca:	1101                	add	sp,sp,-32
    800013cc:	ec06                	sd	ra,24(sp)
    800013ce:	e822                	sd	s0,16(sp)
    800013d0:	e426                	sd	s1,8(sp)
    800013d2:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d6:	00b67d63          	bgeu	a2,a1,800013f0 <uvmdealloc+0x26>
    800013da:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013dc:	6785                	lui	a5,0x1
    800013de:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e0:	00f60733          	add	a4,a2,a5
    800013e4:	76fd                	lui	a3,0xfffff
    800013e6:	8f75                	and	a4,a4,a3
    800013e8:	97ae                	add	a5,a5,a1
    800013ea:	8ff5                	and	a5,a5,a3
    800013ec:	00f76863          	bltu	a4,a5,800013fc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f0:	8526                	mv	a0,s1
    800013f2:	60e2                	ld	ra,24(sp)
    800013f4:	6442                	ld	s0,16(sp)
    800013f6:	64a2                	ld	s1,8(sp)
    800013f8:	6105                	add	sp,sp,32
    800013fa:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fc:	8f99                	sub	a5,a5,a4
    800013fe:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001400:	4685                	li	a3,1
    80001402:	0007861b          	sext.w	a2,a5
    80001406:	85ba                	mv	a1,a4
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	e5e080e7          	jalr	-418(ra) # 80001266 <uvmunmap>
    80001410:	b7c5                	j	800013f0 <uvmdealloc+0x26>

0000000080001412 <uvmalloc>:
  if(newsz < oldsz)
    80001412:	0ab66563          	bltu	a2,a1,800014bc <uvmalloc+0xaa>
{
    80001416:	7139                	add	sp,sp,-64
    80001418:	fc06                	sd	ra,56(sp)
    8000141a:	f822                	sd	s0,48(sp)
    8000141c:	f426                	sd	s1,40(sp)
    8000141e:	f04a                	sd	s2,32(sp)
    80001420:	ec4e                	sd	s3,24(sp)
    80001422:	e852                	sd	s4,16(sp)
    80001424:	e456                	sd	s5,8(sp)
    80001426:	e05a                	sd	s6,0(sp)
    80001428:	0080                	add	s0,sp,64
    8000142a:	8aaa                	mv	s5,a0
    8000142c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142e:	6785                	lui	a5,0x1
    80001430:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001432:	95be                	add	a1,a1,a5
    80001434:	77fd                	lui	a5,0xfffff
    80001436:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000143a:	08c9f363          	bgeu	s3,a2,800014c0 <uvmalloc+0xae>
    8000143e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001440:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    80001444:	fffff097          	auipc	ra,0xfffff
    80001448:	69e080e7          	jalr	1694(ra) # 80000ae2 <kalloc>
    8000144c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144e:	c51d                	beqz	a0,8000147c <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001450:	6605                	lui	a2,0x1
    80001452:	4581                	li	a1,0
    80001454:	00000097          	auipc	ra,0x0
    80001458:	87a080e7          	jalr	-1926(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145c:	875a                	mv	a4,s6
    8000145e:	86a6                	mv	a3,s1
    80001460:	6605                	lui	a2,0x1
    80001462:	85ca                	mv	a1,s2
    80001464:	8556                	mv	a0,s5
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	c3a080e7          	jalr	-966(ra) # 800010a0 <mappages>
    8000146e:	e90d                	bnez	a0,800014a0 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001470:	6785                	lui	a5,0x1
    80001472:	993e                	add	s2,s2,a5
    80001474:	fd4968e3          	bltu	s2,s4,80001444 <uvmalloc+0x32>
  return newsz;
    80001478:	8552                	mv	a0,s4
    8000147a:	a809                	j	8000148c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147c:	864e                	mv	a2,s3
    8000147e:	85ca                	mv	a1,s2
    80001480:	8556                	mv	a0,s5
    80001482:	00000097          	auipc	ra,0x0
    80001486:	f48080e7          	jalr	-184(ra) # 800013ca <uvmdealloc>
      return 0;
    8000148a:	4501                	li	a0,0
}
    8000148c:	70e2                	ld	ra,56(sp)
    8000148e:	7442                	ld	s0,48(sp)
    80001490:	74a2                	ld	s1,40(sp)
    80001492:	7902                	ld	s2,32(sp)
    80001494:	69e2                	ld	s3,24(sp)
    80001496:	6a42                	ld	s4,16(sp)
    80001498:	6aa2                	ld	s5,8(sp)
    8000149a:	6b02                	ld	s6,0(sp)
    8000149c:	6121                	add	sp,sp,64
    8000149e:	8082                	ret
      kfree(mem);
    800014a0:	8526                	mv	a0,s1
    800014a2:	fffff097          	auipc	ra,0xfffff
    800014a6:	542080e7          	jalr	1346(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014aa:	864e                	mv	a2,s3
    800014ac:	85ca                	mv	a1,s2
    800014ae:	8556                	mv	a0,s5
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	f1a080e7          	jalr	-230(ra) # 800013ca <uvmdealloc>
      return 0;
    800014b8:	4501                	li	a0,0
    800014ba:	bfc9                	j	8000148c <uvmalloc+0x7a>
    return oldsz;
    800014bc:	852e                	mv	a0,a1
}
    800014be:	8082                	ret
  return newsz;
    800014c0:	8532                	mv	a0,a2
    800014c2:	b7e9                	j	8000148c <uvmalloc+0x7a>

00000000800014c4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c4:	7179                	add	sp,sp,-48
    800014c6:	f406                	sd	ra,40(sp)
    800014c8:	f022                	sd	s0,32(sp)
    800014ca:	ec26                	sd	s1,24(sp)
    800014cc:	e84a                	sd	s2,16(sp)
    800014ce:	e44e                	sd	s3,8(sp)
    800014d0:	e052                	sd	s4,0(sp)
    800014d2:	1800                	add	s0,sp,48
    800014d4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d6:	84aa                	mv	s1,a0
    800014d8:	6905                	lui	s2,0x1
    800014da:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014dc:	4985                	li	s3,1
    800014de:	a829                	j	800014f8 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e0:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e2:	00c79513          	sll	a0,a5,0xc
    800014e6:	00000097          	auipc	ra,0x0
    800014ea:	fde080e7          	jalr	-34(ra) # 800014c4 <freewalk>
      pagetable[i] = 0;
    800014ee:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f2:	04a1                	add	s1,s1,8
    800014f4:	03248163          	beq	s1,s2,80001516 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fa:	00f7f713          	and	a4,a5,15
    800014fe:	ff3701e3          	beq	a4,s3,800014e0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001502:	8b85                	and	a5,a5,1
    80001504:	d7fd                	beqz	a5,800014f2 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001506:	00007517          	auipc	a0,0x7
    8000150a:	c7250513          	add	a0,a0,-910 # 80008178 <digits+0x138>
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	02e080e7          	jalr	46(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001516:	8552                	mv	a0,s4
    80001518:	fffff097          	auipc	ra,0xfffff
    8000151c:	4cc080e7          	jalr	1228(ra) # 800009e4 <kfree>
}
    80001520:	70a2                	ld	ra,40(sp)
    80001522:	7402                	ld	s0,32(sp)
    80001524:	64e2                	ld	s1,24(sp)
    80001526:	6942                	ld	s2,16(sp)
    80001528:	69a2                	ld	s3,8(sp)
    8000152a:	6a02                	ld	s4,0(sp)
    8000152c:	6145                	add	sp,sp,48
    8000152e:	8082                	ret

0000000080001530 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001530:	1101                	add	sp,sp,-32
    80001532:	ec06                	sd	ra,24(sp)
    80001534:	e822                	sd	s0,16(sp)
    80001536:	e426                	sd	s1,8(sp)
    80001538:	1000                	add	s0,sp,32
    8000153a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153c:	e999                	bnez	a1,80001552 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153e:	8526                	mv	a0,s1
    80001540:	00000097          	auipc	ra,0x0
    80001544:	f84080e7          	jalr	-124(ra) # 800014c4 <freewalk>
}
    80001548:	60e2                	ld	ra,24(sp)
    8000154a:	6442                	ld	s0,16(sp)
    8000154c:	64a2                	ld	s1,8(sp)
    8000154e:	6105                	add	sp,sp,32
    80001550:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001552:	6785                	lui	a5,0x1
    80001554:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001556:	95be                	add	a1,a1,a5
    80001558:	4685                	li	a3,1
    8000155a:	00c5d613          	srl	a2,a1,0xc
    8000155e:	4581                	li	a1,0
    80001560:	00000097          	auipc	ra,0x0
    80001564:	d06080e7          	jalr	-762(ra) # 80001266 <uvmunmap>
    80001568:	bfd9                	j	8000153e <uvmfree+0xe>

000000008000156a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156a:	c679                	beqz	a2,80001638 <uvmcopy+0xce>
{
    8000156c:	715d                	add	sp,sp,-80
    8000156e:	e486                	sd	ra,72(sp)
    80001570:	e0a2                	sd	s0,64(sp)
    80001572:	fc26                	sd	s1,56(sp)
    80001574:	f84a                	sd	s2,48(sp)
    80001576:	f44e                	sd	s3,40(sp)
    80001578:	f052                	sd	s4,32(sp)
    8000157a:	ec56                	sd	s5,24(sp)
    8000157c:	e85a                	sd	s6,16(sp)
    8000157e:	e45e                	sd	s7,8(sp)
    80001580:	0880                	add	s0,sp,80
    80001582:	8b2a                	mv	s6,a0
    80001584:	8aae                	mv	s5,a1
    80001586:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001588:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158a:	4601                	li	a2,0
    8000158c:	85ce                	mv	a1,s3
    8000158e:	855a                	mv	a0,s6
    80001590:	00000097          	auipc	ra,0x0
    80001594:	a28080e7          	jalr	-1496(ra) # 80000fb8 <walk>
    80001598:	c531                	beqz	a0,800015e4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159a:	6118                	ld	a4,0(a0)
    8000159c:	00177793          	and	a5,a4,1
    800015a0:	cbb1                	beqz	a5,800015f4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a2:	00a75593          	srl	a1,a4,0xa
    800015a6:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015aa:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ae:	fffff097          	auipc	ra,0xfffff
    800015b2:	534080e7          	jalr	1332(ra) # 80000ae2 <kalloc>
    800015b6:	892a                	mv	s2,a0
    800015b8:	c939                	beqz	a0,8000160e <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85de                	mv	a1,s7
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	76c080e7          	jalr	1900(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c6:	8726                	mv	a4,s1
    800015c8:	86ca                	mv	a3,s2
    800015ca:	6605                	lui	a2,0x1
    800015cc:	85ce                	mv	a1,s3
    800015ce:	8556                	mv	a0,s5
    800015d0:	00000097          	auipc	ra,0x0
    800015d4:	ad0080e7          	jalr	-1328(ra) # 800010a0 <mappages>
    800015d8:	e515                	bnez	a0,80001604 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015da:	6785                	lui	a5,0x1
    800015dc:	99be                	add	s3,s3,a5
    800015de:	fb49e6e3          	bltu	s3,s4,8000158a <uvmcopy+0x20>
    800015e2:	a081                	j	80001622 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e4:	00007517          	auipc	a0,0x7
    800015e8:	ba450513          	add	a0,a0,-1116 # 80008188 <digits+0x148>
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	f50080e7          	jalr	-176(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015f4:	00007517          	auipc	a0,0x7
    800015f8:	bb450513          	add	a0,a0,-1100 # 800081a8 <digits+0x168>
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	f40080e7          	jalr	-192(ra) # 8000053c <panic>
      kfree(mem);
    80001604:	854a                	mv	a0,s2
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	3de080e7          	jalr	990(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160e:	4685                	li	a3,1
    80001610:	00c9d613          	srl	a2,s3,0xc
    80001614:	4581                	li	a1,0
    80001616:	8556                	mv	a0,s5
    80001618:	00000097          	auipc	ra,0x0
    8000161c:	c4e080e7          	jalr	-946(ra) # 80001266 <uvmunmap>
  return -1;
    80001620:	557d                	li	a0,-1
}
    80001622:	60a6                	ld	ra,72(sp)
    80001624:	6406                	ld	s0,64(sp)
    80001626:	74e2                	ld	s1,56(sp)
    80001628:	7942                	ld	s2,48(sp)
    8000162a:	79a2                	ld	s3,40(sp)
    8000162c:	7a02                	ld	s4,32(sp)
    8000162e:	6ae2                	ld	s5,24(sp)
    80001630:	6b42                	ld	s6,16(sp)
    80001632:	6ba2                	ld	s7,8(sp)
    80001634:	6161                	add	sp,sp,80
    80001636:	8082                	ret
  return 0;
    80001638:	4501                	li	a0,0
}
    8000163a:	8082                	ret

000000008000163c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163c:	1141                	add	sp,sp,-16
    8000163e:	e406                	sd	ra,8(sp)
    80001640:	e022                	sd	s0,0(sp)
    80001642:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001644:	4601                	li	a2,0
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	972080e7          	jalr	-1678(ra) # 80000fb8 <walk>
  if(pte == 0)
    8000164e:	c901                	beqz	a0,8000165e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001650:	611c                	ld	a5,0(a0)
    80001652:	9bbd                	and	a5,a5,-17
    80001654:	e11c                	sd	a5,0(a0)
}
    80001656:	60a2                	ld	ra,8(sp)
    80001658:	6402                	ld	s0,0(sp)
    8000165a:	0141                	add	sp,sp,16
    8000165c:	8082                	ret
    panic("uvmclear");
    8000165e:	00007517          	auipc	a0,0x7
    80001662:	b6a50513          	add	a0,a0,-1174 # 800081c8 <digits+0x188>
    80001666:	fffff097          	auipc	ra,0xfffff
    8000166a:	ed6080e7          	jalr	-298(ra) # 8000053c <panic>

000000008000166e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166e:	c6bd                	beqz	a3,800016dc <copyout+0x6e>
{
    80001670:	715d                	add	sp,sp,-80
    80001672:	e486                	sd	ra,72(sp)
    80001674:	e0a2                	sd	s0,64(sp)
    80001676:	fc26                	sd	s1,56(sp)
    80001678:	f84a                	sd	s2,48(sp)
    8000167a:	f44e                	sd	s3,40(sp)
    8000167c:	f052                	sd	s4,32(sp)
    8000167e:	ec56                	sd	s5,24(sp)
    80001680:	e85a                	sd	s6,16(sp)
    80001682:	e45e                	sd	s7,8(sp)
    80001684:	e062                	sd	s8,0(sp)
    80001686:	0880                	add	s0,sp,80
    80001688:	8b2a                	mv	s6,a0
    8000168a:	8c2e                	mv	s8,a1
    8000168c:	8a32                	mv	s4,a2
    8000168e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001690:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001692:	6a85                	lui	s5,0x1
    80001694:	a015                	j	800016b8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001696:	9562                	add	a0,a0,s8
    80001698:	0004861b          	sext.w	a2,s1
    8000169c:	85d2                	mv	a1,s4
    8000169e:	41250533          	sub	a0,a0,s2
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	688080e7          	jalr	1672(ra) # 80000d2a <memmove>

    len -= n;
    800016aa:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ae:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b4:	02098263          	beqz	s3,800016d8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016bc:	85ca                	mv	a1,s2
    800016be:	855a                	mv	a0,s6
    800016c0:	00000097          	auipc	ra,0x0
    800016c4:	99e080e7          	jalr	-1634(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    800016c8:	cd01                	beqz	a0,800016e0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ca:	418904b3          	sub	s1,s2,s8
    800016ce:	94d6                	add	s1,s1,s5
    800016d0:	fc99f3e3          	bgeu	s3,s1,80001696 <copyout+0x28>
    800016d4:	84ce                	mv	s1,s3
    800016d6:	b7c1                	j	80001696 <copyout+0x28>
  }
  return 0;
    800016d8:	4501                	li	a0,0
    800016da:	a021                	j	800016e2 <copyout+0x74>
    800016dc:	4501                	li	a0,0
}
    800016de:	8082                	ret
      return -1;
    800016e0:	557d                	li	a0,-1
}
    800016e2:	60a6                	ld	ra,72(sp)
    800016e4:	6406                	ld	s0,64(sp)
    800016e6:	74e2                	ld	s1,56(sp)
    800016e8:	7942                	ld	s2,48(sp)
    800016ea:	79a2                	ld	s3,40(sp)
    800016ec:	7a02                	ld	s4,32(sp)
    800016ee:	6ae2                	ld	s5,24(sp)
    800016f0:	6b42                	ld	s6,16(sp)
    800016f2:	6ba2                	ld	s7,8(sp)
    800016f4:	6c02                	ld	s8,0(sp)
    800016f6:	6161                	add	sp,sp,80
    800016f8:	8082                	ret

00000000800016fa <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fa:	caa5                	beqz	a3,8000176a <copyin+0x70>
{
    800016fc:	715d                	add	sp,sp,-80
    800016fe:	e486                	sd	ra,72(sp)
    80001700:	e0a2                	sd	s0,64(sp)
    80001702:	fc26                	sd	s1,56(sp)
    80001704:	f84a                	sd	s2,48(sp)
    80001706:	f44e                	sd	s3,40(sp)
    80001708:	f052                	sd	s4,32(sp)
    8000170a:	ec56                	sd	s5,24(sp)
    8000170c:	e85a                	sd	s6,16(sp)
    8000170e:	e45e                	sd	s7,8(sp)
    80001710:	e062                	sd	s8,0(sp)
    80001712:	0880                	add	s0,sp,80
    80001714:	8b2a                	mv	s6,a0
    80001716:	8a2e                	mv	s4,a1
    80001718:	8c32                	mv	s8,a2
    8000171a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171e:	6a85                	lui	s5,0x1
    80001720:	a01d                	j	80001746 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001722:	018505b3          	add	a1,a0,s8
    80001726:	0004861b          	sext.w	a2,s1
    8000172a:	412585b3          	sub	a1,a1,s2
    8000172e:	8552                	mv	a0,s4
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	5fa080e7          	jalr	1530(ra) # 80000d2a <memmove>

    len -= n;
    80001738:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001742:	02098263          	beqz	s3,80001766 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001746:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174a:	85ca                	mv	a1,s2
    8000174c:	855a                	mv	a0,s6
    8000174e:	00000097          	auipc	ra,0x0
    80001752:	910080e7          	jalr	-1776(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    80001756:	cd01                	beqz	a0,8000176e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001758:	418904b3          	sub	s1,s2,s8
    8000175c:	94d6                	add	s1,s1,s5
    8000175e:	fc99f2e3          	bgeu	s3,s1,80001722 <copyin+0x28>
    80001762:	84ce                	mv	s1,s3
    80001764:	bf7d                	j	80001722 <copyin+0x28>
  }
  return 0;
    80001766:	4501                	li	a0,0
    80001768:	a021                	j	80001770 <copyin+0x76>
    8000176a:	4501                	li	a0,0
}
    8000176c:	8082                	ret
      return -1;
    8000176e:	557d                	li	a0,-1
}
    80001770:	60a6                	ld	ra,72(sp)
    80001772:	6406                	ld	s0,64(sp)
    80001774:	74e2                	ld	s1,56(sp)
    80001776:	7942                	ld	s2,48(sp)
    80001778:	79a2                	ld	s3,40(sp)
    8000177a:	7a02                	ld	s4,32(sp)
    8000177c:	6ae2                	ld	s5,24(sp)
    8000177e:	6b42                	ld	s6,16(sp)
    80001780:	6ba2                	ld	s7,8(sp)
    80001782:	6c02                	ld	s8,0(sp)
    80001784:	6161                	add	sp,sp,80
    80001786:	8082                	ret

0000000080001788 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001788:	c2dd                	beqz	a3,8000182e <copyinstr+0xa6>
{
    8000178a:	715d                	add	sp,sp,-80
    8000178c:	e486                	sd	ra,72(sp)
    8000178e:	e0a2                	sd	s0,64(sp)
    80001790:	fc26                	sd	s1,56(sp)
    80001792:	f84a                	sd	s2,48(sp)
    80001794:	f44e                	sd	s3,40(sp)
    80001796:	f052                	sd	s4,32(sp)
    80001798:	ec56                	sd	s5,24(sp)
    8000179a:	e85a                	sd	s6,16(sp)
    8000179c:	e45e                	sd	s7,8(sp)
    8000179e:	0880                	add	s0,sp,80
    800017a0:	8a2a                	mv	s4,a0
    800017a2:	8b2e                	mv	s6,a1
    800017a4:	8bb2                	mv	s7,a2
    800017a6:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017aa:	6985                	lui	s3,0x1
    800017ac:	a02d                	j	800017d6 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b4:	37fd                	addw	a5,a5,-1
    800017b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ba:	60a6                	ld	ra,72(sp)
    800017bc:	6406                	ld	s0,64(sp)
    800017be:	74e2                	ld	s1,56(sp)
    800017c0:	7942                	ld	s2,48(sp)
    800017c2:	79a2                	ld	s3,40(sp)
    800017c4:	7a02                	ld	s4,32(sp)
    800017c6:	6ae2                	ld	s5,24(sp)
    800017c8:	6b42                	ld	s6,16(sp)
    800017ca:	6ba2                	ld	s7,8(sp)
    800017cc:	6161                	add	sp,sp,80
    800017ce:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d4:	c8a9                	beqz	s1,80001826 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017da:	85ca                	mv	a1,s2
    800017dc:	8552                	mv	a0,s4
    800017de:	00000097          	auipc	ra,0x0
    800017e2:	880080e7          	jalr	-1920(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    800017e6:	c131                	beqz	a0,8000182a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e8:	417906b3          	sub	a3,s2,s7
    800017ec:	96ce                	add	a3,a3,s3
    800017ee:	00d4f363          	bgeu	s1,a3,800017f4 <copyinstr+0x6c>
    800017f2:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f4:	955e                	add	a0,a0,s7
    800017f6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fa:	daf9                	beqz	a3,800017d0 <copyinstr+0x48>
    800017fc:	87da                	mv	a5,s6
    800017fe:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001800:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001804:	96da                	add	a3,a3,s6
    80001806:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc1b0>
    80001810:	df59                	beqz	a4,800017ae <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      dst++;
    80001816:	0785                	add	a5,a5,1
    while(n > 0){
    80001818:	fed797e3          	bne	a5,a3,80001806 <copyinstr+0x7e>
    8000181c:	14fd                	add	s1,s1,-1
    8000181e:	94c2                	add	s1,s1,a6
      --max;
    80001820:	8c8d                	sub	s1,s1,a1
      dst++;
    80001822:	8b3e                	mv	s6,a5
    80001824:	b775                	j	800017d0 <copyinstr+0x48>
    80001826:	4781                	li	a5,0
    80001828:	b771                	j	800017b4 <copyinstr+0x2c>
      return -1;
    8000182a:	557d                	li	a0,-1
    8000182c:	b779                	j	800017ba <copyinstr+0x32>
  int got_null = 0;
    8000182e:	4781                	li	a5,0
  if(got_null){
    80001830:	37fd                	addw	a5,a5,-1
    80001832:	0007851b          	sext.w	a0,a5
}
    80001836:	8082                	ret

0000000080001838 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001838:	7139                	add	sp,sp,-64
    8000183a:	fc06                	sd	ra,56(sp)
    8000183c:	f822                	sd	s0,48(sp)
    8000183e:	f426                	sd	s1,40(sp)
    80001840:	f04a                	sd	s2,32(sp)
    80001842:	ec4e                	sd	s3,24(sp)
    80001844:	e852                	sd	s4,16(sp)
    80001846:	e456                	sd	s5,8(sp)
    80001848:	e05a                	sd	s6,0(sp)
    8000184a:	0080                	add	s0,sp,64
    8000184c:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184e:	00010497          	auipc	s1,0x10
    80001852:	82248493          	add	s1,s1,-2014 # 80011070 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001856:	8b26                	mv	s6,s1
    80001858:	00006a97          	auipc	s5,0x6
    8000185c:	7a8a8a93          	add	s5,s5,1960 # 80008000 <etext>
    80001860:	04000937          	lui	s2,0x4000
    80001864:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001866:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001868:	00015a17          	auipc	s4,0x15
    8000186c:	208a0a13          	add	s4,s4,520 # 80016a70 <tickslock>
    char *pa = kalloc();
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	272080e7          	jalr	626(ra) # 80000ae2 <kalloc>
    80001878:	862a                	mv	a2,a0
    if(pa == 0)
    8000187a:	c131                	beqz	a0,800018be <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187c:	416485b3          	sub	a1,s1,s6
    80001880:	858d                	sra	a1,a1,0x3
    80001882:	000ab783          	ld	a5,0(s5)
    80001886:	02f585b3          	mul	a1,a1,a5
    8000188a:	2585                	addw	a1,a1,1
    8000188c:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001890:	4719                	li	a4,6
    80001892:	6685                	lui	a3,0x1
    80001894:	40b905b3          	sub	a1,s2,a1
    80001898:	854e                	mv	a0,s3
    8000189a:	00000097          	auipc	ra,0x0
    8000189e:	8a6080e7          	jalr	-1882(ra) # 80001140 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a2:	16848493          	add	s1,s1,360
    800018a6:	fd4495e3          	bne	s1,s4,80001870 <proc_mapstacks+0x38>
  }
}
    800018aa:	70e2                	ld	ra,56(sp)
    800018ac:	7442                	ld	s0,48(sp)
    800018ae:	74a2                	ld	s1,40(sp)
    800018b0:	7902                	ld	s2,32(sp)
    800018b2:	69e2                	ld	s3,24(sp)
    800018b4:	6a42                	ld	s4,16(sp)
    800018b6:	6aa2                	ld	s5,8(sp)
    800018b8:	6b02                	ld	s6,0(sp)
    800018ba:	6121                	add	sp,sp,64
    800018bc:	8082                	ret
      panic("kalloc");
    800018be:	00007517          	auipc	a0,0x7
    800018c2:	91a50513          	add	a0,a0,-1766 # 800081d8 <digits+0x198>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	c76080e7          	jalr	-906(ra) # 8000053c <panic>

00000000800018ce <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ce:	7139                	add	sp,sp,-64
    800018d0:	fc06                	sd	ra,56(sp)
    800018d2:	f822                	sd	s0,48(sp)
    800018d4:	f426                	sd	s1,40(sp)
    800018d6:	f04a                	sd	s2,32(sp)
    800018d8:	ec4e                	sd	s3,24(sp)
    800018da:	e852                	sd	s4,16(sp)
    800018dc:	e456                	sd	s5,8(sp)
    800018de:	e05a                	sd	s6,0(sp)
    800018e0:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e2:	00007597          	auipc	a1,0x7
    800018e6:	8fe58593          	add	a1,a1,-1794 # 800081e0 <digits+0x1a0>
    800018ea:	0000f517          	auipc	a0,0xf
    800018ee:	35650513          	add	a0,a0,854 # 80010c40 <pid_lock>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	250080e7          	jalr	592(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8ee58593          	add	a1,a1,-1810 # 800081e8 <digits+0x1a8>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	35650513          	add	a0,a0,854 # 80010c58 <wait_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	238080e7          	jalr	568(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001912:	0000f497          	auipc	s1,0xf
    80001916:	75e48493          	add	s1,s1,1886 # 80011070 <proc>
      initlock(&p->lock, "proc");
    8000191a:	00007b17          	auipc	s6,0x7
    8000191e:	8deb0b13          	add	s6,s6,-1826 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001922:	8aa6                	mv	s5,s1
    80001924:	00006a17          	auipc	s4,0x6
    80001928:	6dca0a13          	add	s4,s4,1756 # 80008000 <etext>
    8000192c:	04000937          	lui	s2,0x4000
    80001930:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001932:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001934:	00015997          	auipc	s3,0x15
    80001938:	13c98993          	add	s3,s3,316 # 80016a70 <tickslock>
      initlock(&p->lock, "proc");
    8000193c:	85da                	mv	a1,s6
    8000193e:	8526                	mv	a0,s1
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	202080e7          	jalr	514(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001948:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194c:	415487b3          	sub	a5,s1,s5
    80001950:	878d                	sra	a5,a5,0x3
    80001952:	000a3703          	ld	a4,0(s4)
    80001956:	02e787b3          	mul	a5,a5,a4
    8000195a:	2785                	addw	a5,a5,1
    8000195c:	00d7979b          	sllw	a5,a5,0xd
    80001960:	40f907b3          	sub	a5,s2,a5
    80001964:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001966:	16848493          	add	s1,s1,360
    8000196a:	fd3499e3          	bne	s1,s3,8000193c <procinit+0x6e>
  }
}
    8000196e:	70e2                	ld	ra,56(sp)
    80001970:	7442                	ld	s0,48(sp)
    80001972:	74a2                	ld	s1,40(sp)
    80001974:	7902                	ld	s2,32(sp)
    80001976:	69e2                	ld	s3,24(sp)
    80001978:	6a42                	ld	s4,16(sp)
    8000197a:	6aa2                	ld	s5,8(sp)
    8000197c:	6b02                	ld	s6,0(sp)
    8000197e:	6121                	add	sp,sp,64
    80001980:	8082                	ret

0000000080001982 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001982:	1141                	add	sp,sp,-16
    80001984:	e422                	sd	s0,8(sp)
    80001986:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001988:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198a:	2501                	sext.w	a0,a0
    8000198c:	6422                	ld	s0,8(sp)
    8000198e:	0141                	add	sp,sp,16
    80001990:	8082                	ret

0000000080001992 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001992:	1141                	add	sp,sp,-16
    80001994:	e422                	sd	s0,8(sp)
    80001996:	0800                	add	s0,sp,16
    80001998:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199a:	2781                	sext.w	a5,a5
    8000199c:	079e                	sll	a5,a5,0x7
  return c;
}
    8000199e:	0000f517          	auipc	a0,0xf
    800019a2:	2d250513          	add	a0,a0,722 # 80010c70 <cpus>
    800019a6:	953e                	add	a0,a0,a5
    800019a8:	6422                	ld	s0,8(sp)
    800019aa:	0141                	add	sp,sp,16
    800019ac:	8082                	ret

00000000800019ae <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ae:	1101                	add	sp,sp,-32
    800019b0:	ec06                	sd	ra,24(sp)
    800019b2:	e822                	sd	s0,16(sp)
    800019b4:	e426                	sd	s1,8(sp)
    800019b6:	1000                	add	s0,sp,32
  push_off();
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	1ce080e7          	jalr	462(ra) # 80000b86 <push_off>
    800019c0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c2:	2781                	sext.w	a5,a5
    800019c4:	079e                	sll	a5,a5,0x7
    800019c6:	0000f717          	auipc	a4,0xf
    800019ca:	27a70713          	add	a4,a4,634 # 80010c40 <pid_lock>
    800019ce:	97ba                	add	a5,a5,a4
    800019d0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	254080e7          	jalr	596(ra) # 80000c26 <pop_off>
  return p;
}
    800019da:	8526                	mv	a0,s1
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6105                	add	sp,sp,32
    800019e4:	8082                	ret

00000000800019e6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e6:	1141                	add	sp,sp,-16
    800019e8:	e406                	sd	ra,8(sp)
    800019ea:	e022                	sd	s0,0(sp)
    800019ec:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ee:	00000097          	auipc	ra,0x0
    800019f2:	fc0080e7          	jalr	-64(ra) # 800019ae <myproc>
    800019f6:	fffff097          	auipc	ra,0xfffff
    800019fa:	290080e7          	jalr	656(ra) # 80000c86 <release>

  if (first) {
    800019fe:	00007797          	auipc	a5,0x7
    80001a02:	f327a783          	lw	a5,-206(a5) # 80008930 <first.1>
    80001a06:	eb89                	bnez	a5,80001a18 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a08:	00001097          	auipc	ra,0x1
    80001a0c:	c5c080e7          	jalr	-932(ra) # 80002664 <usertrapret>
}
    80001a10:	60a2                	ld	ra,8(sp)
    80001a12:	6402                	ld	s0,0(sp)
    80001a14:	0141                	add	sp,sp,16
    80001a16:	8082                	ret
    first = 0;
    80001a18:	00007797          	auipc	a5,0x7
    80001a1c:	f007ac23          	sw	zero,-232(a5) # 80008930 <first.1>
    fsinit(ROOTDEV);
    80001a20:	4505                	li	a0,1
    80001a22:	00002097          	auipc	ra,0x2
    80001a26:	a4a080e7          	jalr	-1462(ra) # 8000346c <fsinit>
    80001a2a:	bff9                	j	80001a08 <forkret+0x22>

0000000080001a2c <allocpid>:
{
    80001a2c:	1101                	add	sp,sp,-32
    80001a2e:	ec06                	sd	ra,24(sp)
    80001a30:	e822                	sd	s0,16(sp)
    80001a32:	e426                	sd	s1,8(sp)
    80001a34:	e04a                	sd	s2,0(sp)
    80001a36:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a38:	0000f917          	auipc	s2,0xf
    80001a3c:	20890913          	add	s2,s2,520 # 80010c40 <pid_lock>
    80001a40:	854a                	mv	a0,s2
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	190080e7          	jalr	400(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a4a:	00007797          	auipc	a5,0x7
    80001a4e:	eea78793          	add	a5,a5,-278 # 80008934 <nextpid>
    80001a52:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a54:	0014871b          	addw	a4,s1,1
    80001a58:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a5a:	854a                	mv	a0,s2
    80001a5c:	fffff097          	auipc	ra,0xfffff
    80001a60:	22a080e7          	jalr	554(ra) # 80000c86 <release>
}
    80001a64:	8526                	mv	a0,s1
    80001a66:	60e2                	ld	ra,24(sp)
    80001a68:	6442                	ld	s0,16(sp)
    80001a6a:	64a2                	ld	s1,8(sp)
    80001a6c:	6902                	ld	s2,0(sp)
    80001a6e:	6105                	add	sp,sp,32
    80001a70:	8082                	ret

0000000080001a72 <proc_pagetable>:
{
    80001a72:	1101                	add	sp,sp,-32
    80001a74:	ec06                	sd	ra,24(sp)
    80001a76:	e822                	sd	s0,16(sp)
    80001a78:	e426                	sd	s1,8(sp)
    80001a7a:	e04a                	sd	s2,0(sp)
    80001a7c:	1000                	add	s0,sp,32
    80001a7e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	8aa080e7          	jalr	-1878(ra) # 8000132a <uvmcreate>
    80001a88:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a8a:	c121                	beqz	a0,80001aca <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8c:	4729                	li	a4,10
    80001a8e:	00005697          	auipc	a3,0x5
    80001a92:	57268693          	add	a3,a3,1394 # 80007000 <_trampoline>
    80001a96:	6605                	lui	a2,0x1
    80001a98:	040005b7          	lui	a1,0x4000
    80001a9c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9e:	05b2                	sll	a1,a1,0xc
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	600080e7          	jalr	1536(ra) # 800010a0 <mappages>
    80001aa8:	02054863          	bltz	a0,80001ad8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aac:	4719                	li	a4,6
    80001aae:	05893683          	ld	a3,88(s2)
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	020005b7          	lui	a1,0x2000
    80001ab8:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aba:	05b6                	sll	a1,a1,0xd
    80001abc:	8526                	mv	a0,s1
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	5e2080e7          	jalr	1506(ra) # 800010a0 <mappages>
    80001ac6:	02054163          	bltz	a0,80001ae8 <proc_pagetable+0x76>
}
    80001aca:	8526                	mv	a0,s1
    80001acc:	60e2                	ld	ra,24(sp)
    80001ace:	6442                	ld	s0,16(sp)
    80001ad0:	64a2                	ld	s1,8(sp)
    80001ad2:	6902                	ld	s2,0(sp)
    80001ad4:	6105                	add	sp,sp,32
    80001ad6:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad8:	4581                	li	a1,0
    80001ada:	8526                	mv	a0,s1
    80001adc:	00000097          	auipc	ra,0x0
    80001ae0:	a54080e7          	jalr	-1452(ra) # 80001530 <uvmfree>
    return 0;
    80001ae4:	4481                	li	s1,0
    80001ae6:	b7d5                	j	80001aca <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae8:	4681                	li	a3,0
    80001aea:	4605                	li	a2,1
    80001aec:	040005b7          	lui	a1,0x4000
    80001af0:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af2:	05b2                	sll	a1,a1,0xc
    80001af4:	8526                	mv	a0,s1
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	770080e7          	jalr	1904(ra) # 80001266 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afe:	4581                	li	a1,0
    80001b00:	8526                	mv	a0,s1
    80001b02:	00000097          	auipc	ra,0x0
    80001b06:	a2e080e7          	jalr	-1490(ra) # 80001530 <uvmfree>
    return 0;
    80001b0a:	4481                	li	s1,0
    80001b0c:	bf7d                	j	80001aca <proc_pagetable+0x58>

0000000080001b0e <proc_freepagetable>:
{
    80001b0e:	1101                	add	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	add	s0,sp,32
    80001b1a:	84aa                	mv	s1,a0
    80001b1c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1e:	4681                	li	a3,0
    80001b20:	4605                	li	a2,1
    80001b22:	040005b7          	lui	a1,0x4000
    80001b26:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b28:	05b2                	sll	a1,a1,0xc
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	73c080e7          	jalr	1852(ra) # 80001266 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b32:	4681                	li	a3,0
    80001b34:	4605                	li	a2,1
    80001b36:	020005b7          	lui	a1,0x2000
    80001b3a:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3c:	05b6                	sll	a1,a1,0xd
    80001b3e:	8526                	mv	a0,s1
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	726080e7          	jalr	1830(ra) # 80001266 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b48:	85ca                	mv	a1,s2
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	00000097          	auipc	ra,0x0
    80001b50:	9e4080e7          	jalr	-1564(ra) # 80001530 <uvmfree>
}
    80001b54:	60e2                	ld	ra,24(sp)
    80001b56:	6442                	ld	s0,16(sp)
    80001b58:	64a2                	ld	s1,8(sp)
    80001b5a:	6902                	ld	s2,0(sp)
    80001b5c:	6105                	add	sp,sp,32
    80001b5e:	8082                	ret

0000000080001b60 <freeproc>:
{
    80001b60:	1101                	add	sp,sp,-32
    80001b62:	ec06                	sd	ra,24(sp)
    80001b64:	e822                	sd	s0,16(sp)
    80001b66:	e426                	sd	s1,8(sp)
    80001b68:	1000                	add	s0,sp,32
    80001b6a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6c:	6d28                	ld	a0,88(a0)
    80001b6e:	c509                	beqz	a0,80001b78 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	e74080e7          	jalr	-396(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b78:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7c:	68a8                	ld	a0,80(s1)
    80001b7e:	c511                	beqz	a0,80001b8a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b80:	64ac                	ld	a1,72(s1)
    80001b82:	00000097          	auipc	ra,0x0
    80001b86:	f8c080e7          	jalr	-116(ra) # 80001b0e <proc_freepagetable>
  p->pagetable = 0;
    80001b8a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b92:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b96:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b9a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001baa:	0004ac23          	sw	zero,24(s1)
}
    80001bae:	60e2                	ld	ra,24(sp)
    80001bb0:	6442                	ld	s0,16(sp)
    80001bb2:	64a2                	ld	s1,8(sp)
    80001bb4:	6105                	add	sp,sp,32
    80001bb6:	8082                	ret

0000000080001bb8 <allocproc>:
{
    80001bb8:	1101                	add	sp,sp,-32
    80001bba:	ec06                	sd	ra,24(sp)
    80001bbc:	e822                	sd	s0,16(sp)
    80001bbe:	e426                	sd	s1,8(sp)
    80001bc0:	e04a                	sd	s2,0(sp)
    80001bc2:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc4:	0000f497          	auipc	s1,0xf
    80001bc8:	4ac48493          	add	s1,s1,1196 # 80011070 <proc>
    80001bcc:	00015917          	auipc	s2,0x15
    80001bd0:	ea490913          	add	s2,s2,-348 # 80016a70 <tickslock>
    acquire(&p->lock);
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	fffff097          	auipc	ra,0xfffff
    80001bda:	ffc080e7          	jalr	-4(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bde:	4c9c                	lw	a5,24(s1)
    80001be0:	cf81                	beqz	a5,80001bf8 <allocproc+0x40>
      release(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	0a2080e7          	jalr	162(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bec:	16848493          	add	s1,s1,360
    80001bf0:	ff2492e3          	bne	s1,s2,80001bd4 <allocproc+0x1c>
  return 0;
    80001bf4:	4481                	li	s1,0
    80001bf6:	a889                	j	80001c48 <allocproc+0x90>
  p->pid = allocpid();
    80001bf8:	00000097          	auipc	ra,0x0
    80001bfc:	e34080e7          	jalr	-460(ra) # 80001a2c <allocpid>
    80001c00:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c02:	4785                	li	a5,1
    80001c04:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	edc080e7          	jalr	-292(ra) # 80000ae2 <kalloc>
    80001c0e:	892a                	mv	s2,a0
    80001c10:	eca8                	sd	a0,88(s1)
    80001c12:	c131                	beqz	a0,80001c56 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c14:	8526                	mv	a0,s1
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	e5c080e7          	jalr	-420(ra) # 80001a72 <proc_pagetable>
    80001c1e:	892a                	mv	s2,a0
    80001c20:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c22:	c531                	beqz	a0,80001c6e <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c24:	07000613          	li	a2,112
    80001c28:	4581                	li	a1,0
    80001c2a:	06048513          	add	a0,s1,96
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	0a0080e7          	jalr	160(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c36:	00000797          	auipc	a5,0x0
    80001c3a:	db078793          	add	a5,a5,-592 # 800019e6 <forkret>
    80001c3e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c40:	60bc                	ld	a5,64(s1)
    80001c42:	6705                	lui	a4,0x1
    80001c44:	97ba                	add	a5,a5,a4
    80001c46:	f4bc                	sd	a5,104(s1)
}
    80001c48:	8526                	mv	a0,s1
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6902                	ld	s2,0(sp)
    80001c52:	6105                	add	sp,sp,32
    80001c54:	8082                	ret
    freeproc(p);
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	f08080e7          	jalr	-248(ra) # 80001b60 <freeproc>
    release(&p->lock);
    80001c60:	8526                	mv	a0,s1
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	024080e7          	jalr	36(ra) # 80000c86 <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	bff1                	j	80001c48 <allocproc+0x90>
    freeproc(p);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	ef0080e7          	jalr	-272(ra) # 80001b60 <freeproc>
    release(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	00c080e7          	jalr	12(ra) # 80000c86 <release>
    return 0;
    80001c82:	84ca                	mv	s1,s2
    80001c84:	b7d1                	j	80001c48 <allocproc+0x90>

0000000080001c86 <userinit>:
{
    80001c86:	1101                	add	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	add	s0,sp,32
  p = allocproc();
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	f28080e7          	jalr	-216(ra) # 80001bb8 <allocproc>
    80001c98:	84aa                	mv	s1,a0
  initproc = p;
    80001c9a:	00007797          	auipc	a5,0x7
    80001c9e:	d2a7b723          	sd	a0,-722(a5) # 800089c8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca2:	03400613          	li	a2,52
    80001ca6:	00007597          	auipc	a1,0x7
    80001caa:	c9a58593          	add	a1,a1,-870 # 80008940 <initcode>
    80001cae:	6928                	ld	a0,80(a0)
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	6a8080e7          	jalr	1704(ra) # 80001358 <uvmfirst>
  p->sz = PGSIZE;
    80001cb8:	6785                	lui	a5,0x1
    80001cba:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cbc:	6cb8                	ld	a4,88(s1)
    80001cbe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc2:	6cb8                	ld	a4,88(s1)
    80001cc4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc6:	4641                	li	a2,16
    80001cc8:	00006597          	auipc	a1,0x6
    80001ccc:	53858593          	add	a1,a1,1336 # 80008200 <digits+0x1c0>
    80001cd0:	15848513          	add	a0,s1,344
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	142080e7          	jalr	322(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cdc:	00006517          	auipc	a0,0x6
    80001ce0:	53450513          	add	a0,a0,1332 # 80008210 <digits+0x1d0>
    80001ce4:	00002097          	auipc	ra,0x2
    80001ce8:	1a6080e7          	jalr	422(ra) # 80003e8a <namei>
    80001cec:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	f90080e7          	jalr	-112(ra) # 80000c86 <release>
}
    80001cfe:	60e2                	ld	ra,24(sp)
    80001d00:	6442                	ld	s0,16(sp)
    80001d02:	64a2                	ld	s1,8(sp)
    80001d04:	6105                	add	sp,sp,32
    80001d06:	8082                	ret

0000000080001d08 <growproc>:
{
    80001d08:	1101                	add	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	e04a                	sd	s2,0(sp)
    80001d12:	1000                	add	s0,sp,32
    80001d14:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d16:	00000097          	auipc	ra,0x0
    80001d1a:	c98080e7          	jalr	-872(ra) # 800019ae <myproc>
    80001d1e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d20:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d22:	01204c63          	bgtz	s2,80001d3a <growproc+0x32>
  } else if(n < 0){
    80001d26:	02094663          	bltz	s2,80001d52 <growproc+0x4a>
  p->sz = sz;
    80001d2a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2c:	4501                	li	a0,0
}
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	add	sp,sp,32
    80001d38:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d3a:	4691                	li	a3,4
    80001d3c:	00b90633          	add	a2,s2,a1
    80001d40:	6928                	ld	a0,80(a0)
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	6d0080e7          	jalr	1744(ra) # 80001412 <uvmalloc>
    80001d4a:	85aa                	mv	a1,a0
    80001d4c:	fd79                	bnez	a0,80001d2a <growproc+0x22>
      return -1;
    80001d4e:	557d                	li	a0,-1
    80001d50:	bff9                	j	80001d2e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d52:	00b90633          	add	a2,s2,a1
    80001d56:	6928                	ld	a0,80(a0)
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	672080e7          	jalr	1650(ra) # 800013ca <uvmdealloc>
    80001d60:	85aa                	mv	a1,a0
    80001d62:	b7e1                	j	80001d2a <growproc+0x22>

0000000080001d64 <fork>:
{
    80001d64:	7139                	add	sp,sp,-64
    80001d66:	fc06                	sd	ra,56(sp)
    80001d68:	f822                	sd	s0,48(sp)
    80001d6a:	f426                	sd	s1,40(sp)
    80001d6c:	f04a                	sd	s2,32(sp)
    80001d6e:	ec4e                	sd	s3,24(sp)
    80001d70:	e852                	sd	s4,16(sp)
    80001d72:	e456                	sd	s5,8(sp)
    80001d74:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	c38080e7          	jalr	-968(ra) # 800019ae <myproc>
    80001d7e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d80:	00000097          	auipc	ra,0x0
    80001d84:	e38080e7          	jalr	-456(ra) # 80001bb8 <allocproc>
    80001d88:	10050c63          	beqz	a0,80001ea0 <fork+0x13c>
    80001d8c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8e:	048ab603          	ld	a2,72(s5)
    80001d92:	692c                	ld	a1,80(a0)
    80001d94:	050ab503          	ld	a0,80(s5)
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	7d2080e7          	jalr	2002(ra) # 8000156a <uvmcopy>
    80001da0:	04054863          	bltz	a0,80001df0 <fork+0x8c>
  np->sz = p->sz;
    80001da4:	048ab783          	ld	a5,72(s5)
    80001da8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dac:	058ab683          	ld	a3,88(s5)
    80001db0:	87b6                	mv	a5,a3
    80001db2:	058a3703          	ld	a4,88(s4)
    80001db6:	12068693          	add	a3,a3,288
    80001dba:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbe:	6788                	ld	a0,8(a5)
    80001dc0:	6b8c                	ld	a1,16(a5)
    80001dc2:	6f90                	ld	a2,24(a5)
    80001dc4:	01073023          	sd	a6,0(a4)
    80001dc8:	e708                	sd	a0,8(a4)
    80001dca:	eb0c                	sd	a1,16(a4)
    80001dcc:	ef10                	sd	a2,24(a4)
    80001dce:	02078793          	add	a5,a5,32
    80001dd2:	02070713          	add	a4,a4,32
    80001dd6:	fed792e3          	bne	a5,a3,80001dba <fork+0x56>
  np->trapframe->a0 = 0;
    80001dda:	058a3783          	ld	a5,88(s4)
    80001dde:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de2:	0d0a8493          	add	s1,s5,208
    80001de6:	0d0a0913          	add	s2,s4,208
    80001dea:	150a8993          	add	s3,s5,336
    80001dee:	a00d                	j	80001e10 <fork+0xac>
    freeproc(np);
    80001df0:	8552                	mv	a0,s4
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	d6e080e7          	jalr	-658(ra) # 80001b60 <freeproc>
    release(&np->lock);
    80001dfa:	8552                	mv	a0,s4
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	e8a080e7          	jalr	-374(ra) # 80000c86 <release>
    return -1;
    80001e04:	597d                	li	s2,-1
    80001e06:	a059                	j	80001e8c <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e08:	04a1                	add	s1,s1,8
    80001e0a:	0921                	add	s2,s2,8
    80001e0c:	01348b63          	beq	s1,s3,80001e22 <fork+0xbe>
    if(p->ofile[i])
    80001e10:	6088                	ld	a0,0(s1)
    80001e12:	d97d                	beqz	a0,80001e08 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e14:	00002097          	auipc	ra,0x2
    80001e18:	6e8080e7          	jalr	1768(ra) # 800044fc <filedup>
    80001e1c:	00a93023          	sd	a0,0(s2)
    80001e20:	b7e5                	j	80001e08 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e22:	150ab503          	ld	a0,336(s5)
    80001e26:	00002097          	auipc	ra,0x2
    80001e2a:	880080e7          	jalr	-1920(ra) # 800036a6 <idup>
    80001e2e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e32:	4641                	li	a2,16
    80001e34:	158a8593          	add	a1,s5,344
    80001e38:	158a0513          	add	a0,s4,344
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	fda080e7          	jalr	-38(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e44:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e48:	8552                	mv	a0,s4
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	e3c080e7          	jalr	-452(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e52:	0000f497          	auipc	s1,0xf
    80001e56:	e0648493          	add	s1,s1,-506 # 80010c58 <wait_lock>
    80001e5a:	8526                	mv	a0,s1
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	d76080e7          	jalr	-650(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e64:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	e1c080e7          	jalr	-484(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e72:	8552                	mv	a0,s4
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d5e080e7          	jalr	-674(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e7c:	478d                	li	a5,3
    80001e7e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e82:	8552                	mv	a0,s4
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	e02080e7          	jalr	-510(ra) # 80000c86 <release>
}
    80001e8c:	854a                	mv	a0,s2
    80001e8e:	70e2                	ld	ra,56(sp)
    80001e90:	7442                	ld	s0,48(sp)
    80001e92:	74a2                	ld	s1,40(sp)
    80001e94:	7902                	ld	s2,32(sp)
    80001e96:	69e2                	ld	s3,24(sp)
    80001e98:	6a42                	ld	s4,16(sp)
    80001e9a:	6aa2                	ld	s5,8(sp)
    80001e9c:	6121                	add	sp,sp,64
    80001e9e:	8082                	ret
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	b7ed                	j	80001e8c <fork+0x128>

0000000080001ea4 <scheduler>:
{
    80001ea4:	7139                	add	sp,sp,-64
    80001ea6:	fc06                	sd	ra,56(sp)
    80001ea8:	f822                	sd	s0,48(sp)
    80001eaa:	f426                	sd	s1,40(sp)
    80001eac:	f04a                	sd	s2,32(sp)
    80001eae:	ec4e                	sd	s3,24(sp)
    80001eb0:	e852                	sd	s4,16(sp)
    80001eb2:	e456                	sd	s5,8(sp)
    80001eb4:	e05a                	sd	s6,0(sp)
    80001eb6:	0080                	add	s0,sp,64
    80001eb8:	8792                	mv	a5,tp
  int id = r_tp();
    80001eba:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ebc:	00779a93          	sll	s5,a5,0x7
    80001ec0:	0000f717          	auipc	a4,0xf
    80001ec4:	d8070713          	add	a4,a4,-640 # 80010c40 <pid_lock>
    80001ec8:	9756                	add	a4,a4,s5
    80001eca:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ece:	0000f717          	auipc	a4,0xf
    80001ed2:	daa70713          	add	a4,a4,-598 # 80010c78 <cpus+0x8>
    80001ed6:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed8:	498d                	li	s3,3
        p->state = RUNNING;
    80001eda:	4b11                	li	s6,4
        c->proc = p;
    80001edc:	079e                	sll	a5,a5,0x7
    80001ede:	0000fa17          	auipc	s4,0xf
    80001ee2:	d62a0a13          	add	s4,s4,-670 # 80010c40 <pid_lock>
    80001ee6:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee8:	00015917          	auipc	s2,0x15
    80001eec:	b8890913          	add	s2,s2,-1144 # 80016a70 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef4:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef8:	10079073          	csrw	sstatus,a5
    80001efc:	0000f497          	auipc	s1,0xf
    80001f00:	17448493          	add	s1,s1,372 # 80011070 <proc>
    80001f04:	a811                	j	80001f18 <scheduler+0x74>
      release(&p->lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d7e080e7          	jalr	-642(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f10:	16848493          	add	s1,s1,360
    80001f14:	fd248ee3          	beq	s1,s2,80001ef0 <scheduler+0x4c>
      acquire(&p->lock);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	cb8080e7          	jalr	-840(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f22:	4c9c                	lw	a5,24(s1)
    80001f24:	ff3791e3          	bne	a5,s3,80001f06 <scheduler+0x62>
        p->state = RUNNING;
    80001f28:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f2c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f30:	06048593          	add	a1,s1,96
    80001f34:	8556                	mv	a0,s5
    80001f36:	00000097          	auipc	ra,0x0
    80001f3a:	684080e7          	jalr	1668(ra) # 800025ba <swtch>
        c->proc = 0;
    80001f3e:	020a3823          	sd	zero,48(s4)
    80001f42:	b7d1                	j	80001f06 <scheduler+0x62>

0000000080001f44 <sched>:
{
    80001f44:	7179                	add	sp,sp,-48
    80001f46:	f406                	sd	ra,40(sp)
    80001f48:	f022                	sd	s0,32(sp)
    80001f4a:	ec26                	sd	s1,24(sp)
    80001f4c:	e84a                	sd	s2,16(sp)
    80001f4e:	e44e                	sd	s3,8(sp)
    80001f50:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	a5c080e7          	jalr	-1444(ra) # 800019ae <myproc>
    80001f5a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	bfc080e7          	jalr	-1028(ra) # 80000b58 <holding>
    80001f64:	c93d                	beqz	a0,80001fda <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f66:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f68:	2781                	sext.w	a5,a5
    80001f6a:	079e                	sll	a5,a5,0x7
    80001f6c:	0000f717          	auipc	a4,0xf
    80001f70:	cd470713          	add	a4,a4,-812 # 80010c40 <pid_lock>
    80001f74:	97ba                	add	a5,a5,a4
    80001f76:	0a87a703          	lw	a4,168(a5)
    80001f7a:	4785                	li	a5,1
    80001f7c:	06f71763          	bne	a4,a5,80001fea <sched+0xa6>
  if(p->state == RUNNING)
    80001f80:	4c98                	lw	a4,24(s1)
    80001f82:	4791                	li	a5,4
    80001f84:	06f70b63          	beq	a4,a5,80001ffa <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f8c:	8b89                	and	a5,a5,2
  if(intr_get())
    80001f8e:	efb5                	bnez	a5,8000200a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f90:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f92:	0000f917          	auipc	s2,0xf
    80001f96:	cae90913          	add	s2,s2,-850 # 80010c40 <pid_lock>
    80001f9a:	2781                	sext.w	a5,a5
    80001f9c:	079e                	sll	a5,a5,0x7
    80001f9e:	97ca                	add	a5,a5,s2
    80001fa0:	0ac7a983          	lw	s3,172(a5)
    80001fa4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	sll	a5,a5,0x7
    80001faa:	0000f597          	auipc	a1,0xf
    80001fae:	cce58593          	add	a1,a1,-818 # 80010c78 <cpus+0x8>
    80001fb2:	95be                	add	a1,a1,a5
    80001fb4:	06048513          	add	a0,s1,96
    80001fb8:	00000097          	auipc	ra,0x0
    80001fbc:	602080e7          	jalr	1538(ra) # 800025ba <swtch>
    80001fc0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc2:	2781                	sext.w	a5,a5
    80001fc4:	079e                	sll	a5,a5,0x7
    80001fc6:	993e                	add	s2,s2,a5
    80001fc8:	0b392623          	sw	s3,172(s2)
}
    80001fcc:	70a2                	ld	ra,40(sp)
    80001fce:	7402                	ld	s0,32(sp)
    80001fd0:	64e2                	ld	s1,24(sp)
    80001fd2:	6942                	ld	s2,16(sp)
    80001fd4:	69a2                	ld	s3,8(sp)
    80001fd6:	6145                	add	sp,sp,48
    80001fd8:	8082                	ret
    panic("sched p->lock");
    80001fda:	00006517          	auipc	a0,0x6
    80001fde:	23e50513          	add	a0,a0,574 # 80008218 <digits+0x1d8>
    80001fe2:	ffffe097          	auipc	ra,0xffffe
    80001fe6:	55a080e7          	jalr	1370(ra) # 8000053c <panic>
    panic("sched locks");
    80001fea:	00006517          	auipc	a0,0x6
    80001fee:	23e50513          	add	a0,a0,574 # 80008228 <digits+0x1e8>
    80001ff2:	ffffe097          	auipc	ra,0xffffe
    80001ff6:	54a080e7          	jalr	1354(ra) # 8000053c <panic>
    panic("sched running");
    80001ffa:	00006517          	auipc	a0,0x6
    80001ffe:	23e50513          	add	a0,a0,574 # 80008238 <digits+0x1f8>
    80002002:	ffffe097          	auipc	ra,0xffffe
    80002006:	53a080e7          	jalr	1338(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000200a:	00006517          	auipc	a0,0x6
    8000200e:	23e50513          	add	a0,a0,574 # 80008248 <digits+0x208>
    80002012:	ffffe097          	auipc	ra,0xffffe
    80002016:	52a080e7          	jalr	1322(ra) # 8000053c <panic>

000000008000201a <yield>:
{
    8000201a:	1101                	add	sp,sp,-32
    8000201c:	ec06                	sd	ra,24(sp)
    8000201e:	e822                	sd	s0,16(sp)
    80002020:	e426                	sd	s1,8(sp)
    80002022:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    80002024:	00000097          	auipc	ra,0x0
    80002028:	98a080e7          	jalr	-1654(ra) # 800019ae <myproc>
    8000202c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	ba4080e7          	jalr	-1116(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002036:	478d                	li	a5,3
    80002038:	cc9c                	sw	a5,24(s1)
  sched();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	f0a080e7          	jalr	-246(ra) # 80001f44 <sched>
  release(&p->lock);
    80002042:	8526                	mv	a0,s1
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	c42080e7          	jalr	-958(ra) # 80000c86 <release>
}
    8000204c:	60e2                	ld	ra,24(sp)
    8000204e:	6442                	ld	s0,16(sp)
    80002050:	64a2                	ld	s1,8(sp)
    80002052:	6105                	add	sp,sp,32
    80002054:	8082                	ret

0000000080002056 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002056:	7179                	add	sp,sp,-48
    80002058:	f406                	sd	ra,40(sp)
    8000205a:	f022                	sd	s0,32(sp)
    8000205c:	ec26                	sd	s1,24(sp)
    8000205e:	e84a                	sd	s2,16(sp)
    80002060:	e44e                	sd	s3,8(sp)
    80002062:	1800                	add	s0,sp,48
    80002064:	89aa                	mv	s3,a0
    80002066:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	946080e7          	jalr	-1722(ra) # 800019ae <myproc>
    80002070:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	b60080e7          	jalr	-1184(ra) # 80000bd2 <acquire>
  release(lk);
    8000207a:	854a                	mv	a0,s2
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	c0a080e7          	jalr	-1014(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002084:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002088:	4789                	li	a5,2
    8000208a:	cc9c                	sw	a5,24(s1)

  sched();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	eb8080e7          	jalr	-328(ra) # 80001f44 <sched>

  // Tidy up.
  p->chan = 0;
    80002094:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	bec080e7          	jalr	-1044(ra) # 80000c86 <release>
  acquire(lk);
    800020a2:	854a                	mv	a0,s2
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	b2e080e7          	jalr	-1234(ra) # 80000bd2 <acquire>
}
    800020ac:	70a2                	ld	ra,40(sp)
    800020ae:	7402                	ld	s0,32(sp)
    800020b0:	64e2                	ld	s1,24(sp)
    800020b2:	6942                	ld	s2,16(sp)
    800020b4:	69a2                	ld	s3,8(sp)
    800020b6:	6145                	add	sp,sp,48
    800020b8:	8082                	ret

00000000800020ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020ba:	7139                	add	sp,sp,-64
    800020bc:	fc06                	sd	ra,56(sp)
    800020be:	f822                	sd	s0,48(sp)
    800020c0:	f426                	sd	s1,40(sp)
    800020c2:	f04a                	sd	s2,32(sp)
    800020c4:	ec4e                	sd	s3,24(sp)
    800020c6:	e852                	sd	s4,16(sp)
    800020c8:	e456                	sd	s5,8(sp)
    800020ca:	0080                	add	s0,sp,64
    800020cc:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020ce:	0000f497          	auipc	s1,0xf
    800020d2:	fa248493          	add	s1,s1,-94 # 80011070 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020d6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020da:	00015917          	auipc	s2,0x15
    800020de:	99690913          	add	s2,s2,-1642 # 80016a70 <tickslock>
    800020e2:	a811                	j	800020f6 <wakeup+0x3c>
      }
      release(&p->lock);
    800020e4:	8526                	mv	a0,s1
    800020e6:	fffff097          	auipc	ra,0xfffff
    800020ea:	ba0080e7          	jalr	-1120(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ee:	16848493          	add	s1,s1,360
    800020f2:	03248663          	beq	s1,s2,8000211e <wakeup+0x64>
    if(p != myproc()){
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	8b8080e7          	jalr	-1864(ra) # 800019ae <myproc>
    800020fe:	fea488e3          	beq	s1,a0,800020ee <wakeup+0x34>
      acquire(&p->lock);
    80002102:	8526                	mv	a0,s1
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	ace080e7          	jalr	-1330(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000210c:	4c9c                	lw	a5,24(s1)
    8000210e:	fd379be3          	bne	a5,s3,800020e4 <wakeup+0x2a>
    80002112:	709c                	ld	a5,32(s1)
    80002114:	fd4798e3          	bne	a5,s4,800020e4 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002118:	0154ac23          	sw	s5,24(s1)
    8000211c:	b7e1                	j	800020e4 <wakeup+0x2a>
    }
  }
}
    8000211e:	70e2                	ld	ra,56(sp)
    80002120:	7442                	ld	s0,48(sp)
    80002122:	74a2                	ld	s1,40(sp)
    80002124:	7902                	ld	s2,32(sp)
    80002126:	69e2                	ld	s3,24(sp)
    80002128:	6a42                	ld	s4,16(sp)
    8000212a:	6aa2                	ld	s5,8(sp)
    8000212c:	6121                	add	sp,sp,64
    8000212e:	8082                	ret

0000000080002130 <reparent>:
{
    80002130:	7179                	add	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	e052                	sd	s4,0(sp)
    8000213e:	1800                	add	s0,sp,48
    80002140:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	0000f497          	auipc	s1,0xf
    80002146:	f2e48493          	add	s1,s1,-210 # 80011070 <proc>
      pp->parent = initproc;
    8000214a:	00007a17          	auipc	s4,0x7
    8000214e:	87ea0a13          	add	s4,s4,-1922 # 800089c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002152:	00015997          	auipc	s3,0x15
    80002156:	91e98993          	add	s3,s3,-1762 # 80016a70 <tickslock>
    8000215a:	a029                	j	80002164 <reparent+0x34>
    8000215c:	16848493          	add	s1,s1,360
    80002160:	01348d63          	beq	s1,s3,8000217a <reparent+0x4a>
    if(pp->parent == p){
    80002164:	7c9c                	ld	a5,56(s1)
    80002166:	ff279be3          	bne	a5,s2,8000215c <reparent+0x2c>
      pp->parent = initproc;
    8000216a:	000a3503          	ld	a0,0(s4)
    8000216e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002170:	00000097          	auipc	ra,0x0
    80002174:	f4a080e7          	jalr	-182(ra) # 800020ba <wakeup>
    80002178:	b7d5                	j	8000215c <reparent+0x2c>
}
    8000217a:	70a2                	ld	ra,40(sp)
    8000217c:	7402                	ld	s0,32(sp)
    8000217e:	64e2                	ld	s1,24(sp)
    80002180:	6942                	ld	s2,16(sp)
    80002182:	69a2                	ld	s3,8(sp)
    80002184:	6a02                	ld	s4,0(sp)
    80002186:	6145                	add	sp,sp,48
    80002188:	8082                	ret

000000008000218a <exit>:
{
    8000218a:	7179                	add	sp,sp,-48
    8000218c:	f406                	sd	ra,40(sp)
    8000218e:	f022                	sd	s0,32(sp)
    80002190:	ec26                	sd	s1,24(sp)
    80002192:	e84a                	sd	s2,16(sp)
    80002194:	e44e                	sd	s3,8(sp)
    80002196:	e052                	sd	s4,0(sp)
    80002198:	1800                	add	s0,sp,48
    8000219a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000219c:	00000097          	auipc	ra,0x0
    800021a0:	812080e7          	jalr	-2030(ra) # 800019ae <myproc>
    800021a4:	89aa                	mv	s3,a0
  if(p == initproc)
    800021a6:	00007797          	auipc	a5,0x7
    800021aa:	8227b783          	ld	a5,-2014(a5) # 800089c8 <initproc>
    800021ae:	0d050493          	add	s1,a0,208
    800021b2:	15050913          	add	s2,a0,336
    800021b6:	02a79363          	bne	a5,a0,800021dc <exit+0x52>
    panic("init exiting");
    800021ba:	00006517          	auipc	a0,0x6
    800021be:	0a650513          	add	a0,a0,166 # 80008260 <digits+0x220>
    800021c2:	ffffe097          	auipc	ra,0xffffe
    800021c6:	37a080e7          	jalr	890(ra) # 8000053c <panic>
      fileclose(f);
    800021ca:	00002097          	auipc	ra,0x2
    800021ce:	384080e7          	jalr	900(ra) # 8000454e <fileclose>
      p->ofile[fd] = 0;
    800021d2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021d6:	04a1                	add	s1,s1,8
    800021d8:	01248563          	beq	s1,s2,800021e2 <exit+0x58>
    if(p->ofile[fd]){
    800021dc:	6088                	ld	a0,0(s1)
    800021de:	f575                	bnez	a0,800021ca <exit+0x40>
    800021e0:	bfdd                	j	800021d6 <exit+0x4c>
  begin_op();
    800021e2:	00002097          	auipc	ra,0x2
    800021e6:	ea8080e7          	jalr	-344(ra) # 8000408a <begin_op>
  iput(p->cwd);
    800021ea:	1509b503          	ld	a0,336(s3)
    800021ee:	00001097          	auipc	ra,0x1
    800021f2:	6b0080e7          	jalr	1712(ra) # 8000389e <iput>
  end_op();
    800021f6:	00002097          	auipc	ra,0x2
    800021fa:	f0e080e7          	jalr	-242(ra) # 80004104 <end_op>
  p->cwd = 0;
    800021fe:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002202:	0000f497          	auipc	s1,0xf
    80002206:	a5648493          	add	s1,s1,-1450 # 80010c58 <wait_lock>
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	9c6080e7          	jalr	-1594(ra) # 80000bd2 <acquire>
  reparent(p);
    80002214:	854e                	mv	a0,s3
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	f1a080e7          	jalr	-230(ra) # 80002130 <reparent>
  wakeup(p->parent);
    8000221e:	0389b503          	ld	a0,56(s3)
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e98080e7          	jalr	-360(ra) # 800020ba <wakeup>
  acquire(&p->lock);
    8000222a:	854e                	mv	a0,s3
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	9a6080e7          	jalr	-1626(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002234:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002238:	4795                	li	a5,5
    8000223a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000223e:	8526                	mv	a0,s1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	a46080e7          	jalr	-1466(ra) # 80000c86 <release>
  sched();
    80002248:	00000097          	auipc	ra,0x0
    8000224c:	cfc080e7          	jalr	-772(ra) # 80001f44 <sched>
  panic("zombie exit");
    80002250:	00006517          	auipc	a0,0x6
    80002254:	02050513          	add	a0,a0,32 # 80008270 <digits+0x230>
    80002258:	ffffe097          	auipc	ra,0xffffe
    8000225c:	2e4080e7          	jalr	740(ra) # 8000053c <panic>

0000000080002260 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002260:	7179                	add	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	1800                	add	s0,sp,48
    8000226e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002270:	0000f497          	auipc	s1,0xf
    80002274:	e0048493          	add	s1,s1,-512 # 80011070 <proc>
    80002278:	00014997          	auipc	s3,0x14
    8000227c:	7f898993          	add	s3,s3,2040 # 80016a70 <tickslock>
    acquire(&p->lock);
    80002280:	8526                	mv	a0,s1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	950080e7          	jalr	-1712(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000228a:	589c                	lw	a5,48(s1)
    8000228c:	01278d63          	beq	a5,s2,800022a6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	9f4080e7          	jalr	-1548(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000229a:	16848493          	add	s1,s1,360
    8000229e:	ff3491e3          	bne	s1,s3,80002280 <kill+0x20>
  }
  return -1;
    800022a2:	557d                	li	a0,-1
    800022a4:	a829                	j	800022be <kill+0x5e>
      p->killed = 1;
    800022a6:	4785                	li	a5,1
    800022a8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022aa:	4c98                	lw	a4,24(s1)
    800022ac:	4789                	li	a5,2
    800022ae:	00f70f63          	beq	a4,a5,800022cc <kill+0x6c>
      release(&p->lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	9d2080e7          	jalr	-1582(ra) # 80000c86 <release>
      return 0;
    800022bc:	4501                	li	a0,0
}
    800022be:	70a2                	ld	ra,40(sp)
    800022c0:	7402                	ld	s0,32(sp)
    800022c2:	64e2                	ld	s1,24(sp)
    800022c4:	6942                	ld	s2,16(sp)
    800022c6:	69a2                	ld	s3,8(sp)
    800022c8:	6145                	add	sp,sp,48
    800022ca:	8082                	ret
        p->state = RUNNABLE;
    800022cc:	478d                	li	a5,3
    800022ce:	cc9c                	sw	a5,24(s1)
    800022d0:	b7cd                	j	800022b2 <kill+0x52>

00000000800022d2 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d2:	1101                	add	sp,sp,-32
    800022d4:	ec06                	sd	ra,24(sp)
    800022d6:	e822                	sd	s0,16(sp)
    800022d8:	e426                	sd	s1,8(sp)
    800022da:	1000                	add	s0,sp,32
    800022dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	8f4080e7          	jalr	-1804(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022e6:	4785                	li	a5,1
    800022e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	99a080e7          	jalr	-1638(ra) # 80000c86 <release>
}
    800022f4:	60e2                	ld	ra,24(sp)
    800022f6:	6442                	ld	s0,16(sp)
    800022f8:	64a2                	ld	s1,8(sp)
    800022fa:	6105                	add	sp,sp,32
    800022fc:	8082                	ret

00000000800022fe <killed>:

int
killed(struct proc *p)
{
    800022fe:	1101                	add	sp,sp,-32
    80002300:	ec06                	sd	ra,24(sp)
    80002302:	e822                	sd	s0,16(sp)
    80002304:	e426                	sd	s1,8(sp)
    80002306:	e04a                	sd	s2,0(sp)
    80002308:	1000                	add	s0,sp,32
    8000230a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	8c6080e7          	jalr	-1850(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002314:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	96c080e7          	jalr	-1684(ra) # 80000c86 <release>
  return k;
}
    80002322:	854a                	mv	a0,s2
    80002324:	60e2                	ld	ra,24(sp)
    80002326:	6442                	ld	s0,16(sp)
    80002328:	64a2                	ld	s1,8(sp)
    8000232a:	6902                	ld	s2,0(sp)
    8000232c:	6105                	add	sp,sp,32
    8000232e:	8082                	ret

0000000080002330 <wait>:
{
    80002330:	715d                	add	sp,sp,-80
    80002332:	e486                	sd	ra,72(sp)
    80002334:	e0a2                	sd	s0,64(sp)
    80002336:	fc26                	sd	s1,56(sp)
    80002338:	f84a                	sd	s2,48(sp)
    8000233a:	f44e                	sd	s3,40(sp)
    8000233c:	f052                	sd	s4,32(sp)
    8000233e:	ec56                	sd	s5,24(sp)
    80002340:	e85a                	sd	s6,16(sp)
    80002342:	e45e                	sd	s7,8(sp)
    80002344:	e062                	sd	s8,0(sp)
    80002346:	0880                	add	s0,sp,80
    80002348:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	664080e7          	jalr	1636(ra) # 800019ae <myproc>
    80002352:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002354:	0000f517          	auipc	a0,0xf
    80002358:	90450513          	add	a0,a0,-1788 # 80010c58 <wait_lock>
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	876080e7          	jalr	-1930(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002364:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002366:	4a15                	li	s4,5
        havekids = 1;
    80002368:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000236a:	00014997          	auipc	s3,0x14
    8000236e:	70698993          	add	s3,s3,1798 # 80016a70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002372:	0000fc17          	auipc	s8,0xf
    80002376:	8e6c0c13          	add	s8,s8,-1818 # 80010c58 <wait_lock>
    8000237a:	a0d1                	j	8000243e <wait+0x10e>
          pid = pp->pid;
    8000237c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002380:	000b0e63          	beqz	s6,8000239c <wait+0x6c>
    80002384:	4691                	li	a3,4
    80002386:	02c48613          	add	a2,s1,44
    8000238a:	85da                	mv	a1,s6
    8000238c:	05093503          	ld	a0,80(s2)
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	2de080e7          	jalr	734(ra) # 8000166e <copyout>
    80002398:	04054163          	bltz	a0,800023da <wait+0xaa>
          freeproc(pp);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	7c2080e7          	jalr	1986(ra) # 80001b60 <freeproc>
          release(&pp->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8de080e7          	jalr	-1826(ra) # 80000c86 <release>
          release(&wait_lock);
    800023b0:	0000f517          	auipc	a0,0xf
    800023b4:	8a850513          	add	a0,a0,-1880 # 80010c58 <wait_lock>
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8ce080e7          	jalr	-1842(ra) # 80000c86 <release>
}
    800023c0:	854e                	mv	a0,s3
    800023c2:	60a6                	ld	ra,72(sp)
    800023c4:	6406                	ld	s0,64(sp)
    800023c6:	74e2                	ld	s1,56(sp)
    800023c8:	7942                	ld	s2,48(sp)
    800023ca:	79a2                	ld	s3,40(sp)
    800023cc:	7a02                	ld	s4,32(sp)
    800023ce:	6ae2                	ld	s5,24(sp)
    800023d0:	6b42                	ld	s6,16(sp)
    800023d2:	6ba2                	ld	s7,8(sp)
    800023d4:	6c02                	ld	s8,0(sp)
    800023d6:	6161                	add	sp,sp,80
    800023d8:	8082                	ret
            release(&pp->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8aa080e7          	jalr	-1878(ra) # 80000c86 <release>
            release(&wait_lock);
    800023e4:	0000f517          	auipc	a0,0xf
    800023e8:	87450513          	add	a0,a0,-1932 # 80010c58 <wait_lock>
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89a080e7          	jalr	-1894(ra) # 80000c86 <release>
            return -1;
    800023f4:	59fd                	li	s3,-1
    800023f6:	b7e9                	j	800023c0 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f8:	16848493          	add	s1,s1,360
    800023fc:	03348463          	beq	s1,s3,80002424 <wait+0xf4>
      if(pp->parent == p){
    80002400:	7c9c                	ld	a5,56(s1)
    80002402:	ff279be3          	bne	a5,s2,800023f8 <wait+0xc8>
        acquire(&pp->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	ffffe097          	auipc	ra,0xffffe
    8000240c:	7ca080e7          	jalr	1994(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002410:	4c9c                	lw	a5,24(s1)
    80002412:	f74785e3          	beq	a5,s4,8000237c <wait+0x4c>
        release(&pp->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	86e080e7          	jalr	-1938(ra) # 80000c86 <release>
        havekids = 1;
    80002420:	8756                	mv	a4,s5
    80002422:	bfd9                	j	800023f8 <wait+0xc8>
    if(!havekids || killed(p)){
    80002424:	c31d                	beqz	a4,8000244a <wait+0x11a>
    80002426:	854a                	mv	a0,s2
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	ed6080e7          	jalr	-298(ra) # 800022fe <killed>
    80002430:	ed09                	bnez	a0,8000244a <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002432:	85e2                	mv	a1,s8
    80002434:	854a                	mv	a0,s2
    80002436:	00000097          	auipc	ra,0x0
    8000243a:	c20080e7          	jalr	-992(ra) # 80002056 <sleep>
    havekids = 0;
    8000243e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002440:	0000f497          	auipc	s1,0xf
    80002444:	c3048493          	add	s1,s1,-976 # 80011070 <proc>
    80002448:	bf65                	j	80002400 <wait+0xd0>
      release(&wait_lock);
    8000244a:	0000f517          	auipc	a0,0xf
    8000244e:	80e50513          	add	a0,a0,-2034 # 80010c58 <wait_lock>
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	834080e7          	jalr	-1996(ra) # 80000c86 <release>
      return -1;
    8000245a:	59fd                	li	s3,-1
    8000245c:	b795                	j	800023c0 <wait+0x90>

000000008000245e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000245e:	7179                	add	sp,sp,-48
    80002460:	f406                	sd	ra,40(sp)
    80002462:	f022                	sd	s0,32(sp)
    80002464:	ec26                	sd	s1,24(sp)
    80002466:	e84a                	sd	s2,16(sp)
    80002468:	e44e                	sd	s3,8(sp)
    8000246a:	e052                	sd	s4,0(sp)
    8000246c:	1800                	add	s0,sp,48
    8000246e:	84aa                	mv	s1,a0
    80002470:	892e                	mv	s2,a1
    80002472:	89b2                	mv	s3,a2
    80002474:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	538080e7          	jalr	1336(ra) # 800019ae <myproc>
  if(user_dst){
    8000247e:	c08d                	beqz	s1,800024a0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002480:	86d2                	mv	a3,s4
    80002482:	864e                	mv	a2,s3
    80002484:	85ca                	mv	a1,s2
    80002486:	6928                	ld	a0,80(a0)
    80002488:	fffff097          	auipc	ra,0xfffff
    8000248c:	1e6080e7          	jalr	486(ra) # 8000166e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002490:	70a2                	ld	ra,40(sp)
    80002492:	7402                	ld	s0,32(sp)
    80002494:	64e2                	ld	s1,24(sp)
    80002496:	6942                	ld	s2,16(sp)
    80002498:	69a2                	ld	s3,8(sp)
    8000249a:	6a02                	ld	s4,0(sp)
    8000249c:	6145                	add	sp,sp,48
    8000249e:	8082                	ret
    memmove((char *)dst, src, len);
    800024a0:	000a061b          	sext.w	a2,s4
    800024a4:	85ce                	mv	a1,s3
    800024a6:	854a                	mv	a0,s2
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	882080e7          	jalr	-1918(ra) # 80000d2a <memmove>
    return 0;
    800024b0:	8526                	mv	a0,s1
    800024b2:	bff9                	j	80002490 <either_copyout+0x32>

00000000800024b4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b4:	7179                	add	sp,sp,-48
    800024b6:	f406                	sd	ra,40(sp)
    800024b8:	f022                	sd	s0,32(sp)
    800024ba:	ec26                	sd	s1,24(sp)
    800024bc:	e84a                	sd	s2,16(sp)
    800024be:	e44e                	sd	s3,8(sp)
    800024c0:	e052                	sd	s4,0(sp)
    800024c2:	1800                	add	s0,sp,48
    800024c4:	892a                	mv	s2,a0
    800024c6:	84ae                	mv	s1,a1
    800024c8:	89b2                	mv	s3,a2
    800024ca:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	4e2080e7          	jalr	1250(ra) # 800019ae <myproc>
  if(user_src){
    800024d4:	c08d                	beqz	s1,800024f6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024d6:	86d2                	mv	a3,s4
    800024d8:	864e                	mv	a2,s3
    800024da:	85ca                	mv	a1,s2
    800024dc:	6928                	ld	a0,80(a0)
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	21c080e7          	jalr	540(ra) # 800016fa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024e6:	70a2                	ld	ra,40(sp)
    800024e8:	7402                	ld	s0,32(sp)
    800024ea:	64e2                	ld	s1,24(sp)
    800024ec:	6942                	ld	s2,16(sp)
    800024ee:	69a2                	ld	s3,8(sp)
    800024f0:	6a02                	ld	s4,0(sp)
    800024f2:	6145                	add	sp,sp,48
    800024f4:	8082                	ret
    memmove(dst, (char*)src, len);
    800024f6:	000a061b          	sext.w	a2,s4
    800024fa:	85ce                	mv	a1,s3
    800024fc:	854a                	mv	a0,s2
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	82c080e7          	jalr	-2004(ra) # 80000d2a <memmove>
    return 0;
    80002506:	8526                	mv	a0,s1
    80002508:	bff9                	j	800024e6 <either_copyin+0x32>

000000008000250a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250a:	715d                	add	sp,sp,-80
    8000250c:	e486                	sd	ra,72(sp)
    8000250e:	e0a2                	sd	s0,64(sp)
    80002510:	fc26                	sd	s1,56(sp)
    80002512:	f84a                	sd	s2,48(sp)
    80002514:	f44e                	sd	s3,40(sp)
    80002516:	f052                	sd	s4,32(sp)
    80002518:	ec56                	sd	s5,24(sp)
    8000251a:	e85a                	sd	s6,16(sp)
    8000251c:	e45e                	sd	s7,8(sp)
    8000251e:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002520:	00006517          	auipc	a0,0x6
    80002524:	ba850513          	add	a0,a0,-1112 # 800080c8 <digits+0x88>
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	05e080e7          	jalr	94(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002530:	0000f497          	auipc	s1,0xf
    80002534:	c9848493          	add	s1,s1,-872 # 800111c8 <proc+0x158>
    80002538:	00014917          	auipc	s2,0x14
    8000253c:	69090913          	add	s2,s2,1680 # 80016bc8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002540:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002542:	00006997          	auipc	s3,0x6
    80002546:	d3e98993          	add	s3,s3,-706 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000254a:	00006a97          	auipc	s5,0x6
    8000254e:	d3ea8a93          	add	s5,s5,-706 # 80008288 <digits+0x248>
    printf("\n");
    80002552:	00006a17          	auipc	s4,0x6
    80002556:	b76a0a13          	add	s4,s4,-1162 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255a:	00006b97          	auipc	s7,0x6
    8000255e:	d6eb8b93          	add	s7,s7,-658 # 800082c8 <states.0>
    80002562:	a00d                	j	80002584 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002564:	ed86a583          	lw	a1,-296(a3)
    80002568:	8556                	mv	a0,s5
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	01c080e7          	jalr	28(ra) # 80000586 <printf>
    printf("\n");
    80002572:	8552                	mv	a0,s4
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	012080e7          	jalr	18(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257c:	16848493          	add	s1,s1,360
    80002580:	03248263          	beq	s1,s2,800025a4 <procdump+0x9a>
    if(p->state == UNUSED)
    80002584:	86a6                	mv	a3,s1
    80002586:	ec04a783          	lw	a5,-320(s1)
    8000258a:	dbed                	beqz	a5,8000257c <procdump+0x72>
      state = "???";
    8000258c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258e:	fcfb6be3          	bltu	s6,a5,80002564 <procdump+0x5a>
    80002592:	02079713          	sll	a4,a5,0x20
    80002596:	01d75793          	srl	a5,a4,0x1d
    8000259a:	97de                	add	a5,a5,s7
    8000259c:	6390                	ld	a2,0(a5)
    8000259e:	f279                	bnez	a2,80002564 <procdump+0x5a>
      state = "???";
    800025a0:	864e                	mv	a2,s3
    800025a2:	b7c9                	j	80002564 <procdump+0x5a>
  }
}
    800025a4:	60a6                	ld	ra,72(sp)
    800025a6:	6406                	ld	s0,64(sp)
    800025a8:	74e2                	ld	s1,56(sp)
    800025aa:	7942                	ld	s2,48(sp)
    800025ac:	79a2                	ld	s3,40(sp)
    800025ae:	7a02                	ld	s4,32(sp)
    800025b0:	6ae2                	ld	s5,24(sp)
    800025b2:	6b42                	ld	s6,16(sp)
    800025b4:	6ba2                	ld	s7,8(sp)
    800025b6:	6161                	add	sp,sp,80
    800025b8:	8082                	ret

00000000800025ba <swtch>:
    800025ba:	00153023          	sd	ra,0(a0)
    800025be:	00253423          	sd	sp,8(a0)
    800025c2:	e900                	sd	s0,16(a0)
    800025c4:	ed04                	sd	s1,24(a0)
    800025c6:	03253023          	sd	s2,32(a0)
    800025ca:	03353423          	sd	s3,40(a0)
    800025ce:	03453823          	sd	s4,48(a0)
    800025d2:	03553c23          	sd	s5,56(a0)
    800025d6:	05653023          	sd	s6,64(a0)
    800025da:	05753423          	sd	s7,72(a0)
    800025de:	05853823          	sd	s8,80(a0)
    800025e2:	05953c23          	sd	s9,88(a0)
    800025e6:	07a53023          	sd	s10,96(a0)
    800025ea:	07b53423          	sd	s11,104(a0)
    800025ee:	0005b083          	ld	ra,0(a1)
    800025f2:	0085b103          	ld	sp,8(a1)
    800025f6:	6980                	ld	s0,16(a1)
    800025f8:	6d84                	ld	s1,24(a1)
    800025fa:	0205b903          	ld	s2,32(a1)
    800025fe:	0285b983          	ld	s3,40(a1)
    80002602:	0305ba03          	ld	s4,48(a1)
    80002606:	0385ba83          	ld	s5,56(a1)
    8000260a:	0405bb03          	ld	s6,64(a1)
    8000260e:	0485bb83          	ld	s7,72(a1)
    80002612:	0505bc03          	ld	s8,80(a1)
    80002616:	0585bc83          	ld	s9,88(a1)
    8000261a:	0605bd03          	ld	s10,96(a1)
    8000261e:	0685bd83          	ld	s11,104(a1)
    80002622:	8082                	ret

0000000080002624 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002624:	1141                	add	sp,sp,-16
    80002626:	e406                	sd	ra,8(sp)
    80002628:	e022                	sd	s0,0(sp)
    8000262a:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000262c:	00006597          	auipc	a1,0x6
    80002630:	ccc58593          	add	a1,a1,-820 # 800082f8 <states.0+0x30>
    80002634:	00014517          	auipc	a0,0x14
    80002638:	43c50513          	add	a0,a0,1084 # 80016a70 <tickslock>
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	506080e7          	jalr	1286(ra) # 80000b42 <initlock>
}
    80002644:	60a2                	ld	ra,8(sp)
    80002646:	6402                	ld	s0,0(sp)
    80002648:	0141                	add	sp,sp,16
    8000264a:	8082                	ret

000000008000264c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000264c:	1141                	add	sp,sp,-16
    8000264e:	e422                	sd	s0,8(sp)
    80002650:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002652:	00003797          	auipc	a5,0x3
    80002656:	51e78793          	add	a5,a5,1310 # 80005b70 <kernelvec>
    8000265a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000265e:	6422                	ld	s0,8(sp)
    80002660:	0141                	add	sp,sp,16
    80002662:	8082                	ret

0000000080002664 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002664:	1141                	add	sp,sp,-16
    80002666:	e406                	sd	ra,8(sp)
    80002668:	e022                	sd	s0,0(sp)
    8000266a:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    8000266c:	fffff097          	auipc	ra,0xfffff
    80002670:	342080e7          	jalr	834(ra) # 800019ae <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002674:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002678:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000267e:	00005697          	auipc	a3,0x5
    80002682:	98268693          	add	a3,a3,-1662 # 80007000 <_trampoline>
    80002686:	00005717          	auipc	a4,0x5
    8000268a:	97a70713          	add	a4,a4,-1670 # 80007000 <_trampoline>
    8000268e:	8f15                	sub	a4,a4,a3
    80002690:	040007b7          	lui	a5,0x4000
    80002694:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002696:	07b2                	sll	a5,a5,0xc
    80002698:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000269e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a0:	18002673          	csrr	a2,satp
    800026a4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026a6:	6d30                	ld	a2,88(a0)
    800026a8:	6138                	ld	a4,64(a0)
    800026aa:	6585                	lui	a1,0x1
    800026ac:	972e                	add	a4,a4,a1
    800026ae:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b0:	6d38                	ld	a4,88(a0)
    800026b2:	00000617          	auipc	a2,0x0
    800026b6:	13460613          	add	a2,a2,308 # 800027e6 <usertrap>
    800026ba:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026bc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026be:	8612                	mv	a2,tp
    800026c0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026c6:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ca:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ce:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d2:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d4:	6f18                	ld	a4,24(a4)
    800026d6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026da:	6928                	ld	a0,80(a0)
    800026dc:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026de:	00005717          	auipc	a4,0x5
    800026e2:	9be70713          	add	a4,a4,-1602 # 8000709c <userret>
    800026e6:	8f15                	sub	a4,a4,a3
    800026e8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026ea:	577d                	li	a4,-1
    800026ec:	177e                	sll	a4,a4,0x3f
    800026ee:	8d59                	or	a0,a0,a4
    800026f0:	9782                	jalr	a5
}
    800026f2:	60a2                	ld	ra,8(sp)
    800026f4:	6402                	ld	s0,0(sp)
    800026f6:	0141                	add	sp,sp,16
    800026f8:	8082                	ret

00000000800026fa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026fa:	1101                	add	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	e426                	sd	s1,8(sp)
    80002702:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002704:	00014497          	auipc	s1,0x14
    80002708:	36c48493          	add	s1,s1,876 # 80016a70 <tickslock>
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	4c4080e7          	jalr	1220(ra) # 80000bd2 <acquire>
  ticks++;
    80002716:	00006517          	auipc	a0,0x6
    8000271a:	2ba50513          	add	a0,a0,698 # 800089d0 <ticks>
    8000271e:	411c                	lw	a5,0(a0)
    80002720:	2785                	addw	a5,a5,1
    80002722:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002724:	00000097          	auipc	ra,0x0
    80002728:	996080e7          	jalr	-1642(ra) # 800020ba <wakeup>
  release(&tickslock);
    8000272c:	8526                	mv	a0,s1
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	558080e7          	jalr	1368(ra) # 80000c86 <release>
}
    80002736:	60e2                	ld	ra,24(sp)
    80002738:	6442                	ld	s0,16(sp)
    8000273a:	64a2                	ld	s1,8(sp)
    8000273c:	6105                	add	sp,sp,32
    8000273e:	8082                	ret

0000000080002740 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002740:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002744:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002746:	0807df63          	bgez	a5,800027e4 <devintr+0xa4>
{
    8000274a:	1101                	add	sp,sp,-32
    8000274c:	ec06                	sd	ra,24(sp)
    8000274e:	e822                	sd	s0,16(sp)
    80002750:	e426                	sd	s1,8(sp)
    80002752:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002754:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002758:	46a5                	li	a3,9
    8000275a:	00d70d63          	beq	a4,a3,80002774 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    8000275e:	577d                	li	a4,-1
    80002760:	177e                	sll	a4,a4,0x3f
    80002762:	0705                	add	a4,a4,1
    return 0;
    80002764:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002766:	04e78e63          	beq	a5,a4,800027c2 <devintr+0x82>
  }
}
    8000276a:	60e2                	ld	ra,24(sp)
    8000276c:	6442                	ld	s0,16(sp)
    8000276e:	64a2                	ld	s1,8(sp)
    80002770:	6105                	add	sp,sp,32
    80002772:	8082                	ret
    int irq = plic_claim();
    80002774:	00003097          	auipc	ra,0x3
    80002778:	504080e7          	jalr	1284(ra) # 80005c78 <plic_claim>
    8000277c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000277e:	47a9                	li	a5,10
    80002780:	02f50763          	beq	a0,a5,800027ae <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002784:	4785                	li	a5,1
    80002786:	02f50963          	beq	a0,a5,800027b8 <devintr+0x78>
    return 1;
    8000278a:	4505                	li	a0,1
    } else if(irq){
    8000278c:	dcf9                	beqz	s1,8000276a <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    8000278e:	85a6                	mv	a1,s1
    80002790:	00006517          	auipc	a0,0x6
    80002794:	b7050513          	add	a0,a0,-1168 # 80008300 <states.0+0x38>
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	dee080e7          	jalr	-530(ra) # 80000586 <printf>
      plic_complete(irq);
    800027a0:	8526                	mv	a0,s1
    800027a2:	00003097          	auipc	ra,0x3
    800027a6:	4fa080e7          	jalr	1274(ra) # 80005c9c <plic_complete>
    return 1;
    800027aa:	4505                	li	a0,1
    800027ac:	bf7d                	j	8000276a <devintr+0x2a>
      uartintr();
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	1e6080e7          	jalr	486(ra) # 80000994 <uartintr>
    if(irq)
    800027b6:	b7ed                	j	800027a0 <devintr+0x60>
      virtio_disk_intr();
    800027b8:	00004097          	auipc	ra,0x4
    800027bc:	9aa080e7          	jalr	-1622(ra) # 80006162 <virtio_disk_intr>
    if(irq)
    800027c0:	b7c5                	j	800027a0 <devintr+0x60>
    if(cpuid() == 0){
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	1c0080e7          	jalr	448(ra) # 80001982 <cpuid>
    800027ca:	c901                	beqz	a0,800027da <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027cc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d0:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d2:	14479073          	csrw	sip,a5
    return 2;
    800027d6:	4509                	li	a0,2
    800027d8:	bf49                	j	8000276a <devintr+0x2a>
      clockintr();
    800027da:	00000097          	auipc	ra,0x0
    800027de:	f20080e7          	jalr	-224(ra) # 800026fa <clockintr>
    800027e2:	b7ed                	j	800027cc <devintr+0x8c>
}
    800027e4:	8082                	ret

00000000800027e6 <usertrap>:
{
    800027e6:	1101                	add	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	e04a                	sd	s2,0(sp)
    800027f0:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f6:	1007f793          	and	a5,a5,256
    800027fa:	e3b1                	bnez	a5,8000283e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027fc:	00003797          	auipc	a5,0x3
    80002800:	37478793          	add	a5,a5,884 # 80005b70 <kernelvec>
    80002804:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002808:	fffff097          	auipc	ra,0xfffff
    8000280c:	1a6080e7          	jalr	422(ra) # 800019ae <myproc>
    80002810:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002812:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002814:	14102773          	csrr	a4,sepc
    80002818:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000281e:	47a1                	li	a5,8
    80002820:	02f70763          	beq	a4,a5,8000284e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002824:	00000097          	auipc	ra,0x0
    80002828:	f1c080e7          	jalr	-228(ra) # 80002740 <devintr>
    8000282c:	892a                	mv	s2,a0
    8000282e:	c151                	beqz	a0,800028b2 <usertrap+0xcc>
  if(killed(p))
    80002830:	8526                	mv	a0,s1
    80002832:	00000097          	auipc	ra,0x0
    80002836:	acc080e7          	jalr	-1332(ra) # 800022fe <killed>
    8000283a:	c929                	beqz	a0,8000288c <usertrap+0xa6>
    8000283c:	a099                	j	80002882 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    8000283e:	00006517          	auipc	a0,0x6
    80002842:	ae250513          	add	a0,a0,-1310 # 80008320 <states.0+0x58>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	cf6080e7          	jalr	-778(ra) # 8000053c <panic>
    if(killed(p))
    8000284e:	00000097          	auipc	ra,0x0
    80002852:	ab0080e7          	jalr	-1360(ra) # 800022fe <killed>
    80002856:	e921                	bnez	a0,800028a6 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002858:	6cb8                	ld	a4,88(s1)
    8000285a:	6f1c                	ld	a5,24(a4)
    8000285c:	0791                	add	a5,a5,4
    8000285e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002864:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
    syscall();
    8000286c:	00000097          	auipc	ra,0x0
    80002870:	2d4080e7          	jalr	724(ra) # 80002b40 <syscall>
  if(killed(p))
    80002874:	8526                	mv	a0,s1
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	a88080e7          	jalr	-1400(ra) # 800022fe <killed>
    8000287e:	c911                	beqz	a0,80002892 <usertrap+0xac>
    80002880:	4901                	li	s2,0
    exit(-1);
    80002882:	557d                	li	a0,-1
    80002884:	00000097          	auipc	ra,0x0
    80002888:	906080e7          	jalr	-1786(ra) # 8000218a <exit>
  if(which_dev == 2)
    8000288c:	4789                	li	a5,2
    8000288e:	04f90f63          	beq	s2,a5,800028ec <usertrap+0x106>
  usertrapret();
    80002892:	00000097          	auipc	ra,0x0
    80002896:	dd2080e7          	jalr	-558(ra) # 80002664 <usertrapret>
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6902                	ld	s2,0(sp)
    800028a2:	6105                	add	sp,sp,32
    800028a4:	8082                	ret
      exit(-1);
    800028a6:	557d                	li	a0,-1
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	8e2080e7          	jalr	-1822(ra) # 8000218a <exit>
    800028b0:	b765                	j	80002858 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b6:	5890                	lw	a2,48(s1)
    800028b8:	00006517          	auipc	a0,0x6
    800028bc:	a8850513          	add	a0,a0,-1400 # 80008340 <states.0+0x78>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	cc6080e7          	jalr	-826(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028cc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	aa050513          	add	a0,a0,-1376 # 80008370 <states.0+0xa8>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	cae080e7          	jalr	-850(ra) # 80000586 <printf>
    setkilled(p);
    800028e0:	8526                	mv	a0,s1
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	9f0080e7          	jalr	-1552(ra) # 800022d2 <setkilled>
    800028ea:	b769                	j	80002874 <usertrap+0x8e>
    yield();
    800028ec:	fffff097          	auipc	ra,0xfffff
    800028f0:	72e080e7          	jalr	1838(ra) # 8000201a <yield>
    800028f4:	bf79                	j	80002892 <usertrap+0xac>

00000000800028f6 <kerneltrap>:
{
    800028f6:	7179                	add	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002904:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002908:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002910:	1004f793          	and	a5,s1,256
    80002914:	cb85                	beqz	a5,80002944 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002916:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291a:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    8000291c:	ef85                	bnez	a5,80002954 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	e22080e7          	jalr	-478(ra) # 80002740 <devintr>
    80002926:	cd1d                	beqz	a0,80002964 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002928:	4789                	li	a5,2
    8000292a:	06f50a63          	beq	a0,a5,8000299e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000292e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002932:	10049073          	csrw	sstatus,s1
}
    80002936:	70a2                	ld	ra,40(sp)
    80002938:	7402                	ld	s0,32(sp)
    8000293a:	64e2                	ld	s1,24(sp)
    8000293c:	6942                	ld	s2,16(sp)
    8000293e:	69a2                	ld	s3,8(sp)
    80002940:	6145                	add	sp,sp,48
    80002942:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002944:	00006517          	auipc	a0,0x6
    80002948:	a4c50513          	add	a0,a0,-1460 # 80008390 <states.0+0xc8>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	bf0080e7          	jalr	-1040(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002954:	00006517          	auipc	a0,0x6
    80002958:	a6450513          	add	a0,a0,-1436 # 800083b8 <states.0+0xf0>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	be0080e7          	jalr	-1056(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002964:	85ce                	mv	a1,s3
    80002966:	00006517          	auipc	a0,0x6
    8000296a:	a7250513          	add	a0,a0,-1422 # 800083d8 <states.0+0x110>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	c18080e7          	jalr	-1000(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000297e:	00006517          	auipc	a0,0x6
    80002982:	a6a50513          	add	a0,a0,-1430 # 800083e8 <states.0+0x120>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	c00080e7          	jalr	-1024(ra) # 80000586 <printf>
    panic("kerneltrap");
    8000298e:	00006517          	auipc	a0,0x6
    80002992:	a7250513          	add	a0,a0,-1422 # 80008400 <states.0+0x138>
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	ba6080e7          	jalr	-1114(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000299e:	fffff097          	auipc	ra,0xfffff
    800029a2:	010080e7          	jalr	16(ra) # 800019ae <myproc>
    800029a6:	d541                	beqz	a0,8000292e <kerneltrap+0x38>
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	006080e7          	jalr	6(ra) # 800019ae <myproc>
    800029b0:	4d18                	lw	a4,24(a0)
    800029b2:	4791                	li	a5,4
    800029b4:	f6f71de3          	bne	a4,a5,8000292e <kerneltrap+0x38>
    yield();
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	662080e7          	jalr	1634(ra) # 8000201a <yield>
    800029c0:	b7bd                	j	8000292e <kerneltrap+0x38>

00000000800029c2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c2:	1101                	add	sp,sp,-32
    800029c4:	ec06                	sd	ra,24(sp)
    800029c6:	e822                	sd	s0,16(sp)
    800029c8:	e426                	sd	s1,8(sp)
    800029ca:	1000                	add	s0,sp,32
    800029cc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	fe0080e7          	jalr	-32(ra) # 800019ae <myproc>
  switch (n) {
    800029d6:	4795                	li	a5,5
    800029d8:	0497e163          	bltu	a5,s1,80002a1a <argraw+0x58>
    800029dc:	048a                	sll	s1,s1,0x2
    800029de:	00006717          	auipc	a4,0x6
    800029e2:	a5a70713          	add	a4,a4,-1446 # 80008438 <states.0+0x170>
    800029e6:	94ba                	add	s1,s1,a4
    800029e8:	409c                	lw	a5,0(s1)
    800029ea:	97ba                	add	a5,a5,a4
    800029ec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029ee:	6d3c                	ld	a5,88(a0)
    800029f0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f2:	60e2                	ld	ra,24(sp)
    800029f4:	6442                	ld	s0,16(sp)
    800029f6:	64a2                	ld	s1,8(sp)
    800029f8:	6105                	add	sp,sp,32
    800029fa:	8082                	ret
    return p->trapframe->a1;
    800029fc:	6d3c                	ld	a5,88(a0)
    800029fe:	7fa8                	ld	a0,120(a5)
    80002a00:	bfcd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a2;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	63c8                	ld	a0,128(a5)
    80002a06:	b7f5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a3;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	67c8                	ld	a0,136(a5)
    80002a0c:	b7dd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a4;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	6bc8                	ld	a0,144(a5)
    80002a12:	b7c5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a5;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	6fc8                	ld	a0,152(a5)
    80002a18:	bfe9                	j	800029f2 <argraw+0x30>
  panic("argraw");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	9f650513          	add	a0,a0,-1546 # 80008410 <states.0+0x148>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	b1a080e7          	jalr	-1254(ra) # 8000053c <panic>

0000000080002a2a <fetchaddr>:
{
    80002a2a:	1101                	add	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	e04a                	sd	s2,0(sp)
    80002a34:	1000                	add	s0,sp,32
    80002a36:	84aa                	mv	s1,a0
    80002a38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a3a:	fffff097          	auipc	ra,0xfffff
    80002a3e:	f74080e7          	jalr	-140(ra) # 800019ae <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a42:	653c                	ld	a5,72(a0)
    80002a44:	02f4f863          	bgeu	s1,a5,80002a74 <fetchaddr+0x4a>
    80002a48:	00848713          	add	a4,s1,8
    80002a4c:	02e7e663          	bltu	a5,a4,80002a78 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a50:	46a1                	li	a3,8
    80002a52:	8626                	mv	a2,s1
    80002a54:	85ca                	mv	a1,s2
    80002a56:	6928                	ld	a0,80(a0)
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	ca2080e7          	jalr	-862(ra) # 800016fa <copyin>
    80002a60:	00a03533          	snez	a0,a0
    80002a64:	40a00533          	neg	a0,a0
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6902                	ld	s2,0(sp)
    80002a70:	6105                	add	sp,sp,32
    80002a72:	8082                	ret
    return -1;
    80002a74:	557d                	li	a0,-1
    80002a76:	bfcd                	j	80002a68 <fetchaddr+0x3e>
    80002a78:	557d                	li	a0,-1
    80002a7a:	b7fd                	j	80002a68 <fetchaddr+0x3e>

0000000080002a7c <fetchstr>:
{
    80002a7c:	7179                	add	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	e84a                	sd	s2,16(sp)
    80002a86:	e44e                	sd	s3,8(sp)
    80002a88:	1800                	add	s0,sp,48
    80002a8a:	892a                	mv	s2,a0
    80002a8c:	84ae                	mv	s1,a1
    80002a8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	f1e080e7          	jalr	-226(ra) # 800019ae <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a98:	86ce                	mv	a3,s3
    80002a9a:	864a                	mv	a2,s2
    80002a9c:	85a6                	mv	a1,s1
    80002a9e:	6928                	ld	a0,80(a0)
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	ce8080e7          	jalr	-792(ra) # 80001788 <copyinstr>
    80002aa8:	00054e63          	bltz	a0,80002ac4 <fetchstr+0x48>
  return strlen(buf);
    80002aac:	8526                	mv	a0,s1
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	39a080e7          	jalr	922(ra) # 80000e48 <strlen>
}
    80002ab6:	70a2                	ld	ra,40(sp)
    80002ab8:	7402                	ld	s0,32(sp)
    80002aba:	64e2                	ld	s1,24(sp)
    80002abc:	6942                	ld	s2,16(sp)
    80002abe:	69a2                	ld	s3,8(sp)
    80002ac0:	6145                	add	sp,sp,48
    80002ac2:	8082                	ret
    return -1;
    80002ac4:	557d                	li	a0,-1
    80002ac6:	bfc5                	j	80002ab6 <fetchstr+0x3a>

0000000080002ac8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac8:	1101                	add	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	1000                	add	s0,sp,32
    80002ad2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad4:	00000097          	auipc	ra,0x0
    80002ad8:	eee080e7          	jalr	-274(ra) # 800029c2 <argraw>
    80002adc:	c088                	sw	a0,0(s1)
}
    80002ade:	60e2                	ld	ra,24(sp)
    80002ae0:	6442                	ld	s0,16(sp)
    80002ae2:	64a2                	ld	s1,8(sp)
    80002ae4:	6105                	add	sp,sp,32
    80002ae6:	8082                	ret

0000000080002ae8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae8:	1101                	add	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	1000                	add	s0,sp,32
    80002af2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	ece080e7          	jalr	-306(ra) # 800029c2 <argraw>
    80002afc:	e088                	sd	a0,0(s1)
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6105                	add	sp,sp,32
    80002b06:	8082                	ret

0000000080002b08 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b08:	7179                	add	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	1800                	add	s0,sp,48
    80002b14:	84ae                	mv	s1,a1
    80002b16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b18:	fd840593          	add	a1,s0,-40
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	fcc080e7          	jalr	-52(ra) # 80002ae8 <argaddr>
  return fetchstr(addr, buf, max);
    80002b24:	864a                	mv	a2,s2
    80002b26:	85a6                	mv	a1,s1
    80002b28:	fd843503          	ld	a0,-40(s0)
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	f50080e7          	jalr	-176(ra) # 80002a7c <fetchstr>
}
    80002b34:	70a2                	ld	ra,40(sp)
    80002b36:	7402                	ld	s0,32(sp)
    80002b38:	64e2                	ld	s1,24(sp)
    80002b3a:	6942                	ld	s2,16(sp)
    80002b3c:	6145                	add	sp,sp,48
    80002b3e:	8082                	ret

0000000080002b40 <syscall>:
[SYS_sem_close]  sys_sem_close,
};

void
syscall(void)
{
    80002b40:	1101                	add	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	e04a                	sd	s2,0(sp)
    80002b4a:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	e62080e7          	jalr	-414(ra) # 800019ae <myproc>
    80002b54:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b56:	05853903          	ld	s2,88(a0)
    80002b5a:	0a893783          	ld	a5,168(s2)
    80002b5e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b62:	37fd                	addw	a5,a5,-1
    80002b64:	4761                	li	a4,24
    80002b66:	00f76f63          	bltu	a4,a5,80002b84 <syscall+0x44>
    80002b6a:	00369713          	sll	a4,a3,0x3
    80002b6e:	00006797          	auipc	a5,0x6
    80002b72:	8e278793          	add	a5,a5,-1822 # 80008450 <syscalls>
    80002b76:	97ba                	add	a5,a5,a4
    80002b78:	639c                	ld	a5,0(a5)
    80002b7a:	c789                	beqz	a5,80002b84 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b7c:	9782                	jalr	a5
    80002b7e:	06a93823          	sd	a0,112(s2)
    80002b82:	a839                	j	80002ba0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b84:	15848613          	add	a2,s1,344
    80002b88:	588c                	lw	a1,48(s1)
    80002b8a:	00006517          	auipc	a0,0x6
    80002b8e:	88e50513          	add	a0,a0,-1906 # 80008418 <states.0+0x150>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f4080e7          	jalr	-1548(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9a:	6cbc                	ld	a5,88(s1)
    80002b9c:	577d                	li	a4,-1
    80002b9e:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6902                	ld	s2,0(sp)
    80002ba8:	6105                	add	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_exit>:
#include "proc.h"
#include "semaphores.h"

uint64
sys_exit(void)
{
    80002bac:	1101                	add	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002bb4:	fec40593          	add	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	f0e080e7          	jalr	-242(ra) # 80002ac8 <argint>
  exit(n);
    80002bc2:	fec42503          	lw	a0,-20(s0)
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	5c4080e7          	jalr	1476(ra) # 8000218a <exit>
  return 0;  // not reached
}
    80002bce:	4501                	li	a0,0
    80002bd0:	60e2                	ld	ra,24(sp)
    80002bd2:	6442                	ld	s0,16(sp)
    80002bd4:	6105                	add	sp,sp,32
    80002bd6:	8082                	ret

0000000080002bd8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd8:	1141                	add	sp,sp,-16
    80002bda:	e406                	sd	ra,8(sp)
    80002bdc:	e022                	sd	s0,0(sp)
    80002bde:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002be0:	fffff097          	auipc	ra,0xfffff
    80002be4:	dce080e7          	jalr	-562(ra) # 800019ae <myproc>
}
    80002be8:	5908                	lw	a0,48(a0)
    80002bea:	60a2                	ld	ra,8(sp)
    80002bec:	6402                	ld	s0,0(sp)
    80002bee:	0141                	add	sp,sp,16
    80002bf0:	8082                	ret

0000000080002bf2 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf2:	1141                	add	sp,sp,-16
    80002bf4:	e406                	sd	ra,8(sp)
    80002bf6:	e022                	sd	s0,0(sp)
    80002bf8:	0800                	add	s0,sp,16
  return fork();
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	16a080e7          	jalr	362(ra) # 80001d64 <fork>
}
    80002c02:	60a2                	ld	ra,8(sp)
    80002c04:	6402                	ld	s0,0(sp)
    80002c06:	0141                	add	sp,sp,16
    80002c08:	8082                	ret

0000000080002c0a <sys_wait>:

uint64
sys_wait(void)
{
    80002c0a:	1101                	add	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c12:	fe840593          	add	a1,s0,-24
    80002c16:	4501                	li	a0,0
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	ed0080e7          	jalr	-304(ra) # 80002ae8 <argaddr>
  return wait(p);
    80002c20:	fe843503          	ld	a0,-24(s0)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	70c080e7          	jalr	1804(ra) # 80002330 <wait>
}
    80002c2c:	60e2                	ld	ra,24(sp)
    80002c2e:	6442                	ld	s0,16(sp)
    80002c30:	6105                	add	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c34:	7179                	add	sp,sp,-48
    80002c36:	f406                	sd	ra,40(sp)
    80002c38:	f022                	sd	s0,32(sp)
    80002c3a:	ec26                	sd	s1,24(sp)
    80002c3c:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c3e:	fdc40593          	add	a1,s0,-36
    80002c42:	4501                	li	a0,0
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	e84080e7          	jalr	-380(ra) # 80002ac8 <argint>
  addr = myproc()->sz;
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	d62080e7          	jalr	-670(ra) # 800019ae <myproc>
    80002c54:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c56:	fdc42503          	lw	a0,-36(s0)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	0ae080e7          	jalr	174(ra) # 80001d08 <growproc>
    80002c62:	00054863          	bltz	a0,80002c72 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c66:	8526                	mv	a0,s1
    80002c68:	70a2                	ld	ra,40(sp)
    80002c6a:	7402                	ld	s0,32(sp)
    80002c6c:	64e2                	ld	s1,24(sp)
    80002c6e:	6145                	add	sp,sp,48
    80002c70:	8082                	ret
    return -1;
    80002c72:	54fd                	li	s1,-1
    80002c74:	bfcd                	j	80002c66 <sys_sbrk+0x32>

0000000080002c76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c76:	7139                	add	sp,sp,-64
    80002c78:	fc06                	sd	ra,56(sp)
    80002c7a:	f822                	sd	s0,48(sp)
    80002c7c:	f426                	sd	s1,40(sp)
    80002c7e:	f04a                	sd	s2,32(sp)
    80002c80:	ec4e                	sd	s3,24(sp)
    80002c82:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c84:	fcc40593          	add	a1,s0,-52
    80002c88:	4501                	li	a0,0
    80002c8a:	00000097          	auipc	ra,0x0
    80002c8e:	e3e080e7          	jalr	-450(ra) # 80002ac8 <argint>
  acquire(&tickslock);
    80002c92:	00014517          	auipc	a0,0x14
    80002c96:	dde50513          	add	a0,a0,-546 # 80016a70 <tickslock>
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	f38080e7          	jalr	-200(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002ca2:	00006917          	auipc	s2,0x6
    80002ca6:	d2e92903          	lw	s2,-722(s2) # 800089d0 <ticks>
  while(ticks - ticks0 < n){
    80002caa:	fcc42783          	lw	a5,-52(s0)
    80002cae:	cf9d                	beqz	a5,80002cec <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb0:	00014997          	auipc	s3,0x14
    80002cb4:	dc098993          	add	s3,s3,-576 # 80016a70 <tickslock>
    80002cb8:	00006497          	auipc	s1,0x6
    80002cbc:	d1848493          	add	s1,s1,-744 # 800089d0 <ticks>
    if(killed(myproc())){
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	cee080e7          	jalr	-786(ra) # 800019ae <myproc>
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	636080e7          	jalr	1590(ra) # 800022fe <killed>
    80002cd0:	ed15                	bnez	a0,80002d0c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd2:	85ce                	mv	a1,s3
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	380080e7          	jalr	896(ra) # 80002056 <sleep>
  while(ticks - ticks0 < n){
    80002cde:	409c                	lw	a5,0(s1)
    80002ce0:	412787bb          	subw	a5,a5,s2
    80002ce4:	fcc42703          	lw	a4,-52(s0)
    80002ce8:	fce7ece3          	bltu	a5,a4,80002cc0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cec:	00014517          	auipc	a0,0x14
    80002cf0:	d8450513          	add	a0,a0,-636 # 80016a70 <tickslock>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	f92080e7          	jalr	-110(ra) # 80000c86 <release>
  return 0;
    80002cfc:	4501                	li	a0,0
}
    80002cfe:	70e2                	ld	ra,56(sp)
    80002d00:	7442                	ld	s0,48(sp)
    80002d02:	74a2                	ld	s1,40(sp)
    80002d04:	7902                	ld	s2,32(sp)
    80002d06:	69e2                	ld	s3,24(sp)
    80002d08:	6121                	add	sp,sp,64
    80002d0a:	8082                	ret
      release(&tickslock);
    80002d0c:	00014517          	auipc	a0,0x14
    80002d10:	d6450513          	add	a0,a0,-668 # 80016a70 <tickslock>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	f72080e7          	jalr	-142(ra) # 80000c86 <release>
      return -1;
    80002d1c:	557d                	li	a0,-1
    80002d1e:	b7c5                	j	80002cfe <sys_sleep+0x88>

0000000080002d20 <sys_kill>:

uint64
sys_kill(void)
{
    80002d20:	1101                	add	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d28:	fec40593          	add	a1,s0,-20
    80002d2c:	4501                	li	a0,0
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	d9a080e7          	jalr	-614(ra) # 80002ac8 <argint>
  return kill(pid);
    80002d36:	fec42503          	lw	a0,-20(s0)
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	526080e7          	jalr	1318(ra) # 80002260 <kill>
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	6105                	add	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d4a:	1101                	add	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d54:	00014517          	auipc	a0,0x14
    80002d58:	d1c50513          	add	a0,a0,-740 # 80016a70 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	e76080e7          	jalr	-394(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002d64:	00006497          	auipc	s1,0x6
    80002d68:	c6c4a483          	lw	s1,-916(s1) # 800089d0 <ticks>
  release(&tickslock);
    80002d6c:	00014517          	auipc	a0,0x14
    80002d70:	d0450513          	add	a0,a0,-764 # 80016a70 <tickslock>
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	f12080e7          	jalr	-238(ra) # 80000c86 <release>
  return xticks;
}
    80002d7c:	02049513          	sll	a0,s1,0x20
    80002d80:	9101                	srl	a0,a0,0x20
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6105                	add	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <sys_sem_open>:

uint64 
sys_sem_open(void)
{
    80002d8c:	1101                	add	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	1000                	add	s0,sp,32
  int sem, value;
  argint(0, &sem);
    80002d94:	fec40593          	add	a1,s0,-20
    80002d98:	4501                	li	a0,0
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	d2e080e7          	jalr	-722(ra) # 80002ac8 <argint>
  argint(1, &value);
    80002da2:	fe840593          	add	a1,s0,-24
    80002da6:	4505                	li	a0,1
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	d20080e7          	jalr	-736(ra) # 80002ac8 <argint>
  return sem_open(sem,value);
    80002db0:	fe842583          	lw	a1,-24(s0)
    80002db4:	fec42503          	lw	a0,-20(s0)
    80002db8:	00003097          	auipc	ra,0x3
    80002dbc:	4ae080e7          	jalr	1198(ra) # 80006266 <sem_open>
}
    80002dc0:	60e2                	ld	ra,24(sp)
    80002dc2:	6442                	ld	s0,16(sp)
    80002dc4:	6105                	add	sp,sp,32
    80002dc6:	8082                	ret

0000000080002dc8 <sys_sem_close>:

uint64 
sys_sem_close(void)
{  
    80002dc8:	1101                	add	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	1000                	add	s0,sp,32
  // Frees the resources associated with a semaphore.
  // Pass the user-level function argument to kernel level, which is the semaphore ID.
  int sem;
  argint(0, &sem);
    80002dd0:	fec40593          	add	a1,s0,-20
    80002dd4:	4501                	li	a0,0
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	cf2080e7          	jalr	-782(ra) # 80002ac8 <argint>
  return sem_close(sem);
    80002dde:	fec42503          	lw	a0,-20(s0)
    80002de2:	00003097          	auipc	ra,0x3
    80002de6:	512080e7          	jalr	1298(ra) # 800062f4 <sem_close>
}
    80002dea:	60e2                	ld	ra,24(sp)
    80002dec:	6442                	ld	s0,16(sp)
    80002dee:	6105                	add	sp,sp,32
    80002df0:	8082                	ret

0000000080002df2 <sys_sem_up>:

uint64 
sys_sem_up(void)
{
    80002df2:	1101                	add	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	1000                	add	s0,sp,32
  int sem;
  argint(0, &sem);
    80002dfa:	fec40593          	add	a1,s0,-20
    80002dfe:	4501                	li	a0,0
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	cc8080e7          	jalr	-824(ra) # 80002ac8 <argint>
  return sem_up(sem);
    80002e08:	fec42503          	lw	a0,-20(s0)
    80002e0c:	00003097          	auipc	ra,0x3
    80002e10:	5d2080e7          	jalr	1490(ra) # 800063de <sem_up>
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	6105                	add	sp,sp,32
    80002e1a:	8082                	ret

0000000080002e1c <sys_sem_down>:

uint64 
sys_sem_down(void)
{
    80002e1c:	1101                	add	sp,sp,-32
    80002e1e:	ec06                	sd	ra,24(sp)
    80002e20:	e822                	sd	s0,16(sp)
    80002e22:	1000                	add	s0,sp,32
  int sem;
  argint(0, &sem);
    80002e24:	fec40593          	add	a1,s0,-20
    80002e28:	4501                	li	a0,0
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	c9e080e7          	jalr	-866(ra) # 80002ac8 <argint>
  return sem_down(sem);  
    80002e32:	fec42503          	lw	a0,-20(s0)
    80002e36:	00003097          	auipc	ra,0x3
    80002e3a:	614080e7          	jalr	1556(ra) # 8000644a <sem_down>
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	6105                	add	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e46:	7179                	add	sp,sp,-48
    80002e48:	f406                	sd	ra,40(sp)
    80002e4a:	f022                	sd	s0,32(sp)
    80002e4c:	ec26                	sd	s1,24(sp)
    80002e4e:	e84a                	sd	s2,16(sp)
    80002e50:	e44e                	sd	s3,8(sp)
    80002e52:	e052                	sd	s4,0(sp)
    80002e54:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e56:	00005597          	auipc	a1,0x5
    80002e5a:	6ca58593          	add	a1,a1,1738 # 80008520 <syscalls+0xd0>
    80002e5e:	00014517          	auipc	a0,0x14
    80002e62:	c2a50513          	add	a0,a0,-982 # 80016a88 <bcache>
    80002e66:	ffffe097          	auipc	ra,0xffffe
    80002e6a:	cdc080e7          	jalr	-804(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e6e:	0001c797          	auipc	a5,0x1c
    80002e72:	c1a78793          	add	a5,a5,-998 # 8001ea88 <bcache+0x8000>
    80002e76:	0001c717          	auipc	a4,0x1c
    80002e7a:	e7a70713          	add	a4,a4,-390 # 8001ecf0 <bcache+0x8268>
    80002e7e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e82:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e86:	00014497          	auipc	s1,0x14
    80002e8a:	c1a48493          	add	s1,s1,-998 # 80016aa0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e8e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e90:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e92:	00005a17          	auipc	s4,0x5
    80002e96:	696a0a13          	add	s4,s4,1686 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002e9a:	2b893783          	ld	a5,696(s2)
    80002e9e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ea0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ea4:	85d2                	mv	a1,s4
    80002ea6:	01048513          	add	a0,s1,16
    80002eaa:	00001097          	auipc	ra,0x1
    80002eae:	496080e7          	jalr	1174(ra) # 80004340 <initsleeplock>
    bcache.head.next->prev = b;
    80002eb2:	2b893783          	ld	a5,696(s2)
    80002eb6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002eb8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ebc:	45848493          	add	s1,s1,1112
    80002ec0:	fd349de3          	bne	s1,s3,80002e9a <binit+0x54>
  }
}
    80002ec4:	70a2                	ld	ra,40(sp)
    80002ec6:	7402                	ld	s0,32(sp)
    80002ec8:	64e2                	ld	s1,24(sp)
    80002eca:	6942                	ld	s2,16(sp)
    80002ecc:	69a2                	ld	s3,8(sp)
    80002ece:	6a02                	ld	s4,0(sp)
    80002ed0:	6145                	add	sp,sp,48
    80002ed2:	8082                	ret

0000000080002ed4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ed4:	7179                	add	sp,sp,-48
    80002ed6:	f406                	sd	ra,40(sp)
    80002ed8:	f022                	sd	s0,32(sp)
    80002eda:	ec26                	sd	s1,24(sp)
    80002edc:	e84a                	sd	s2,16(sp)
    80002ede:	e44e                	sd	s3,8(sp)
    80002ee0:	1800                	add	s0,sp,48
    80002ee2:	892a                	mv	s2,a0
    80002ee4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ee6:	00014517          	auipc	a0,0x14
    80002eea:	ba250513          	add	a0,a0,-1118 # 80016a88 <bcache>
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	ce4080e7          	jalr	-796(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ef6:	0001c497          	auipc	s1,0x1c
    80002efa:	e4a4b483          	ld	s1,-438(s1) # 8001ed40 <bcache+0x82b8>
    80002efe:	0001c797          	auipc	a5,0x1c
    80002f02:	df278793          	add	a5,a5,-526 # 8001ecf0 <bcache+0x8268>
    80002f06:	02f48f63          	beq	s1,a5,80002f44 <bread+0x70>
    80002f0a:	873e                	mv	a4,a5
    80002f0c:	a021                	j	80002f14 <bread+0x40>
    80002f0e:	68a4                	ld	s1,80(s1)
    80002f10:	02e48a63          	beq	s1,a4,80002f44 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f14:	449c                	lw	a5,8(s1)
    80002f16:	ff279ce3          	bne	a5,s2,80002f0e <bread+0x3a>
    80002f1a:	44dc                	lw	a5,12(s1)
    80002f1c:	ff3799e3          	bne	a5,s3,80002f0e <bread+0x3a>
      b->refcnt++;
    80002f20:	40bc                	lw	a5,64(s1)
    80002f22:	2785                	addw	a5,a5,1
    80002f24:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f26:	00014517          	auipc	a0,0x14
    80002f2a:	b6250513          	add	a0,a0,-1182 # 80016a88 <bcache>
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	d58080e7          	jalr	-680(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f36:	01048513          	add	a0,s1,16
    80002f3a:	00001097          	auipc	ra,0x1
    80002f3e:	440080e7          	jalr	1088(ra) # 8000437a <acquiresleep>
      return b;
    80002f42:	a8b9                	j	80002fa0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f44:	0001c497          	auipc	s1,0x1c
    80002f48:	df44b483          	ld	s1,-524(s1) # 8001ed38 <bcache+0x82b0>
    80002f4c:	0001c797          	auipc	a5,0x1c
    80002f50:	da478793          	add	a5,a5,-604 # 8001ecf0 <bcache+0x8268>
    80002f54:	00f48863          	beq	s1,a5,80002f64 <bread+0x90>
    80002f58:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f5a:	40bc                	lw	a5,64(s1)
    80002f5c:	cf81                	beqz	a5,80002f74 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f5e:	64a4                	ld	s1,72(s1)
    80002f60:	fee49de3          	bne	s1,a4,80002f5a <bread+0x86>
  panic("bget: no buffers");
    80002f64:	00005517          	auipc	a0,0x5
    80002f68:	5cc50513          	add	a0,a0,1484 # 80008530 <syscalls+0xe0>
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	5d0080e7          	jalr	1488(ra) # 8000053c <panic>
      b->dev = dev;
    80002f74:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f78:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f7c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f80:	4785                	li	a5,1
    80002f82:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f84:	00014517          	auipc	a0,0x14
    80002f88:	b0450513          	add	a0,a0,-1276 # 80016a88 <bcache>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	cfa080e7          	jalr	-774(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f94:	01048513          	add	a0,s1,16
    80002f98:	00001097          	auipc	ra,0x1
    80002f9c:	3e2080e7          	jalr	994(ra) # 8000437a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fa0:	409c                	lw	a5,0(s1)
    80002fa2:	cb89                	beqz	a5,80002fb4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fa4:	8526                	mv	a0,s1
    80002fa6:	70a2                	ld	ra,40(sp)
    80002fa8:	7402                	ld	s0,32(sp)
    80002faa:	64e2                	ld	s1,24(sp)
    80002fac:	6942                	ld	s2,16(sp)
    80002fae:	69a2                	ld	s3,8(sp)
    80002fb0:	6145                	add	sp,sp,48
    80002fb2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fb4:	4581                	li	a1,0
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	00003097          	auipc	ra,0x3
    80002fbc:	f7a080e7          	jalr	-134(ra) # 80005f32 <virtio_disk_rw>
    b->valid = 1;
    80002fc0:	4785                	li	a5,1
    80002fc2:	c09c                	sw	a5,0(s1)
  return b;
    80002fc4:	b7c5                	j	80002fa4 <bread+0xd0>

0000000080002fc6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fc6:	1101                	add	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	e426                	sd	s1,8(sp)
    80002fce:	1000                	add	s0,sp,32
    80002fd0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fd2:	0541                	add	a0,a0,16
    80002fd4:	00001097          	auipc	ra,0x1
    80002fd8:	440080e7          	jalr	1088(ra) # 80004414 <holdingsleep>
    80002fdc:	cd01                	beqz	a0,80002ff4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fde:	4585                	li	a1,1
    80002fe0:	8526                	mv	a0,s1
    80002fe2:	00003097          	auipc	ra,0x3
    80002fe6:	f50080e7          	jalr	-176(ra) # 80005f32 <virtio_disk_rw>
}
    80002fea:	60e2                	ld	ra,24(sp)
    80002fec:	6442                	ld	s0,16(sp)
    80002fee:	64a2                	ld	s1,8(sp)
    80002ff0:	6105                	add	sp,sp,32
    80002ff2:	8082                	ret
    panic("bwrite");
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	55450513          	add	a0,a0,1364 # 80008548 <syscalls+0xf8>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	540080e7          	jalr	1344(ra) # 8000053c <panic>

0000000080003004 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003004:	1101                	add	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	e04a                	sd	s2,0(sp)
    8000300e:	1000                	add	s0,sp,32
    80003010:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003012:	01050913          	add	s2,a0,16
    80003016:	854a                	mv	a0,s2
    80003018:	00001097          	auipc	ra,0x1
    8000301c:	3fc080e7          	jalr	1020(ra) # 80004414 <holdingsleep>
    80003020:	c925                	beqz	a0,80003090 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003022:	854a                	mv	a0,s2
    80003024:	00001097          	auipc	ra,0x1
    80003028:	3ac080e7          	jalr	940(ra) # 800043d0 <releasesleep>

  acquire(&bcache.lock);
    8000302c:	00014517          	auipc	a0,0x14
    80003030:	a5c50513          	add	a0,a0,-1444 # 80016a88 <bcache>
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	b9e080e7          	jalr	-1122(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000303c:	40bc                	lw	a5,64(s1)
    8000303e:	37fd                	addw	a5,a5,-1
    80003040:	0007871b          	sext.w	a4,a5
    80003044:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003046:	e71d                	bnez	a4,80003074 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003048:	68b8                	ld	a4,80(s1)
    8000304a:	64bc                	ld	a5,72(s1)
    8000304c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000304e:	68b8                	ld	a4,80(s1)
    80003050:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003052:	0001c797          	auipc	a5,0x1c
    80003056:	a3678793          	add	a5,a5,-1482 # 8001ea88 <bcache+0x8000>
    8000305a:	2b87b703          	ld	a4,696(a5)
    8000305e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003060:	0001c717          	auipc	a4,0x1c
    80003064:	c9070713          	add	a4,a4,-880 # 8001ecf0 <bcache+0x8268>
    80003068:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000306a:	2b87b703          	ld	a4,696(a5)
    8000306e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003070:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003074:	00014517          	auipc	a0,0x14
    80003078:	a1450513          	add	a0,a0,-1516 # 80016a88 <bcache>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	c0a080e7          	jalr	-1014(ra) # 80000c86 <release>
}
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6902                	ld	s2,0(sp)
    8000308c:	6105                	add	sp,sp,32
    8000308e:	8082                	ret
    panic("brelse");
    80003090:	00005517          	auipc	a0,0x5
    80003094:	4c050513          	add	a0,a0,1216 # 80008550 <syscalls+0x100>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4a4080e7          	jalr	1188(ra) # 8000053c <panic>

00000000800030a0 <bpin>:

void
bpin(struct buf *b) {
    800030a0:	1101                	add	sp,sp,-32
    800030a2:	ec06                	sd	ra,24(sp)
    800030a4:	e822                	sd	s0,16(sp)
    800030a6:	e426                	sd	s1,8(sp)
    800030a8:	1000                	add	s0,sp,32
    800030aa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030ac:	00014517          	auipc	a0,0x14
    800030b0:	9dc50513          	add	a0,a0,-1572 # 80016a88 <bcache>
    800030b4:	ffffe097          	auipc	ra,0xffffe
    800030b8:	b1e080e7          	jalr	-1250(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	2785                	addw	a5,a5,1
    800030c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c2:	00014517          	auipc	a0,0x14
    800030c6:	9c650513          	add	a0,a0,-1594 # 80016a88 <bcache>
    800030ca:	ffffe097          	auipc	ra,0xffffe
    800030ce:	bbc080e7          	jalr	-1092(ra) # 80000c86 <release>
}
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6105                	add	sp,sp,32
    800030da:	8082                	ret

00000000800030dc <bunpin>:

void
bunpin(struct buf *b) {
    800030dc:	1101                	add	sp,sp,-32
    800030de:	ec06                	sd	ra,24(sp)
    800030e0:	e822                	sd	s0,16(sp)
    800030e2:	e426                	sd	s1,8(sp)
    800030e4:	1000                	add	s0,sp,32
    800030e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030e8:	00014517          	auipc	a0,0x14
    800030ec:	9a050513          	add	a0,a0,-1632 # 80016a88 <bcache>
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	ae2080e7          	jalr	-1310(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030f8:	40bc                	lw	a5,64(s1)
    800030fa:	37fd                	addw	a5,a5,-1
    800030fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030fe:	00014517          	auipc	a0,0x14
    80003102:	98a50513          	add	a0,a0,-1654 # 80016a88 <bcache>
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	b80080e7          	jalr	-1152(ra) # 80000c86 <release>
}
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	64a2                	ld	s1,8(sp)
    80003114:	6105                	add	sp,sp,32
    80003116:	8082                	ret

0000000080003118 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003118:	1101                	add	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	e04a                	sd	s2,0(sp)
    80003122:	1000                	add	s0,sp,32
    80003124:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003126:	00d5d59b          	srlw	a1,a1,0xd
    8000312a:	0001c797          	auipc	a5,0x1c
    8000312e:	03a7a783          	lw	a5,58(a5) # 8001f164 <sb+0x1c>
    80003132:	9dbd                	addw	a1,a1,a5
    80003134:	00000097          	auipc	ra,0x0
    80003138:	da0080e7          	jalr	-608(ra) # 80002ed4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000313c:	0074f713          	and	a4,s1,7
    80003140:	4785                	li	a5,1
    80003142:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003146:	14ce                	sll	s1,s1,0x33
    80003148:	90d9                	srl	s1,s1,0x36
    8000314a:	00950733          	add	a4,a0,s1
    8000314e:	05874703          	lbu	a4,88(a4)
    80003152:	00e7f6b3          	and	a3,a5,a4
    80003156:	c69d                	beqz	a3,80003184 <bfree+0x6c>
    80003158:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000315a:	94aa                	add	s1,s1,a0
    8000315c:	fff7c793          	not	a5,a5
    80003160:	8f7d                	and	a4,a4,a5
    80003162:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003166:	00001097          	auipc	ra,0x1
    8000316a:	0f6080e7          	jalr	246(ra) # 8000425c <log_write>
  brelse(bp);
    8000316e:	854a                	mv	a0,s2
    80003170:	00000097          	auipc	ra,0x0
    80003174:	e94080e7          	jalr	-364(ra) # 80003004 <brelse>
}
    80003178:	60e2                	ld	ra,24(sp)
    8000317a:	6442                	ld	s0,16(sp)
    8000317c:	64a2                	ld	s1,8(sp)
    8000317e:	6902                	ld	s2,0(sp)
    80003180:	6105                	add	sp,sp,32
    80003182:	8082                	ret
    panic("freeing free block");
    80003184:	00005517          	auipc	a0,0x5
    80003188:	3d450513          	add	a0,a0,980 # 80008558 <syscalls+0x108>
    8000318c:	ffffd097          	auipc	ra,0xffffd
    80003190:	3b0080e7          	jalr	944(ra) # 8000053c <panic>

0000000080003194 <balloc>:
{
    80003194:	711d                	add	sp,sp,-96
    80003196:	ec86                	sd	ra,88(sp)
    80003198:	e8a2                	sd	s0,80(sp)
    8000319a:	e4a6                	sd	s1,72(sp)
    8000319c:	e0ca                	sd	s2,64(sp)
    8000319e:	fc4e                	sd	s3,56(sp)
    800031a0:	f852                	sd	s4,48(sp)
    800031a2:	f456                	sd	s5,40(sp)
    800031a4:	f05a                	sd	s6,32(sp)
    800031a6:	ec5e                	sd	s7,24(sp)
    800031a8:	e862                	sd	s8,16(sp)
    800031aa:	e466                	sd	s9,8(sp)
    800031ac:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031ae:	0001c797          	auipc	a5,0x1c
    800031b2:	f9e7a783          	lw	a5,-98(a5) # 8001f14c <sb+0x4>
    800031b6:	cff5                	beqz	a5,800032b2 <balloc+0x11e>
    800031b8:	8baa                	mv	s7,a0
    800031ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031bc:	0001cb17          	auipc	s6,0x1c
    800031c0:	f8cb0b13          	add	s6,s6,-116 # 8001f148 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031ca:	6c89                	lui	s9,0x2
    800031cc:	a061                	j	80003254 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031ce:	97ca                	add	a5,a5,s2
    800031d0:	8e55                	or	a2,a2,a3
    800031d2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031d6:	854a                	mv	a0,s2
    800031d8:	00001097          	auipc	ra,0x1
    800031dc:	084080e7          	jalr	132(ra) # 8000425c <log_write>
        brelse(bp);
    800031e0:	854a                	mv	a0,s2
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	e22080e7          	jalr	-478(ra) # 80003004 <brelse>
  bp = bread(dev, bno);
    800031ea:	85a6                	mv	a1,s1
    800031ec:	855e                	mv	a0,s7
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	ce6080e7          	jalr	-794(ra) # 80002ed4 <bread>
    800031f6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031f8:	40000613          	li	a2,1024
    800031fc:	4581                	li	a1,0
    800031fe:	05850513          	add	a0,a0,88
    80003202:	ffffe097          	auipc	ra,0xffffe
    80003206:	acc080e7          	jalr	-1332(ra) # 80000cce <memset>
  log_write(bp);
    8000320a:	854a                	mv	a0,s2
    8000320c:	00001097          	auipc	ra,0x1
    80003210:	050080e7          	jalr	80(ra) # 8000425c <log_write>
  brelse(bp);
    80003214:	854a                	mv	a0,s2
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	dee080e7          	jalr	-530(ra) # 80003004 <brelse>
}
    8000321e:	8526                	mv	a0,s1
    80003220:	60e6                	ld	ra,88(sp)
    80003222:	6446                	ld	s0,80(sp)
    80003224:	64a6                	ld	s1,72(sp)
    80003226:	6906                	ld	s2,64(sp)
    80003228:	79e2                	ld	s3,56(sp)
    8000322a:	7a42                	ld	s4,48(sp)
    8000322c:	7aa2                	ld	s5,40(sp)
    8000322e:	7b02                	ld	s6,32(sp)
    80003230:	6be2                	ld	s7,24(sp)
    80003232:	6c42                	ld	s8,16(sp)
    80003234:	6ca2                	ld	s9,8(sp)
    80003236:	6125                	add	sp,sp,96
    80003238:	8082                	ret
    brelse(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	dc8080e7          	jalr	-568(ra) # 80003004 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003244:	015c87bb          	addw	a5,s9,s5
    80003248:	00078a9b          	sext.w	s5,a5
    8000324c:	004b2703          	lw	a4,4(s6)
    80003250:	06eaf163          	bgeu	s5,a4,800032b2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003254:	41fad79b          	sraw	a5,s5,0x1f
    80003258:	0137d79b          	srlw	a5,a5,0x13
    8000325c:	015787bb          	addw	a5,a5,s5
    80003260:	40d7d79b          	sraw	a5,a5,0xd
    80003264:	01cb2583          	lw	a1,28(s6)
    80003268:	9dbd                	addw	a1,a1,a5
    8000326a:	855e                	mv	a0,s7
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	c68080e7          	jalr	-920(ra) # 80002ed4 <bread>
    80003274:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003276:	004b2503          	lw	a0,4(s6)
    8000327a:	000a849b          	sext.w	s1,s5
    8000327e:	8762                	mv	a4,s8
    80003280:	faa4fde3          	bgeu	s1,a0,8000323a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003284:	00777693          	and	a3,a4,7
    80003288:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000328c:	41f7579b          	sraw	a5,a4,0x1f
    80003290:	01d7d79b          	srlw	a5,a5,0x1d
    80003294:	9fb9                	addw	a5,a5,a4
    80003296:	4037d79b          	sraw	a5,a5,0x3
    8000329a:	00f90633          	add	a2,s2,a5
    8000329e:	05864603          	lbu	a2,88(a2)
    800032a2:	00c6f5b3          	and	a1,a3,a2
    800032a6:	d585                	beqz	a1,800031ce <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a8:	2705                	addw	a4,a4,1
    800032aa:	2485                	addw	s1,s1,1
    800032ac:	fd471ae3          	bne	a4,s4,80003280 <balloc+0xec>
    800032b0:	b769                	j	8000323a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800032b2:	00005517          	auipc	a0,0x5
    800032b6:	2be50513          	add	a0,a0,702 # 80008570 <syscalls+0x120>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	2cc080e7          	jalr	716(ra) # 80000586 <printf>
  return 0;
    800032c2:	4481                	li	s1,0
    800032c4:	bfa9                	j	8000321e <balloc+0x8a>

00000000800032c6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032c6:	7179                	add	sp,sp,-48
    800032c8:	f406                	sd	ra,40(sp)
    800032ca:	f022                	sd	s0,32(sp)
    800032cc:	ec26                	sd	s1,24(sp)
    800032ce:	e84a                	sd	s2,16(sp)
    800032d0:	e44e                	sd	s3,8(sp)
    800032d2:	e052                	sd	s4,0(sp)
    800032d4:	1800                	add	s0,sp,48
    800032d6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032d8:	47ad                	li	a5,11
    800032da:	02b7e863          	bltu	a5,a1,8000330a <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800032de:	02059793          	sll	a5,a1,0x20
    800032e2:	01e7d593          	srl	a1,a5,0x1e
    800032e6:	00b504b3          	add	s1,a0,a1
    800032ea:	0504a903          	lw	s2,80(s1)
    800032ee:	06091e63          	bnez	s2,8000336a <bmap+0xa4>
      addr = balloc(ip->dev);
    800032f2:	4108                	lw	a0,0(a0)
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	ea0080e7          	jalr	-352(ra) # 80003194 <balloc>
    800032fc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003300:	06090563          	beqz	s2,8000336a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003304:	0524a823          	sw	s2,80(s1)
    80003308:	a08d                	j	8000336a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000330a:	ff45849b          	addw	s1,a1,-12
    8000330e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003312:	0ff00793          	li	a5,255
    80003316:	08e7e563          	bltu	a5,a4,800033a0 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000331a:	08052903          	lw	s2,128(a0)
    8000331e:	00091d63          	bnez	s2,80003338 <bmap+0x72>
      addr = balloc(ip->dev);
    80003322:	4108                	lw	a0,0(a0)
    80003324:	00000097          	auipc	ra,0x0
    80003328:	e70080e7          	jalr	-400(ra) # 80003194 <balloc>
    8000332c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003330:	02090d63          	beqz	s2,8000336a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003334:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003338:	85ca                	mv	a1,s2
    8000333a:	0009a503          	lw	a0,0(s3)
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	b96080e7          	jalr	-1130(ra) # 80002ed4 <bread>
    80003346:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003348:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    8000334c:	02049713          	sll	a4,s1,0x20
    80003350:	01e75593          	srl	a1,a4,0x1e
    80003354:	00b784b3          	add	s1,a5,a1
    80003358:	0004a903          	lw	s2,0(s1)
    8000335c:	02090063          	beqz	s2,8000337c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003360:	8552                	mv	a0,s4
    80003362:	00000097          	auipc	ra,0x0
    80003366:	ca2080e7          	jalr	-862(ra) # 80003004 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000336a:	854a                	mv	a0,s2
    8000336c:	70a2                	ld	ra,40(sp)
    8000336e:	7402                	ld	s0,32(sp)
    80003370:	64e2                	ld	s1,24(sp)
    80003372:	6942                	ld	s2,16(sp)
    80003374:	69a2                	ld	s3,8(sp)
    80003376:	6a02                	ld	s4,0(sp)
    80003378:	6145                	add	sp,sp,48
    8000337a:	8082                	ret
      addr = balloc(ip->dev);
    8000337c:	0009a503          	lw	a0,0(s3)
    80003380:	00000097          	auipc	ra,0x0
    80003384:	e14080e7          	jalr	-492(ra) # 80003194 <balloc>
    80003388:	0005091b          	sext.w	s2,a0
      if(addr){
    8000338c:	fc090ae3          	beqz	s2,80003360 <bmap+0x9a>
        a[bn] = addr;
    80003390:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003394:	8552                	mv	a0,s4
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	ec6080e7          	jalr	-314(ra) # 8000425c <log_write>
    8000339e:	b7c9                	j	80003360 <bmap+0x9a>
  panic("bmap: out of range");
    800033a0:	00005517          	auipc	a0,0x5
    800033a4:	1e850513          	add	a0,a0,488 # 80008588 <syscalls+0x138>
    800033a8:	ffffd097          	auipc	ra,0xffffd
    800033ac:	194080e7          	jalr	404(ra) # 8000053c <panic>

00000000800033b0 <iget>:
{
    800033b0:	7179                	add	sp,sp,-48
    800033b2:	f406                	sd	ra,40(sp)
    800033b4:	f022                	sd	s0,32(sp)
    800033b6:	ec26                	sd	s1,24(sp)
    800033b8:	e84a                	sd	s2,16(sp)
    800033ba:	e44e                	sd	s3,8(sp)
    800033bc:	e052                	sd	s4,0(sp)
    800033be:	1800                	add	s0,sp,48
    800033c0:	89aa                	mv	s3,a0
    800033c2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033c4:	0001c517          	auipc	a0,0x1c
    800033c8:	da450513          	add	a0,a0,-604 # 8001f168 <itable>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	806080e7          	jalr	-2042(ra) # 80000bd2 <acquire>
  empty = 0;
    800033d4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033d6:	0001c497          	auipc	s1,0x1c
    800033da:	daa48493          	add	s1,s1,-598 # 8001f180 <itable+0x18>
    800033de:	0001e697          	auipc	a3,0x1e
    800033e2:	83268693          	add	a3,a3,-1998 # 80020c10 <log>
    800033e6:	a039                	j	800033f4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033e8:	02090b63          	beqz	s2,8000341e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ec:	08848493          	add	s1,s1,136
    800033f0:	02d48a63          	beq	s1,a3,80003424 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f4:	449c                	lw	a5,8(s1)
    800033f6:	fef059e3          	blez	a5,800033e8 <iget+0x38>
    800033fa:	4098                	lw	a4,0(s1)
    800033fc:	ff3716e3          	bne	a4,s3,800033e8 <iget+0x38>
    80003400:	40d8                	lw	a4,4(s1)
    80003402:	ff4713e3          	bne	a4,s4,800033e8 <iget+0x38>
      ip->ref++;
    80003406:	2785                	addw	a5,a5,1
    80003408:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	d5e50513          	add	a0,a0,-674 # 8001f168 <itable>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	874080e7          	jalr	-1932(ra) # 80000c86 <release>
      return ip;
    8000341a:	8926                	mv	s2,s1
    8000341c:	a03d                	j	8000344a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000341e:	f7f9                	bnez	a5,800033ec <iget+0x3c>
    80003420:	8926                	mv	s2,s1
    80003422:	b7e9                	j	800033ec <iget+0x3c>
  if(empty == 0)
    80003424:	02090c63          	beqz	s2,8000345c <iget+0xac>
  ip->dev = dev;
    80003428:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000342c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003430:	4785                	li	a5,1
    80003432:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003436:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000343a:	0001c517          	auipc	a0,0x1c
    8000343e:	d2e50513          	add	a0,a0,-722 # 8001f168 <itable>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	844080e7          	jalr	-1980(ra) # 80000c86 <release>
}
    8000344a:	854a                	mv	a0,s2
    8000344c:	70a2                	ld	ra,40(sp)
    8000344e:	7402                	ld	s0,32(sp)
    80003450:	64e2                	ld	s1,24(sp)
    80003452:	6942                	ld	s2,16(sp)
    80003454:	69a2                	ld	s3,8(sp)
    80003456:	6a02                	ld	s4,0(sp)
    80003458:	6145                	add	sp,sp,48
    8000345a:	8082                	ret
    panic("iget: no inodes");
    8000345c:	00005517          	auipc	a0,0x5
    80003460:	14450513          	add	a0,a0,324 # 800085a0 <syscalls+0x150>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	0d8080e7          	jalr	216(ra) # 8000053c <panic>

000000008000346c <fsinit>:
fsinit(int dev) {
    8000346c:	7179                	add	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	add	s0,sp,48
    8000347a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000347c:	4585                	li	a1,1
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	a56080e7          	jalr	-1450(ra) # 80002ed4 <bread>
    80003486:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003488:	0001c997          	auipc	s3,0x1c
    8000348c:	cc098993          	add	s3,s3,-832 # 8001f148 <sb>
    80003490:	02000613          	li	a2,32
    80003494:	05850593          	add	a1,a0,88
    80003498:	854e                	mv	a0,s3
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	890080e7          	jalr	-1904(ra) # 80000d2a <memmove>
  brelse(bp);
    800034a2:	8526                	mv	a0,s1
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	b60080e7          	jalr	-1184(ra) # 80003004 <brelse>
  if(sb.magic != FSMAGIC)
    800034ac:	0009a703          	lw	a4,0(s3)
    800034b0:	102037b7          	lui	a5,0x10203
    800034b4:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034b8:	02f71263          	bne	a4,a5,800034dc <fsinit+0x70>
  initlog(dev, &sb);
    800034bc:	0001c597          	auipc	a1,0x1c
    800034c0:	c8c58593          	add	a1,a1,-884 # 8001f148 <sb>
    800034c4:	854a                	mv	a0,s2
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	b2c080e7          	jalr	-1236(ra) # 80003ff2 <initlog>
}
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6145                	add	sp,sp,48
    800034da:	8082                	ret
    panic("invalid file system");
    800034dc:	00005517          	auipc	a0,0x5
    800034e0:	0d450513          	add	a0,a0,212 # 800085b0 <syscalls+0x160>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	058080e7          	jalr	88(ra) # 8000053c <panic>

00000000800034ec <iinit>:
{
    800034ec:	7179                	add	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800034fa:	00005597          	auipc	a1,0x5
    800034fe:	0ce58593          	add	a1,a1,206 # 800085c8 <syscalls+0x178>
    80003502:	0001c517          	auipc	a0,0x1c
    80003506:	c6650513          	add	a0,a0,-922 # 8001f168 <itable>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	638080e7          	jalr	1592(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003512:	0001c497          	auipc	s1,0x1c
    80003516:	c7e48493          	add	s1,s1,-898 # 8001f190 <itable+0x28>
    8000351a:	0001d997          	auipc	s3,0x1d
    8000351e:	70698993          	add	s3,s3,1798 # 80020c20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003522:	00005917          	auipc	s2,0x5
    80003526:	0ae90913          	add	s2,s2,174 # 800085d0 <syscalls+0x180>
    8000352a:	85ca                	mv	a1,s2
    8000352c:	8526                	mv	a0,s1
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	e12080e7          	jalr	-494(ra) # 80004340 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003536:	08848493          	add	s1,s1,136
    8000353a:	ff3498e3          	bne	s1,s3,8000352a <iinit+0x3e>
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6942                	ld	s2,16(sp)
    80003546:	69a2                	ld	s3,8(sp)
    80003548:	6145                	add	sp,sp,48
    8000354a:	8082                	ret

000000008000354c <ialloc>:
{
    8000354c:	7139                	add	sp,sp,-64
    8000354e:	fc06                	sd	ra,56(sp)
    80003550:	f822                	sd	s0,48(sp)
    80003552:	f426                	sd	s1,40(sp)
    80003554:	f04a                	sd	s2,32(sp)
    80003556:	ec4e                	sd	s3,24(sp)
    80003558:	e852                	sd	s4,16(sp)
    8000355a:	e456                	sd	s5,8(sp)
    8000355c:	e05a                	sd	s6,0(sp)
    8000355e:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003560:	0001c717          	auipc	a4,0x1c
    80003564:	bf472703          	lw	a4,-1036(a4) # 8001f154 <sb+0xc>
    80003568:	4785                	li	a5,1
    8000356a:	04e7f863          	bgeu	a5,a4,800035ba <ialloc+0x6e>
    8000356e:	8aaa                	mv	s5,a0
    80003570:	8b2e                	mv	s6,a1
    80003572:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003574:	0001ca17          	auipc	s4,0x1c
    80003578:	bd4a0a13          	add	s4,s4,-1068 # 8001f148 <sb>
    8000357c:	00495593          	srl	a1,s2,0x4
    80003580:	018a2783          	lw	a5,24(s4)
    80003584:	9dbd                	addw	a1,a1,a5
    80003586:	8556                	mv	a0,s5
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	94c080e7          	jalr	-1716(ra) # 80002ed4 <bread>
    80003590:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003592:	05850993          	add	s3,a0,88
    80003596:	00f97793          	and	a5,s2,15
    8000359a:	079a                	sll	a5,a5,0x6
    8000359c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000359e:	00099783          	lh	a5,0(s3)
    800035a2:	cf9d                	beqz	a5,800035e0 <ialloc+0x94>
    brelse(bp);
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	a60080e7          	jalr	-1440(ra) # 80003004 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ac:	0905                	add	s2,s2,1
    800035ae:	00ca2703          	lw	a4,12(s4)
    800035b2:	0009079b          	sext.w	a5,s2
    800035b6:	fce7e3e3          	bltu	a5,a4,8000357c <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800035ba:	00005517          	auipc	a0,0x5
    800035be:	01e50513          	add	a0,a0,30 # 800085d8 <syscalls+0x188>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	fc4080e7          	jalr	-60(ra) # 80000586 <printf>
  return 0;
    800035ca:	4501                	li	a0,0
}
    800035cc:	70e2                	ld	ra,56(sp)
    800035ce:	7442                	ld	s0,48(sp)
    800035d0:	74a2                	ld	s1,40(sp)
    800035d2:	7902                	ld	s2,32(sp)
    800035d4:	69e2                	ld	s3,24(sp)
    800035d6:	6a42                	ld	s4,16(sp)
    800035d8:	6aa2                	ld	s5,8(sp)
    800035da:	6b02                	ld	s6,0(sp)
    800035dc:	6121                	add	sp,sp,64
    800035de:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035e0:	04000613          	li	a2,64
    800035e4:	4581                	li	a1,0
    800035e6:	854e                	mv	a0,s3
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	6e6080e7          	jalr	1766(ra) # 80000cce <memset>
      dip->type = type;
    800035f0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035f4:	8526                	mv	a0,s1
    800035f6:	00001097          	auipc	ra,0x1
    800035fa:	c66080e7          	jalr	-922(ra) # 8000425c <log_write>
      brelse(bp);
    800035fe:	8526                	mv	a0,s1
    80003600:	00000097          	auipc	ra,0x0
    80003604:	a04080e7          	jalr	-1532(ra) # 80003004 <brelse>
      return iget(dev, inum);
    80003608:	0009059b          	sext.w	a1,s2
    8000360c:	8556                	mv	a0,s5
    8000360e:	00000097          	auipc	ra,0x0
    80003612:	da2080e7          	jalr	-606(ra) # 800033b0 <iget>
    80003616:	bf5d                	j	800035cc <ialloc+0x80>

0000000080003618 <iupdate>:
{
    80003618:	1101                	add	sp,sp,-32
    8000361a:	ec06                	sd	ra,24(sp)
    8000361c:	e822                	sd	s0,16(sp)
    8000361e:	e426                	sd	s1,8(sp)
    80003620:	e04a                	sd	s2,0(sp)
    80003622:	1000                	add	s0,sp,32
    80003624:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003626:	415c                	lw	a5,4(a0)
    80003628:	0047d79b          	srlw	a5,a5,0x4
    8000362c:	0001c597          	auipc	a1,0x1c
    80003630:	b345a583          	lw	a1,-1228(a1) # 8001f160 <sb+0x18>
    80003634:	9dbd                	addw	a1,a1,a5
    80003636:	4108                	lw	a0,0(a0)
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	89c080e7          	jalr	-1892(ra) # 80002ed4 <bread>
    80003640:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003642:	05850793          	add	a5,a0,88
    80003646:	40d8                	lw	a4,4(s1)
    80003648:	8b3d                	and	a4,a4,15
    8000364a:	071a                	sll	a4,a4,0x6
    8000364c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000364e:	04449703          	lh	a4,68(s1)
    80003652:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003656:	04649703          	lh	a4,70(s1)
    8000365a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000365e:	04849703          	lh	a4,72(s1)
    80003662:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003666:	04a49703          	lh	a4,74(s1)
    8000366a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000366e:	44f8                	lw	a4,76(s1)
    80003670:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003672:	03400613          	li	a2,52
    80003676:	05048593          	add	a1,s1,80
    8000367a:	00c78513          	add	a0,a5,12
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	6ac080e7          	jalr	1708(ra) # 80000d2a <memmove>
  log_write(bp);
    80003686:	854a                	mv	a0,s2
    80003688:	00001097          	auipc	ra,0x1
    8000368c:	bd4080e7          	jalr	-1068(ra) # 8000425c <log_write>
  brelse(bp);
    80003690:	854a                	mv	a0,s2
    80003692:	00000097          	auipc	ra,0x0
    80003696:	972080e7          	jalr	-1678(ra) # 80003004 <brelse>
}
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6902                	ld	s2,0(sp)
    800036a2:	6105                	add	sp,sp,32
    800036a4:	8082                	ret

00000000800036a6 <idup>:
{
    800036a6:	1101                	add	sp,sp,-32
    800036a8:	ec06                	sd	ra,24(sp)
    800036aa:	e822                	sd	s0,16(sp)
    800036ac:	e426                	sd	s1,8(sp)
    800036ae:	1000                	add	s0,sp,32
    800036b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036b2:	0001c517          	auipc	a0,0x1c
    800036b6:	ab650513          	add	a0,a0,-1354 # 8001f168 <itable>
    800036ba:	ffffd097          	auipc	ra,0xffffd
    800036be:	518080e7          	jalr	1304(ra) # 80000bd2 <acquire>
  ip->ref++;
    800036c2:	449c                	lw	a5,8(s1)
    800036c4:	2785                	addw	a5,a5,1
    800036c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036c8:	0001c517          	auipc	a0,0x1c
    800036cc:	aa050513          	add	a0,a0,-1376 # 8001f168 <itable>
    800036d0:	ffffd097          	auipc	ra,0xffffd
    800036d4:	5b6080e7          	jalr	1462(ra) # 80000c86 <release>
}
    800036d8:	8526                	mv	a0,s1
    800036da:	60e2                	ld	ra,24(sp)
    800036dc:	6442                	ld	s0,16(sp)
    800036de:	64a2                	ld	s1,8(sp)
    800036e0:	6105                	add	sp,sp,32
    800036e2:	8082                	ret

00000000800036e4 <ilock>:
{
    800036e4:	1101                	add	sp,sp,-32
    800036e6:	ec06                	sd	ra,24(sp)
    800036e8:	e822                	sd	s0,16(sp)
    800036ea:	e426                	sd	s1,8(sp)
    800036ec:	e04a                	sd	s2,0(sp)
    800036ee:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036f0:	c115                	beqz	a0,80003714 <ilock+0x30>
    800036f2:	84aa                	mv	s1,a0
    800036f4:	451c                	lw	a5,8(a0)
    800036f6:	00f05f63          	blez	a5,80003714 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036fa:	0541                	add	a0,a0,16
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	c7e080e7          	jalr	-898(ra) # 8000437a <acquiresleep>
  if(ip->valid == 0){
    80003704:	40bc                	lw	a5,64(s1)
    80003706:	cf99                	beqz	a5,80003724 <ilock+0x40>
}
    80003708:	60e2                	ld	ra,24(sp)
    8000370a:	6442                	ld	s0,16(sp)
    8000370c:	64a2                	ld	s1,8(sp)
    8000370e:	6902                	ld	s2,0(sp)
    80003710:	6105                	add	sp,sp,32
    80003712:	8082                	ret
    panic("ilock");
    80003714:	00005517          	auipc	a0,0x5
    80003718:	edc50513          	add	a0,a0,-292 # 800085f0 <syscalls+0x1a0>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	e20080e7          	jalr	-480(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003724:	40dc                	lw	a5,4(s1)
    80003726:	0047d79b          	srlw	a5,a5,0x4
    8000372a:	0001c597          	auipc	a1,0x1c
    8000372e:	a365a583          	lw	a1,-1482(a1) # 8001f160 <sb+0x18>
    80003732:	9dbd                	addw	a1,a1,a5
    80003734:	4088                	lw	a0,0(s1)
    80003736:	fffff097          	auipc	ra,0xfffff
    8000373a:	79e080e7          	jalr	1950(ra) # 80002ed4 <bread>
    8000373e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003740:	05850593          	add	a1,a0,88
    80003744:	40dc                	lw	a5,4(s1)
    80003746:	8bbd                	and	a5,a5,15
    80003748:	079a                	sll	a5,a5,0x6
    8000374a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000374c:	00059783          	lh	a5,0(a1)
    80003750:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003754:	00259783          	lh	a5,2(a1)
    80003758:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000375c:	00459783          	lh	a5,4(a1)
    80003760:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003764:	00659783          	lh	a5,6(a1)
    80003768:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000376c:	459c                	lw	a5,8(a1)
    8000376e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003770:	03400613          	li	a2,52
    80003774:	05b1                	add	a1,a1,12
    80003776:	05048513          	add	a0,s1,80
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	5b0080e7          	jalr	1456(ra) # 80000d2a <memmove>
    brelse(bp);
    80003782:	854a                	mv	a0,s2
    80003784:	00000097          	auipc	ra,0x0
    80003788:	880080e7          	jalr	-1920(ra) # 80003004 <brelse>
    ip->valid = 1;
    8000378c:	4785                	li	a5,1
    8000378e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003790:	04449783          	lh	a5,68(s1)
    80003794:	fbb5                	bnez	a5,80003708 <ilock+0x24>
      panic("ilock: no type");
    80003796:	00005517          	auipc	a0,0x5
    8000379a:	e6250513          	add	a0,a0,-414 # 800085f8 <syscalls+0x1a8>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	d9e080e7          	jalr	-610(ra) # 8000053c <panic>

00000000800037a6 <iunlock>:
{
    800037a6:	1101                	add	sp,sp,-32
    800037a8:	ec06                	sd	ra,24(sp)
    800037aa:	e822                	sd	s0,16(sp)
    800037ac:	e426                	sd	s1,8(sp)
    800037ae:	e04a                	sd	s2,0(sp)
    800037b0:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037b2:	c905                	beqz	a0,800037e2 <iunlock+0x3c>
    800037b4:	84aa                	mv	s1,a0
    800037b6:	01050913          	add	s2,a0,16
    800037ba:	854a                	mv	a0,s2
    800037bc:	00001097          	auipc	ra,0x1
    800037c0:	c58080e7          	jalr	-936(ra) # 80004414 <holdingsleep>
    800037c4:	cd19                	beqz	a0,800037e2 <iunlock+0x3c>
    800037c6:	449c                	lw	a5,8(s1)
    800037c8:	00f05d63          	blez	a5,800037e2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037cc:	854a                	mv	a0,s2
    800037ce:	00001097          	auipc	ra,0x1
    800037d2:	c02080e7          	jalr	-1022(ra) # 800043d0 <releasesleep>
}
    800037d6:	60e2                	ld	ra,24(sp)
    800037d8:	6442                	ld	s0,16(sp)
    800037da:	64a2                	ld	s1,8(sp)
    800037dc:	6902                	ld	s2,0(sp)
    800037de:	6105                	add	sp,sp,32
    800037e0:	8082                	ret
    panic("iunlock");
    800037e2:	00005517          	auipc	a0,0x5
    800037e6:	e2650513          	add	a0,a0,-474 # 80008608 <syscalls+0x1b8>
    800037ea:	ffffd097          	auipc	ra,0xffffd
    800037ee:	d52080e7          	jalr	-686(ra) # 8000053c <panic>

00000000800037f2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037f2:	7179                	add	sp,sp,-48
    800037f4:	f406                	sd	ra,40(sp)
    800037f6:	f022                	sd	s0,32(sp)
    800037f8:	ec26                	sd	s1,24(sp)
    800037fa:	e84a                	sd	s2,16(sp)
    800037fc:	e44e                	sd	s3,8(sp)
    800037fe:	e052                	sd	s4,0(sp)
    80003800:	1800                	add	s0,sp,48
    80003802:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003804:	05050493          	add	s1,a0,80
    80003808:	08050913          	add	s2,a0,128
    8000380c:	a021                	j	80003814 <itrunc+0x22>
    8000380e:	0491                	add	s1,s1,4
    80003810:	01248d63          	beq	s1,s2,8000382a <itrunc+0x38>
    if(ip->addrs[i]){
    80003814:	408c                	lw	a1,0(s1)
    80003816:	dde5                	beqz	a1,8000380e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003818:	0009a503          	lw	a0,0(s3)
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	8fc080e7          	jalr	-1796(ra) # 80003118 <bfree>
      ip->addrs[i] = 0;
    80003824:	0004a023          	sw	zero,0(s1)
    80003828:	b7dd                	j	8000380e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000382a:	0809a583          	lw	a1,128(s3)
    8000382e:	e185                	bnez	a1,8000384e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003830:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003834:	854e                	mv	a0,s3
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	de2080e7          	jalr	-542(ra) # 80003618 <iupdate>
}
    8000383e:	70a2                	ld	ra,40(sp)
    80003840:	7402                	ld	s0,32(sp)
    80003842:	64e2                	ld	s1,24(sp)
    80003844:	6942                	ld	s2,16(sp)
    80003846:	69a2                	ld	s3,8(sp)
    80003848:	6a02                	ld	s4,0(sp)
    8000384a:	6145                	add	sp,sp,48
    8000384c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000384e:	0009a503          	lw	a0,0(s3)
    80003852:	fffff097          	auipc	ra,0xfffff
    80003856:	682080e7          	jalr	1666(ra) # 80002ed4 <bread>
    8000385a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000385c:	05850493          	add	s1,a0,88
    80003860:	45850913          	add	s2,a0,1112
    80003864:	a021                	j	8000386c <itrunc+0x7a>
    80003866:	0491                	add	s1,s1,4
    80003868:	01248b63          	beq	s1,s2,8000387e <itrunc+0x8c>
      if(a[j])
    8000386c:	408c                	lw	a1,0(s1)
    8000386e:	dde5                	beqz	a1,80003866 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003870:	0009a503          	lw	a0,0(s3)
    80003874:	00000097          	auipc	ra,0x0
    80003878:	8a4080e7          	jalr	-1884(ra) # 80003118 <bfree>
    8000387c:	b7ed                	j	80003866 <itrunc+0x74>
    brelse(bp);
    8000387e:	8552                	mv	a0,s4
    80003880:	fffff097          	auipc	ra,0xfffff
    80003884:	784080e7          	jalr	1924(ra) # 80003004 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003888:	0809a583          	lw	a1,128(s3)
    8000388c:	0009a503          	lw	a0,0(s3)
    80003890:	00000097          	auipc	ra,0x0
    80003894:	888080e7          	jalr	-1912(ra) # 80003118 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003898:	0809a023          	sw	zero,128(s3)
    8000389c:	bf51                	j	80003830 <itrunc+0x3e>

000000008000389e <iput>:
{
    8000389e:	1101                	add	sp,sp,-32
    800038a0:	ec06                	sd	ra,24(sp)
    800038a2:	e822                	sd	s0,16(sp)
    800038a4:	e426                	sd	s1,8(sp)
    800038a6:	e04a                	sd	s2,0(sp)
    800038a8:	1000                	add	s0,sp,32
    800038aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038ac:	0001c517          	auipc	a0,0x1c
    800038b0:	8bc50513          	add	a0,a0,-1860 # 8001f168 <itable>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	31e080e7          	jalr	798(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038bc:	4498                	lw	a4,8(s1)
    800038be:	4785                	li	a5,1
    800038c0:	02f70363          	beq	a4,a5,800038e6 <iput+0x48>
  ip->ref--;
    800038c4:	449c                	lw	a5,8(s1)
    800038c6:	37fd                	addw	a5,a5,-1
    800038c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038ca:	0001c517          	auipc	a0,0x1c
    800038ce:	89e50513          	add	a0,a0,-1890 # 8001f168 <itable>
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	3b4080e7          	jalr	948(ra) # 80000c86 <release>
}
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6902                	ld	s2,0(sp)
    800038e2:	6105                	add	sp,sp,32
    800038e4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038e6:	40bc                	lw	a5,64(s1)
    800038e8:	dff1                	beqz	a5,800038c4 <iput+0x26>
    800038ea:	04a49783          	lh	a5,74(s1)
    800038ee:	fbf9                	bnez	a5,800038c4 <iput+0x26>
    acquiresleep(&ip->lock);
    800038f0:	01048913          	add	s2,s1,16
    800038f4:	854a                	mv	a0,s2
    800038f6:	00001097          	auipc	ra,0x1
    800038fa:	a84080e7          	jalr	-1404(ra) # 8000437a <acquiresleep>
    release(&itable.lock);
    800038fe:	0001c517          	auipc	a0,0x1c
    80003902:	86a50513          	add	a0,a0,-1942 # 8001f168 <itable>
    80003906:	ffffd097          	auipc	ra,0xffffd
    8000390a:	380080e7          	jalr	896(ra) # 80000c86 <release>
    itrunc(ip);
    8000390e:	8526                	mv	a0,s1
    80003910:	00000097          	auipc	ra,0x0
    80003914:	ee2080e7          	jalr	-286(ra) # 800037f2 <itrunc>
    ip->type = 0;
    80003918:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000391c:	8526                	mv	a0,s1
    8000391e:	00000097          	auipc	ra,0x0
    80003922:	cfa080e7          	jalr	-774(ra) # 80003618 <iupdate>
    ip->valid = 0;
    80003926:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000392a:	854a                	mv	a0,s2
    8000392c:	00001097          	auipc	ra,0x1
    80003930:	aa4080e7          	jalr	-1372(ra) # 800043d0 <releasesleep>
    acquire(&itable.lock);
    80003934:	0001c517          	auipc	a0,0x1c
    80003938:	83450513          	add	a0,a0,-1996 # 8001f168 <itable>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	296080e7          	jalr	662(ra) # 80000bd2 <acquire>
    80003944:	b741                	j	800038c4 <iput+0x26>

0000000080003946 <iunlockput>:
{
    80003946:	1101                	add	sp,sp,-32
    80003948:	ec06                	sd	ra,24(sp)
    8000394a:	e822                	sd	s0,16(sp)
    8000394c:	e426                	sd	s1,8(sp)
    8000394e:	1000                	add	s0,sp,32
    80003950:	84aa                	mv	s1,a0
  iunlock(ip);
    80003952:	00000097          	auipc	ra,0x0
    80003956:	e54080e7          	jalr	-428(ra) # 800037a6 <iunlock>
  iput(ip);
    8000395a:	8526                	mv	a0,s1
    8000395c:	00000097          	auipc	ra,0x0
    80003960:	f42080e7          	jalr	-190(ra) # 8000389e <iput>
}
    80003964:	60e2                	ld	ra,24(sp)
    80003966:	6442                	ld	s0,16(sp)
    80003968:	64a2                	ld	s1,8(sp)
    8000396a:	6105                	add	sp,sp,32
    8000396c:	8082                	ret

000000008000396e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000396e:	1141                	add	sp,sp,-16
    80003970:	e422                	sd	s0,8(sp)
    80003972:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003974:	411c                	lw	a5,0(a0)
    80003976:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003978:	415c                	lw	a5,4(a0)
    8000397a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000397c:	04451783          	lh	a5,68(a0)
    80003980:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003984:	04a51783          	lh	a5,74(a0)
    80003988:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000398c:	04c56783          	lwu	a5,76(a0)
    80003990:	e99c                	sd	a5,16(a1)
}
    80003992:	6422                	ld	s0,8(sp)
    80003994:	0141                	add	sp,sp,16
    80003996:	8082                	ret

0000000080003998 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003998:	457c                	lw	a5,76(a0)
    8000399a:	0ed7e963          	bltu	a5,a3,80003a8c <readi+0xf4>
{
    8000399e:	7159                	add	sp,sp,-112
    800039a0:	f486                	sd	ra,104(sp)
    800039a2:	f0a2                	sd	s0,96(sp)
    800039a4:	eca6                	sd	s1,88(sp)
    800039a6:	e8ca                	sd	s2,80(sp)
    800039a8:	e4ce                	sd	s3,72(sp)
    800039aa:	e0d2                	sd	s4,64(sp)
    800039ac:	fc56                	sd	s5,56(sp)
    800039ae:	f85a                	sd	s6,48(sp)
    800039b0:	f45e                	sd	s7,40(sp)
    800039b2:	f062                	sd	s8,32(sp)
    800039b4:	ec66                	sd	s9,24(sp)
    800039b6:	e86a                	sd	s10,16(sp)
    800039b8:	e46e                	sd	s11,8(sp)
    800039ba:	1880                	add	s0,sp,112
    800039bc:	8b2a                	mv	s6,a0
    800039be:	8bae                	mv	s7,a1
    800039c0:	8a32                	mv	s4,a2
    800039c2:	84b6                	mv	s1,a3
    800039c4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039c6:	9f35                	addw	a4,a4,a3
    return 0;
    800039c8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039ca:	0ad76063          	bltu	a4,a3,80003a6a <readi+0xd2>
  if(off + n > ip->size)
    800039ce:	00e7f463          	bgeu	a5,a4,800039d6 <readi+0x3e>
    n = ip->size - off;
    800039d2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039d6:	0a0a8963          	beqz	s5,80003a88 <readi+0xf0>
    800039da:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039dc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039e0:	5c7d                	li	s8,-1
    800039e2:	a82d                	j	80003a1c <readi+0x84>
    800039e4:	020d1d93          	sll	s11,s10,0x20
    800039e8:	020ddd93          	srl	s11,s11,0x20
    800039ec:	05890613          	add	a2,s2,88
    800039f0:	86ee                	mv	a3,s11
    800039f2:	963a                	add	a2,a2,a4
    800039f4:	85d2                	mv	a1,s4
    800039f6:	855e                	mv	a0,s7
    800039f8:	fffff097          	auipc	ra,0xfffff
    800039fc:	a66080e7          	jalr	-1434(ra) # 8000245e <either_copyout>
    80003a00:	05850d63          	beq	a0,s8,80003a5a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	fffff097          	auipc	ra,0xfffff
    80003a0a:	5fe080e7          	jalr	1534(ra) # 80003004 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a0e:	013d09bb          	addw	s3,s10,s3
    80003a12:	009d04bb          	addw	s1,s10,s1
    80003a16:	9a6e                	add	s4,s4,s11
    80003a18:	0559f763          	bgeu	s3,s5,80003a66 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a1c:	00a4d59b          	srlw	a1,s1,0xa
    80003a20:	855a                	mv	a0,s6
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	8a4080e7          	jalr	-1884(ra) # 800032c6 <bmap>
    80003a2a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a2e:	cd85                	beqz	a1,80003a66 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a30:	000b2503          	lw	a0,0(s6)
    80003a34:	fffff097          	auipc	ra,0xfffff
    80003a38:	4a0080e7          	jalr	1184(ra) # 80002ed4 <bread>
    80003a3c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3e:	3ff4f713          	and	a4,s1,1023
    80003a42:	40ec87bb          	subw	a5,s9,a4
    80003a46:	413a86bb          	subw	a3,s5,s3
    80003a4a:	8d3e                	mv	s10,a5
    80003a4c:	2781                	sext.w	a5,a5
    80003a4e:	0006861b          	sext.w	a2,a3
    80003a52:	f8f679e3          	bgeu	a2,a5,800039e4 <readi+0x4c>
    80003a56:	8d36                	mv	s10,a3
    80003a58:	b771                	j	800039e4 <readi+0x4c>
      brelse(bp);
    80003a5a:	854a                	mv	a0,s2
    80003a5c:	fffff097          	auipc	ra,0xfffff
    80003a60:	5a8080e7          	jalr	1448(ra) # 80003004 <brelse>
      tot = -1;
    80003a64:	59fd                	li	s3,-1
  }
  return tot;
    80003a66:	0009851b          	sext.w	a0,s3
}
    80003a6a:	70a6                	ld	ra,104(sp)
    80003a6c:	7406                	ld	s0,96(sp)
    80003a6e:	64e6                	ld	s1,88(sp)
    80003a70:	6946                	ld	s2,80(sp)
    80003a72:	69a6                	ld	s3,72(sp)
    80003a74:	6a06                	ld	s4,64(sp)
    80003a76:	7ae2                	ld	s5,56(sp)
    80003a78:	7b42                	ld	s6,48(sp)
    80003a7a:	7ba2                	ld	s7,40(sp)
    80003a7c:	7c02                	ld	s8,32(sp)
    80003a7e:	6ce2                	ld	s9,24(sp)
    80003a80:	6d42                	ld	s10,16(sp)
    80003a82:	6da2                	ld	s11,8(sp)
    80003a84:	6165                	add	sp,sp,112
    80003a86:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a88:	89d6                	mv	s3,s5
    80003a8a:	bff1                	j	80003a66 <readi+0xce>
    return 0;
    80003a8c:	4501                	li	a0,0
}
    80003a8e:	8082                	ret

0000000080003a90 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a90:	457c                	lw	a5,76(a0)
    80003a92:	10d7e863          	bltu	a5,a3,80003ba2 <writei+0x112>
{
    80003a96:	7159                	add	sp,sp,-112
    80003a98:	f486                	sd	ra,104(sp)
    80003a9a:	f0a2                	sd	s0,96(sp)
    80003a9c:	eca6                	sd	s1,88(sp)
    80003a9e:	e8ca                	sd	s2,80(sp)
    80003aa0:	e4ce                	sd	s3,72(sp)
    80003aa2:	e0d2                	sd	s4,64(sp)
    80003aa4:	fc56                	sd	s5,56(sp)
    80003aa6:	f85a                	sd	s6,48(sp)
    80003aa8:	f45e                	sd	s7,40(sp)
    80003aaa:	f062                	sd	s8,32(sp)
    80003aac:	ec66                	sd	s9,24(sp)
    80003aae:	e86a                	sd	s10,16(sp)
    80003ab0:	e46e                	sd	s11,8(sp)
    80003ab2:	1880                	add	s0,sp,112
    80003ab4:	8aaa                	mv	s5,a0
    80003ab6:	8bae                	mv	s7,a1
    80003ab8:	8a32                	mv	s4,a2
    80003aba:	8936                	mv	s2,a3
    80003abc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003abe:	00e687bb          	addw	a5,a3,a4
    80003ac2:	0ed7e263          	bltu	a5,a3,80003ba6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ac6:	00043737          	lui	a4,0x43
    80003aca:	0ef76063          	bltu	a4,a5,80003baa <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ace:	0c0b0863          	beqz	s6,80003b9e <writei+0x10e>
    80003ad2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ad4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ad8:	5c7d                	li	s8,-1
    80003ada:	a091                	j	80003b1e <writei+0x8e>
    80003adc:	020d1d93          	sll	s11,s10,0x20
    80003ae0:	020ddd93          	srl	s11,s11,0x20
    80003ae4:	05848513          	add	a0,s1,88
    80003ae8:	86ee                	mv	a3,s11
    80003aea:	8652                	mv	a2,s4
    80003aec:	85de                	mv	a1,s7
    80003aee:	953a                	add	a0,a0,a4
    80003af0:	fffff097          	auipc	ra,0xfffff
    80003af4:	9c4080e7          	jalr	-1596(ra) # 800024b4 <either_copyin>
    80003af8:	07850263          	beq	a0,s8,80003b5c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003afc:	8526                	mv	a0,s1
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	75e080e7          	jalr	1886(ra) # 8000425c <log_write>
    brelse(bp);
    80003b06:	8526                	mv	a0,s1
    80003b08:	fffff097          	auipc	ra,0xfffff
    80003b0c:	4fc080e7          	jalr	1276(ra) # 80003004 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b10:	013d09bb          	addw	s3,s10,s3
    80003b14:	012d093b          	addw	s2,s10,s2
    80003b18:	9a6e                	add	s4,s4,s11
    80003b1a:	0569f663          	bgeu	s3,s6,80003b66 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b1e:	00a9559b          	srlw	a1,s2,0xa
    80003b22:	8556                	mv	a0,s5
    80003b24:	fffff097          	auipc	ra,0xfffff
    80003b28:	7a2080e7          	jalr	1954(ra) # 800032c6 <bmap>
    80003b2c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b30:	c99d                	beqz	a1,80003b66 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b32:	000aa503          	lw	a0,0(s5)
    80003b36:	fffff097          	auipc	ra,0xfffff
    80003b3a:	39e080e7          	jalr	926(ra) # 80002ed4 <bread>
    80003b3e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b40:	3ff97713          	and	a4,s2,1023
    80003b44:	40ec87bb          	subw	a5,s9,a4
    80003b48:	413b06bb          	subw	a3,s6,s3
    80003b4c:	8d3e                	mv	s10,a5
    80003b4e:	2781                	sext.w	a5,a5
    80003b50:	0006861b          	sext.w	a2,a3
    80003b54:	f8f674e3          	bgeu	a2,a5,80003adc <writei+0x4c>
    80003b58:	8d36                	mv	s10,a3
    80003b5a:	b749                	j	80003adc <writei+0x4c>
      brelse(bp);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	fffff097          	auipc	ra,0xfffff
    80003b62:	4a6080e7          	jalr	1190(ra) # 80003004 <brelse>
  }

  if(off > ip->size)
    80003b66:	04caa783          	lw	a5,76(s5)
    80003b6a:	0127f463          	bgeu	a5,s2,80003b72 <writei+0xe2>
    ip->size = off;
    80003b6e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b72:	8556                	mv	a0,s5
    80003b74:	00000097          	auipc	ra,0x0
    80003b78:	aa4080e7          	jalr	-1372(ra) # 80003618 <iupdate>

  return tot;
    80003b7c:	0009851b          	sext.w	a0,s3
}
    80003b80:	70a6                	ld	ra,104(sp)
    80003b82:	7406                	ld	s0,96(sp)
    80003b84:	64e6                	ld	s1,88(sp)
    80003b86:	6946                	ld	s2,80(sp)
    80003b88:	69a6                	ld	s3,72(sp)
    80003b8a:	6a06                	ld	s4,64(sp)
    80003b8c:	7ae2                	ld	s5,56(sp)
    80003b8e:	7b42                	ld	s6,48(sp)
    80003b90:	7ba2                	ld	s7,40(sp)
    80003b92:	7c02                	ld	s8,32(sp)
    80003b94:	6ce2                	ld	s9,24(sp)
    80003b96:	6d42                	ld	s10,16(sp)
    80003b98:	6da2                	ld	s11,8(sp)
    80003b9a:	6165                	add	sp,sp,112
    80003b9c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b9e:	89da                	mv	s3,s6
    80003ba0:	bfc9                	j	80003b72 <writei+0xe2>
    return -1;
    80003ba2:	557d                	li	a0,-1
}
    80003ba4:	8082                	ret
    return -1;
    80003ba6:	557d                	li	a0,-1
    80003ba8:	bfe1                	j	80003b80 <writei+0xf0>
    return -1;
    80003baa:	557d                	li	a0,-1
    80003bac:	bfd1                	j	80003b80 <writei+0xf0>

0000000080003bae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bae:	1141                	add	sp,sp,-16
    80003bb0:	e406                	sd	ra,8(sp)
    80003bb2:	e022                	sd	s0,0(sp)
    80003bb4:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bb6:	4639                	li	a2,14
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	1e6080e7          	jalr	486(ra) # 80000d9e <strncmp>
}
    80003bc0:	60a2                	ld	ra,8(sp)
    80003bc2:	6402                	ld	s0,0(sp)
    80003bc4:	0141                	add	sp,sp,16
    80003bc6:	8082                	ret

0000000080003bc8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bc8:	7139                	add	sp,sp,-64
    80003bca:	fc06                	sd	ra,56(sp)
    80003bcc:	f822                	sd	s0,48(sp)
    80003bce:	f426                	sd	s1,40(sp)
    80003bd0:	f04a                	sd	s2,32(sp)
    80003bd2:	ec4e                	sd	s3,24(sp)
    80003bd4:	e852                	sd	s4,16(sp)
    80003bd6:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bd8:	04451703          	lh	a4,68(a0)
    80003bdc:	4785                	li	a5,1
    80003bde:	00f71a63          	bne	a4,a5,80003bf2 <dirlookup+0x2a>
    80003be2:	892a                	mv	s2,a0
    80003be4:	89ae                	mv	s3,a1
    80003be6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003be8:	457c                	lw	a5,76(a0)
    80003bea:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bec:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bee:	e79d                	bnez	a5,80003c1c <dirlookup+0x54>
    80003bf0:	a8a5                	j	80003c68 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bf2:	00005517          	auipc	a0,0x5
    80003bf6:	a1e50513          	add	a0,a0,-1506 # 80008610 <syscalls+0x1c0>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	942080e7          	jalr	-1726(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c02:	00005517          	auipc	a0,0x5
    80003c06:	a2650513          	add	a0,a0,-1498 # 80008628 <syscalls+0x1d8>
    80003c0a:	ffffd097          	auipc	ra,0xffffd
    80003c0e:	932080e7          	jalr	-1742(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c12:	24c1                	addw	s1,s1,16
    80003c14:	04c92783          	lw	a5,76(s2)
    80003c18:	04f4f763          	bgeu	s1,a5,80003c66 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c1c:	4741                	li	a4,16
    80003c1e:	86a6                	mv	a3,s1
    80003c20:	fc040613          	add	a2,s0,-64
    80003c24:	4581                	li	a1,0
    80003c26:	854a                	mv	a0,s2
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	d70080e7          	jalr	-656(ra) # 80003998 <readi>
    80003c30:	47c1                	li	a5,16
    80003c32:	fcf518e3          	bne	a0,a5,80003c02 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c36:	fc045783          	lhu	a5,-64(s0)
    80003c3a:	dfe1                	beqz	a5,80003c12 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c3c:	fc240593          	add	a1,s0,-62
    80003c40:	854e                	mv	a0,s3
    80003c42:	00000097          	auipc	ra,0x0
    80003c46:	f6c080e7          	jalr	-148(ra) # 80003bae <namecmp>
    80003c4a:	f561                	bnez	a0,80003c12 <dirlookup+0x4a>
      if(poff)
    80003c4c:	000a0463          	beqz	s4,80003c54 <dirlookup+0x8c>
        *poff = off;
    80003c50:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c54:	fc045583          	lhu	a1,-64(s0)
    80003c58:	00092503          	lw	a0,0(s2)
    80003c5c:	fffff097          	auipc	ra,0xfffff
    80003c60:	754080e7          	jalr	1876(ra) # 800033b0 <iget>
    80003c64:	a011                	j	80003c68 <dirlookup+0xa0>
  return 0;
    80003c66:	4501                	li	a0,0
}
    80003c68:	70e2                	ld	ra,56(sp)
    80003c6a:	7442                	ld	s0,48(sp)
    80003c6c:	74a2                	ld	s1,40(sp)
    80003c6e:	7902                	ld	s2,32(sp)
    80003c70:	69e2                	ld	s3,24(sp)
    80003c72:	6a42                	ld	s4,16(sp)
    80003c74:	6121                	add	sp,sp,64
    80003c76:	8082                	ret

0000000080003c78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c78:	711d                	add	sp,sp,-96
    80003c7a:	ec86                	sd	ra,88(sp)
    80003c7c:	e8a2                	sd	s0,80(sp)
    80003c7e:	e4a6                	sd	s1,72(sp)
    80003c80:	e0ca                	sd	s2,64(sp)
    80003c82:	fc4e                	sd	s3,56(sp)
    80003c84:	f852                	sd	s4,48(sp)
    80003c86:	f456                	sd	s5,40(sp)
    80003c88:	f05a                	sd	s6,32(sp)
    80003c8a:	ec5e                	sd	s7,24(sp)
    80003c8c:	e862                	sd	s8,16(sp)
    80003c8e:	e466                	sd	s9,8(sp)
    80003c90:	1080                	add	s0,sp,96
    80003c92:	84aa                	mv	s1,a0
    80003c94:	8b2e                	mv	s6,a1
    80003c96:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c98:	00054703          	lbu	a4,0(a0)
    80003c9c:	02f00793          	li	a5,47
    80003ca0:	02f70263          	beq	a4,a5,80003cc4 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ca4:	ffffe097          	auipc	ra,0xffffe
    80003ca8:	d0a080e7          	jalr	-758(ra) # 800019ae <myproc>
    80003cac:	15053503          	ld	a0,336(a0)
    80003cb0:	00000097          	auipc	ra,0x0
    80003cb4:	9f6080e7          	jalr	-1546(ra) # 800036a6 <idup>
    80003cb8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cba:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cbe:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cc0:	4b85                	li	s7,1
    80003cc2:	a875                	j	80003d7e <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003cc4:	4585                	li	a1,1
    80003cc6:	4505                	li	a0,1
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	6e8080e7          	jalr	1768(ra) # 800033b0 <iget>
    80003cd0:	8a2a                	mv	s4,a0
    80003cd2:	b7e5                	j	80003cba <namex+0x42>
      iunlockput(ip);
    80003cd4:	8552                	mv	a0,s4
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	c70080e7          	jalr	-912(ra) # 80003946 <iunlockput>
      return 0;
    80003cde:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ce0:	8552                	mv	a0,s4
    80003ce2:	60e6                	ld	ra,88(sp)
    80003ce4:	6446                	ld	s0,80(sp)
    80003ce6:	64a6                	ld	s1,72(sp)
    80003ce8:	6906                	ld	s2,64(sp)
    80003cea:	79e2                	ld	s3,56(sp)
    80003cec:	7a42                	ld	s4,48(sp)
    80003cee:	7aa2                	ld	s5,40(sp)
    80003cf0:	7b02                	ld	s6,32(sp)
    80003cf2:	6be2                	ld	s7,24(sp)
    80003cf4:	6c42                	ld	s8,16(sp)
    80003cf6:	6ca2                	ld	s9,8(sp)
    80003cf8:	6125                	add	sp,sp,96
    80003cfa:	8082                	ret
      iunlock(ip);
    80003cfc:	8552                	mv	a0,s4
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	aa8080e7          	jalr	-1368(ra) # 800037a6 <iunlock>
      return ip;
    80003d06:	bfe9                	j	80003ce0 <namex+0x68>
      iunlockput(ip);
    80003d08:	8552                	mv	a0,s4
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	c3c080e7          	jalr	-964(ra) # 80003946 <iunlockput>
      return 0;
    80003d12:	8a4e                	mv	s4,s3
    80003d14:	b7f1                	j	80003ce0 <namex+0x68>
  len = path - s;
    80003d16:	40998633          	sub	a2,s3,s1
    80003d1a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d1e:	099c5863          	bge	s8,s9,80003dae <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003d22:	4639                	li	a2,14
    80003d24:	85a6                	mv	a1,s1
    80003d26:	8556                	mv	a0,s5
    80003d28:	ffffd097          	auipc	ra,0xffffd
    80003d2c:	002080e7          	jalr	2(ra) # 80000d2a <memmove>
    80003d30:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d32:	0004c783          	lbu	a5,0(s1)
    80003d36:	01279763          	bne	a5,s2,80003d44 <namex+0xcc>
    path++;
    80003d3a:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d3c:	0004c783          	lbu	a5,0(s1)
    80003d40:	ff278de3          	beq	a5,s2,80003d3a <namex+0xc2>
    ilock(ip);
    80003d44:	8552                	mv	a0,s4
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	99e080e7          	jalr	-1634(ra) # 800036e4 <ilock>
    if(ip->type != T_DIR){
    80003d4e:	044a1783          	lh	a5,68(s4)
    80003d52:	f97791e3          	bne	a5,s7,80003cd4 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003d56:	000b0563          	beqz	s6,80003d60 <namex+0xe8>
    80003d5a:	0004c783          	lbu	a5,0(s1)
    80003d5e:	dfd9                	beqz	a5,80003cfc <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d60:	4601                	li	a2,0
    80003d62:	85d6                	mv	a1,s5
    80003d64:	8552                	mv	a0,s4
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	e62080e7          	jalr	-414(ra) # 80003bc8 <dirlookup>
    80003d6e:	89aa                	mv	s3,a0
    80003d70:	dd41                	beqz	a0,80003d08 <namex+0x90>
    iunlockput(ip);
    80003d72:	8552                	mv	a0,s4
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	bd2080e7          	jalr	-1070(ra) # 80003946 <iunlockput>
    ip = next;
    80003d7c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d7e:	0004c783          	lbu	a5,0(s1)
    80003d82:	01279763          	bne	a5,s2,80003d90 <namex+0x118>
    path++;
    80003d86:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d88:	0004c783          	lbu	a5,0(s1)
    80003d8c:	ff278de3          	beq	a5,s2,80003d86 <namex+0x10e>
  if(*path == 0)
    80003d90:	cb9d                	beqz	a5,80003dc6 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003d92:	0004c783          	lbu	a5,0(s1)
    80003d96:	89a6                	mv	s3,s1
  len = path - s;
    80003d98:	4c81                	li	s9,0
    80003d9a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d9c:	01278963          	beq	a5,s2,80003dae <namex+0x136>
    80003da0:	dbbd                	beqz	a5,80003d16 <namex+0x9e>
    path++;
    80003da2:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003da4:	0009c783          	lbu	a5,0(s3)
    80003da8:	ff279ce3          	bne	a5,s2,80003da0 <namex+0x128>
    80003dac:	b7ad                	j	80003d16 <namex+0x9e>
    memmove(name, s, len);
    80003dae:	2601                	sext.w	a2,a2
    80003db0:	85a6                	mv	a1,s1
    80003db2:	8556                	mv	a0,s5
    80003db4:	ffffd097          	auipc	ra,0xffffd
    80003db8:	f76080e7          	jalr	-138(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003dbc:	9cd6                	add	s9,s9,s5
    80003dbe:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dc2:	84ce                	mv	s1,s3
    80003dc4:	b7bd                	j	80003d32 <namex+0xba>
  if(nameiparent){
    80003dc6:	f00b0de3          	beqz	s6,80003ce0 <namex+0x68>
    iput(ip);
    80003dca:	8552                	mv	a0,s4
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	ad2080e7          	jalr	-1326(ra) # 8000389e <iput>
    return 0;
    80003dd4:	4a01                	li	s4,0
    80003dd6:	b729                	j	80003ce0 <namex+0x68>

0000000080003dd8 <dirlink>:
{
    80003dd8:	7139                	add	sp,sp,-64
    80003dda:	fc06                	sd	ra,56(sp)
    80003ddc:	f822                	sd	s0,48(sp)
    80003dde:	f426                	sd	s1,40(sp)
    80003de0:	f04a                	sd	s2,32(sp)
    80003de2:	ec4e                	sd	s3,24(sp)
    80003de4:	e852                	sd	s4,16(sp)
    80003de6:	0080                	add	s0,sp,64
    80003de8:	892a                	mv	s2,a0
    80003dea:	8a2e                	mv	s4,a1
    80003dec:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dee:	4601                	li	a2,0
    80003df0:	00000097          	auipc	ra,0x0
    80003df4:	dd8080e7          	jalr	-552(ra) # 80003bc8 <dirlookup>
    80003df8:	e93d                	bnez	a0,80003e6e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dfa:	04c92483          	lw	s1,76(s2)
    80003dfe:	c49d                	beqz	s1,80003e2c <dirlink+0x54>
    80003e00:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e02:	4741                	li	a4,16
    80003e04:	86a6                	mv	a3,s1
    80003e06:	fc040613          	add	a2,s0,-64
    80003e0a:	4581                	li	a1,0
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	b8a080e7          	jalr	-1142(ra) # 80003998 <readi>
    80003e16:	47c1                	li	a5,16
    80003e18:	06f51163          	bne	a0,a5,80003e7a <dirlink+0xa2>
    if(de.inum == 0)
    80003e1c:	fc045783          	lhu	a5,-64(s0)
    80003e20:	c791                	beqz	a5,80003e2c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e22:	24c1                	addw	s1,s1,16
    80003e24:	04c92783          	lw	a5,76(s2)
    80003e28:	fcf4ede3          	bltu	s1,a5,80003e02 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e2c:	4639                	li	a2,14
    80003e2e:	85d2                	mv	a1,s4
    80003e30:	fc240513          	add	a0,s0,-62
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	fa6080e7          	jalr	-90(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003e3c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e40:	4741                	li	a4,16
    80003e42:	86a6                	mv	a3,s1
    80003e44:	fc040613          	add	a2,s0,-64
    80003e48:	4581                	li	a1,0
    80003e4a:	854a                	mv	a0,s2
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	c44080e7          	jalr	-956(ra) # 80003a90 <writei>
    80003e54:	1541                	add	a0,a0,-16
    80003e56:	00a03533          	snez	a0,a0
    80003e5a:	40a00533          	neg	a0,a0
}
    80003e5e:	70e2                	ld	ra,56(sp)
    80003e60:	7442                	ld	s0,48(sp)
    80003e62:	74a2                	ld	s1,40(sp)
    80003e64:	7902                	ld	s2,32(sp)
    80003e66:	69e2                	ld	s3,24(sp)
    80003e68:	6a42                	ld	s4,16(sp)
    80003e6a:	6121                	add	sp,sp,64
    80003e6c:	8082                	ret
    iput(ip);
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	a30080e7          	jalr	-1488(ra) # 8000389e <iput>
    return -1;
    80003e76:	557d                	li	a0,-1
    80003e78:	b7dd                	j	80003e5e <dirlink+0x86>
      panic("dirlink read");
    80003e7a:	00004517          	auipc	a0,0x4
    80003e7e:	7be50513          	add	a0,a0,1982 # 80008638 <syscalls+0x1e8>
    80003e82:	ffffc097          	auipc	ra,0xffffc
    80003e86:	6ba080e7          	jalr	1722(ra) # 8000053c <panic>

0000000080003e8a <namei>:

struct inode*
namei(char *path)
{
    80003e8a:	1101                	add	sp,sp,-32
    80003e8c:	ec06                	sd	ra,24(sp)
    80003e8e:	e822                	sd	s0,16(sp)
    80003e90:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e92:	fe040613          	add	a2,s0,-32
    80003e96:	4581                	li	a1,0
    80003e98:	00000097          	auipc	ra,0x0
    80003e9c:	de0080e7          	jalr	-544(ra) # 80003c78 <namex>
}
    80003ea0:	60e2                	ld	ra,24(sp)
    80003ea2:	6442                	ld	s0,16(sp)
    80003ea4:	6105                	add	sp,sp,32
    80003ea6:	8082                	ret

0000000080003ea8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ea8:	1141                	add	sp,sp,-16
    80003eaa:	e406                	sd	ra,8(sp)
    80003eac:	e022                	sd	s0,0(sp)
    80003eae:	0800                	add	s0,sp,16
    80003eb0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003eb2:	4585                	li	a1,1
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	dc4080e7          	jalr	-572(ra) # 80003c78 <namex>
}
    80003ebc:	60a2                	ld	ra,8(sp)
    80003ebe:	6402                	ld	s0,0(sp)
    80003ec0:	0141                	add	sp,sp,16
    80003ec2:	8082                	ret

0000000080003ec4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ec4:	1101                	add	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ed0:	0001d917          	auipc	s2,0x1d
    80003ed4:	d4090913          	add	s2,s2,-704 # 80020c10 <log>
    80003ed8:	01892583          	lw	a1,24(s2)
    80003edc:	02892503          	lw	a0,40(s2)
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	ff4080e7          	jalr	-12(ra) # 80002ed4 <bread>
    80003ee8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eea:	02c92603          	lw	a2,44(s2)
    80003eee:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ef0:	00c05f63          	blez	a2,80003f0e <write_head+0x4a>
    80003ef4:	0001d717          	auipc	a4,0x1d
    80003ef8:	d4c70713          	add	a4,a4,-692 # 80020c40 <log+0x30>
    80003efc:	87aa                	mv	a5,a0
    80003efe:	060a                	sll	a2,a2,0x2
    80003f00:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f02:	4314                	lw	a3,0(a4)
    80003f04:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f06:	0711                	add	a4,a4,4
    80003f08:	0791                	add	a5,a5,4
    80003f0a:	fec79ce3          	bne	a5,a2,80003f02 <write_head+0x3e>
  }
  bwrite(buf);
    80003f0e:	8526                	mv	a0,s1
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	0b6080e7          	jalr	182(ra) # 80002fc6 <bwrite>
  brelse(buf);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	0ea080e7          	jalr	234(ra) # 80003004 <brelse>
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6902                	ld	s2,0(sp)
    80003f2a:	6105                	add	sp,sp,32
    80003f2c:	8082                	ret

0000000080003f2e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2e:	0001d797          	auipc	a5,0x1d
    80003f32:	d0e7a783          	lw	a5,-754(a5) # 80020c3c <log+0x2c>
    80003f36:	0af05d63          	blez	a5,80003ff0 <install_trans+0xc2>
{
    80003f3a:	7139                	add	sp,sp,-64
    80003f3c:	fc06                	sd	ra,56(sp)
    80003f3e:	f822                	sd	s0,48(sp)
    80003f40:	f426                	sd	s1,40(sp)
    80003f42:	f04a                	sd	s2,32(sp)
    80003f44:	ec4e                	sd	s3,24(sp)
    80003f46:	e852                	sd	s4,16(sp)
    80003f48:	e456                	sd	s5,8(sp)
    80003f4a:	e05a                	sd	s6,0(sp)
    80003f4c:	0080                	add	s0,sp,64
    80003f4e:	8b2a                	mv	s6,a0
    80003f50:	0001da97          	auipc	s5,0x1d
    80003f54:	cf0a8a93          	add	s5,s5,-784 # 80020c40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f58:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f5a:	0001d997          	auipc	s3,0x1d
    80003f5e:	cb698993          	add	s3,s3,-842 # 80020c10 <log>
    80003f62:	a00d                	j	80003f84 <install_trans+0x56>
    brelse(lbuf);
    80003f64:	854a                	mv	a0,s2
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	09e080e7          	jalr	158(ra) # 80003004 <brelse>
    brelse(dbuf);
    80003f6e:	8526                	mv	a0,s1
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	094080e7          	jalr	148(ra) # 80003004 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f78:	2a05                	addw	s4,s4,1
    80003f7a:	0a91                	add	s5,s5,4
    80003f7c:	02c9a783          	lw	a5,44(s3)
    80003f80:	04fa5e63          	bge	s4,a5,80003fdc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f84:	0189a583          	lw	a1,24(s3)
    80003f88:	014585bb          	addw	a1,a1,s4
    80003f8c:	2585                	addw	a1,a1,1
    80003f8e:	0289a503          	lw	a0,40(s3)
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	f42080e7          	jalr	-190(ra) # 80002ed4 <bread>
    80003f9a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f9c:	000aa583          	lw	a1,0(s5)
    80003fa0:	0289a503          	lw	a0,40(s3)
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	f30080e7          	jalr	-208(ra) # 80002ed4 <bread>
    80003fac:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fae:	40000613          	li	a2,1024
    80003fb2:	05890593          	add	a1,s2,88
    80003fb6:	05850513          	add	a0,a0,88
    80003fba:	ffffd097          	auipc	ra,0xffffd
    80003fbe:	d70080e7          	jalr	-656(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fc2:	8526                	mv	a0,s1
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	002080e7          	jalr	2(ra) # 80002fc6 <bwrite>
    if(recovering == 0)
    80003fcc:	f80b1ce3          	bnez	s6,80003f64 <install_trans+0x36>
      bunpin(dbuf);
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	10a080e7          	jalr	266(ra) # 800030dc <bunpin>
    80003fda:	b769                	j	80003f64 <install_trans+0x36>
}
    80003fdc:	70e2                	ld	ra,56(sp)
    80003fde:	7442                	ld	s0,48(sp)
    80003fe0:	74a2                	ld	s1,40(sp)
    80003fe2:	7902                	ld	s2,32(sp)
    80003fe4:	69e2                	ld	s3,24(sp)
    80003fe6:	6a42                	ld	s4,16(sp)
    80003fe8:	6aa2                	ld	s5,8(sp)
    80003fea:	6b02                	ld	s6,0(sp)
    80003fec:	6121                	add	sp,sp,64
    80003fee:	8082                	ret
    80003ff0:	8082                	ret

0000000080003ff2 <initlog>:
{
    80003ff2:	7179                	add	sp,sp,-48
    80003ff4:	f406                	sd	ra,40(sp)
    80003ff6:	f022                	sd	s0,32(sp)
    80003ff8:	ec26                	sd	s1,24(sp)
    80003ffa:	e84a                	sd	s2,16(sp)
    80003ffc:	e44e                	sd	s3,8(sp)
    80003ffe:	1800                	add	s0,sp,48
    80004000:	892a                	mv	s2,a0
    80004002:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004004:	0001d497          	auipc	s1,0x1d
    80004008:	c0c48493          	add	s1,s1,-1012 # 80020c10 <log>
    8000400c:	00004597          	auipc	a1,0x4
    80004010:	63c58593          	add	a1,a1,1596 # 80008648 <syscalls+0x1f8>
    80004014:	8526                	mv	a0,s1
    80004016:	ffffd097          	auipc	ra,0xffffd
    8000401a:	b2c080e7          	jalr	-1236(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    8000401e:	0149a583          	lw	a1,20(s3)
    80004022:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004024:	0109a783          	lw	a5,16(s3)
    80004028:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000402a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000402e:	854a                	mv	a0,s2
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	ea4080e7          	jalr	-348(ra) # 80002ed4 <bread>
  log.lh.n = lh->n;
    80004038:	4d30                	lw	a2,88(a0)
    8000403a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000403c:	00c05f63          	blez	a2,8000405a <initlog+0x68>
    80004040:	87aa                	mv	a5,a0
    80004042:	0001d717          	auipc	a4,0x1d
    80004046:	bfe70713          	add	a4,a4,-1026 # 80020c40 <log+0x30>
    8000404a:	060a                	sll	a2,a2,0x2
    8000404c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000404e:	4ff4                	lw	a3,92(a5)
    80004050:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004052:	0791                	add	a5,a5,4
    80004054:	0711                	add	a4,a4,4
    80004056:	fec79ce3          	bne	a5,a2,8000404e <initlog+0x5c>
  brelse(buf);
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	faa080e7          	jalr	-86(ra) # 80003004 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004062:	4505                	li	a0,1
    80004064:	00000097          	auipc	ra,0x0
    80004068:	eca080e7          	jalr	-310(ra) # 80003f2e <install_trans>
  log.lh.n = 0;
    8000406c:	0001d797          	auipc	a5,0x1d
    80004070:	bc07a823          	sw	zero,-1072(a5) # 80020c3c <log+0x2c>
  write_head(); // clear the log
    80004074:	00000097          	auipc	ra,0x0
    80004078:	e50080e7          	jalr	-432(ra) # 80003ec4 <write_head>
}
    8000407c:	70a2                	ld	ra,40(sp)
    8000407e:	7402                	ld	s0,32(sp)
    80004080:	64e2                	ld	s1,24(sp)
    80004082:	6942                	ld	s2,16(sp)
    80004084:	69a2                	ld	s3,8(sp)
    80004086:	6145                	add	sp,sp,48
    80004088:	8082                	ret

000000008000408a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000408a:	1101                	add	sp,sp,-32
    8000408c:	ec06                	sd	ra,24(sp)
    8000408e:	e822                	sd	s0,16(sp)
    80004090:	e426                	sd	s1,8(sp)
    80004092:	e04a                	sd	s2,0(sp)
    80004094:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004096:	0001d517          	auipc	a0,0x1d
    8000409a:	b7a50513          	add	a0,a0,-1158 # 80020c10 <log>
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	b34080e7          	jalr	-1228(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    800040a6:	0001d497          	auipc	s1,0x1d
    800040aa:	b6a48493          	add	s1,s1,-1174 # 80020c10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040ae:	4979                	li	s2,30
    800040b0:	a039                	j	800040be <begin_op+0x34>
      sleep(&log, &log.lock);
    800040b2:	85a6                	mv	a1,s1
    800040b4:	8526                	mv	a0,s1
    800040b6:	ffffe097          	auipc	ra,0xffffe
    800040ba:	fa0080e7          	jalr	-96(ra) # 80002056 <sleep>
    if(log.committing){
    800040be:	50dc                	lw	a5,36(s1)
    800040c0:	fbed                	bnez	a5,800040b2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040c2:	5098                	lw	a4,32(s1)
    800040c4:	2705                	addw	a4,a4,1
    800040c6:	0027179b          	sllw	a5,a4,0x2
    800040ca:	9fb9                	addw	a5,a5,a4
    800040cc:	0017979b          	sllw	a5,a5,0x1
    800040d0:	54d4                	lw	a3,44(s1)
    800040d2:	9fb5                	addw	a5,a5,a3
    800040d4:	00f95963          	bge	s2,a5,800040e6 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040d8:	85a6                	mv	a1,s1
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffe097          	auipc	ra,0xffffe
    800040e0:	f7a080e7          	jalr	-134(ra) # 80002056 <sleep>
    800040e4:	bfe9                	j	800040be <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040e6:	0001d517          	auipc	a0,0x1d
    800040ea:	b2a50513          	add	a0,a0,-1238 # 80020c10 <log>
    800040ee:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800040f0:	ffffd097          	auipc	ra,0xffffd
    800040f4:	b96080e7          	jalr	-1130(ra) # 80000c86 <release>
      break;
    }
  }
}
    800040f8:	60e2                	ld	ra,24(sp)
    800040fa:	6442                	ld	s0,16(sp)
    800040fc:	64a2                	ld	s1,8(sp)
    800040fe:	6902                	ld	s2,0(sp)
    80004100:	6105                	add	sp,sp,32
    80004102:	8082                	ret

0000000080004104 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004104:	7139                	add	sp,sp,-64
    80004106:	fc06                	sd	ra,56(sp)
    80004108:	f822                	sd	s0,48(sp)
    8000410a:	f426                	sd	s1,40(sp)
    8000410c:	f04a                	sd	s2,32(sp)
    8000410e:	ec4e                	sd	s3,24(sp)
    80004110:	e852                	sd	s4,16(sp)
    80004112:	e456                	sd	s5,8(sp)
    80004114:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004116:	0001d497          	auipc	s1,0x1d
    8000411a:	afa48493          	add	s1,s1,-1286 # 80020c10 <log>
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	ab2080e7          	jalr	-1358(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    80004128:	509c                	lw	a5,32(s1)
    8000412a:	37fd                	addw	a5,a5,-1
    8000412c:	0007891b          	sext.w	s2,a5
    80004130:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004132:	50dc                	lw	a5,36(s1)
    80004134:	e7b9                	bnez	a5,80004182 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004136:	04091e63          	bnez	s2,80004192 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000413a:	0001d497          	auipc	s1,0x1d
    8000413e:	ad648493          	add	s1,s1,-1322 # 80020c10 <log>
    80004142:	4785                	li	a5,1
    80004144:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004146:	8526                	mv	a0,s1
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	b3e080e7          	jalr	-1218(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004150:	54dc                	lw	a5,44(s1)
    80004152:	06f04763          	bgtz	a5,800041c0 <end_op+0xbc>
    acquire(&log.lock);
    80004156:	0001d497          	auipc	s1,0x1d
    8000415a:	aba48493          	add	s1,s1,-1350 # 80020c10 <log>
    8000415e:	8526                	mv	a0,s1
    80004160:	ffffd097          	auipc	ra,0xffffd
    80004164:	a72080e7          	jalr	-1422(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004168:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000416c:	8526                	mv	a0,s1
    8000416e:	ffffe097          	auipc	ra,0xffffe
    80004172:	f4c080e7          	jalr	-180(ra) # 800020ba <wakeup>
    release(&log.lock);
    80004176:	8526                	mv	a0,s1
    80004178:	ffffd097          	auipc	ra,0xffffd
    8000417c:	b0e080e7          	jalr	-1266(ra) # 80000c86 <release>
}
    80004180:	a03d                	j	800041ae <end_op+0xaa>
    panic("log.committing");
    80004182:	00004517          	auipc	a0,0x4
    80004186:	4ce50513          	add	a0,a0,1230 # 80008650 <syscalls+0x200>
    8000418a:	ffffc097          	auipc	ra,0xffffc
    8000418e:	3b2080e7          	jalr	946(ra) # 8000053c <panic>
    wakeup(&log);
    80004192:	0001d497          	auipc	s1,0x1d
    80004196:	a7e48493          	add	s1,s1,-1410 # 80020c10 <log>
    8000419a:	8526                	mv	a0,s1
    8000419c:	ffffe097          	auipc	ra,0xffffe
    800041a0:	f1e080e7          	jalr	-226(ra) # 800020ba <wakeup>
  release(&log.lock);
    800041a4:	8526                	mv	a0,s1
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	ae0080e7          	jalr	-1312(ra) # 80000c86 <release>
}
    800041ae:	70e2                	ld	ra,56(sp)
    800041b0:	7442                	ld	s0,48(sp)
    800041b2:	74a2                	ld	s1,40(sp)
    800041b4:	7902                	ld	s2,32(sp)
    800041b6:	69e2                	ld	s3,24(sp)
    800041b8:	6a42                	ld	s4,16(sp)
    800041ba:	6aa2                	ld	s5,8(sp)
    800041bc:	6121                	add	sp,sp,64
    800041be:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c0:	0001da97          	auipc	s5,0x1d
    800041c4:	a80a8a93          	add	s5,s5,-1408 # 80020c40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041c8:	0001da17          	auipc	s4,0x1d
    800041cc:	a48a0a13          	add	s4,s4,-1464 # 80020c10 <log>
    800041d0:	018a2583          	lw	a1,24(s4)
    800041d4:	012585bb          	addw	a1,a1,s2
    800041d8:	2585                	addw	a1,a1,1
    800041da:	028a2503          	lw	a0,40(s4)
    800041de:	fffff097          	auipc	ra,0xfffff
    800041e2:	cf6080e7          	jalr	-778(ra) # 80002ed4 <bread>
    800041e6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041e8:	000aa583          	lw	a1,0(s5)
    800041ec:	028a2503          	lw	a0,40(s4)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	ce4080e7          	jalr	-796(ra) # 80002ed4 <bread>
    800041f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041fa:	40000613          	li	a2,1024
    800041fe:	05850593          	add	a1,a0,88
    80004202:	05848513          	add	a0,s1,88
    80004206:	ffffd097          	auipc	ra,0xffffd
    8000420a:	b24080e7          	jalr	-1244(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    8000420e:	8526                	mv	a0,s1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	db6080e7          	jalr	-586(ra) # 80002fc6 <bwrite>
    brelse(from);
    80004218:	854e                	mv	a0,s3
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	dea080e7          	jalr	-534(ra) # 80003004 <brelse>
    brelse(to);
    80004222:	8526                	mv	a0,s1
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	de0080e7          	jalr	-544(ra) # 80003004 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422c:	2905                	addw	s2,s2,1
    8000422e:	0a91                	add	s5,s5,4
    80004230:	02ca2783          	lw	a5,44(s4)
    80004234:	f8f94ee3          	blt	s2,a5,800041d0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	c8c080e7          	jalr	-884(ra) # 80003ec4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004240:	4501                	li	a0,0
    80004242:	00000097          	auipc	ra,0x0
    80004246:	cec080e7          	jalr	-788(ra) # 80003f2e <install_trans>
    log.lh.n = 0;
    8000424a:	0001d797          	auipc	a5,0x1d
    8000424e:	9e07a923          	sw	zero,-1550(a5) # 80020c3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004252:	00000097          	auipc	ra,0x0
    80004256:	c72080e7          	jalr	-910(ra) # 80003ec4 <write_head>
    8000425a:	bdf5                	j	80004156 <end_op+0x52>

000000008000425c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000425c:	1101                	add	sp,sp,-32
    8000425e:	ec06                	sd	ra,24(sp)
    80004260:	e822                	sd	s0,16(sp)
    80004262:	e426                	sd	s1,8(sp)
    80004264:	e04a                	sd	s2,0(sp)
    80004266:	1000                	add	s0,sp,32
    80004268:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000426a:	0001d917          	auipc	s2,0x1d
    8000426e:	9a690913          	add	s2,s2,-1626 # 80020c10 <log>
    80004272:	854a                	mv	a0,s2
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	95e080e7          	jalr	-1698(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000427c:	02c92603          	lw	a2,44(s2)
    80004280:	47f5                	li	a5,29
    80004282:	06c7c563          	blt	a5,a2,800042ec <log_write+0x90>
    80004286:	0001d797          	auipc	a5,0x1d
    8000428a:	9a67a783          	lw	a5,-1626(a5) # 80020c2c <log+0x1c>
    8000428e:	37fd                	addw	a5,a5,-1
    80004290:	04f65e63          	bge	a2,a5,800042ec <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004294:	0001d797          	auipc	a5,0x1d
    80004298:	99c7a783          	lw	a5,-1636(a5) # 80020c30 <log+0x20>
    8000429c:	06f05063          	blez	a5,800042fc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042a0:	4781                	li	a5,0
    800042a2:	06c05563          	blez	a2,8000430c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042a6:	44cc                	lw	a1,12(s1)
    800042a8:	0001d717          	auipc	a4,0x1d
    800042ac:	99870713          	add	a4,a4,-1640 # 80020c40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042b0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042b2:	4314                	lw	a3,0(a4)
    800042b4:	04b68c63          	beq	a3,a1,8000430c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042b8:	2785                	addw	a5,a5,1
    800042ba:	0711                	add	a4,a4,4
    800042bc:	fef61be3          	bne	a2,a5,800042b2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042c0:	0621                	add	a2,a2,8
    800042c2:	060a                	sll	a2,a2,0x2
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	94c78793          	add	a5,a5,-1716 # 80020c10 <log>
    800042cc:	97b2                	add	a5,a5,a2
    800042ce:	44d8                	lw	a4,12(s1)
    800042d0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042d2:	8526                	mv	a0,s1
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	dcc080e7          	jalr	-564(ra) # 800030a0 <bpin>
    log.lh.n++;
    800042dc:	0001d717          	auipc	a4,0x1d
    800042e0:	93470713          	add	a4,a4,-1740 # 80020c10 <log>
    800042e4:	575c                	lw	a5,44(a4)
    800042e6:	2785                	addw	a5,a5,1
    800042e8:	d75c                	sw	a5,44(a4)
    800042ea:	a82d                	j	80004324 <log_write+0xc8>
    panic("too big a transaction");
    800042ec:	00004517          	auipc	a0,0x4
    800042f0:	37450513          	add	a0,a0,884 # 80008660 <syscalls+0x210>
    800042f4:	ffffc097          	auipc	ra,0xffffc
    800042f8:	248080e7          	jalr	584(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800042fc:	00004517          	auipc	a0,0x4
    80004300:	37c50513          	add	a0,a0,892 # 80008678 <syscalls+0x228>
    80004304:	ffffc097          	auipc	ra,0xffffc
    80004308:	238080e7          	jalr	568(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    8000430c:	00878693          	add	a3,a5,8
    80004310:	068a                	sll	a3,a3,0x2
    80004312:	0001d717          	auipc	a4,0x1d
    80004316:	8fe70713          	add	a4,a4,-1794 # 80020c10 <log>
    8000431a:	9736                	add	a4,a4,a3
    8000431c:	44d4                	lw	a3,12(s1)
    8000431e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004320:	faf609e3          	beq	a2,a5,800042d2 <log_write+0x76>
  }
  release(&log.lock);
    80004324:	0001d517          	auipc	a0,0x1d
    80004328:	8ec50513          	add	a0,a0,-1812 # 80020c10 <log>
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	95a080e7          	jalr	-1702(ra) # 80000c86 <release>
}
    80004334:	60e2                	ld	ra,24(sp)
    80004336:	6442                	ld	s0,16(sp)
    80004338:	64a2                	ld	s1,8(sp)
    8000433a:	6902                	ld	s2,0(sp)
    8000433c:	6105                	add	sp,sp,32
    8000433e:	8082                	ret

0000000080004340 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004340:	1101                	add	sp,sp,-32
    80004342:	ec06                	sd	ra,24(sp)
    80004344:	e822                	sd	s0,16(sp)
    80004346:	e426                	sd	s1,8(sp)
    80004348:	e04a                	sd	s2,0(sp)
    8000434a:	1000                	add	s0,sp,32
    8000434c:	84aa                	mv	s1,a0
    8000434e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004350:	00004597          	auipc	a1,0x4
    80004354:	34858593          	add	a1,a1,840 # 80008698 <syscalls+0x248>
    80004358:	0521                	add	a0,a0,8
    8000435a:	ffffc097          	auipc	ra,0xffffc
    8000435e:	7e8080e7          	jalr	2024(ra) # 80000b42 <initlock>
  lk->name = name;
    80004362:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004366:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000436a:	0204a423          	sw	zero,40(s1)
}
    8000436e:	60e2                	ld	ra,24(sp)
    80004370:	6442                	ld	s0,16(sp)
    80004372:	64a2                	ld	s1,8(sp)
    80004374:	6902                	ld	s2,0(sp)
    80004376:	6105                	add	sp,sp,32
    80004378:	8082                	ret

000000008000437a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000437a:	1101                	add	sp,sp,-32
    8000437c:	ec06                	sd	ra,24(sp)
    8000437e:	e822                	sd	s0,16(sp)
    80004380:	e426                	sd	s1,8(sp)
    80004382:	e04a                	sd	s2,0(sp)
    80004384:	1000                	add	s0,sp,32
    80004386:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004388:	00850913          	add	s2,a0,8
    8000438c:	854a                	mv	a0,s2
    8000438e:	ffffd097          	auipc	ra,0xffffd
    80004392:	844080e7          	jalr	-1980(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004396:	409c                	lw	a5,0(s1)
    80004398:	cb89                	beqz	a5,800043aa <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000439a:	85ca                	mv	a1,s2
    8000439c:	8526                	mv	a0,s1
    8000439e:	ffffe097          	auipc	ra,0xffffe
    800043a2:	cb8080e7          	jalr	-840(ra) # 80002056 <sleep>
  while (lk->locked) {
    800043a6:	409c                	lw	a5,0(s1)
    800043a8:	fbed                	bnez	a5,8000439a <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043aa:	4785                	li	a5,1
    800043ac:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	600080e7          	jalr	1536(ra) # 800019ae <myproc>
    800043b6:	591c                	lw	a5,48(a0)
    800043b8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ba:	854a                	mv	a0,s2
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	8ca080e7          	jalr	-1846(ra) # 80000c86 <release>
}
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6902                	ld	s2,0(sp)
    800043cc:	6105                	add	sp,sp,32
    800043ce:	8082                	ret

00000000800043d0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043d0:	1101                	add	sp,sp,-32
    800043d2:	ec06                	sd	ra,24(sp)
    800043d4:	e822                	sd	s0,16(sp)
    800043d6:	e426                	sd	s1,8(sp)
    800043d8:	e04a                	sd	s2,0(sp)
    800043da:	1000                	add	s0,sp,32
    800043dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043de:	00850913          	add	s2,a0,8
    800043e2:	854a                	mv	a0,s2
    800043e4:	ffffc097          	auipc	ra,0xffffc
    800043e8:	7ee080e7          	jalr	2030(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800043ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffe097          	auipc	ra,0xffffe
    800043fa:	cc4080e7          	jalr	-828(ra) # 800020ba <wakeup>
  release(&lk->lk);
    800043fe:	854a                	mv	a0,s2
    80004400:	ffffd097          	auipc	ra,0xffffd
    80004404:	886080e7          	jalr	-1914(ra) # 80000c86 <release>
}
    80004408:	60e2                	ld	ra,24(sp)
    8000440a:	6442                	ld	s0,16(sp)
    8000440c:	64a2                	ld	s1,8(sp)
    8000440e:	6902                	ld	s2,0(sp)
    80004410:	6105                	add	sp,sp,32
    80004412:	8082                	ret

0000000080004414 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004414:	7179                	add	sp,sp,-48
    80004416:	f406                	sd	ra,40(sp)
    80004418:	f022                	sd	s0,32(sp)
    8000441a:	ec26                	sd	s1,24(sp)
    8000441c:	e84a                	sd	s2,16(sp)
    8000441e:	e44e                	sd	s3,8(sp)
    80004420:	1800                	add	s0,sp,48
    80004422:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004424:	00850913          	add	s2,a0,8
    80004428:	854a                	mv	a0,s2
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	7a8080e7          	jalr	1960(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004432:	409c                	lw	a5,0(s1)
    80004434:	ef99                	bnez	a5,80004452 <holdingsleep+0x3e>
    80004436:	4481                	li	s1,0
  release(&lk->lk);
    80004438:	854a                	mv	a0,s2
    8000443a:	ffffd097          	auipc	ra,0xffffd
    8000443e:	84c080e7          	jalr	-1972(ra) # 80000c86 <release>
  return r;
}
    80004442:	8526                	mv	a0,s1
    80004444:	70a2                	ld	ra,40(sp)
    80004446:	7402                	ld	s0,32(sp)
    80004448:	64e2                	ld	s1,24(sp)
    8000444a:	6942                	ld	s2,16(sp)
    8000444c:	69a2                	ld	s3,8(sp)
    8000444e:	6145                	add	sp,sp,48
    80004450:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004452:	0284a983          	lw	s3,40(s1)
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	558080e7          	jalr	1368(ra) # 800019ae <myproc>
    8000445e:	5904                	lw	s1,48(a0)
    80004460:	413484b3          	sub	s1,s1,s3
    80004464:	0014b493          	seqz	s1,s1
    80004468:	bfc1                	j	80004438 <holdingsleep+0x24>

000000008000446a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000446a:	1141                	add	sp,sp,-16
    8000446c:	e406                	sd	ra,8(sp)
    8000446e:	e022                	sd	s0,0(sp)
    80004470:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004472:	00004597          	auipc	a1,0x4
    80004476:	23658593          	add	a1,a1,566 # 800086a8 <syscalls+0x258>
    8000447a:	0001d517          	auipc	a0,0x1d
    8000447e:	8de50513          	add	a0,a0,-1826 # 80020d58 <ftable>
    80004482:	ffffc097          	auipc	ra,0xffffc
    80004486:	6c0080e7          	jalr	1728(ra) # 80000b42 <initlock>
}
    8000448a:	60a2                	ld	ra,8(sp)
    8000448c:	6402                	ld	s0,0(sp)
    8000448e:	0141                	add	sp,sp,16
    80004490:	8082                	ret

0000000080004492 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004492:	1101                	add	sp,sp,-32
    80004494:	ec06                	sd	ra,24(sp)
    80004496:	e822                	sd	s0,16(sp)
    80004498:	e426                	sd	s1,8(sp)
    8000449a:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000449c:	0001d517          	auipc	a0,0x1d
    800044a0:	8bc50513          	add	a0,a0,-1860 # 80020d58 <ftable>
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	72e080e7          	jalr	1838(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ac:	0001d497          	auipc	s1,0x1d
    800044b0:	8c448493          	add	s1,s1,-1852 # 80020d70 <ftable+0x18>
    800044b4:	0001e717          	auipc	a4,0x1e
    800044b8:	85c70713          	add	a4,a4,-1956 # 80021d10 <disk>
    if(f->ref == 0){
    800044bc:	40dc                	lw	a5,4(s1)
    800044be:	cf99                	beqz	a5,800044dc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044c0:	02848493          	add	s1,s1,40
    800044c4:	fee49ce3          	bne	s1,a4,800044bc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044c8:	0001d517          	auipc	a0,0x1d
    800044cc:	89050513          	add	a0,a0,-1904 # 80020d58 <ftable>
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	7b6080e7          	jalr	1974(ra) # 80000c86 <release>
  return 0;
    800044d8:	4481                	li	s1,0
    800044da:	a819                	j	800044f0 <filealloc+0x5e>
      f->ref = 1;
    800044dc:	4785                	li	a5,1
    800044de:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044e0:	0001d517          	auipc	a0,0x1d
    800044e4:	87850513          	add	a0,a0,-1928 # 80020d58 <ftable>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	79e080e7          	jalr	1950(ra) # 80000c86 <release>
}
    800044f0:	8526                	mv	a0,s1
    800044f2:	60e2                	ld	ra,24(sp)
    800044f4:	6442                	ld	s0,16(sp)
    800044f6:	64a2                	ld	s1,8(sp)
    800044f8:	6105                	add	sp,sp,32
    800044fa:	8082                	ret

00000000800044fc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044fc:	1101                	add	sp,sp,-32
    800044fe:	ec06                	sd	ra,24(sp)
    80004500:	e822                	sd	s0,16(sp)
    80004502:	e426                	sd	s1,8(sp)
    80004504:	1000                	add	s0,sp,32
    80004506:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004508:	0001d517          	auipc	a0,0x1d
    8000450c:	85050513          	add	a0,a0,-1968 # 80020d58 <ftable>
    80004510:	ffffc097          	auipc	ra,0xffffc
    80004514:	6c2080e7          	jalr	1730(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004518:	40dc                	lw	a5,4(s1)
    8000451a:	02f05263          	blez	a5,8000453e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000451e:	2785                	addw	a5,a5,1
    80004520:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004522:	0001d517          	auipc	a0,0x1d
    80004526:	83650513          	add	a0,a0,-1994 # 80020d58 <ftable>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	75c080e7          	jalr	1884(ra) # 80000c86 <release>
  return f;
}
    80004532:	8526                	mv	a0,s1
    80004534:	60e2                	ld	ra,24(sp)
    80004536:	6442                	ld	s0,16(sp)
    80004538:	64a2                	ld	s1,8(sp)
    8000453a:	6105                	add	sp,sp,32
    8000453c:	8082                	ret
    panic("filedup");
    8000453e:	00004517          	auipc	a0,0x4
    80004542:	17250513          	add	a0,a0,370 # 800086b0 <syscalls+0x260>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	ff6080e7          	jalr	-10(ra) # 8000053c <panic>

000000008000454e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000454e:	7139                	add	sp,sp,-64
    80004550:	fc06                	sd	ra,56(sp)
    80004552:	f822                	sd	s0,48(sp)
    80004554:	f426                	sd	s1,40(sp)
    80004556:	f04a                	sd	s2,32(sp)
    80004558:	ec4e                	sd	s3,24(sp)
    8000455a:	e852                	sd	s4,16(sp)
    8000455c:	e456                	sd	s5,8(sp)
    8000455e:	0080                	add	s0,sp,64
    80004560:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004562:	0001c517          	auipc	a0,0x1c
    80004566:	7f650513          	add	a0,a0,2038 # 80020d58 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	668080e7          	jalr	1640(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004572:	40dc                	lw	a5,4(s1)
    80004574:	06f05163          	blez	a5,800045d6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004578:	37fd                	addw	a5,a5,-1
    8000457a:	0007871b          	sext.w	a4,a5
    8000457e:	c0dc                	sw	a5,4(s1)
    80004580:	06e04363          	bgtz	a4,800045e6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004584:	0004a903          	lw	s2,0(s1)
    80004588:	0094ca83          	lbu	s5,9(s1)
    8000458c:	0104ba03          	ld	s4,16(s1)
    80004590:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004594:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004598:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000459c:	0001c517          	auipc	a0,0x1c
    800045a0:	7bc50513          	add	a0,a0,1980 # 80020d58 <ftable>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	6e2080e7          	jalr	1762(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800045ac:	4785                	li	a5,1
    800045ae:	04f90d63          	beq	s2,a5,80004608 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045b2:	3979                	addw	s2,s2,-2
    800045b4:	4785                	li	a5,1
    800045b6:	0527e063          	bltu	a5,s2,800045f6 <fileclose+0xa8>
    begin_op();
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	ad0080e7          	jalr	-1328(ra) # 8000408a <begin_op>
    iput(ff.ip);
    800045c2:	854e                	mv	a0,s3
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	2da080e7          	jalr	730(ra) # 8000389e <iput>
    end_op();
    800045cc:	00000097          	auipc	ra,0x0
    800045d0:	b38080e7          	jalr	-1224(ra) # 80004104 <end_op>
    800045d4:	a00d                	j	800045f6 <fileclose+0xa8>
    panic("fileclose");
    800045d6:	00004517          	auipc	a0,0x4
    800045da:	0e250513          	add	a0,a0,226 # 800086b8 <syscalls+0x268>
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	f5e080e7          	jalr	-162(ra) # 8000053c <panic>
    release(&ftable.lock);
    800045e6:	0001c517          	auipc	a0,0x1c
    800045ea:	77250513          	add	a0,a0,1906 # 80020d58 <ftable>
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	698080e7          	jalr	1688(ra) # 80000c86 <release>
  }
}
    800045f6:	70e2                	ld	ra,56(sp)
    800045f8:	7442                	ld	s0,48(sp)
    800045fa:	74a2                	ld	s1,40(sp)
    800045fc:	7902                	ld	s2,32(sp)
    800045fe:	69e2                	ld	s3,24(sp)
    80004600:	6a42                	ld	s4,16(sp)
    80004602:	6aa2                	ld	s5,8(sp)
    80004604:	6121                	add	sp,sp,64
    80004606:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004608:	85d6                	mv	a1,s5
    8000460a:	8552                	mv	a0,s4
    8000460c:	00000097          	auipc	ra,0x0
    80004610:	348080e7          	jalr	840(ra) # 80004954 <pipeclose>
    80004614:	b7cd                	j	800045f6 <fileclose+0xa8>

0000000080004616 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004616:	715d                	add	sp,sp,-80
    80004618:	e486                	sd	ra,72(sp)
    8000461a:	e0a2                	sd	s0,64(sp)
    8000461c:	fc26                	sd	s1,56(sp)
    8000461e:	f84a                	sd	s2,48(sp)
    80004620:	f44e                	sd	s3,40(sp)
    80004622:	0880                	add	s0,sp,80
    80004624:	84aa                	mv	s1,a0
    80004626:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004628:	ffffd097          	auipc	ra,0xffffd
    8000462c:	386080e7          	jalr	902(ra) # 800019ae <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004630:	409c                	lw	a5,0(s1)
    80004632:	37f9                	addw	a5,a5,-2
    80004634:	4705                	li	a4,1
    80004636:	04f76763          	bltu	a4,a5,80004684 <filestat+0x6e>
    8000463a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000463c:	6c88                	ld	a0,24(s1)
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	0a6080e7          	jalr	166(ra) # 800036e4 <ilock>
    stati(f->ip, &st);
    80004646:	fb840593          	add	a1,s0,-72
    8000464a:	6c88                	ld	a0,24(s1)
    8000464c:	fffff097          	auipc	ra,0xfffff
    80004650:	322080e7          	jalr	802(ra) # 8000396e <stati>
    iunlock(f->ip);
    80004654:	6c88                	ld	a0,24(s1)
    80004656:	fffff097          	auipc	ra,0xfffff
    8000465a:	150080e7          	jalr	336(ra) # 800037a6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000465e:	46e1                	li	a3,24
    80004660:	fb840613          	add	a2,s0,-72
    80004664:	85ce                	mv	a1,s3
    80004666:	05093503          	ld	a0,80(s2)
    8000466a:	ffffd097          	auipc	ra,0xffffd
    8000466e:	004080e7          	jalr	4(ra) # 8000166e <copyout>
    80004672:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004676:	60a6                	ld	ra,72(sp)
    80004678:	6406                	ld	s0,64(sp)
    8000467a:	74e2                	ld	s1,56(sp)
    8000467c:	7942                	ld	s2,48(sp)
    8000467e:	79a2                	ld	s3,40(sp)
    80004680:	6161                	add	sp,sp,80
    80004682:	8082                	ret
  return -1;
    80004684:	557d                	li	a0,-1
    80004686:	bfc5                	j	80004676 <filestat+0x60>

0000000080004688 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004688:	7179                	add	sp,sp,-48
    8000468a:	f406                	sd	ra,40(sp)
    8000468c:	f022                	sd	s0,32(sp)
    8000468e:	ec26                	sd	s1,24(sp)
    80004690:	e84a                	sd	s2,16(sp)
    80004692:	e44e                	sd	s3,8(sp)
    80004694:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004696:	00854783          	lbu	a5,8(a0)
    8000469a:	c3d5                	beqz	a5,8000473e <fileread+0xb6>
    8000469c:	84aa                	mv	s1,a0
    8000469e:	89ae                	mv	s3,a1
    800046a0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a2:	411c                	lw	a5,0(a0)
    800046a4:	4705                	li	a4,1
    800046a6:	04e78963          	beq	a5,a4,800046f8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046aa:	470d                	li	a4,3
    800046ac:	04e78d63          	beq	a5,a4,80004706 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b0:	4709                	li	a4,2
    800046b2:	06e79e63          	bne	a5,a4,8000472e <fileread+0xa6>
    ilock(f->ip);
    800046b6:	6d08                	ld	a0,24(a0)
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	02c080e7          	jalr	44(ra) # 800036e4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046c0:	874a                	mv	a4,s2
    800046c2:	5094                	lw	a3,32(s1)
    800046c4:	864e                	mv	a2,s3
    800046c6:	4585                	li	a1,1
    800046c8:	6c88                	ld	a0,24(s1)
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	2ce080e7          	jalr	718(ra) # 80003998 <readi>
    800046d2:	892a                	mv	s2,a0
    800046d4:	00a05563          	blez	a0,800046de <fileread+0x56>
      f->off += r;
    800046d8:	509c                	lw	a5,32(s1)
    800046da:	9fa9                	addw	a5,a5,a0
    800046dc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046de:	6c88                	ld	a0,24(s1)
    800046e0:	fffff097          	auipc	ra,0xfffff
    800046e4:	0c6080e7          	jalr	198(ra) # 800037a6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046e8:	854a                	mv	a0,s2
    800046ea:	70a2                	ld	ra,40(sp)
    800046ec:	7402                	ld	s0,32(sp)
    800046ee:	64e2                	ld	s1,24(sp)
    800046f0:	6942                	ld	s2,16(sp)
    800046f2:	69a2                	ld	s3,8(sp)
    800046f4:	6145                	add	sp,sp,48
    800046f6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046f8:	6908                	ld	a0,16(a0)
    800046fa:	00000097          	auipc	ra,0x0
    800046fe:	3c2080e7          	jalr	962(ra) # 80004abc <piperead>
    80004702:	892a                	mv	s2,a0
    80004704:	b7d5                	j	800046e8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004706:	02451783          	lh	a5,36(a0)
    8000470a:	03079693          	sll	a3,a5,0x30
    8000470e:	92c1                	srl	a3,a3,0x30
    80004710:	4725                	li	a4,9
    80004712:	02d76863          	bltu	a4,a3,80004742 <fileread+0xba>
    80004716:	0792                	sll	a5,a5,0x4
    80004718:	0001c717          	auipc	a4,0x1c
    8000471c:	5a070713          	add	a4,a4,1440 # 80020cb8 <devsw>
    80004720:	97ba                	add	a5,a5,a4
    80004722:	639c                	ld	a5,0(a5)
    80004724:	c38d                	beqz	a5,80004746 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004726:	4505                	li	a0,1
    80004728:	9782                	jalr	a5
    8000472a:	892a                	mv	s2,a0
    8000472c:	bf75                	j	800046e8 <fileread+0x60>
    panic("fileread");
    8000472e:	00004517          	auipc	a0,0x4
    80004732:	f9a50513          	add	a0,a0,-102 # 800086c8 <syscalls+0x278>
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	e06080e7          	jalr	-506(ra) # 8000053c <panic>
    return -1;
    8000473e:	597d                	li	s2,-1
    80004740:	b765                	j	800046e8 <fileread+0x60>
      return -1;
    80004742:	597d                	li	s2,-1
    80004744:	b755                	j	800046e8 <fileread+0x60>
    80004746:	597d                	li	s2,-1
    80004748:	b745                	j	800046e8 <fileread+0x60>

000000008000474a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000474a:	00954783          	lbu	a5,9(a0)
    8000474e:	10078e63          	beqz	a5,8000486a <filewrite+0x120>
{
    80004752:	715d                	add	sp,sp,-80
    80004754:	e486                	sd	ra,72(sp)
    80004756:	e0a2                	sd	s0,64(sp)
    80004758:	fc26                	sd	s1,56(sp)
    8000475a:	f84a                	sd	s2,48(sp)
    8000475c:	f44e                	sd	s3,40(sp)
    8000475e:	f052                	sd	s4,32(sp)
    80004760:	ec56                	sd	s5,24(sp)
    80004762:	e85a                	sd	s6,16(sp)
    80004764:	e45e                	sd	s7,8(sp)
    80004766:	e062                	sd	s8,0(sp)
    80004768:	0880                	add	s0,sp,80
    8000476a:	892a                	mv	s2,a0
    8000476c:	8b2e                	mv	s6,a1
    8000476e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004770:	411c                	lw	a5,0(a0)
    80004772:	4705                	li	a4,1
    80004774:	02e78263          	beq	a5,a4,80004798 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004778:	470d                	li	a4,3
    8000477a:	02e78563          	beq	a5,a4,800047a4 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000477e:	4709                	li	a4,2
    80004780:	0ce79d63          	bne	a5,a4,8000485a <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004784:	0ac05b63          	blez	a2,8000483a <filewrite+0xf0>
    int i = 0;
    80004788:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000478a:	6b85                	lui	s7,0x1
    8000478c:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004790:	6c05                	lui	s8,0x1
    80004792:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004796:	a851                	j	8000482a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004798:	6908                	ld	a0,16(a0)
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	22a080e7          	jalr	554(ra) # 800049c4 <pipewrite>
    800047a2:	a045                	j	80004842 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047a4:	02451783          	lh	a5,36(a0)
    800047a8:	03079693          	sll	a3,a5,0x30
    800047ac:	92c1                	srl	a3,a3,0x30
    800047ae:	4725                	li	a4,9
    800047b0:	0ad76f63          	bltu	a4,a3,8000486e <filewrite+0x124>
    800047b4:	0792                	sll	a5,a5,0x4
    800047b6:	0001c717          	auipc	a4,0x1c
    800047ba:	50270713          	add	a4,a4,1282 # 80020cb8 <devsw>
    800047be:	97ba                	add	a5,a5,a4
    800047c0:	679c                	ld	a5,8(a5)
    800047c2:	cbc5                	beqz	a5,80004872 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800047c4:	4505                	li	a0,1
    800047c6:	9782                	jalr	a5
    800047c8:	a8ad                	j	80004842 <filewrite+0xf8>
      if(n1 > max)
    800047ca:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800047ce:	00000097          	auipc	ra,0x0
    800047d2:	8bc080e7          	jalr	-1860(ra) # 8000408a <begin_op>
      ilock(f->ip);
    800047d6:	01893503          	ld	a0,24(s2)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	f0a080e7          	jalr	-246(ra) # 800036e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047e2:	8756                	mv	a4,s5
    800047e4:	02092683          	lw	a3,32(s2)
    800047e8:	01698633          	add	a2,s3,s6
    800047ec:	4585                	li	a1,1
    800047ee:	01893503          	ld	a0,24(s2)
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	29e080e7          	jalr	670(ra) # 80003a90 <writei>
    800047fa:	84aa                	mv	s1,a0
    800047fc:	00a05763          	blez	a0,8000480a <filewrite+0xc0>
        f->off += r;
    80004800:	02092783          	lw	a5,32(s2)
    80004804:	9fa9                	addw	a5,a5,a0
    80004806:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000480a:	01893503          	ld	a0,24(s2)
    8000480e:	fffff097          	auipc	ra,0xfffff
    80004812:	f98080e7          	jalr	-104(ra) # 800037a6 <iunlock>
      end_op();
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	8ee080e7          	jalr	-1810(ra) # 80004104 <end_op>

      if(r != n1){
    8000481e:	009a9f63          	bne	s5,s1,8000483c <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004822:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004826:	0149db63          	bge	s3,s4,8000483c <filewrite+0xf2>
      int n1 = n - i;
    8000482a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000482e:	0004879b          	sext.w	a5,s1
    80004832:	f8fbdce3          	bge	s7,a5,800047ca <filewrite+0x80>
    80004836:	84e2                	mv	s1,s8
    80004838:	bf49                	j	800047ca <filewrite+0x80>
    int i = 0;
    8000483a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000483c:	033a1d63          	bne	s4,s3,80004876 <filewrite+0x12c>
    80004840:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004842:	60a6                	ld	ra,72(sp)
    80004844:	6406                	ld	s0,64(sp)
    80004846:	74e2                	ld	s1,56(sp)
    80004848:	7942                	ld	s2,48(sp)
    8000484a:	79a2                	ld	s3,40(sp)
    8000484c:	7a02                	ld	s4,32(sp)
    8000484e:	6ae2                	ld	s5,24(sp)
    80004850:	6b42                	ld	s6,16(sp)
    80004852:	6ba2                	ld	s7,8(sp)
    80004854:	6c02                	ld	s8,0(sp)
    80004856:	6161                	add	sp,sp,80
    80004858:	8082                	ret
    panic("filewrite");
    8000485a:	00004517          	auipc	a0,0x4
    8000485e:	e7e50513          	add	a0,a0,-386 # 800086d8 <syscalls+0x288>
    80004862:	ffffc097          	auipc	ra,0xffffc
    80004866:	cda080e7          	jalr	-806(ra) # 8000053c <panic>
    return -1;
    8000486a:	557d                	li	a0,-1
}
    8000486c:	8082                	ret
      return -1;
    8000486e:	557d                	li	a0,-1
    80004870:	bfc9                	j	80004842 <filewrite+0xf8>
    80004872:	557d                	li	a0,-1
    80004874:	b7f9                	j	80004842 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004876:	557d                	li	a0,-1
    80004878:	b7e9                	j	80004842 <filewrite+0xf8>

000000008000487a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000487a:	7179                	add	sp,sp,-48
    8000487c:	f406                	sd	ra,40(sp)
    8000487e:	f022                	sd	s0,32(sp)
    80004880:	ec26                	sd	s1,24(sp)
    80004882:	e84a                	sd	s2,16(sp)
    80004884:	e44e                	sd	s3,8(sp)
    80004886:	e052                	sd	s4,0(sp)
    80004888:	1800                	add	s0,sp,48
    8000488a:	84aa                	mv	s1,a0
    8000488c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000488e:	0005b023          	sd	zero,0(a1)
    80004892:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	bfc080e7          	jalr	-1028(ra) # 80004492 <filealloc>
    8000489e:	e088                	sd	a0,0(s1)
    800048a0:	c551                	beqz	a0,8000492c <pipealloc+0xb2>
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	bf0080e7          	jalr	-1040(ra) # 80004492 <filealloc>
    800048aa:	00aa3023          	sd	a0,0(s4)
    800048ae:	c92d                	beqz	a0,80004920 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	232080e7          	jalr	562(ra) # 80000ae2 <kalloc>
    800048b8:	892a                	mv	s2,a0
    800048ba:	c125                	beqz	a0,8000491a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048bc:	4985                	li	s3,1
    800048be:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048c2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048c6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048ca:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048ce:	00004597          	auipc	a1,0x4
    800048d2:	e1a58593          	add	a1,a1,-486 # 800086e8 <syscalls+0x298>
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	26c080e7          	jalr	620(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    800048de:	609c                	ld	a5,0(s1)
    800048e0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048e4:	609c                	ld	a5,0(s1)
    800048e6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048ea:	609c                	ld	a5,0(s1)
    800048ec:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048f0:	609c                	ld	a5,0(s1)
    800048f2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048f6:	000a3783          	ld	a5,0(s4)
    800048fa:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048fe:	000a3783          	ld	a5,0(s4)
    80004902:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004906:	000a3783          	ld	a5,0(s4)
    8000490a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000490e:	000a3783          	ld	a5,0(s4)
    80004912:	0127b823          	sd	s2,16(a5)
  return 0;
    80004916:	4501                	li	a0,0
    80004918:	a025                	j	80004940 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000491a:	6088                	ld	a0,0(s1)
    8000491c:	e501                	bnez	a0,80004924 <pipealloc+0xaa>
    8000491e:	a039                	j	8000492c <pipealloc+0xb2>
    80004920:	6088                	ld	a0,0(s1)
    80004922:	c51d                	beqz	a0,80004950 <pipealloc+0xd6>
    fileclose(*f0);
    80004924:	00000097          	auipc	ra,0x0
    80004928:	c2a080e7          	jalr	-982(ra) # 8000454e <fileclose>
  if(*f1)
    8000492c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004930:	557d                	li	a0,-1
  if(*f1)
    80004932:	c799                	beqz	a5,80004940 <pipealloc+0xc6>
    fileclose(*f1);
    80004934:	853e                	mv	a0,a5
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	c18080e7          	jalr	-1000(ra) # 8000454e <fileclose>
  return -1;
    8000493e:	557d                	li	a0,-1
}
    80004940:	70a2                	ld	ra,40(sp)
    80004942:	7402                	ld	s0,32(sp)
    80004944:	64e2                	ld	s1,24(sp)
    80004946:	6942                	ld	s2,16(sp)
    80004948:	69a2                	ld	s3,8(sp)
    8000494a:	6a02                	ld	s4,0(sp)
    8000494c:	6145                	add	sp,sp,48
    8000494e:	8082                	ret
  return -1;
    80004950:	557d                	li	a0,-1
    80004952:	b7fd                	j	80004940 <pipealloc+0xc6>

0000000080004954 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004954:	1101                	add	sp,sp,-32
    80004956:	ec06                	sd	ra,24(sp)
    80004958:	e822                	sd	s0,16(sp)
    8000495a:	e426                	sd	s1,8(sp)
    8000495c:	e04a                	sd	s2,0(sp)
    8000495e:	1000                	add	s0,sp,32
    80004960:	84aa                	mv	s1,a0
    80004962:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	26e080e7          	jalr	622(ra) # 80000bd2 <acquire>
  if(writable){
    8000496c:	02090d63          	beqz	s2,800049a6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004970:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004974:	21848513          	add	a0,s1,536
    80004978:	ffffd097          	auipc	ra,0xffffd
    8000497c:	742080e7          	jalr	1858(ra) # 800020ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004980:	2204b783          	ld	a5,544(s1)
    80004984:	eb95                	bnez	a5,800049b8 <pipeclose+0x64>
    release(&pi->lock);
    80004986:	8526                	mv	a0,s1
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	2fe080e7          	jalr	766(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004990:	8526                	mv	a0,s1
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	052080e7          	jalr	82(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    8000499a:	60e2                	ld	ra,24(sp)
    8000499c:	6442                	ld	s0,16(sp)
    8000499e:	64a2                	ld	s1,8(sp)
    800049a0:	6902                	ld	s2,0(sp)
    800049a2:	6105                	add	sp,sp,32
    800049a4:	8082                	ret
    pi->readopen = 0;
    800049a6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049aa:	21c48513          	add	a0,s1,540
    800049ae:	ffffd097          	auipc	ra,0xffffd
    800049b2:	70c080e7          	jalr	1804(ra) # 800020ba <wakeup>
    800049b6:	b7e9                	j	80004980 <pipeclose+0x2c>
    release(&pi->lock);
    800049b8:	8526                	mv	a0,s1
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	2cc080e7          	jalr	716(ra) # 80000c86 <release>
}
    800049c2:	bfe1                	j	8000499a <pipeclose+0x46>

00000000800049c4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049c4:	711d                	add	sp,sp,-96
    800049c6:	ec86                	sd	ra,88(sp)
    800049c8:	e8a2                	sd	s0,80(sp)
    800049ca:	e4a6                	sd	s1,72(sp)
    800049cc:	e0ca                	sd	s2,64(sp)
    800049ce:	fc4e                	sd	s3,56(sp)
    800049d0:	f852                	sd	s4,48(sp)
    800049d2:	f456                	sd	s5,40(sp)
    800049d4:	f05a                	sd	s6,32(sp)
    800049d6:	ec5e                	sd	s7,24(sp)
    800049d8:	e862                	sd	s8,16(sp)
    800049da:	1080                	add	s0,sp,96
    800049dc:	84aa                	mv	s1,a0
    800049de:	8aae                	mv	s5,a1
    800049e0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049e2:	ffffd097          	auipc	ra,0xffffd
    800049e6:	fcc080e7          	jalr	-52(ra) # 800019ae <myproc>
    800049ea:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049ec:	8526                	mv	a0,s1
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	1e4080e7          	jalr	484(ra) # 80000bd2 <acquire>
  while(i < n){
    800049f6:	0b405663          	blez	s4,80004aa2 <pipewrite+0xde>
  int i = 0;
    800049fa:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049fc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049fe:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a02:	21c48b93          	add	s7,s1,540
    80004a06:	a089                	j	80004a48 <pipewrite+0x84>
      release(&pi->lock);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	27c080e7          	jalr	636(ra) # 80000c86 <release>
      return -1;
    80004a12:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a14:	854a                	mv	a0,s2
    80004a16:	60e6                	ld	ra,88(sp)
    80004a18:	6446                	ld	s0,80(sp)
    80004a1a:	64a6                	ld	s1,72(sp)
    80004a1c:	6906                	ld	s2,64(sp)
    80004a1e:	79e2                	ld	s3,56(sp)
    80004a20:	7a42                	ld	s4,48(sp)
    80004a22:	7aa2                	ld	s5,40(sp)
    80004a24:	7b02                	ld	s6,32(sp)
    80004a26:	6be2                	ld	s7,24(sp)
    80004a28:	6c42                	ld	s8,16(sp)
    80004a2a:	6125                	add	sp,sp,96
    80004a2c:	8082                	ret
      wakeup(&pi->nread);
    80004a2e:	8562                	mv	a0,s8
    80004a30:	ffffd097          	auipc	ra,0xffffd
    80004a34:	68a080e7          	jalr	1674(ra) # 800020ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a38:	85a6                	mv	a1,s1
    80004a3a:	855e                	mv	a0,s7
    80004a3c:	ffffd097          	auipc	ra,0xffffd
    80004a40:	61a080e7          	jalr	1562(ra) # 80002056 <sleep>
  while(i < n){
    80004a44:	07495063          	bge	s2,s4,80004aa4 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a48:	2204a783          	lw	a5,544(s1)
    80004a4c:	dfd5                	beqz	a5,80004a08 <pipewrite+0x44>
    80004a4e:	854e                	mv	a0,s3
    80004a50:	ffffe097          	auipc	ra,0xffffe
    80004a54:	8ae080e7          	jalr	-1874(ra) # 800022fe <killed>
    80004a58:	f945                	bnez	a0,80004a08 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a5a:	2184a783          	lw	a5,536(s1)
    80004a5e:	21c4a703          	lw	a4,540(s1)
    80004a62:	2007879b          	addw	a5,a5,512
    80004a66:	fcf704e3          	beq	a4,a5,80004a2e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a6a:	4685                	li	a3,1
    80004a6c:	01590633          	add	a2,s2,s5
    80004a70:	faf40593          	add	a1,s0,-81
    80004a74:	0509b503          	ld	a0,80(s3)
    80004a78:	ffffd097          	auipc	ra,0xffffd
    80004a7c:	c82080e7          	jalr	-894(ra) # 800016fa <copyin>
    80004a80:	03650263          	beq	a0,s6,80004aa4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a84:	21c4a783          	lw	a5,540(s1)
    80004a88:	0017871b          	addw	a4,a5,1
    80004a8c:	20e4ae23          	sw	a4,540(s1)
    80004a90:	1ff7f793          	and	a5,a5,511
    80004a94:	97a6                	add	a5,a5,s1
    80004a96:	faf44703          	lbu	a4,-81(s0)
    80004a9a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a9e:	2905                	addw	s2,s2,1
    80004aa0:	b755                	j	80004a44 <pipewrite+0x80>
  int i = 0;
    80004aa2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004aa4:	21848513          	add	a0,s1,536
    80004aa8:	ffffd097          	auipc	ra,0xffffd
    80004aac:	612080e7          	jalr	1554(ra) # 800020ba <wakeup>
  release(&pi->lock);
    80004ab0:	8526                	mv	a0,s1
    80004ab2:	ffffc097          	auipc	ra,0xffffc
    80004ab6:	1d4080e7          	jalr	468(ra) # 80000c86 <release>
  return i;
    80004aba:	bfa9                	j	80004a14 <pipewrite+0x50>

0000000080004abc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004abc:	715d                	add	sp,sp,-80
    80004abe:	e486                	sd	ra,72(sp)
    80004ac0:	e0a2                	sd	s0,64(sp)
    80004ac2:	fc26                	sd	s1,56(sp)
    80004ac4:	f84a                	sd	s2,48(sp)
    80004ac6:	f44e                	sd	s3,40(sp)
    80004ac8:	f052                	sd	s4,32(sp)
    80004aca:	ec56                	sd	s5,24(sp)
    80004acc:	e85a                	sd	s6,16(sp)
    80004ace:	0880                	add	s0,sp,80
    80004ad0:	84aa                	mv	s1,a0
    80004ad2:	892e                	mv	s2,a1
    80004ad4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	ed8080e7          	jalr	-296(ra) # 800019ae <myproc>
    80004ade:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	0f0080e7          	jalr	240(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aea:	2184a703          	lw	a4,536(s1)
    80004aee:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004af2:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af6:	02f71763          	bne	a4,a5,80004b24 <piperead+0x68>
    80004afa:	2244a783          	lw	a5,548(s1)
    80004afe:	c39d                	beqz	a5,80004b24 <piperead+0x68>
    if(killed(pr)){
    80004b00:	8552                	mv	a0,s4
    80004b02:	ffffd097          	auipc	ra,0xffffd
    80004b06:	7fc080e7          	jalr	2044(ra) # 800022fe <killed>
    80004b0a:	e949                	bnez	a0,80004b9c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b0c:	85a6                	mv	a1,s1
    80004b0e:	854e                	mv	a0,s3
    80004b10:	ffffd097          	auipc	ra,0xffffd
    80004b14:	546080e7          	jalr	1350(ra) # 80002056 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b18:	2184a703          	lw	a4,536(s1)
    80004b1c:	21c4a783          	lw	a5,540(s1)
    80004b20:	fcf70de3          	beq	a4,a5,80004afa <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b24:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b26:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b28:	05505463          	blez	s5,80004b70 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b2c:	2184a783          	lw	a5,536(s1)
    80004b30:	21c4a703          	lw	a4,540(s1)
    80004b34:	02f70e63          	beq	a4,a5,80004b70 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b38:	0017871b          	addw	a4,a5,1
    80004b3c:	20e4ac23          	sw	a4,536(s1)
    80004b40:	1ff7f793          	and	a5,a5,511
    80004b44:	97a6                	add	a5,a5,s1
    80004b46:	0187c783          	lbu	a5,24(a5)
    80004b4a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b4e:	4685                	li	a3,1
    80004b50:	fbf40613          	add	a2,s0,-65
    80004b54:	85ca                	mv	a1,s2
    80004b56:	050a3503          	ld	a0,80(s4)
    80004b5a:	ffffd097          	auipc	ra,0xffffd
    80004b5e:	b14080e7          	jalr	-1260(ra) # 8000166e <copyout>
    80004b62:	01650763          	beq	a0,s6,80004b70 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b66:	2985                	addw	s3,s3,1
    80004b68:	0905                	add	s2,s2,1
    80004b6a:	fd3a91e3          	bne	s5,s3,80004b2c <piperead+0x70>
    80004b6e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b70:	21c48513          	add	a0,s1,540
    80004b74:	ffffd097          	auipc	ra,0xffffd
    80004b78:	546080e7          	jalr	1350(ra) # 800020ba <wakeup>
  release(&pi->lock);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	108080e7          	jalr	264(ra) # 80000c86 <release>
  return i;
}
    80004b86:	854e                	mv	a0,s3
    80004b88:	60a6                	ld	ra,72(sp)
    80004b8a:	6406                	ld	s0,64(sp)
    80004b8c:	74e2                	ld	s1,56(sp)
    80004b8e:	7942                	ld	s2,48(sp)
    80004b90:	79a2                	ld	s3,40(sp)
    80004b92:	7a02                	ld	s4,32(sp)
    80004b94:	6ae2                	ld	s5,24(sp)
    80004b96:	6b42                	ld	s6,16(sp)
    80004b98:	6161                	add	sp,sp,80
    80004b9a:	8082                	ret
      release(&pi->lock);
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	ffffc097          	auipc	ra,0xffffc
    80004ba2:	0e8080e7          	jalr	232(ra) # 80000c86 <release>
      return -1;
    80004ba6:	59fd                	li	s3,-1
    80004ba8:	bff9                	j	80004b86 <piperead+0xca>

0000000080004baa <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004baa:	1141                	add	sp,sp,-16
    80004bac:	e422                	sd	s0,8(sp)
    80004bae:	0800                	add	s0,sp,16
    80004bb0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bb2:	8905                	and	a0,a0,1
    80004bb4:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bb6:	8b89                	and	a5,a5,2
    80004bb8:	c399                	beqz	a5,80004bbe <flags2perm+0x14>
      perm |= PTE_W;
    80004bba:	00456513          	or	a0,a0,4
    return perm;
}
    80004bbe:	6422                	ld	s0,8(sp)
    80004bc0:	0141                	add	sp,sp,16
    80004bc2:	8082                	ret

0000000080004bc4 <exec>:

int
exec(char *path, char **argv)
{
    80004bc4:	df010113          	add	sp,sp,-528
    80004bc8:	20113423          	sd	ra,520(sp)
    80004bcc:	20813023          	sd	s0,512(sp)
    80004bd0:	ffa6                	sd	s1,504(sp)
    80004bd2:	fbca                	sd	s2,496(sp)
    80004bd4:	f7ce                	sd	s3,488(sp)
    80004bd6:	f3d2                	sd	s4,480(sp)
    80004bd8:	efd6                	sd	s5,472(sp)
    80004bda:	ebda                	sd	s6,464(sp)
    80004bdc:	e7de                	sd	s7,456(sp)
    80004bde:	e3e2                	sd	s8,448(sp)
    80004be0:	ff66                	sd	s9,440(sp)
    80004be2:	fb6a                	sd	s10,432(sp)
    80004be4:	f76e                	sd	s11,424(sp)
    80004be6:	0c00                	add	s0,sp,528
    80004be8:	892a                	mv	s2,a0
    80004bea:	dea43c23          	sd	a0,-520(s0)
    80004bee:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bf2:	ffffd097          	auipc	ra,0xffffd
    80004bf6:	dbc080e7          	jalr	-580(ra) # 800019ae <myproc>
    80004bfa:	84aa                	mv	s1,a0

  begin_op();
    80004bfc:	fffff097          	auipc	ra,0xfffff
    80004c00:	48e080e7          	jalr	1166(ra) # 8000408a <begin_op>

  if((ip = namei(path)) == 0){
    80004c04:	854a                	mv	a0,s2
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	284080e7          	jalr	644(ra) # 80003e8a <namei>
    80004c0e:	c92d                	beqz	a0,80004c80 <exec+0xbc>
    80004c10:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	ad2080e7          	jalr	-1326(ra) # 800036e4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c1a:	04000713          	li	a4,64
    80004c1e:	4681                	li	a3,0
    80004c20:	e5040613          	add	a2,s0,-432
    80004c24:	4581                	li	a1,0
    80004c26:	8552                	mv	a0,s4
    80004c28:	fffff097          	auipc	ra,0xfffff
    80004c2c:	d70080e7          	jalr	-656(ra) # 80003998 <readi>
    80004c30:	04000793          	li	a5,64
    80004c34:	00f51a63          	bne	a0,a5,80004c48 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c38:	e5042703          	lw	a4,-432(s0)
    80004c3c:	464c47b7          	lui	a5,0x464c4
    80004c40:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c44:	04f70463          	beq	a4,a5,80004c8c <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c48:	8552                	mv	a0,s4
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	cfc080e7          	jalr	-772(ra) # 80003946 <iunlockput>
    end_op();
    80004c52:	fffff097          	auipc	ra,0xfffff
    80004c56:	4b2080e7          	jalr	1202(ra) # 80004104 <end_op>
  }
  return -1;
    80004c5a:	557d                	li	a0,-1
}
    80004c5c:	20813083          	ld	ra,520(sp)
    80004c60:	20013403          	ld	s0,512(sp)
    80004c64:	74fe                	ld	s1,504(sp)
    80004c66:	795e                	ld	s2,496(sp)
    80004c68:	79be                	ld	s3,488(sp)
    80004c6a:	7a1e                	ld	s4,480(sp)
    80004c6c:	6afe                	ld	s5,472(sp)
    80004c6e:	6b5e                	ld	s6,464(sp)
    80004c70:	6bbe                	ld	s7,456(sp)
    80004c72:	6c1e                	ld	s8,448(sp)
    80004c74:	7cfa                	ld	s9,440(sp)
    80004c76:	7d5a                	ld	s10,432(sp)
    80004c78:	7dba                	ld	s11,424(sp)
    80004c7a:	21010113          	add	sp,sp,528
    80004c7e:	8082                	ret
    end_op();
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	484080e7          	jalr	1156(ra) # 80004104 <end_op>
    return -1;
    80004c88:	557d                	li	a0,-1
    80004c8a:	bfc9                	j	80004c5c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffd097          	auipc	ra,0xffffd
    80004c92:	de4080e7          	jalr	-540(ra) # 80001a72 <proc_pagetable>
    80004c96:	8b2a                	mv	s6,a0
    80004c98:	d945                	beqz	a0,80004c48 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c9a:	e7042d03          	lw	s10,-400(s0)
    80004c9e:	e8845783          	lhu	a5,-376(s0)
    80004ca2:	10078463          	beqz	a5,80004daa <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ca6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ca8:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004caa:	6c85                	lui	s9,0x1
    80004cac:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004cb0:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cb4:	6a85                	lui	s5,0x1
    80004cb6:	a0b5                	j	80004d22 <exec+0x15e>
      panic("loadseg: address should exist");
    80004cb8:	00004517          	auipc	a0,0x4
    80004cbc:	a3850513          	add	a0,a0,-1480 # 800086f0 <syscalls+0x2a0>
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	87c080e7          	jalr	-1924(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004cc8:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cca:	8726                	mv	a4,s1
    80004ccc:	012c06bb          	addw	a3,s8,s2
    80004cd0:	4581                	li	a1,0
    80004cd2:	8552                	mv	a0,s4
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	cc4080e7          	jalr	-828(ra) # 80003998 <readi>
    80004cdc:	2501                	sext.w	a0,a0
    80004cde:	24a49863          	bne	s1,a0,80004f2e <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004ce2:	012a893b          	addw	s2,s5,s2
    80004ce6:	03397563          	bgeu	s2,s3,80004d10 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004cea:	02091593          	sll	a1,s2,0x20
    80004cee:	9181                	srl	a1,a1,0x20
    80004cf0:	95de                	add	a1,a1,s7
    80004cf2:	855a                	mv	a0,s6
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	36a080e7          	jalr	874(ra) # 8000105e <walkaddr>
    80004cfc:	862a                	mv	a2,a0
    if(pa == 0)
    80004cfe:	dd4d                	beqz	a0,80004cb8 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004d00:	412984bb          	subw	s1,s3,s2
    80004d04:	0004879b          	sext.w	a5,s1
    80004d08:	fcfcf0e3          	bgeu	s9,a5,80004cc8 <exec+0x104>
    80004d0c:	84d6                	mv	s1,s5
    80004d0e:	bf6d                	j	80004cc8 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d10:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d14:	2d85                	addw	s11,s11,1
    80004d16:	038d0d1b          	addw	s10,s10,56
    80004d1a:	e8845783          	lhu	a5,-376(s0)
    80004d1e:	08fdd763          	bge	s11,a5,80004dac <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d22:	2d01                	sext.w	s10,s10
    80004d24:	03800713          	li	a4,56
    80004d28:	86ea                	mv	a3,s10
    80004d2a:	e1840613          	add	a2,s0,-488
    80004d2e:	4581                	li	a1,0
    80004d30:	8552                	mv	a0,s4
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	c66080e7          	jalr	-922(ra) # 80003998 <readi>
    80004d3a:	03800793          	li	a5,56
    80004d3e:	1ef51663          	bne	a0,a5,80004f2a <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004d42:	e1842783          	lw	a5,-488(s0)
    80004d46:	4705                	li	a4,1
    80004d48:	fce796e3          	bne	a5,a4,80004d14 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004d4c:	e4043483          	ld	s1,-448(s0)
    80004d50:	e3843783          	ld	a5,-456(s0)
    80004d54:	1ef4e863          	bltu	s1,a5,80004f44 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d58:	e2843783          	ld	a5,-472(s0)
    80004d5c:	94be                	add	s1,s1,a5
    80004d5e:	1ef4e663          	bltu	s1,a5,80004f4a <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004d62:	df043703          	ld	a4,-528(s0)
    80004d66:	8ff9                	and	a5,a5,a4
    80004d68:	1e079463          	bnez	a5,80004f50 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d6c:	e1c42503          	lw	a0,-484(s0)
    80004d70:	00000097          	auipc	ra,0x0
    80004d74:	e3a080e7          	jalr	-454(ra) # 80004baa <flags2perm>
    80004d78:	86aa                	mv	a3,a0
    80004d7a:	8626                	mv	a2,s1
    80004d7c:	85ca                	mv	a1,s2
    80004d7e:	855a                	mv	a0,s6
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	692080e7          	jalr	1682(ra) # 80001412 <uvmalloc>
    80004d88:	e0a43423          	sd	a0,-504(s0)
    80004d8c:	1c050563          	beqz	a0,80004f56 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d90:	e2843b83          	ld	s7,-472(s0)
    80004d94:	e2042c03          	lw	s8,-480(s0)
    80004d98:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d9c:	00098463          	beqz	s3,80004da4 <exec+0x1e0>
    80004da0:	4901                	li	s2,0
    80004da2:	b7a1                	j	80004cea <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004da4:	e0843903          	ld	s2,-504(s0)
    80004da8:	b7b5                	j	80004d14 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004daa:	4901                	li	s2,0
  iunlockput(ip);
    80004dac:	8552                	mv	a0,s4
    80004dae:	fffff097          	auipc	ra,0xfffff
    80004db2:	b98080e7          	jalr	-1128(ra) # 80003946 <iunlockput>
  end_op();
    80004db6:	fffff097          	auipc	ra,0xfffff
    80004dba:	34e080e7          	jalr	846(ra) # 80004104 <end_op>
  p = myproc();
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	bf0080e7          	jalr	-1040(ra) # 800019ae <myproc>
    80004dc6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004dc8:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004dcc:	6985                	lui	s3,0x1
    80004dce:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004dd0:	99ca                	add	s3,s3,s2
    80004dd2:	77fd                	lui	a5,0xfffff
    80004dd4:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004dd8:	4691                	li	a3,4
    80004dda:	6609                	lui	a2,0x2
    80004ddc:	964e                	add	a2,a2,s3
    80004dde:	85ce                	mv	a1,s3
    80004de0:	855a                	mv	a0,s6
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	630080e7          	jalr	1584(ra) # 80001412 <uvmalloc>
    80004dea:	892a                	mv	s2,a0
    80004dec:	e0a43423          	sd	a0,-504(s0)
    80004df0:	e509                	bnez	a0,80004dfa <exec+0x236>
  if(pagetable)
    80004df2:	e1343423          	sd	s3,-504(s0)
    80004df6:	4a01                	li	s4,0
    80004df8:	aa1d                	j	80004f2e <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dfa:	75f9                	lui	a1,0xffffe
    80004dfc:	95aa                	add	a1,a1,a0
    80004dfe:	855a                	mv	a0,s6
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	83c080e7          	jalr	-1988(ra) # 8000163c <uvmclear>
  stackbase = sp - PGSIZE;
    80004e08:	7bfd                	lui	s7,0xfffff
    80004e0a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004e0c:	e0043783          	ld	a5,-512(s0)
    80004e10:	6388                	ld	a0,0(a5)
    80004e12:	c52d                	beqz	a0,80004e7c <exec+0x2b8>
    80004e14:	e9040993          	add	s3,s0,-368
    80004e18:	f9040c13          	add	s8,s0,-112
    80004e1c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	02a080e7          	jalr	42(ra) # 80000e48 <strlen>
    80004e26:	0015079b          	addw	a5,a0,1
    80004e2a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e2e:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80004e32:	13796563          	bltu	s2,s7,80004f5c <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e36:	e0043d03          	ld	s10,-512(s0)
    80004e3a:	000d3a03          	ld	s4,0(s10)
    80004e3e:	8552                	mv	a0,s4
    80004e40:	ffffc097          	auipc	ra,0xffffc
    80004e44:	008080e7          	jalr	8(ra) # 80000e48 <strlen>
    80004e48:	0015069b          	addw	a3,a0,1
    80004e4c:	8652                	mv	a2,s4
    80004e4e:	85ca                	mv	a1,s2
    80004e50:	855a                	mv	a0,s6
    80004e52:	ffffd097          	auipc	ra,0xffffd
    80004e56:	81c080e7          	jalr	-2020(ra) # 8000166e <copyout>
    80004e5a:	10054363          	bltz	a0,80004f60 <exec+0x39c>
    ustack[argc] = sp;
    80004e5e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e62:	0485                	add	s1,s1,1
    80004e64:	008d0793          	add	a5,s10,8
    80004e68:	e0f43023          	sd	a5,-512(s0)
    80004e6c:	008d3503          	ld	a0,8(s10)
    80004e70:	c909                	beqz	a0,80004e82 <exec+0x2be>
    if(argc >= MAXARG)
    80004e72:	09a1                	add	s3,s3,8
    80004e74:	fb8995e3          	bne	s3,s8,80004e1e <exec+0x25a>
  ip = 0;
    80004e78:	4a01                	li	s4,0
    80004e7a:	a855                	j	80004f2e <exec+0x36a>
  sp = sz;
    80004e7c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e80:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e82:	00349793          	sll	a5,s1,0x3
    80004e86:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc140>
    80004e8a:	97a2                	add	a5,a5,s0
    80004e8c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e90:	00148693          	add	a3,s1,1
    80004e94:	068e                	sll	a3,a3,0x3
    80004e96:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e9a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80004e9e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004ea2:	f57968e3          	bltu	s2,s7,80004df2 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ea6:	e9040613          	add	a2,s0,-368
    80004eaa:	85ca                	mv	a1,s2
    80004eac:	855a                	mv	a0,s6
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	7c0080e7          	jalr	1984(ra) # 8000166e <copyout>
    80004eb6:	0a054763          	bltz	a0,80004f64 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004eba:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004ebe:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ec2:	df843783          	ld	a5,-520(s0)
    80004ec6:	0007c703          	lbu	a4,0(a5)
    80004eca:	cf11                	beqz	a4,80004ee6 <exec+0x322>
    80004ecc:	0785                	add	a5,a5,1
    if(*s == '/')
    80004ece:	02f00693          	li	a3,47
    80004ed2:	a039                	j	80004ee0 <exec+0x31c>
      last = s+1;
    80004ed4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004ed8:	0785                	add	a5,a5,1
    80004eda:	fff7c703          	lbu	a4,-1(a5)
    80004ede:	c701                	beqz	a4,80004ee6 <exec+0x322>
    if(*s == '/')
    80004ee0:	fed71ce3          	bne	a4,a3,80004ed8 <exec+0x314>
    80004ee4:	bfc5                	j	80004ed4 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ee6:	4641                	li	a2,16
    80004ee8:	df843583          	ld	a1,-520(s0)
    80004eec:	158a8513          	add	a0,s5,344
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	f26080e7          	jalr	-218(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ef8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004efc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f00:	e0843783          	ld	a5,-504(s0)
    80004f04:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f08:	058ab783          	ld	a5,88(s5)
    80004f0c:	e6843703          	ld	a4,-408(s0)
    80004f10:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f12:	058ab783          	ld	a5,88(s5)
    80004f16:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f1a:	85e6                	mv	a1,s9
    80004f1c:	ffffd097          	auipc	ra,0xffffd
    80004f20:	bf2080e7          	jalr	-1038(ra) # 80001b0e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f24:	0004851b          	sext.w	a0,s1
    80004f28:	bb15                	j	80004c5c <exec+0x98>
    80004f2a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004f2e:	e0843583          	ld	a1,-504(s0)
    80004f32:	855a                	mv	a0,s6
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	bda080e7          	jalr	-1062(ra) # 80001b0e <proc_freepagetable>
  return -1;
    80004f3c:	557d                	li	a0,-1
  if(ip){
    80004f3e:	d00a0fe3          	beqz	s4,80004c5c <exec+0x98>
    80004f42:	b319                	j	80004c48 <exec+0x84>
    80004f44:	e1243423          	sd	s2,-504(s0)
    80004f48:	b7dd                	j	80004f2e <exec+0x36a>
    80004f4a:	e1243423          	sd	s2,-504(s0)
    80004f4e:	b7c5                	j	80004f2e <exec+0x36a>
    80004f50:	e1243423          	sd	s2,-504(s0)
    80004f54:	bfe9                	j	80004f2e <exec+0x36a>
    80004f56:	e1243423          	sd	s2,-504(s0)
    80004f5a:	bfd1                	j	80004f2e <exec+0x36a>
  ip = 0;
    80004f5c:	4a01                	li	s4,0
    80004f5e:	bfc1                	j	80004f2e <exec+0x36a>
    80004f60:	4a01                	li	s4,0
  if(pagetable)
    80004f62:	b7f1                	j	80004f2e <exec+0x36a>
  sz = sz1;
    80004f64:	e0843983          	ld	s3,-504(s0)
    80004f68:	b569                	j	80004df2 <exec+0x22e>

0000000080004f6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f6a:	7179                	add	sp,sp,-48
    80004f6c:	f406                	sd	ra,40(sp)
    80004f6e:	f022                	sd	s0,32(sp)
    80004f70:	ec26                	sd	s1,24(sp)
    80004f72:	e84a                	sd	s2,16(sp)
    80004f74:	1800                	add	s0,sp,48
    80004f76:	892e                	mv	s2,a1
    80004f78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f7a:	fdc40593          	add	a1,s0,-36
    80004f7e:	ffffe097          	auipc	ra,0xffffe
    80004f82:	b4a080e7          	jalr	-1206(ra) # 80002ac8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f86:	fdc42703          	lw	a4,-36(s0)
    80004f8a:	47bd                	li	a5,15
    80004f8c:	02e7eb63          	bltu	a5,a4,80004fc2 <argfd+0x58>
    80004f90:	ffffd097          	auipc	ra,0xffffd
    80004f94:	a1e080e7          	jalr	-1506(ra) # 800019ae <myproc>
    80004f98:	fdc42703          	lw	a4,-36(s0)
    80004f9c:	01a70793          	add	a5,a4,26
    80004fa0:	078e                	sll	a5,a5,0x3
    80004fa2:	953e                	add	a0,a0,a5
    80004fa4:	611c                	ld	a5,0(a0)
    80004fa6:	c385                	beqz	a5,80004fc6 <argfd+0x5c>
    return -1;
  if(pfd)
    80004fa8:	00090463          	beqz	s2,80004fb0 <argfd+0x46>
    *pfd = fd;
    80004fac:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fb0:	4501                	li	a0,0
  if(pf)
    80004fb2:	c091                	beqz	s1,80004fb6 <argfd+0x4c>
    *pf = f;
    80004fb4:	e09c                	sd	a5,0(s1)
}
    80004fb6:	70a2                	ld	ra,40(sp)
    80004fb8:	7402                	ld	s0,32(sp)
    80004fba:	64e2                	ld	s1,24(sp)
    80004fbc:	6942                	ld	s2,16(sp)
    80004fbe:	6145                	add	sp,sp,48
    80004fc0:	8082                	ret
    return -1;
    80004fc2:	557d                	li	a0,-1
    80004fc4:	bfcd                	j	80004fb6 <argfd+0x4c>
    80004fc6:	557d                	li	a0,-1
    80004fc8:	b7fd                	j	80004fb6 <argfd+0x4c>

0000000080004fca <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fca:	1101                	add	sp,sp,-32
    80004fcc:	ec06                	sd	ra,24(sp)
    80004fce:	e822                	sd	s0,16(sp)
    80004fd0:	e426                	sd	s1,8(sp)
    80004fd2:	1000                	add	s0,sp,32
    80004fd4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fd6:	ffffd097          	auipc	ra,0xffffd
    80004fda:	9d8080e7          	jalr	-1576(ra) # 800019ae <myproc>
    80004fde:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fe0:	0d050793          	add	a5,a0,208
    80004fe4:	4501                	li	a0,0
    80004fe6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fe8:	6398                	ld	a4,0(a5)
    80004fea:	cb19                	beqz	a4,80005000 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fec:	2505                	addw	a0,a0,1
    80004fee:	07a1                	add	a5,a5,8
    80004ff0:	fed51ce3          	bne	a0,a3,80004fe8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ff4:	557d                	li	a0,-1
}
    80004ff6:	60e2                	ld	ra,24(sp)
    80004ff8:	6442                	ld	s0,16(sp)
    80004ffa:	64a2                	ld	s1,8(sp)
    80004ffc:	6105                	add	sp,sp,32
    80004ffe:	8082                	ret
      p->ofile[fd] = f;
    80005000:	01a50793          	add	a5,a0,26
    80005004:	078e                	sll	a5,a5,0x3
    80005006:	963e                	add	a2,a2,a5
    80005008:	e204                	sd	s1,0(a2)
      return fd;
    8000500a:	b7f5                	j	80004ff6 <fdalloc+0x2c>

000000008000500c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000500c:	715d                	add	sp,sp,-80
    8000500e:	e486                	sd	ra,72(sp)
    80005010:	e0a2                	sd	s0,64(sp)
    80005012:	fc26                	sd	s1,56(sp)
    80005014:	f84a                	sd	s2,48(sp)
    80005016:	f44e                	sd	s3,40(sp)
    80005018:	f052                	sd	s4,32(sp)
    8000501a:	ec56                	sd	s5,24(sp)
    8000501c:	e85a                	sd	s6,16(sp)
    8000501e:	0880                	add	s0,sp,80
    80005020:	8b2e                	mv	s6,a1
    80005022:	89b2                	mv	s3,a2
    80005024:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005026:	fb040593          	add	a1,s0,-80
    8000502a:	fffff097          	auipc	ra,0xfffff
    8000502e:	e7e080e7          	jalr	-386(ra) # 80003ea8 <nameiparent>
    80005032:	84aa                	mv	s1,a0
    80005034:	14050b63          	beqz	a0,8000518a <create+0x17e>
    return 0;

  ilock(dp);
    80005038:	ffffe097          	auipc	ra,0xffffe
    8000503c:	6ac080e7          	jalr	1708(ra) # 800036e4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005040:	4601                	li	a2,0
    80005042:	fb040593          	add	a1,s0,-80
    80005046:	8526                	mv	a0,s1
    80005048:	fffff097          	auipc	ra,0xfffff
    8000504c:	b80080e7          	jalr	-1152(ra) # 80003bc8 <dirlookup>
    80005050:	8aaa                	mv	s5,a0
    80005052:	c921                	beqz	a0,800050a2 <create+0x96>
    iunlockput(dp);
    80005054:	8526                	mv	a0,s1
    80005056:	fffff097          	auipc	ra,0xfffff
    8000505a:	8f0080e7          	jalr	-1808(ra) # 80003946 <iunlockput>
    ilock(ip);
    8000505e:	8556                	mv	a0,s5
    80005060:	ffffe097          	auipc	ra,0xffffe
    80005064:	684080e7          	jalr	1668(ra) # 800036e4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005068:	4789                	li	a5,2
    8000506a:	02fb1563          	bne	s6,a5,80005094 <create+0x88>
    8000506e:	044ad783          	lhu	a5,68(s5)
    80005072:	37f9                	addw	a5,a5,-2
    80005074:	17c2                	sll	a5,a5,0x30
    80005076:	93c1                	srl	a5,a5,0x30
    80005078:	4705                	li	a4,1
    8000507a:	00f76d63          	bltu	a4,a5,80005094 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000507e:	8556                	mv	a0,s5
    80005080:	60a6                	ld	ra,72(sp)
    80005082:	6406                	ld	s0,64(sp)
    80005084:	74e2                	ld	s1,56(sp)
    80005086:	7942                	ld	s2,48(sp)
    80005088:	79a2                	ld	s3,40(sp)
    8000508a:	7a02                	ld	s4,32(sp)
    8000508c:	6ae2                	ld	s5,24(sp)
    8000508e:	6b42                	ld	s6,16(sp)
    80005090:	6161                	add	sp,sp,80
    80005092:	8082                	ret
    iunlockput(ip);
    80005094:	8556                	mv	a0,s5
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	8b0080e7          	jalr	-1872(ra) # 80003946 <iunlockput>
    return 0;
    8000509e:	4a81                	li	s5,0
    800050a0:	bff9                	j	8000507e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050a2:	85da                	mv	a1,s6
    800050a4:	4088                	lw	a0,0(s1)
    800050a6:	ffffe097          	auipc	ra,0xffffe
    800050aa:	4a6080e7          	jalr	1190(ra) # 8000354c <ialloc>
    800050ae:	8a2a                	mv	s4,a0
    800050b0:	c529                	beqz	a0,800050fa <create+0xee>
  ilock(ip);
    800050b2:	ffffe097          	auipc	ra,0xffffe
    800050b6:	632080e7          	jalr	1586(ra) # 800036e4 <ilock>
  ip->major = major;
    800050ba:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050be:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050c2:	4905                	li	s2,1
    800050c4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050c8:	8552                	mv	a0,s4
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	54e080e7          	jalr	1358(ra) # 80003618 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050d2:	032b0b63          	beq	s6,s2,80005108 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800050d6:	004a2603          	lw	a2,4(s4)
    800050da:	fb040593          	add	a1,s0,-80
    800050de:	8526                	mv	a0,s1
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	cf8080e7          	jalr	-776(ra) # 80003dd8 <dirlink>
    800050e8:	06054f63          	bltz	a0,80005166 <create+0x15a>
  iunlockput(dp);
    800050ec:	8526                	mv	a0,s1
    800050ee:	fffff097          	auipc	ra,0xfffff
    800050f2:	858080e7          	jalr	-1960(ra) # 80003946 <iunlockput>
  return ip;
    800050f6:	8ad2                	mv	s5,s4
    800050f8:	b759                	j	8000507e <create+0x72>
    iunlockput(dp);
    800050fa:	8526                	mv	a0,s1
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	84a080e7          	jalr	-1974(ra) # 80003946 <iunlockput>
    return 0;
    80005104:	8ad2                	mv	s5,s4
    80005106:	bfa5                	j	8000507e <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005108:	004a2603          	lw	a2,4(s4)
    8000510c:	00003597          	auipc	a1,0x3
    80005110:	60458593          	add	a1,a1,1540 # 80008710 <syscalls+0x2c0>
    80005114:	8552                	mv	a0,s4
    80005116:	fffff097          	auipc	ra,0xfffff
    8000511a:	cc2080e7          	jalr	-830(ra) # 80003dd8 <dirlink>
    8000511e:	04054463          	bltz	a0,80005166 <create+0x15a>
    80005122:	40d0                	lw	a2,4(s1)
    80005124:	00003597          	auipc	a1,0x3
    80005128:	5f458593          	add	a1,a1,1524 # 80008718 <syscalls+0x2c8>
    8000512c:	8552                	mv	a0,s4
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	caa080e7          	jalr	-854(ra) # 80003dd8 <dirlink>
    80005136:	02054863          	bltz	a0,80005166 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    8000513a:	004a2603          	lw	a2,4(s4)
    8000513e:	fb040593          	add	a1,s0,-80
    80005142:	8526                	mv	a0,s1
    80005144:	fffff097          	auipc	ra,0xfffff
    80005148:	c94080e7          	jalr	-876(ra) # 80003dd8 <dirlink>
    8000514c:	00054d63          	bltz	a0,80005166 <create+0x15a>
    dp->nlink++;  // for ".."
    80005150:	04a4d783          	lhu	a5,74(s1)
    80005154:	2785                	addw	a5,a5,1
    80005156:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000515a:	8526                	mv	a0,s1
    8000515c:	ffffe097          	auipc	ra,0xffffe
    80005160:	4bc080e7          	jalr	1212(ra) # 80003618 <iupdate>
    80005164:	b761                	j	800050ec <create+0xe0>
  ip->nlink = 0;
    80005166:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000516a:	8552                	mv	a0,s4
    8000516c:	ffffe097          	auipc	ra,0xffffe
    80005170:	4ac080e7          	jalr	1196(ra) # 80003618 <iupdate>
  iunlockput(ip);
    80005174:	8552                	mv	a0,s4
    80005176:	ffffe097          	auipc	ra,0xffffe
    8000517a:	7d0080e7          	jalr	2000(ra) # 80003946 <iunlockput>
  iunlockput(dp);
    8000517e:	8526                	mv	a0,s1
    80005180:	ffffe097          	auipc	ra,0xffffe
    80005184:	7c6080e7          	jalr	1990(ra) # 80003946 <iunlockput>
  return 0;
    80005188:	bddd                	j	8000507e <create+0x72>
    return 0;
    8000518a:	8aaa                	mv	s5,a0
    8000518c:	bdcd                	j	8000507e <create+0x72>

000000008000518e <sys_dup>:
{
    8000518e:	7179                	add	sp,sp,-48
    80005190:	f406                	sd	ra,40(sp)
    80005192:	f022                	sd	s0,32(sp)
    80005194:	ec26                	sd	s1,24(sp)
    80005196:	e84a                	sd	s2,16(sp)
    80005198:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000519a:	fd840613          	add	a2,s0,-40
    8000519e:	4581                	li	a1,0
    800051a0:	4501                	li	a0,0
    800051a2:	00000097          	auipc	ra,0x0
    800051a6:	dc8080e7          	jalr	-568(ra) # 80004f6a <argfd>
    return -1;
    800051aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051ac:	02054363          	bltz	a0,800051d2 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051b0:	fd843903          	ld	s2,-40(s0)
    800051b4:	854a                	mv	a0,s2
    800051b6:	00000097          	auipc	ra,0x0
    800051ba:	e14080e7          	jalr	-492(ra) # 80004fca <fdalloc>
    800051be:	84aa                	mv	s1,a0
    return -1;
    800051c0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051c2:	00054863          	bltz	a0,800051d2 <sys_dup+0x44>
  filedup(f);
    800051c6:	854a                	mv	a0,s2
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	334080e7          	jalr	820(ra) # 800044fc <filedup>
  return fd;
    800051d0:	87a6                	mv	a5,s1
}
    800051d2:	853e                	mv	a0,a5
    800051d4:	70a2                	ld	ra,40(sp)
    800051d6:	7402                	ld	s0,32(sp)
    800051d8:	64e2                	ld	s1,24(sp)
    800051da:	6942                	ld	s2,16(sp)
    800051dc:	6145                	add	sp,sp,48
    800051de:	8082                	ret

00000000800051e0 <sys_read>:
{
    800051e0:	7179                	add	sp,sp,-48
    800051e2:	f406                	sd	ra,40(sp)
    800051e4:	f022                	sd	s0,32(sp)
    800051e6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800051e8:	fd840593          	add	a1,s0,-40
    800051ec:	4505                	li	a0,1
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	8fa080e7          	jalr	-1798(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    800051f6:	fe440593          	add	a1,s0,-28
    800051fa:	4509                	li	a0,2
    800051fc:	ffffe097          	auipc	ra,0xffffe
    80005200:	8cc080e7          	jalr	-1844(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005204:	fe840613          	add	a2,s0,-24
    80005208:	4581                	li	a1,0
    8000520a:	4501                	li	a0,0
    8000520c:	00000097          	auipc	ra,0x0
    80005210:	d5e080e7          	jalr	-674(ra) # 80004f6a <argfd>
    80005214:	87aa                	mv	a5,a0
    return -1;
    80005216:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005218:	0007cc63          	bltz	a5,80005230 <sys_read+0x50>
  return fileread(f, p, n);
    8000521c:	fe442603          	lw	a2,-28(s0)
    80005220:	fd843583          	ld	a1,-40(s0)
    80005224:	fe843503          	ld	a0,-24(s0)
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	460080e7          	jalr	1120(ra) # 80004688 <fileread>
}
    80005230:	70a2                	ld	ra,40(sp)
    80005232:	7402                	ld	s0,32(sp)
    80005234:	6145                	add	sp,sp,48
    80005236:	8082                	ret

0000000080005238 <sys_write>:
{
    80005238:	7179                	add	sp,sp,-48
    8000523a:	f406                	sd	ra,40(sp)
    8000523c:	f022                	sd	s0,32(sp)
    8000523e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005240:	fd840593          	add	a1,s0,-40
    80005244:	4505                	li	a0,1
    80005246:	ffffe097          	auipc	ra,0xffffe
    8000524a:	8a2080e7          	jalr	-1886(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    8000524e:	fe440593          	add	a1,s0,-28
    80005252:	4509                	li	a0,2
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	874080e7          	jalr	-1932(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000525c:	fe840613          	add	a2,s0,-24
    80005260:	4581                	li	a1,0
    80005262:	4501                	li	a0,0
    80005264:	00000097          	auipc	ra,0x0
    80005268:	d06080e7          	jalr	-762(ra) # 80004f6a <argfd>
    8000526c:	87aa                	mv	a5,a0
    return -1;
    8000526e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005270:	0007cc63          	bltz	a5,80005288 <sys_write+0x50>
  return filewrite(f, p, n);
    80005274:	fe442603          	lw	a2,-28(s0)
    80005278:	fd843583          	ld	a1,-40(s0)
    8000527c:	fe843503          	ld	a0,-24(s0)
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	4ca080e7          	jalr	1226(ra) # 8000474a <filewrite>
}
    80005288:	70a2                	ld	ra,40(sp)
    8000528a:	7402                	ld	s0,32(sp)
    8000528c:	6145                	add	sp,sp,48
    8000528e:	8082                	ret

0000000080005290 <sys_close>:
{
    80005290:	1101                	add	sp,sp,-32
    80005292:	ec06                	sd	ra,24(sp)
    80005294:	e822                	sd	s0,16(sp)
    80005296:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005298:	fe040613          	add	a2,s0,-32
    8000529c:	fec40593          	add	a1,s0,-20
    800052a0:	4501                	li	a0,0
    800052a2:	00000097          	auipc	ra,0x0
    800052a6:	cc8080e7          	jalr	-824(ra) # 80004f6a <argfd>
    return -1;
    800052aa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052ac:	02054463          	bltz	a0,800052d4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052b0:	ffffc097          	auipc	ra,0xffffc
    800052b4:	6fe080e7          	jalr	1790(ra) # 800019ae <myproc>
    800052b8:	fec42783          	lw	a5,-20(s0)
    800052bc:	07e9                	add	a5,a5,26
    800052be:	078e                	sll	a5,a5,0x3
    800052c0:	953e                	add	a0,a0,a5
    800052c2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052c6:	fe043503          	ld	a0,-32(s0)
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	284080e7          	jalr	644(ra) # 8000454e <fileclose>
  return 0;
    800052d2:	4781                	li	a5,0
}
    800052d4:	853e                	mv	a0,a5
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	6105                	add	sp,sp,32
    800052dc:	8082                	ret

00000000800052de <sys_fstat>:
{
    800052de:	1101                	add	sp,sp,-32
    800052e0:	ec06                	sd	ra,24(sp)
    800052e2:	e822                	sd	s0,16(sp)
    800052e4:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800052e6:	fe040593          	add	a1,s0,-32
    800052ea:	4505                	li	a0,1
    800052ec:	ffffd097          	auipc	ra,0xffffd
    800052f0:	7fc080e7          	jalr	2044(ra) # 80002ae8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052f4:	fe840613          	add	a2,s0,-24
    800052f8:	4581                	li	a1,0
    800052fa:	4501                	li	a0,0
    800052fc:	00000097          	auipc	ra,0x0
    80005300:	c6e080e7          	jalr	-914(ra) # 80004f6a <argfd>
    80005304:	87aa                	mv	a5,a0
    return -1;
    80005306:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005308:	0007ca63          	bltz	a5,8000531c <sys_fstat+0x3e>
  return filestat(f, st);
    8000530c:	fe043583          	ld	a1,-32(s0)
    80005310:	fe843503          	ld	a0,-24(s0)
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	302080e7          	jalr	770(ra) # 80004616 <filestat>
}
    8000531c:	60e2                	ld	ra,24(sp)
    8000531e:	6442                	ld	s0,16(sp)
    80005320:	6105                	add	sp,sp,32
    80005322:	8082                	ret

0000000080005324 <sys_link>:
{
    80005324:	7169                	add	sp,sp,-304
    80005326:	f606                	sd	ra,296(sp)
    80005328:	f222                	sd	s0,288(sp)
    8000532a:	ee26                	sd	s1,280(sp)
    8000532c:	ea4a                	sd	s2,272(sp)
    8000532e:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005330:	08000613          	li	a2,128
    80005334:	ed040593          	add	a1,s0,-304
    80005338:	4501                	li	a0,0
    8000533a:	ffffd097          	auipc	ra,0xffffd
    8000533e:	7ce080e7          	jalr	1998(ra) # 80002b08 <argstr>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005344:	10054e63          	bltz	a0,80005460 <sys_link+0x13c>
    80005348:	08000613          	li	a2,128
    8000534c:	f5040593          	add	a1,s0,-176
    80005350:	4505                	li	a0,1
    80005352:	ffffd097          	auipc	ra,0xffffd
    80005356:	7b6080e7          	jalr	1974(ra) # 80002b08 <argstr>
    return -1;
    8000535a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000535c:	10054263          	bltz	a0,80005460 <sys_link+0x13c>
  begin_op();
    80005360:	fffff097          	auipc	ra,0xfffff
    80005364:	d2a080e7          	jalr	-726(ra) # 8000408a <begin_op>
  if((ip = namei(old)) == 0){
    80005368:	ed040513          	add	a0,s0,-304
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	b1e080e7          	jalr	-1250(ra) # 80003e8a <namei>
    80005374:	84aa                	mv	s1,a0
    80005376:	c551                	beqz	a0,80005402 <sys_link+0xde>
  ilock(ip);
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	36c080e7          	jalr	876(ra) # 800036e4 <ilock>
  if(ip->type == T_DIR){
    80005380:	04449703          	lh	a4,68(s1)
    80005384:	4785                	li	a5,1
    80005386:	08f70463          	beq	a4,a5,8000540e <sys_link+0xea>
  ip->nlink++;
    8000538a:	04a4d783          	lhu	a5,74(s1)
    8000538e:	2785                	addw	a5,a5,1
    80005390:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	282080e7          	jalr	642(ra) # 80003618 <iupdate>
  iunlock(ip);
    8000539e:	8526                	mv	a0,s1
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	406080e7          	jalr	1030(ra) # 800037a6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053a8:	fd040593          	add	a1,s0,-48
    800053ac:	f5040513          	add	a0,s0,-176
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	af8080e7          	jalr	-1288(ra) # 80003ea8 <nameiparent>
    800053b8:	892a                	mv	s2,a0
    800053ba:	c935                	beqz	a0,8000542e <sys_link+0x10a>
  ilock(dp);
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	328080e7          	jalr	808(ra) # 800036e4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053c4:	00092703          	lw	a4,0(s2)
    800053c8:	409c                	lw	a5,0(s1)
    800053ca:	04f71d63          	bne	a4,a5,80005424 <sys_link+0x100>
    800053ce:	40d0                	lw	a2,4(s1)
    800053d0:	fd040593          	add	a1,s0,-48
    800053d4:	854a                	mv	a0,s2
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	a02080e7          	jalr	-1534(ra) # 80003dd8 <dirlink>
    800053de:	04054363          	bltz	a0,80005424 <sys_link+0x100>
  iunlockput(dp);
    800053e2:	854a                	mv	a0,s2
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	562080e7          	jalr	1378(ra) # 80003946 <iunlockput>
  iput(ip);
    800053ec:	8526                	mv	a0,s1
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	4b0080e7          	jalr	1200(ra) # 8000389e <iput>
  end_op();
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	d0e080e7          	jalr	-754(ra) # 80004104 <end_op>
  return 0;
    800053fe:	4781                	li	a5,0
    80005400:	a085                	j	80005460 <sys_link+0x13c>
    end_op();
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	d02080e7          	jalr	-766(ra) # 80004104 <end_op>
    return -1;
    8000540a:	57fd                	li	a5,-1
    8000540c:	a891                	j	80005460 <sys_link+0x13c>
    iunlockput(ip);
    8000540e:	8526                	mv	a0,s1
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	536080e7          	jalr	1334(ra) # 80003946 <iunlockput>
    end_op();
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	cec080e7          	jalr	-788(ra) # 80004104 <end_op>
    return -1;
    80005420:	57fd                	li	a5,-1
    80005422:	a83d                	j	80005460 <sys_link+0x13c>
    iunlockput(dp);
    80005424:	854a                	mv	a0,s2
    80005426:	ffffe097          	auipc	ra,0xffffe
    8000542a:	520080e7          	jalr	1312(ra) # 80003946 <iunlockput>
  ilock(ip);
    8000542e:	8526                	mv	a0,s1
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	2b4080e7          	jalr	692(ra) # 800036e4 <ilock>
  ip->nlink--;
    80005438:	04a4d783          	lhu	a5,74(s1)
    8000543c:	37fd                	addw	a5,a5,-1
    8000543e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	1d4080e7          	jalr	468(ra) # 80003618 <iupdate>
  iunlockput(ip);
    8000544c:	8526                	mv	a0,s1
    8000544e:	ffffe097          	auipc	ra,0xffffe
    80005452:	4f8080e7          	jalr	1272(ra) # 80003946 <iunlockput>
  end_op();
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	cae080e7          	jalr	-850(ra) # 80004104 <end_op>
  return -1;
    8000545e:	57fd                	li	a5,-1
}
    80005460:	853e                	mv	a0,a5
    80005462:	70b2                	ld	ra,296(sp)
    80005464:	7412                	ld	s0,288(sp)
    80005466:	64f2                	ld	s1,280(sp)
    80005468:	6952                	ld	s2,272(sp)
    8000546a:	6155                	add	sp,sp,304
    8000546c:	8082                	ret

000000008000546e <sys_unlink>:
{
    8000546e:	7151                	add	sp,sp,-240
    80005470:	f586                	sd	ra,232(sp)
    80005472:	f1a2                	sd	s0,224(sp)
    80005474:	eda6                	sd	s1,216(sp)
    80005476:	e9ca                	sd	s2,208(sp)
    80005478:	e5ce                	sd	s3,200(sp)
    8000547a:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000547c:	08000613          	li	a2,128
    80005480:	f3040593          	add	a1,s0,-208
    80005484:	4501                	li	a0,0
    80005486:	ffffd097          	auipc	ra,0xffffd
    8000548a:	682080e7          	jalr	1666(ra) # 80002b08 <argstr>
    8000548e:	18054163          	bltz	a0,80005610 <sys_unlink+0x1a2>
  begin_op();
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	bf8080e7          	jalr	-1032(ra) # 8000408a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000549a:	fb040593          	add	a1,s0,-80
    8000549e:	f3040513          	add	a0,s0,-208
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	a06080e7          	jalr	-1530(ra) # 80003ea8 <nameiparent>
    800054aa:	84aa                	mv	s1,a0
    800054ac:	c979                	beqz	a0,80005582 <sys_unlink+0x114>
  ilock(dp);
    800054ae:	ffffe097          	auipc	ra,0xffffe
    800054b2:	236080e7          	jalr	566(ra) # 800036e4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054b6:	00003597          	auipc	a1,0x3
    800054ba:	25a58593          	add	a1,a1,602 # 80008710 <syscalls+0x2c0>
    800054be:	fb040513          	add	a0,s0,-80
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	6ec080e7          	jalr	1772(ra) # 80003bae <namecmp>
    800054ca:	14050a63          	beqz	a0,8000561e <sys_unlink+0x1b0>
    800054ce:	00003597          	auipc	a1,0x3
    800054d2:	24a58593          	add	a1,a1,586 # 80008718 <syscalls+0x2c8>
    800054d6:	fb040513          	add	a0,s0,-80
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	6d4080e7          	jalr	1748(ra) # 80003bae <namecmp>
    800054e2:	12050e63          	beqz	a0,8000561e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054e6:	f2c40613          	add	a2,s0,-212
    800054ea:	fb040593          	add	a1,s0,-80
    800054ee:	8526                	mv	a0,s1
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	6d8080e7          	jalr	1752(ra) # 80003bc8 <dirlookup>
    800054f8:	892a                	mv	s2,a0
    800054fa:	12050263          	beqz	a0,8000561e <sys_unlink+0x1b0>
  ilock(ip);
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	1e6080e7          	jalr	486(ra) # 800036e4 <ilock>
  if(ip->nlink < 1)
    80005506:	04a91783          	lh	a5,74(s2)
    8000550a:	08f05263          	blez	a5,8000558e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000550e:	04491703          	lh	a4,68(s2)
    80005512:	4785                	li	a5,1
    80005514:	08f70563          	beq	a4,a5,8000559e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005518:	4641                	li	a2,16
    8000551a:	4581                	li	a1,0
    8000551c:	fc040513          	add	a0,s0,-64
    80005520:	ffffb097          	auipc	ra,0xffffb
    80005524:	7ae080e7          	jalr	1966(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005528:	4741                	li	a4,16
    8000552a:	f2c42683          	lw	a3,-212(s0)
    8000552e:	fc040613          	add	a2,s0,-64
    80005532:	4581                	li	a1,0
    80005534:	8526                	mv	a0,s1
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	55a080e7          	jalr	1370(ra) # 80003a90 <writei>
    8000553e:	47c1                	li	a5,16
    80005540:	0af51563          	bne	a0,a5,800055ea <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005544:	04491703          	lh	a4,68(s2)
    80005548:	4785                	li	a5,1
    8000554a:	0af70863          	beq	a4,a5,800055fa <sys_unlink+0x18c>
  iunlockput(dp);
    8000554e:	8526                	mv	a0,s1
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	3f6080e7          	jalr	1014(ra) # 80003946 <iunlockput>
  ip->nlink--;
    80005558:	04a95783          	lhu	a5,74(s2)
    8000555c:	37fd                	addw	a5,a5,-1
    8000555e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005562:	854a                	mv	a0,s2
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	0b4080e7          	jalr	180(ra) # 80003618 <iupdate>
  iunlockput(ip);
    8000556c:	854a                	mv	a0,s2
    8000556e:	ffffe097          	auipc	ra,0xffffe
    80005572:	3d8080e7          	jalr	984(ra) # 80003946 <iunlockput>
  end_op();
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	b8e080e7          	jalr	-1138(ra) # 80004104 <end_op>
  return 0;
    8000557e:	4501                	li	a0,0
    80005580:	a84d                	j	80005632 <sys_unlink+0x1c4>
    end_op();
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	b82080e7          	jalr	-1150(ra) # 80004104 <end_op>
    return -1;
    8000558a:	557d                	li	a0,-1
    8000558c:	a05d                	j	80005632 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000558e:	00003517          	auipc	a0,0x3
    80005592:	19250513          	add	a0,a0,402 # 80008720 <syscalls+0x2d0>
    80005596:	ffffb097          	auipc	ra,0xffffb
    8000559a:	fa6080e7          	jalr	-90(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000559e:	04c92703          	lw	a4,76(s2)
    800055a2:	02000793          	li	a5,32
    800055a6:	f6e7f9e3          	bgeu	a5,a4,80005518 <sys_unlink+0xaa>
    800055aa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055ae:	4741                	li	a4,16
    800055b0:	86ce                	mv	a3,s3
    800055b2:	f1840613          	add	a2,s0,-232
    800055b6:	4581                	li	a1,0
    800055b8:	854a                	mv	a0,s2
    800055ba:	ffffe097          	auipc	ra,0xffffe
    800055be:	3de080e7          	jalr	990(ra) # 80003998 <readi>
    800055c2:	47c1                	li	a5,16
    800055c4:	00f51b63          	bne	a0,a5,800055da <sys_unlink+0x16c>
    if(de.inum != 0)
    800055c8:	f1845783          	lhu	a5,-232(s0)
    800055cc:	e7a1                	bnez	a5,80005614 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ce:	29c1                	addw	s3,s3,16
    800055d0:	04c92783          	lw	a5,76(s2)
    800055d4:	fcf9ede3          	bltu	s3,a5,800055ae <sys_unlink+0x140>
    800055d8:	b781                	j	80005518 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055da:	00003517          	auipc	a0,0x3
    800055de:	15e50513          	add	a0,a0,350 # 80008738 <syscalls+0x2e8>
    800055e2:	ffffb097          	auipc	ra,0xffffb
    800055e6:	f5a080e7          	jalr	-166(ra) # 8000053c <panic>
    panic("unlink: writei");
    800055ea:	00003517          	auipc	a0,0x3
    800055ee:	16650513          	add	a0,a0,358 # 80008750 <syscalls+0x300>
    800055f2:	ffffb097          	auipc	ra,0xffffb
    800055f6:	f4a080e7          	jalr	-182(ra) # 8000053c <panic>
    dp->nlink--;
    800055fa:	04a4d783          	lhu	a5,74(s1)
    800055fe:	37fd                	addw	a5,a5,-1
    80005600:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005604:	8526                	mv	a0,s1
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	012080e7          	jalr	18(ra) # 80003618 <iupdate>
    8000560e:	b781                	j	8000554e <sys_unlink+0xe0>
    return -1;
    80005610:	557d                	li	a0,-1
    80005612:	a005                	j	80005632 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005614:	854a                	mv	a0,s2
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	330080e7          	jalr	816(ra) # 80003946 <iunlockput>
  iunlockput(dp);
    8000561e:	8526                	mv	a0,s1
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	326080e7          	jalr	806(ra) # 80003946 <iunlockput>
  end_op();
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	adc080e7          	jalr	-1316(ra) # 80004104 <end_op>
  return -1;
    80005630:	557d                	li	a0,-1
}
    80005632:	70ae                	ld	ra,232(sp)
    80005634:	740e                	ld	s0,224(sp)
    80005636:	64ee                	ld	s1,216(sp)
    80005638:	694e                	ld	s2,208(sp)
    8000563a:	69ae                	ld	s3,200(sp)
    8000563c:	616d                	add	sp,sp,240
    8000563e:	8082                	ret

0000000080005640 <sys_open>:

uint64
sys_open(void)
{
    80005640:	7131                	add	sp,sp,-192
    80005642:	fd06                	sd	ra,184(sp)
    80005644:	f922                	sd	s0,176(sp)
    80005646:	f526                	sd	s1,168(sp)
    80005648:	f14a                	sd	s2,160(sp)
    8000564a:	ed4e                	sd	s3,152(sp)
    8000564c:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000564e:	f4c40593          	add	a1,s0,-180
    80005652:	4505                	li	a0,1
    80005654:	ffffd097          	auipc	ra,0xffffd
    80005658:	474080e7          	jalr	1140(ra) # 80002ac8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000565c:	08000613          	li	a2,128
    80005660:	f5040593          	add	a1,s0,-176
    80005664:	4501                	li	a0,0
    80005666:	ffffd097          	auipc	ra,0xffffd
    8000566a:	4a2080e7          	jalr	1186(ra) # 80002b08 <argstr>
    8000566e:	87aa                	mv	a5,a0
    return -1;
    80005670:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005672:	0a07c863          	bltz	a5,80005722 <sys_open+0xe2>

  begin_op();
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	a14080e7          	jalr	-1516(ra) # 8000408a <begin_op>

  if(omode & O_CREATE){
    8000567e:	f4c42783          	lw	a5,-180(s0)
    80005682:	2007f793          	and	a5,a5,512
    80005686:	cbdd                	beqz	a5,8000573c <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005688:	4681                	li	a3,0
    8000568a:	4601                	li	a2,0
    8000568c:	4589                	li	a1,2
    8000568e:	f5040513          	add	a0,s0,-176
    80005692:	00000097          	auipc	ra,0x0
    80005696:	97a080e7          	jalr	-1670(ra) # 8000500c <create>
    8000569a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000569c:	c951                	beqz	a0,80005730 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000569e:	04449703          	lh	a4,68(s1)
    800056a2:	478d                	li	a5,3
    800056a4:	00f71763          	bne	a4,a5,800056b2 <sys_open+0x72>
    800056a8:	0464d703          	lhu	a4,70(s1)
    800056ac:	47a5                	li	a5,9
    800056ae:	0ce7ec63          	bltu	a5,a4,80005786 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	de0080e7          	jalr	-544(ra) # 80004492 <filealloc>
    800056ba:	892a                	mv	s2,a0
    800056bc:	c56d                	beqz	a0,800057a6 <sys_open+0x166>
    800056be:	00000097          	auipc	ra,0x0
    800056c2:	90c080e7          	jalr	-1780(ra) # 80004fca <fdalloc>
    800056c6:	89aa                	mv	s3,a0
    800056c8:	0c054a63          	bltz	a0,8000579c <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056cc:	04449703          	lh	a4,68(s1)
    800056d0:	478d                	li	a5,3
    800056d2:	0ef70563          	beq	a4,a5,800057bc <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056d6:	4789                	li	a5,2
    800056d8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800056dc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800056e0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800056e4:	f4c42783          	lw	a5,-180(s0)
    800056e8:	0017c713          	xor	a4,a5,1
    800056ec:	8b05                	and	a4,a4,1
    800056ee:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056f2:	0037f713          	and	a4,a5,3
    800056f6:	00e03733          	snez	a4,a4
    800056fa:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056fe:	4007f793          	and	a5,a5,1024
    80005702:	c791                	beqz	a5,8000570e <sys_open+0xce>
    80005704:	04449703          	lh	a4,68(s1)
    80005708:	4789                	li	a5,2
    8000570a:	0cf70063          	beq	a4,a5,800057ca <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	096080e7          	jalr	150(ra) # 800037a6 <iunlock>
  end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	9ec080e7          	jalr	-1556(ra) # 80004104 <end_op>

  return fd;
    80005720:	854e                	mv	a0,s3
}
    80005722:	70ea                	ld	ra,184(sp)
    80005724:	744a                	ld	s0,176(sp)
    80005726:	74aa                	ld	s1,168(sp)
    80005728:	790a                	ld	s2,160(sp)
    8000572a:	69ea                	ld	s3,152(sp)
    8000572c:	6129                	add	sp,sp,192
    8000572e:	8082                	ret
      end_op();
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	9d4080e7          	jalr	-1580(ra) # 80004104 <end_op>
      return -1;
    80005738:	557d                	li	a0,-1
    8000573a:	b7e5                	j	80005722 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000573c:	f5040513          	add	a0,s0,-176
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	74a080e7          	jalr	1866(ra) # 80003e8a <namei>
    80005748:	84aa                	mv	s1,a0
    8000574a:	c905                	beqz	a0,8000577a <sys_open+0x13a>
    ilock(ip);
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	f98080e7          	jalr	-104(ra) # 800036e4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005754:	04449703          	lh	a4,68(s1)
    80005758:	4785                	li	a5,1
    8000575a:	f4f712e3          	bne	a4,a5,8000569e <sys_open+0x5e>
    8000575e:	f4c42783          	lw	a5,-180(s0)
    80005762:	dba1                	beqz	a5,800056b2 <sys_open+0x72>
      iunlockput(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	1e0080e7          	jalr	480(ra) # 80003946 <iunlockput>
      end_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	996080e7          	jalr	-1642(ra) # 80004104 <end_op>
      return -1;
    80005776:	557d                	li	a0,-1
    80005778:	b76d                	j	80005722 <sys_open+0xe2>
      end_op();
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	98a080e7          	jalr	-1654(ra) # 80004104 <end_op>
      return -1;
    80005782:	557d                	li	a0,-1
    80005784:	bf79                	j	80005722 <sys_open+0xe2>
    iunlockput(ip);
    80005786:	8526                	mv	a0,s1
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	1be080e7          	jalr	446(ra) # 80003946 <iunlockput>
    end_op();
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	974080e7          	jalr	-1676(ra) # 80004104 <end_op>
    return -1;
    80005798:	557d                	li	a0,-1
    8000579a:	b761                	j	80005722 <sys_open+0xe2>
      fileclose(f);
    8000579c:	854a                	mv	a0,s2
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	db0080e7          	jalr	-592(ra) # 8000454e <fileclose>
    iunlockput(ip);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	19e080e7          	jalr	414(ra) # 80003946 <iunlockput>
    end_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	954080e7          	jalr	-1708(ra) # 80004104 <end_op>
    return -1;
    800057b8:	557d                	li	a0,-1
    800057ba:	b7a5                	j	80005722 <sys_open+0xe2>
    f->type = FD_DEVICE;
    800057bc:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800057c0:	04649783          	lh	a5,70(s1)
    800057c4:	02f91223          	sh	a5,36(s2)
    800057c8:	bf21                	j	800056e0 <sys_open+0xa0>
    itrunc(ip);
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	026080e7          	jalr	38(ra) # 800037f2 <itrunc>
    800057d4:	bf2d                	j	8000570e <sys_open+0xce>

00000000800057d6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057d6:	7175                	add	sp,sp,-144
    800057d8:	e506                	sd	ra,136(sp)
    800057da:	e122                	sd	s0,128(sp)
    800057dc:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	8ac080e7          	jalr	-1876(ra) # 8000408a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057e6:	08000613          	li	a2,128
    800057ea:	f7040593          	add	a1,s0,-144
    800057ee:	4501                	li	a0,0
    800057f0:	ffffd097          	auipc	ra,0xffffd
    800057f4:	318080e7          	jalr	792(ra) # 80002b08 <argstr>
    800057f8:	02054963          	bltz	a0,8000582a <sys_mkdir+0x54>
    800057fc:	4681                	li	a3,0
    800057fe:	4601                	li	a2,0
    80005800:	4585                	li	a1,1
    80005802:	f7040513          	add	a0,s0,-144
    80005806:	00000097          	auipc	ra,0x0
    8000580a:	806080e7          	jalr	-2042(ra) # 8000500c <create>
    8000580e:	cd11                	beqz	a0,8000582a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	136080e7          	jalr	310(ra) # 80003946 <iunlockput>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	8ec080e7          	jalr	-1812(ra) # 80004104 <end_op>
  return 0;
    80005820:	4501                	li	a0,0
}
    80005822:	60aa                	ld	ra,136(sp)
    80005824:	640a                	ld	s0,128(sp)
    80005826:	6149                	add	sp,sp,144
    80005828:	8082                	ret
    end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	8da080e7          	jalr	-1830(ra) # 80004104 <end_op>
    return -1;
    80005832:	557d                	li	a0,-1
    80005834:	b7fd                	j	80005822 <sys_mkdir+0x4c>

0000000080005836 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005836:	7135                	add	sp,sp,-160
    80005838:	ed06                	sd	ra,152(sp)
    8000583a:	e922                	sd	s0,144(sp)
    8000583c:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	84c080e7          	jalr	-1972(ra) # 8000408a <begin_op>
  argint(1, &major);
    80005846:	f6c40593          	add	a1,s0,-148
    8000584a:	4505                	li	a0,1
    8000584c:	ffffd097          	auipc	ra,0xffffd
    80005850:	27c080e7          	jalr	636(ra) # 80002ac8 <argint>
  argint(2, &minor);
    80005854:	f6840593          	add	a1,s0,-152
    80005858:	4509                	li	a0,2
    8000585a:	ffffd097          	auipc	ra,0xffffd
    8000585e:	26e080e7          	jalr	622(ra) # 80002ac8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005862:	08000613          	li	a2,128
    80005866:	f7040593          	add	a1,s0,-144
    8000586a:	4501                	li	a0,0
    8000586c:	ffffd097          	auipc	ra,0xffffd
    80005870:	29c080e7          	jalr	668(ra) # 80002b08 <argstr>
    80005874:	02054b63          	bltz	a0,800058aa <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005878:	f6841683          	lh	a3,-152(s0)
    8000587c:	f6c41603          	lh	a2,-148(s0)
    80005880:	458d                	li	a1,3
    80005882:	f7040513          	add	a0,s0,-144
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	786080e7          	jalr	1926(ra) # 8000500c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000588e:	cd11                	beqz	a0,800058aa <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	0b6080e7          	jalr	182(ra) # 80003946 <iunlockput>
  end_op();
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	86c080e7          	jalr	-1940(ra) # 80004104 <end_op>
  return 0;
    800058a0:	4501                	li	a0,0
}
    800058a2:	60ea                	ld	ra,152(sp)
    800058a4:	644a                	ld	s0,144(sp)
    800058a6:	610d                	add	sp,sp,160
    800058a8:	8082                	ret
    end_op();
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	85a080e7          	jalr	-1958(ra) # 80004104 <end_op>
    return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	b7fd                	j	800058a2 <sys_mknod+0x6c>

00000000800058b6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800058b6:	7135                	add	sp,sp,-160
    800058b8:	ed06                	sd	ra,152(sp)
    800058ba:	e922                	sd	s0,144(sp)
    800058bc:	e526                	sd	s1,136(sp)
    800058be:	e14a                	sd	s2,128(sp)
    800058c0:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058c2:	ffffc097          	auipc	ra,0xffffc
    800058c6:	0ec080e7          	jalr	236(ra) # 800019ae <myproc>
    800058ca:	892a                	mv	s2,a0
  
  begin_op();
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	7be080e7          	jalr	1982(ra) # 8000408a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058d4:	08000613          	li	a2,128
    800058d8:	f6040593          	add	a1,s0,-160
    800058dc:	4501                	li	a0,0
    800058de:	ffffd097          	auipc	ra,0xffffd
    800058e2:	22a080e7          	jalr	554(ra) # 80002b08 <argstr>
    800058e6:	04054b63          	bltz	a0,8000593c <sys_chdir+0x86>
    800058ea:	f6040513          	add	a0,s0,-160
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	59c080e7          	jalr	1436(ra) # 80003e8a <namei>
    800058f6:	84aa                	mv	s1,a0
    800058f8:	c131                	beqz	a0,8000593c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	dea080e7          	jalr	-534(ra) # 800036e4 <ilock>
  if(ip->type != T_DIR){
    80005902:	04449703          	lh	a4,68(s1)
    80005906:	4785                	li	a5,1
    80005908:	04f71063          	bne	a4,a5,80005948 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000590c:	8526                	mv	a0,s1
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	e98080e7          	jalr	-360(ra) # 800037a6 <iunlock>
  iput(p->cwd);
    80005916:	15093503          	ld	a0,336(s2)
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	f84080e7          	jalr	-124(ra) # 8000389e <iput>
  end_op();
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	7e2080e7          	jalr	2018(ra) # 80004104 <end_op>
  p->cwd = ip;
    8000592a:	14993823          	sd	s1,336(s2)
  return 0;
    8000592e:	4501                	li	a0,0
}
    80005930:	60ea                	ld	ra,152(sp)
    80005932:	644a                	ld	s0,144(sp)
    80005934:	64aa                	ld	s1,136(sp)
    80005936:	690a                	ld	s2,128(sp)
    80005938:	610d                	add	sp,sp,160
    8000593a:	8082                	ret
    end_op();
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	7c8080e7          	jalr	1992(ra) # 80004104 <end_op>
    return -1;
    80005944:	557d                	li	a0,-1
    80005946:	b7ed                	j	80005930 <sys_chdir+0x7a>
    iunlockput(ip);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	ffc080e7          	jalr	-4(ra) # 80003946 <iunlockput>
    end_op();
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	7b2080e7          	jalr	1970(ra) # 80004104 <end_op>
    return -1;
    8000595a:	557d                	li	a0,-1
    8000595c:	bfd1                	j	80005930 <sys_chdir+0x7a>

000000008000595e <sys_exec>:

uint64
sys_exec(void)
{
    8000595e:	7121                	add	sp,sp,-448
    80005960:	ff06                	sd	ra,440(sp)
    80005962:	fb22                	sd	s0,432(sp)
    80005964:	f726                	sd	s1,424(sp)
    80005966:	f34a                	sd	s2,416(sp)
    80005968:	ef4e                	sd	s3,408(sp)
    8000596a:	eb52                	sd	s4,400(sp)
    8000596c:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000596e:	e4840593          	add	a1,s0,-440
    80005972:	4505                	li	a0,1
    80005974:	ffffd097          	auipc	ra,0xffffd
    80005978:	174080e7          	jalr	372(ra) # 80002ae8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000597c:	08000613          	li	a2,128
    80005980:	f5040593          	add	a1,s0,-176
    80005984:	4501                	li	a0,0
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	182080e7          	jalr	386(ra) # 80002b08 <argstr>
    8000598e:	87aa                	mv	a5,a0
    return -1;
    80005990:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005992:	0c07c263          	bltz	a5,80005a56 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005996:	10000613          	li	a2,256
    8000599a:	4581                	li	a1,0
    8000599c:	e5040513          	add	a0,s0,-432
    800059a0:	ffffb097          	auipc	ra,0xffffb
    800059a4:	32e080e7          	jalr	814(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059a8:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800059ac:	89a6                	mv	s3,s1
    800059ae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059b0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059b4:	00391513          	sll	a0,s2,0x3
    800059b8:	e4040593          	add	a1,s0,-448
    800059bc:	e4843783          	ld	a5,-440(s0)
    800059c0:	953e                	add	a0,a0,a5
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	068080e7          	jalr	104(ra) # 80002a2a <fetchaddr>
    800059ca:	02054a63          	bltz	a0,800059fe <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    800059ce:	e4043783          	ld	a5,-448(s0)
    800059d2:	c3b9                	beqz	a5,80005a18 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059d4:	ffffb097          	auipc	ra,0xffffb
    800059d8:	10e080e7          	jalr	270(ra) # 80000ae2 <kalloc>
    800059dc:	85aa                	mv	a1,a0
    800059de:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059e2:	cd11                	beqz	a0,800059fe <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059e4:	6605                	lui	a2,0x1
    800059e6:	e4043503          	ld	a0,-448(s0)
    800059ea:	ffffd097          	auipc	ra,0xffffd
    800059ee:	092080e7          	jalr	146(ra) # 80002a7c <fetchstr>
    800059f2:	00054663          	bltz	a0,800059fe <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    800059f6:	0905                	add	s2,s2,1
    800059f8:	09a1                	add	s3,s3,8
    800059fa:	fb491de3          	bne	s2,s4,800059b4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059fe:	f5040913          	add	s2,s0,-176
    80005a02:	6088                	ld	a0,0(s1)
    80005a04:	c921                	beqz	a0,80005a54 <sys_exec+0xf6>
    kfree(argv[i]);
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	fde080e7          	jalr	-34(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a0e:	04a1                	add	s1,s1,8
    80005a10:	ff2499e3          	bne	s1,s2,80005a02 <sys_exec+0xa4>
  return -1;
    80005a14:	557d                	li	a0,-1
    80005a16:	a081                	j	80005a56 <sys_exec+0xf8>
      argv[i] = 0;
    80005a18:	0009079b          	sext.w	a5,s2
    80005a1c:	078e                	sll	a5,a5,0x3
    80005a1e:	fd078793          	add	a5,a5,-48
    80005a22:	97a2                	add	a5,a5,s0
    80005a24:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005a28:	e5040593          	add	a1,s0,-432
    80005a2c:	f5040513          	add	a0,s0,-176
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	194080e7          	jalr	404(ra) # 80004bc4 <exec>
    80005a38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a3a:	f5040993          	add	s3,s0,-176
    80005a3e:	6088                	ld	a0,0(s1)
    80005a40:	c901                	beqz	a0,80005a50 <sys_exec+0xf2>
    kfree(argv[i]);
    80005a42:	ffffb097          	auipc	ra,0xffffb
    80005a46:	fa2080e7          	jalr	-94(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a4a:	04a1                	add	s1,s1,8
    80005a4c:	ff3499e3          	bne	s1,s3,80005a3e <sys_exec+0xe0>
  return ret;
    80005a50:	854a                	mv	a0,s2
    80005a52:	a011                	j	80005a56 <sys_exec+0xf8>
  return -1;
    80005a54:	557d                	li	a0,-1
}
    80005a56:	70fa                	ld	ra,440(sp)
    80005a58:	745a                	ld	s0,432(sp)
    80005a5a:	74ba                	ld	s1,424(sp)
    80005a5c:	791a                	ld	s2,416(sp)
    80005a5e:	69fa                	ld	s3,408(sp)
    80005a60:	6a5a                	ld	s4,400(sp)
    80005a62:	6139                	add	sp,sp,448
    80005a64:	8082                	ret

0000000080005a66 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a66:	7139                	add	sp,sp,-64
    80005a68:	fc06                	sd	ra,56(sp)
    80005a6a:	f822                	sd	s0,48(sp)
    80005a6c:	f426                	sd	s1,40(sp)
    80005a6e:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a70:	ffffc097          	auipc	ra,0xffffc
    80005a74:	f3e080e7          	jalr	-194(ra) # 800019ae <myproc>
    80005a78:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a7a:	fd840593          	add	a1,s0,-40
    80005a7e:	4501                	li	a0,0
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	068080e7          	jalr	104(ra) # 80002ae8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a88:	fc840593          	add	a1,s0,-56
    80005a8c:	fd040513          	add	a0,s0,-48
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	dea080e7          	jalr	-534(ra) # 8000487a <pipealloc>
    return -1;
    80005a98:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a9a:	0c054463          	bltz	a0,80005b62 <sys_pipe+0xfc>
  fd0 = -1;
    80005a9e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005aa2:	fd043503          	ld	a0,-48(s0)
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	524080e7          	jalr	1316(ra) # 80004fca <fdalloc>
    80005aae:	fca42223          	sw	a0,-60(s0)
    80005ab2:	08054b63          	bltz	a0,80005b48 <sys_pipe+0xe2>
    80005ab6:	fc843503          	ld	a0,-56(s0)
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	510080e7          	jalr	1296(ra) # 80004fca <fdalloc>
    80005ac2:	fca42023          	sw	a0,-64(s0)
    80005ac6:	06054863          	bltz	a0,80005b36 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aca:	4691                	li	a3,4
    80005acc:	fc440613          	add	a2,s0,-60
    80005ad0:	fd843583          	ld	a1,-40(s0)
    80005ad4:	68a8                	ld	a0,80(s1)
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	b98080e7          	jalr	-1128(ra) # 8000166e <copyout>
    80005ade:	02054063          	bltz	a0,80005afe <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ae2:	4691                	li	a3,4
    80005ae4:	fc040613          	add	a2,s0,-64
    80005ae8:	fd843583          	ld	a1,-40(s0)
    80005aec:	0591                	add	a1,a1,4
    80005aee:	68a8                	ld	a0,80(s1)
    80005af0:	ffffc097          	auipc	ra,0xffffc
    80005af4:	b7e080e7          	jalr	-1154(ra) # 8000166e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005af8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005afa:	06055463          	bgez	a0,80005b62 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005afe:	fc442783          	lw	a5,-60(s0)
    80005b02:	07e9                	add	a5,a5,26
    80005b04:	078e                	sll	a5,a5,0x3
    80005b06:	97a6                	add	a5,a5,s1
    80005b08:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b0c:	fc042783          	lw	a5,-64(s0)
    80005b10:	07e9                	add	a5,a5,26
    80005b12:	078e                	sll	a5,a5,0x3
    80005b14:	94be                	add	s1,s1,a5
    80005b16:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b1a:	fd043503          	ld	a0,-48(s0)
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	a30080e7          	jalr	-1488(ra) # 8000454e <fileclose>
    fileclose(wf);
    80005b26:	fc843503          	ld	a0,-56(s0)
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	a24080e7          	jalr	-1500(ra) # 8000454e <fileclose>
    return -1;
    80005b32:	57fd                	li	a5,-1
    80005b34:	a03d                	j	80005b62 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b36:	fc442783          	lw	a5,-60(s0)
    80005b3a:	0007c763          	bltz	a5,80005b48 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b3e:	07e9                	add	a5,a5,26
    80005b40:	078e                	sll	a5,a5,0x3
    80005b42:	97a6                	add	a5,a5,s1
    80005b44:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b48:	fd043503          	ld	a0,-48(s0)
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	a02080e7          	jalr	-1534(ra) # 8000454e <fileclose>
    fileclose(wf);
    80005b54:	fc843503          	ld	a0,-56(s0)
    80005b58:	fffff097          	auipc	ra,0xfffff
    80005b5c:	9f6080e7          	jalr	-1546(ra) # 8000454e <fileclose>
    return -1;
    80005b60:	57fd                	li	a5,-1
}
    80005b62:	853e                	mv	a0,a5
    80005b64:	70e2                	ld	ra,56(sp)
    80005b66:	7442                	ld	s0,48(sp)
    80005b68:	74a2                	ld	s1,40(sp)
    80005b6a:	6121                	add	sp,sp,64
    80005b6c:	8082                	ret
	...

0000000080005b70 <kernelvec>:
    80005b70:	7111                	add	sp,sp,-256
    80005b72:	e006                	sd	ra,0(sp)
    80005b74:	e40a                	sd	sp,8(sp)
    80005b76:	e80e                	sd	gp,16(sp)
    80005b78:	ec12                	sd	tp,24(sp)
    80005b7a:	f016                	sd	t0,32(sp)
    80005b7c:	f41a                	sd	t1,40(sp)
    80005b7e:	f81e                	sd	t2,48(sp)
    80005b80:	fc22                	sd	s0,56(sp)
    80005b82:	e0a6                	sd	s1,64(sp)
    80005b84:	e4aa                	sd	a0,72(sp)
    80005b86:	e8ae                	sd	a1,80(sp)
    80005b88:	ecb2                	sd	a2,88(sp)
    80005b8a:	f0b6                	sd	a3,96(sp)
    80005b8c:	f4ba                	sd	a4,104(sp)
    80005b8e:	f8be                	sd	a5,112(sp)
    80005b90:	fcc2                	sd	a6,120(sp)
    80005b92:	e146                	sd	a7,128(sp)
    80005b94:	e54a                	sd	s2,136(sp)
    80005b96:	e94e                	sd	s3,144(sp)
    80005b98:	ed52                	sd	s4,152(sp)
    80005b9a:	f156                	sd	s5,160(sp)
    80005b9c:	f55a                	sd	s6,168(sp)
    80005b9e:	f95e                	sd	s7,176(sp)
    80005ba0:	fd62                	sd	s8,184(sp)
    80005ba2:	e1e6                	sd	s9,192(sp)
    80005ba4:	e5ea                	sd	s10,200(sp)
    80005ba6:	e9ee                	sd	s11,208(sp)
    80005ba8:	edf2                	sd	t3,216(sp)
    80005baa:	f1f6                	sd	t4,224(sp)
    80005bac:	f5fa                	sd	t5,232(sp)
    80005bae:	f9fe                	sd	t6,240(sp)
    80005bb0:	d47fc0ef          	jal	800028f6 <kerneltrap>
    80005bb4:	6082                	ld	ra,0(sp)
    80005bb6:	6122                	ld	sp,8(sp)
    80005bb8:	61c2                	ld	gp,16(sp)
    80005bba:	7282                	ld	t0,32(sp)
    80005bbc:	7322                	ld	t1,40(sp)
    80005bbe:	73c2                	ld	t2,48(sp)
    80005bc0:	7462                	ld	s0,56(sp)
    80005bc2:	6486                	ld	s1,64(sp)
    80005bc4:	6526                	ld	a0,72(sp)
    80005bc6:	65c6                	ld	a1,80(sp)
    80005bc8:	6666                	ld	a2,88(sp)
    80005bca:	7686                	ld	a3,96(sp)
    80005bcc:	7726                	ld	a4,104(sp)
    80005bce:	77c6                	ld	a5,112(sp)
    80005bd0:	7866                	ld	a6,120(sp)
    80005bd2:	688a                	ld	a7,128(sp)
    80005bd4:	692a                	ld	s2,136(sp)
    80005bd6:	69ca                	ld	s3,144(sp)
    80005bd8:	6a6a                	ld	s4,152(sp)
    80005bda:	7a8a                	ld	s5,160(sp)
    80005bdc:	7b2a                	ld	s6,168(sp)
    80005bde:	7bca                	ld	s7,176(sp)
    80005be0:	7c6a                	ld	s8,184(sp)
    80005be2:	6c8e                	ld	s9,192(sp)
    80005be4:	6d2e                	ld	s10,200(sp)
    80005be6:	6dce                	ld	s11,208(sp)
    80005be8:	6e6e                	ld	t3,216(sp)
    80005bea:	7e8e                	ld	t4,224(sp)
    80005bec:	7f2e                	ld	t5,232(sp)
    80005bee:	7fce                	ld	t6,240(sp)
    80005bf0:	6111                	add	sp,sp,256
    80005bf2:	10200073          	sret
    80005bf6:	00000013          	nop
    80005bfa:	00000013          	nop
    80005bfe:	0001                	nop

0000000080005c00 <timervec>:
    80005c00:	34051573          	csrrw	a0,mscratch,a0
    80005c04:	e10c                	sd	a1,0(a0)
    80005c06:	e510                	sd	a2,8(a0)
    80005c08:	e914                	sd	a3,16(a0)
    80005c0a:	6d0c                	ld	a1,24(a0)
    80005c0c:	7110                	ld	a2,32(a0)
    80005c0e:	6194                	ld	a3,0(a1)
    80005c10:	96b2                	add	a3,a3,a2
    80005c12:	e194                	sd	a3,0(a1)
    80005c14:	4589                	li	a1,2
    80005c16:	14459073          	csrw	sip,a1
    80005c1a:	6914                	ld	a3,16(a0)
    80005c1c:	6510                	ld	a2,8(a0)
    80005c1e:	610c                	ld	a1,0(a0)
    80005c20:	34051573          	csrrw	a0,mscratch,a0
    80005c24:	30200073          	mret
	...

0000000080005c2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c2a:	1141                	add	sp,sp,-16
    80005c2c:	e422                	sd	s0,8(sp)
    80005c2e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c30:	0c0007b7          	lui	a5,0xc000
    80005c34:	4705                	li	a4,1
    80005c36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c38:	c3d8                	sw	a4,4(a5)
}
    80005c3a:	6422                	ld	s0,8(sp)
    80005c3c:	0141                	add	sp,sp,16
    80005c3e:	8082                	ret

0000000080005c40 <plicinithart>:

void
plicinithart(void)
{
    80005c40:	1141                	add	sp,sp,-16
    80005c42:	e406                	sd	ra,8(sp)
    80005c44:	e022                	sd	s0,0(sp)
    80005c46:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005c48:	ffffc097          	auipc	ra,0xffffc
    80005c4c:	d3a080e7          	jalr	-710(ra) # 80001982 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c50:	0085171b          	sllw	a4,a0,0x8
    80005c54:	0c0027b7          	lui	a5,0xc002
    80005c58:	97ba                	add	a5,a5,a4
    80005c5a:	40200713          	li	a4,1026
    80005c5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c62:	00d5151b          	sllw	a0,a0,0xd
    80005c66:	0c2017b7          	lui	a5,0xc201
    80005c6a:	97aa                	add	a5,a5,a0
    80005c6c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c70:	60a2                	ld	ra,8(sp)
    80005c72:	6402                	ld	s0,0(sp)
    80005c74:	0141                	add	sp,sp,16
    80005c76:	8082                	ret

0000000080005c78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c78:	1141                	add	sp,sp,-16
    80005c7a:	e406                	sd	ra,8(sp)
    80005c7c:	e022                	sd	s0,0(sp)
    80005c7e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005c80:	ffffc097          	auipc	ra,0xffffc
    80005c84:	d02080e7          	jalr	-766(ra) # 80001982 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c88:	00d5151b          	sllw	a0,a0,0xd
    80005c8c:	0c2017b7          	lui	a5,0xc201
    80005c90:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c92:	43c8                	lw	a0,4(a5)
    80005c94:	60a2                	ld	ra,8(sp)
    80005c96:	6402                	ld	s0,0(sp)
    80005c98:	0141                	add	sp,sp,16
    80005c9a:	8082                	ret

0000000080005c9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c9c:	1101                	add	sp,sp,-32
    80005c9e:	ec06                	sd	ra,24(sp)
    80005ca0:	e822                	sd	s0,16(sp)
    80005ca2:	e426                	sd	s1,8(sp)
    80005ca4:	1000                	add	s0,sp,32
    80005ca6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	cda080e7          	jalr	-806(ra) # 80001982 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cb0:	00d5151b          	sllw	a0,a0,0xd
    80005cb4:	0c2017b7          	lui	a5,0xc201
    80005cb8:	97aa                	add	a5,a5,a0
    80005cba:	c3c4                	sw	s1,4(a5)
}
    80005cbc:	60e2                	ld	ra,24(sp)
    80005cbe:	6442                	ld	s0,16(sp)
    80005cc0:	64a2                	ld	s1,8(sp)
    80005cc2:	6105                	add	sp,sp,32
    80005cc4:	8082                	ret

0000000080005cc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cc6:	1141                	add	sp,sp,-16
    80005cc8:	e406                	sd	ra,8(sp)
    80005cca:	e022                	sd	s0,0(sp)
    80005ccc:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005cce:	479d                	li	a5,7
    80005cd0:	04a7cc63          	blt	a5,a0,80005d28 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005cd4:	0001c797          	auipc	a5,0x1c
    80005cd8:	03c78793          	add	a5,a5,60 # 80021d10 <disk>
    80005cdc:	97aa                	add	a5,a5,a0
    80005cde:	0187c783          	lbu	a5,24(a5)
    80005ce2:	ebb9                	bnez	a5,80005d38 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ce4:	00451693          	sll	a3,a0,0x4
    80005ce8:	0001c797          	auipc	a5,0x1c
    80005cec:	02878793          	add	a5,a5,40 # 80021d10 <disk>
    80005cf0:	6398                	ld	a4,0(a5)
    80005cf2:	9736                	add	a4,a4,a3
    80005cf4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005cf8:	6398                	ld	a4,0(a5)
    80005cfa:	9736                	add	a4,a4,a3
    80005cfc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d00:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d04:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d08:	97aa                	add	a5,a5,a0
    80005d0a:	4705                	li	a4,1
    80005d0c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d10:	0001c517          	auipc	a0,0x1c
    80005d14:	01850513          	add	a0,a0,24 # 80021d28 <disk+0x18>
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	3a2080e7          	jalr	930(ra) # 800020ba <wakeup>
}
    80005d20:	60a2                	ld	ra,8(sp)
    80005d22:	6402                	ld	s0,0(sp)
    80005d24:	0141                	add	sp,sp,16
    80005d26:	8082                	ret
    panic("free_desc 1");
    80005d28:	00003517          	auipc	a0,0x3
    80005d2c:	a3850513          	add	a0,a0,-1480 # 80008760 <syscalls+0x310>
    80005d30:	ffffb097          	auipc	ra,0xffffb
    80005d34:	80c080e7          	jalr	-2036(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005d38:	00003517          	auipc	a0,0x3
    80005d3c:	a3850513          	add	a0,a0,-1480 # 80008770 <syscalls+0x320>
    80005d40:	ffffa097          	auipc	ra,0xffffa
    80005d44:	7fc080e7          	jalr	2044(ra) # 8000053c <panic>

0000000080005d48 <virtio_disk_init>:
{
    80005d48:	1101                	add	sp,sp,-32
    80005d4a:	ec06                	sd	ra,24(sp)
    80005d4c:	e822                	sd	s0,16(sp)
    80005d4e:	e426                	sd	s1,8(sp)
    80005d50:	e04a                	sd	s2,0(sp)
    80005d52:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d54:	00003597          	auipc	a1,0x3
    80005d58:	a2c58593          	add	a1,a1,-1492 # 80008780 <syscalls+0x330>
    80005d5c:	0001c517          	auipc	a0,0x1c
    80005d60:	0dc50513          	add	a0,a0,220 # 80021e38 <disk+0x128>
    80005d64:	ffffb097          	auipc	ra,0xffffb
    80005d68:	dde080e7          	jalr	-546(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d6c:	100017b7          	lui	a5,0x10001
    80005d70:	4398                	lw	a4,0(a5)
    80005d72:	2701                	sext.w	a4,a4
    80005d74:	747277b7          	lui	a5,0x74727
    80005d78:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d7c:	14f71b63          	bne	a4,a5,80005ed2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d80:	100017b7          	lui	a5,0x10001
    80005d84:	43dc                	lw	a5,4(a5)
    80005d86:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d88:	4709                	li	a4,2
    80005d8a:	14e79463          	bne	a5,a4,80005ed2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d8e:	100017b7          	lui	a5,0x10001
    80005d92:	479c                	lw	a5,8(a5)
    80005d94:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d96:	12e79e63          	bne	a5,a4,80005ed2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d9a:	100017b7          	lui	a5,0x10001
    80005d9e:	47d8                	lw	a4,12(a5)
    80005da0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005da2:	554d47b7          	lui	a5,0x554d4
    80005da6:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005daa:	12f71463          	bne	a4,a5,80005ed2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dae:	100017b7          	lui	a5,0x10001
    80005db2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db6:	4705                	li	a4,1
    80005db8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dba:	470d                	li	a4,3
    80005dbc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dbe:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dc0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005dc4:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb90f>
    80005dc8:	8f75                	and	a4,a4,a3
    80005dca:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dcc:	472d                	li	a4,11
    80005dce:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005dd0:	5bbc                	lw	a5,112(a5)
    80005dd2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005dd6:	8ba1                	and	a5,a5,8
    80005dd8:	10078563          	beqz	a5,80005ee2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ddc:	100017b7          	lui	a5,0x10001
    80005de0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005de4:	43fc                	lw	a5,68(a5)
    80005de6:	2781                	sext.w	a5,a5
    80005de8:	10079563          	bnez	a5,80005ef2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dec:	100017b7          	lui	a5,0x10001
    80005df0:	5bdc                	lw	a5,52(a5)
    80005df2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005df4:	10078763          	beqz	a5,80005f02 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005df8:	471d                	li	a4,7
    80005dfa:	10f77c63          	bgeu	a4,a5,80005f12 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005dfe:	ffffb097          	auipc	ra,0xffffb
    80005e02:	ce4080e7          	jalr	-796(ra) # 80000ae2 <kalloc>
    80005e06:	0001c497          	auipc	s1,0x1c
    80005e0a:	f0a48493          	add	s1,s1,-246 # 80021d10 <disk>
    80005e0e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	cd2080e7          	jalr	-814(ra) # 80000ae2 <kalloc>
    80005e18:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e1a:	ffffb097          	auipc	ra,0xffffb
    80005e1e:	cc8080e7          	jalr	-824(ra) # 80000ae2 <kalloc>
    80005e22:	87aa                	mv	a5,a0
    80005e24:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e26:	6088                	ld	a0,0(s1)
    80005e28:	cd6d                	beqz	a0,80005f22 <virtio_disk_init+0x1da>
    80005e2a:	0001c717          	auipc	a4,0x1c
    80005e2e:	eee73703          	ld	a4,-274(a4) # 80021d18 <disk+0x8>
    80005e32:	cb65                	beqz	a4,80005f22 <virtio_disk_init+0x1da>
    80005e34:	c7fd                	beqz	a5,80005f22 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005e36:	6605                	lui	a2,0x1
    80005e38:	4581                	li	a1,0
    80005e3a:	ffffb097          	auipc	ra,0xffffb
    80005e3e:	e94080e7          	jalr	-364(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e42:	0001c497          	auipc	s1,0x1c
    80005e46:	ece48493          	add	s1,s1,-306 # 80021d10 <disk>
    80005e4a:	6605                	lui	a2,0x1
    80005e4c:	4581                	li	a1,0
    80005e4e:	6488                	ld	a0,8(s1)
    80005e50:	ffffb097          	auipc	ra,0xffffb
    80005e54:	e7e080e7          	jalr	-386(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005e58:	6605                	lui	a2,0x1
    80005e5a:	4581                	li	a1,0
    80005e5c:	6888                	ld	a0,16(s1)
    80005e5e:	ffffb097          	auipc	ra,0xffffb
    80005e62:	e70080e7          	jalr	-400(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e66:	100017b7          	lui	a5,0x10001
    80005e6a:	4721                	li	a4,8
    80005e6c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e6e:	4098                	lw	a4,0(s1)
    80005e70:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e74:	40d8                	lw	a4,4(s1)
    80005e76:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e7a:	6498                	ld	a4,8(s1)
    80005e7c:	0007069b          	sext.w	a3,a4
    80005e80:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e84:	9701                	sra	a4,a4,0x20
    80005e86:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e8a:	6898                	ld	a4,16(s1)
    80005e8c:	0007069b          	sext.w	a3,a4
    80005e90:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e94:	9701                	sra	a4,a4,0x20
    80005e96:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e9a:	4705                	li	a4,1
    80005e9c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e9e:	00e48c23          	sb	a4,24(s1)
    80005ea2:	00e48ca3          	sb	a4,25(s1)
    80005ea6:	00e48d23          	sb	a4,26(s1)
    80005eaa:	00e48da3          	sb	a4,27(s1)
    80005eae:	00e48e23          	sb	a4,28(s1)
    80005eb2:	00e48ea3          	sb	a4,29(s1)
    80005eb6:	00e48f23          	sb	a4,30(s1)
    80005eba:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ebe:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ec2:	0727a823          	sw	s2,112(a5)
}
    80005ec6:	60e2                	ld	ra,24(sp)
    80005ec8:	6442                	ld	s0,16(sp)
    80005eca:	64a2                	ld	s1,8(sp)
    80005ecc:	6902                	ld	s2,0(sp)
    80005ece:	6105                	add	sp,sp,32
    80005ed0:	8082                	ret
    panic("could not find virtio disk");
    80005ed2:	00003517          	auipc	a0,0x3
    80005ed6:	8be50513          	add	a0,a0,-1858 # 80008790 <syscalls+0x340>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	662080e7          	jalr	1634(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	8ce50513          	add	a0,a0,-1842 # 800087b0 <syscalls+0x360>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	652080e7          	jalr	1618(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	8de50513          	add	a0,a0,-1826 # 800087d0 <syscalls+0x380>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	642080e7          	jalr	1602(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005f02:	00003517          	auipc	a0,0x3
    80005f06:	8ee50513          	add	a0,a0,-1810 # 800087f0 <syscalls+0x3a0>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	632080e7          	jalr	1586(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005f12:	00003517          	auipc	a0,0x3
    80005f16:	8fe50513          	add	a0,a0,-1794 # 80008810 <syscalls+0x3c0>
    80005f1a:	ffffa097          	auipc	ra,0xffffa
    80005f1e:	622080e7          	jalr	1570(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005f22:	00003517          	auipc	a0,0x3
    80005f26:	90e50513          	add	a0,a0,-1778 # 80008830 <syscalls+0x3e0>
    80005f2a:	ffffa097          	auipc	ra,0xffffa
    80005f2e:	612080e7          	jalr	1554(ra) # 8000053c <panic>

0000000080005f32 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f32:	7159                	add	sp,sp,-112
    80005f34:	f486                	sd	ra,104(sp)
    80005f36:	f0a2                	sd	s0,96(sp)
    80005f38:	eca6                	sd	s1,88(sp)
    80005f3a:	e8ca                	sd	s2,80(sp)
    80005f3c:	e4ce                	sd	s3,72(sp)
    80005f3e:	e0d2                	sd	s4,64(sp)
    80005f40:	fc56                	sd	s5,56(sp)
    80005f42:	f85a                	sd	s6,48(sp)
    80005f44:	f45e                	sd	s7,40(sp)
    80005f46:	f062                	sd	s8,32(sp)
    80005f48:	ec66                	sd	s9,24(sp)
    80005f4a:	e86a                	sd	s10,16(sp)
    80005f4c:	1880                	add	s0,sp,112
    80005f4e:	8a2a                	mv	s4,a0
    80005f50:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f52:	00c52c83          	lw	s9,12(a0)
    80005f56:	001c9c9b          	sllw	s9,s9,0x1
    80005f5a:	1c82                	sll	s9,s9,0x20
    80005f5c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f60:	0001c517          	auipc	a0,0x1c
    80005f64:	ed850513          	add	a0,a0,-296 # 80021e38 <disk+0x128>
    80005f68:	ffffb097          	auipc	ra,0xffffb
    80005f6c:	c6a080e7          	jalr	-918(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80005f70:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005f72:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f74:	0001cb17          	auipc	s6,0x1c
    80005f78:	d9cb0b13          	add	s6,s6,-612 # 80021d10 <disk>
  for(int i = 0; i < 3; i++){
    80005f7c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f7e:	0001cc17          	auipc	s8,0x1c
    80005f82:	ebac0c13          	add	s8,s8,-326 # 80021e38 <disk+0x128>
    80005f86:	a095                	j	80005fea <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f88:	00fb0733          	add	a4,s6,a5
    80005f8c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f90:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80005f92:	0207c563          	bltz	a5,80005fbc <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80005f96:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80005f98:	0591                	add	a1,a1,4
    80005f9a:	05560d63          	beq	a2,s5,80005ff4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f9e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80005fa0:	0001c717          	auipc	a4,0x1c
    80005fa4:	d7070713          	add	a4,a4,-656 # 80021d10 <disk>
    80005fa8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80005faa:	01874683          	lbu	a3,24(a4)
    80005fae:	fee9                	bnez	a3,80005f88 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80005fb0:	2785                	addw	a5,a5,1
    80005fb2:	0705                	add	a4,a4,1
    80005fb4:	fe979be3          	bne	a5,s1,80005faa <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80005fb8:	57fd                	li	a5,-1
    80005fba:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80005fbc:	00c05e63          	blez	a2,80005fd8 <virtio_disk_rw+0xa6>
    80005fc0:	060a                	sll	a2,a2,0x2
    80005fc2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80005fc6:	0009a503          	lw	a0,0(s3)
    80005fca:	00000097          	auipc	ra,0x0
    80005fce:	cfc080e7          	jalr	-772(ra) # 80005cc6 <free_desc>
      for(int j = 0; j < i; j++)
    80005fd2:	0991                	add	s3,s3,4
    80005fd4:	ffa999e3          	bne	s3,s10,80005fc6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fd8:	85e2                	mv	a1,s8
    80005fda:	0001c517          	auipc	a0,0x1c
    80005fde:	d4e50513          	add	a0,a0,-690 # 80021d28 <disk+0x18>
    80005fe2:	ffffc097          	auipc	ra,0xffffc
    80005fe6:	074080e7          	jalr	116(ra) # 80002056 <sleep>
  for(int i = 0; i < 3; i++){
    80005fea:	f9040993          	add	s3,s0,-112
{
    80005fee:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80005ff0:	864a                	mv	a2,s2
    80005ff2:	b775                	j	80005f9e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ff4:	f9042503          	lw	a0,-112(s0)
    80005ff8:	00a50713          	add	a4,a0,10
    80005ffc:	0712                	sll	a4,a4,0x4

  if(write)
    80005ffe:	0001c797          	auipc	a5,0x1c
    80006002:	d1278793          	add	a5,a5,-750 # 80021d10 <disk>
    80006006:	00e786b3          	add	a3,a5,a4
    8000600a:	01703633          	snez	a2,s7
    8000600e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006010:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006014:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006018:	f6070613          	add	a2,a4,-160
    8000601c:	6394                	ld	a3,0(a5)
    8000601e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006020:	00870593          	add	a1,a4,8
    80006024:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006026:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006028:	0007b803          	ld	a6,0(a5)
    8000602c:	9642                	add	a2,a2,a6
    8000602e:	46c1                	li	a3,16
    80006030:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006032:	4585                	li	a1,1
    80006034:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006038:	f9442683          	lw	a3,-108(s0)
    8000603c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006040:	0692                	sll	a3,a3,0x4
    80006042:	9836                	add	a6,a6,a3
    80006044:	058a0613          	add	a2,s4,88
    80006048:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000604c:	0007b803          	ld	a6,0(a5)
    80006050:	96c2                	add	a3,a3,a6
    80006052:	40000613          	li	a2,1024
    80006056:	c690                	sw	a2,8(a3)
  if(write)
    80006058:	001bb613          	seqz	a2,s7
    8000605c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006060:	00166613          	or	a2,a2,1
    80006064:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006068:	f9842603          	lw	a2,-104(s0)
    8000606c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006070:	00250693          	add	a3,a0,2
    80006074:	0692                	sll	a3,a3,0x4
    80006076:	96be                	add	a3,a3,a5
    80006078:	58fd                	li	a7,-1
    8000607a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000607e:	0612                	sll	a2,a2,0x4
    80006080:	9832                	add	a6,a6,a2
    80006082:	f9070713          	add	a4,a4,-112
    80006086:	973e                	add	a4,a4,a5
    80006088:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000608c:	6398                	ld	a4,0(a5)
    8000608e:	9732                	add	a4,a4,a2
    80006090:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006092:	4609                	li	a2,2
    80006094:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006098:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000609c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    800060a0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060a4:	6794                	ld	a3,8(a5)
    800060a6:	0026d703          	lhu	a4,2(a3)
    800060aa:	8b1d                	and	a4,a4,7
    800060ac:	0706                	sll	a4,a4,0x1
    800060ae:	96ba                	add	a3,a3,a4
    800060b0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800060b4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060b8:	6798                	ld	a4,8(a5)
    800060ba:	00275783          	lhu	a5,2(a4)
    800060be:	2785                	addw	a5,a5,1
    800060c0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800060c4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060c8:	100017b7          	lui	a5,0x10001
    800060cc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060d0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800060d4:	0001c917          	auipc	s2,0x1c
    800060d8:	d6490913          	add	s2,s2,-668 # 80021e38 <disk+0x128>
  while(b->disk == 1) {
    800060dc:	4485                	li	s1,1
    800060de:	00b79c63          	bne	a5,a1,800060f6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800060e2:	85ca                	mv	a1,s2
    800060e4:	8552                	mv	a0,s4
    800060e6:	ffffc097          	auipc	ra,0xffffc
    800060ea:	f70080e7          	jalr	-144(ra) # 80002056 <sleep>
  while(b->disk == 1) {
    800060ee:	004a2783          	lw	a5,4(s4)
    800060f2:	fe9788e3          	beq	a5,s1,800060e2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800060f6:	f9042903          	lw	s2,-112(s0)
    800060fa:	00290713          	add	a4,s2,2
    800060fe:	0712                	sll	a4,a4,0x4
    80006100:	0001c797          	auipc	a5,0x1c
    80006104:	c1078793          	add	a5,a5,-1008 # 80021d10 <disk>
    80006108:	97ba                	add	a5,a5,a4
    8000610a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000610e:	0001c997          	auipc	s3,0x1c
    80006112:	c0298993          	add	s3,s3,-1022 # 80021d10 <disk>
    80006116:	00491713          	sll	a4,s2,0x4
    8000611a:	0009b783          	ld	a5,0(s3)
    8000611e:	97ba                	add	a5,a5,a4
    80006120:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006124:	854a                	mv	a0,s2
    80006126:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000612a:	00000097          	auipc	ra,0x0
    8000612e:	b9c080e7          	jalr	-1124(ra) # 80005cc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006132:	8885                	and	s1,s1,1
    80006134:	f0ed                	bnez	s1,80006116 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006136:	0001c517          	auipc	a0,0x1c
    8000613a:	d0250513          	add	a0,a0,-766 # 80021e38 <disk+0x128>
    8000613e:	ffffb097          	auipc	ra,0xffffb
    80006142:	b48080e7          	jalr	-1208(ra) # 80000c86 <release>
}
    80006146:	70a6                	ld	ra,104(sp)
    80006148:	7406                	ld	s0,96(sp)
    8000614a:	64e6                	ld	s1,88(sp)
    8000614c:	6946                	ld	s2,80(sp)
    8000614e:	69a6                	ld	s3,72(sp)
    80006150:	6a06                	ld	s4,64(sp)
    80006152:	7ae2                	ld	s5,56(sp)
    80006154:	7b42                	ld	s6,48(sp)
    80006156:	7ba2                	ld	s7,40(sp)
    80006158:	7c02                	ld	s8,32(sp)
    8000615a:	6ce2                	ld	s9,24(sp)
    8000615c:	6d42                	ld	s10,16(sp)
    8000615e:	6165                	add	sp,sp,112
    80006160:	8082                	ret

0000000080006162 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006162:	1101                	add	sp,sp,-32
    80006164:	ec06                	sd	ra,24(sp)
    80006166:	e822                	sd	s0,16(sp)
    80006168:	e426                	sd	s1,8(sp)
    8000616a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000616c:	0001c497          	auipc	s1,0x1c
    80006170:	ba448493          	add	s1,s1,-1116 # 80021d10 <disk>
    80006174:	0001c517          	auipc	a0,0x1c
    80006178:	cc450513          	add	a0,a0,-828 # 80021e38 <disk+0x128>
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	a56080e7          	jalr	-1450(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006184:	10001737          	lui	a4,0x10001
    80006188:	533c                	lw	a5,96(a4)
    8000618a:	8b8d                	and	a5,a5,3
    8000618c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000618e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006192:	689c                	ld	a5,16(s1)
    80006194:	0204d703          	lhu	a4,32(s1)
    80006198:	0027d783          	lhu	a5,2(a5)
    8000619c:	04f70863          	beq	a4,a5,800061ec <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800061a0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061a4:	6898                	ld	a4,16(s1)
    800061a6:	0204d783          	lhu	a5,32(s1)
    800061aa:	8b9d                	and	a5,a5,7
    800061ac:	078e                	sll	a5,a5,0x3
    800061ae:	97ba                	add	a5,a5,a4
    800061b0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061b2:	00278713          	add	a4,a5,2
    800061b6:	0712                	sll	a4,a4,0x4
    800061b8:	9726                	add	a4,a4,s1
    800061ba:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800061be:	e721                	bnez	a4,80006206 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061c0:	0789                	add	a5,a5,2
    800061c2:	0792                	sll	a5,a5,0x4
    800061c4:	97a6                	add	a5,a5,s1
    800061c6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800061c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061cc:	ffffc097          	auipc	ra,0xffffc
    800061d0:	eee080e7          	jalr	-274(ra) # 800020ba <wakeup>

    disk.used_idx += 1;
    800061d4:	0204d783          	lhu	a5,32(s1)
    800061d8:	2785                	addw	a5,a5,1
    800061da:	17c2                	sll	a5,a5,0x30
    800061dc:	93c1                	srl	a5,a5,0x30
    800061de:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061e2:	6898                	ld	a4,16(s1)
    800061e4:	00275703          	lhu	a4,2(a4)
    800061e8:	faf71ce3          	bne	a4,a5,800061a0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061ec:	0001c517          	auipc	a0,0x1c
    800061f0:	c4c50513          	add	a0,a0,-948 # 80021e38 <disk+0x128>
    800061f4:	ffffb097          	auipc	ra,0xffffb
    800061f8:	a92080e7          	jalr	-1390(ra) # 80000c86 <release>
}
    800061fc:	60e2                	ld	ra,24(sp)
    800061fe:	6442                	ld	s0,16(sp)
    80006200:	64a2                	ld	s1,8(sp)
    80006202:	6105                	add	sp,sp,32
    80006204:	8082                	ret
      panic("virtio_disk_intr status");
    80006206:	00002517          	auipc	a0,0x2
    8000620a:	64250513          	add	a0,a0,1602 # 80008848 <syscalls+0x3f8>
    8000620e:	ffffa097          	auipc	ra,0xffffa
    80006212:	32e080e7          	jalr	814(ra) # 8000053c <panic>

0000000080006216 <semaphores_init>:

struct semaphore semaphores[MAX_SEMAPHORES]; 

void
semaphores_init()
{
    80006216:	7179                	add	sp,sp,-48
    80006218:	f406                	sd	ra,40(sp)
    8000621a:	f022                	sd	s0,32(sp)
    8000621c:	ec26                	sd	s1,24(sp)
    8000621e:	e84a                	sd	s2,16(sp)
    80006220:	e44e                	sd	s3,8(sp)
    80006222:	1800                	add	s0,sp,48
  for(unsigned int i = 0u; i < MAX_SEMAPHORES; i++) {
    80006224:	0001c497          	auipc	s1,0x1c
    80006228:	c3448493          	add	s1,s1,-972 # 80021e58 <semaphores+0x8>
    8000622c:	0001d997          	auipc	s3,0x1d
    80006230:	c2c98993          	add	s3,s3,-980 # 80022e58 <end+0x8>
    semaphores[i].value = 0;
    semaphores[i].in_use = 0;
    initlock(&semaphores[i].lock, "semaphore");
    80006234:	00002917          	auipc	s2,0x2
    80006238:	62c90913          	add	s2,s2,1580 # 80008860 <syscalls+0x410>
    semaphores[i].value = 0;
    8000623c:	fe04ac23          	sw	zero,-8(s1)
    semaphores[i].in_use = 0;
    80006240:	fe04ae23          	sw	zero,-4(s1)
    initlock(&semaphores[i].lock, "semaphore");
    80006244:	85ca                	mv	a1,s2
    80006246:	8526                	mv	a0,s1
    80006248:	ffffb097          	auipc	ra,0xffffb
    8000624c:	8fa080e7          	jalr	-1798(ra) # 80000b42 <initlock>
  for(unsigned int i = 0u; i < MAX_SEMAPHORES; i++) {
    80006250:	02048493          	add	s1,s1,32
    80006254:	ff3494e3          	bne	s1,s3,8000623c <semaphores_init+0x26>
  }
}
    80006258:	70a2                	ld	ra,40(sp)
    8000625a:	7402                	ld	s0,32(sp)
    8000625c:	64e2                	ld	s1,24(sp)
    8000625e:	6942                	ld	s2,16(sp)
    80006260:	69a2                	ld	s3,8(sp)
    80006262:	6145                	add	sp,sp,48
    80006264:	8082                	ret

0000000080006266 <sem_open>:

int
sem_open(int sem, int value)
{
    80006266:	7139                	add	sp,sp,-64
    80006268:	fc06                	sd	ra,56(sp)
    8000626a:	f822                	sd	s0,48(sp)
    8000626c:	f426                	sd	s1,40(sp)
    8000626e:	f04a                	sd	s2,32(sp)
    80006270:	ec4e                	sd	s3,24(sp)
    80006272:	e852                	sd	s4,16(sp)
    80006274:	e456                	sd	s5,8(sp)
    80006276:	0080                	add	s0,sp,64
  if (sem < 0 || value < 0 || sem >= MAX_SEMAPHORES) {
    80006278:	07f00793          	li	a5,127
    8000627c:	06a7e863          	bltu	a5,a0,800062ec <sem_open+0x86>
    80006280:	84ae                	mv	s1,a1
    80006282:	892a                	mv	s2,a0
    80006284:	0605c663          	bltz	a1,800062f0 <sem_open+0x8a>
    return -1;
  }

  acquire(&semaphores[sem].lock); 
    80006288:	00551a93          	sll	s5,a0,0x5
    8000628c:	008a8993          	add	s3,s5,8
    80006290:	0001ca17          	auipc	s4,0x1c
    80006294:	bc0a0a13          	add	s4,s4,-1088 # 80021e50 <semaphores>
    80006298:	99d2                	add	s3,s3,s4
    8000629a:	854e                	mv	a0,s3
    8000629c:	ffffb097          	auipc	ra,0xffffb
    800062a0:	936080e7          	jalr	-1738(ra) # 80000bd2 <acquire>
  // Attempts to acquire the lock of the semaphore at position sem.
  // This prevents other processes from working with that semaphore while sem_open is using it.

  if (semaphores[sem].in_use) { // If it was already in use, return error.
    800062a4:	9a56                	add	s4,s4,s5
    800062a6:	004a2a03          	lw	s4,4(s4)
    800062aa:	020a1a63          	bnez	s4,800062de <sem_open+0x78>
    release(&semaphores[sem].lock);
    return -1;
  } 

  semaphores[sem].in_use = 1; // Activates the semaphore so it can be modified by sem_up and sem_down.
    800062ae:	0916                	sll	s2,s2,0x5
    800062b0:	0001c797          	auipc	a5,0x1c
    800062b4:	ba078793          	add	a5,a5,-1120 # 80021e50 <semaphores>
    800062b8:	97ca                	add	a5,a5,s2
    800062ba:	4705                	li	a4,1
    800062bc:	c3d8                	sw	a4,4(a5)
  semaphores[sem].value = value;
    800062be:	c384                	sw	s1,0(a5)
  release(&semaphores[sem].lock); // Releases the lock, allowing other programs to use it.
    800062c0:	854e                	mv	a0,s3
    800062c2:	ffffb097          	auipc	ra,0xffffb
    800062c6:	9c4080e7          	jalr	-1596(ra) # 80000c86 <release>
  
  return 0;
}
    800062ca:	8552                	mv	a0,s4
    800062cc:	70e2                	ld	ra,56(sp)
    800062ce:	7442                	ld	s0,48(sp)
    800062d0:	74a2                	ld	s1,40(sp)
    800062d2:	7902                	ld	s2,32(sp)
    800062d4:	69e2                	ld	s3,24(sp)
    800062d6:	6a42                	ld	s4,16(sp)
    800062d8:	6aa2                	ld	s5,8(sp)
    800062da:	6121                	add	sp,sp,64
    800062dc:	8082                	ret
    release(&semaphores[sem].lock);
    800062de:	854e                	mv	a0,s3
    800062e0:	ffffb097          	auipc	ra,0xffffb
    800062e4:	9a6080e7          	jalr	-1626(ra) # 80000c86 <release>
    return -1;
    800062e8:	5a7d                	li	s4,-1
    800062ea:	b7c5                	j	800062ca <sem_open+0x64>
    return -1;
    800062ec:	5a7d                	li	s4,-1
    800062ee:	bff1                	j	800062ca <sem_open+0x64>
    800062f0:	5a7d                	li	s4,-1
    800062f2:	bfe1                	j	800062ca <sem_open+0x64>

00000000800062f4 <sem_close>:

int
sem_close(int sem)
{
    800062f4:	7139                	add	sp,sp,-64
    800062f6:	fc06                	sd	ra,56(sp)
    800062f8:	f822                	sd	s0,48(sp)
    800062fa:	f426                	sd	s1,40(sp)
    800062fc:	f04a                	sd	s2,32(sp)
    800062fe:	ec4e                	sd	s3,24(sp)
    80006300:	e852                	sd	s4,16(sp)
    80006302:	e456                	sd	s5,8(sp)
    80006304:	0080                	add	s0,sp,64
  // Verify that the semaphore is valid.
  if (sem < 0 || sem >= MAX_SEMAPHORES) {
    80006306:	07f00793          	li	a5,127
    8000630a:	02a7ee63          	bltu	a5,a0,80006346 <sem_close+0x52>
    8000630e:	892a                	mv	s2,a0
  	printf("ERROR: Invalid semaphore. Please ensure that the process ID is correct.\n");
  	return -1;
  }

  if (!(semaphores[sem].in_use && semaphores[sem].value == 0)) {
    80006310:	00551713          	sll	a4,a0,0x5
    80006314:	0001c797          	auipc	a5,0x1c
    80006318:	b3c78793          	add	a5,a5,-1220 # 80021e50 <semaphores>
    8000631c:	97ba                	add	a5,a5,a4
    8000631e:	43c4                	lw	s1,4(a5)
    80006320:	c889                	beqz	s1,80006332 <sem_close+0x3e>
    80006322:	0001c797          	auipc	a5,0x1c
    80006326:	b2e78793          	add	a5,a5,-1234 # 80021e50 <semaphores>
    8000632a:	97ba                	add	a5,a5,a4
    8000632c:	4384                	lw	s1,0(a5)
    8000632e:	c495                	beqz	s1,8000635a <sem_close+0x66>
    return 0;
    80006330:	4481                	li	s1,0
  	return -1;
  }
  
  release(&(semaphores[sem].lock)); // Release the lock.
  return 0; // Semaphore closed successfully.
}
    80006332:	8526                	mv	a0,s1
    80006334:	70e2                	ld	ra,56(sp)
    80006336:	7442                	ld	s0,48(sp)
    80006338:	74a2                	ld	s1,40(sp)
    8000633a:	7902                	ld	s2,32(sp)
    8000633c:	69e2                	ld	s3,24(sp)
    8000633e:	6a42                	ld	s4,16(sp)
    80006340:	6aa2                	ld	s5,8(sp)
    80006342:	6121                	add	sp,sp,64
    80006344:	8082                	ret
  	printf("ERROR: Invalid semaphore. Please ensure that the process ID is correct.\n");
    80006346:	00002517          	auipc	a0,0x2
    8000634a:	52a50513          	add	a0,a0,1322 # 80008870 <syscalls+0x420>
    8000634e:	ffffa097          	auipc	ra,0xffffa
    80006352:	238080e7          	jalr	568(ra) # 80000586 <printf>
  	return -1;
    80006356:	54fd                	li	s1,-1
    80006358:	bfe9                	j	80006332 <sem_close+0x3e>
    acquire(&(semaphores[sem].lock));
    8000635a:	8aba                	mv	s5,a4
    8000635c:	00870993          	add	s3,a4,8
    80006360:	0001ca17          	auipc	s4,0x1c
    80006364:	af0a0a13          	add	s4,s4,-1296 # 80021e50 <semaphores>
    80006368:	99d2                	add	s3,s3,s4
    8000636a:	854e                	mv	a0,s3
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	866080e7          	jalr	-1946(ra) # 80000bd2 <acquire>
if (semaphores[sem].value != 0) {
    80006374:	9a56                	add	s4,s4,s5
    80006376:	000a2783          	lw	a5,0(s4)
    8000637a:	c399                	beqz	a5,80006380 <sem_close+0x8c>
  semaphores[sem].value = 0u;
    8000637c:	000a2023          	sw	zero,0(s4)
  if (semaphores[sem].in_use != 0) {
    80006380:	00591713          	sll	a4,s2,0x5
    80006384:	0001c797          	auipc	a5,0x1c
    80006388:	acc78793          	add	a5,a5,-1332 # 80021e50 <semaphores>
    8000638c:	97ba                	add	a5,a5,a4
    8000638e:	43dc                	lw	a5,4(a5)
    80006390:	cb81                	beqz	a5,800063a0 <sem_close+0xac>
  semaphores[sem].in_use = 0u;
    80006392:	0001c797          	auipc	a5,0x1c
    80006396:	abe78793          	add	a5,a5,-1346 # 80021e50 <semaphores>
    8000639a:	97ba                	add	a5,a5,a4
    8000639c:	0007a223          	sw	zero,4(a5)
  if (semaphores[sem].value != semaphores[sem].in_use) {
    800063a0:	0916                	sll	s2,s2,0x5
    800063a2:	0001c797          	auipc	a5,0x1c
    800063a6:	aae78793          	add	a5,a5,-1362 # 80021e50 <semaphores>
    800063aa:	97ca                	add	a5,a5,s2
    800063ac:	4398                	lw	a4,0(a5)
    800063ae:	43dc                	lw	a5,4(a5)
    800063b0:	00f71863          	bne	a4,a5,800063c0 <sem_close+0xcc>
  release(&(semaphores[sem].lock)); // Release the lock.
    800063b4:	854e                	mv	a0,s3
    800063b6:	ffffb097          	auipc	ra,0xffffb
    800063ba:	8d0080e7          	jalr	-1840(ra) # 80000c86 <release>
  return 0; // Semaphore closed successfully.
    800063be:	bf95                	j	80006332 <sem_close+0x3e>
  	printf("ERROR: Could not free the semaphore as expected. Please verify that it is at its initial value.\n");
    800063c0:	00002517          	auipc	a0,0x2
    800063c4:	50050513          	add	a0,a0,1280 # 800088c0 <syscalls+0x470>
    800063c8:	ffffa097          	auipc	ra,0xffffa
    800063cc:	1be080e7          	jalr	446(ra) # 80000586 <printf>
  	release(&(semaphores[sem].lock));
    800063d0:	854e                	mv	a0,s3
    800063d2:	ffffb097          	auipc	ra,0xffffb
    800063d6:	8b4080e7          	jalr	-1868(ra) # 80000c86 <release>
  	return -1;
    800063da:	54fd                	li	s1,-1
    800063dc:	bf99                	j	80006332 <sem_close+0x3e>

00000000800063de <sem_up>:

int
sem_up(int sem)
{
 if (sem < 0 || sem >= MAX_SEMAPHORES) { // Ensure that the semaphore is valid.
    800063de:	07f00793          	li	a5,127
    800063e2:	06a7e263          	bltu	a5,a0,80006446 <sem_up+0x68>
{
    800063e6:	7179                	add	sp,sp,-48
    800063e8:	f406                	sd	ra,40(sp)
    800063ea:	f022                	sd	s0,32(sp)
    800063ec:	ec26                	sd	s1,24(sp)
    800063ee:	e84a                	sd	s2,16(sp)
    800063f0:	e44e                	sd	s3,8(sp)
    800063f2:	1800                	add	s0,sp,48
    return -1;  // Error code if the semaphore is not valid.
  }

  acquire(&semaphores[sem].lock); // Acquire the semaphore's lock.
    800063f4:	00551913          	sll	s2,a0,0x5
    800063f8:	00890993          	add	s3,s2,8
    800063fc:	0001c497          	auipc	s1,0x1c
    80006400:	a5448493          	add	s1,s1,-1452 # 80021e50 <semaphores>
    80006404:	99a6                	add	s3,s3,s1
    80006406:	854e                	mv	a0,s3
    80006408:	ffffa097          	auipc	ra,0xffffa
    8000640c:	7ca080e7          	jalr	1994(ra) # 80000bd2 <acquire>
  semaphores[sem].value++; // Increment the semaphore.
    80006410:	94ca                	add	s1,s1,s2
    80006412:	409c                	lw	a5,0(s1)
    80006414:	2785                	addw	a5,a5,1
    80006416:	0007871b          	sext.w	a4,a5
    8000641a:	c09c                	sw	a5,0(s1)
  
  if (semaphores[sem].value > 0) { // Check if any processes need to be awakened.
    8000641c:	00e04f63          	bgtz	a4,8000643a <sem_up+0x5c>
    wakeup(&semaphores[sem]);  // Unblock processes that are waiting.
  }

  release(&semaphores[sem].lock); // Release the lock.
    80006420:	854e                	mv	a0,s3
    80006422:	ffffb097          	auipc	ra,0xffffb
    80006426:	864080e7          	jalr	-1948(ra) # 80000c86 <release>

  return 0;
    8000642a:	4501                	li	a0,0
}
    8000642c:	70a2                	ld	ra,40(sp)
    8000642e:	7402                	ld	s0,32(sp)
    80006430:	64e2                	ld	s1,24(sp)
    80006432:	6942                	ld	s2,16(sp)
    80006434:	69a2                	ld	s3,8(sp)
    80006436:	6145                	add	sp,sp,48
    80006438:	8082                	ret
    wakeup(&semaphores[sem]);  // Unblock processes that are waiting.
    8000643a:	8526                	mv	a0,s1
    8000643c:	ffffc097          	auipc	ra,0xffffc
    80006440:	c7e080e7          	jalr	-898(ra) # 800020ba <wakeup>
    80006444:	bff1                	j	80006420 <sem_up+0x42>
    return -1;  // Error code if the semaphore is not valid.
    80006446:	557d                	li	a0,-1
}
    80006448:	8082                	ret

000000008000644a <sem_down>:

int
sem_down(int sem)
{
  if (sem < 0 || sem >= MAX_SEMAPHORES) {
    8000644a:	07f00793          	li	a5,127
    8000644e:	08a7e663          	bltu	a5,a0,800064da <sem_down+0x90>
{
    80006452:	7179                	add	sp,sp,-48
    80006454:	f406                	sd	ra,40(sp)
    80006456:	f022                	sd	s0,32(sp)
    80006458:	ec26                	sd	s1,24(sp)
    8000645a:	e84a                	sd	s2,16(sp)
    8000645c:	e44e                	sd	s3,8(sp)
    8000645e:	e052                	sd	s4,0(sp)
    80006460:	1800                	add	s0,sp,48
    80006462:	8a2a                	mv	s4,a0
    return -1;
  }

  acquire(&semaphores[sem].lock); 
    80006464:	00551913          	sll	s2,a0,0x5
    80006468:	00890493          	add	s1,s2,8
    8000646c:	0001c997          	auipc	s3,0x1c
    80006470:	9e498993          	add	s3,s3,-1564 # 80021e50 <semaphores>
    80006474:	94ce                	add	s1,s1,s3
    80006476:	8526                	mv	a0,s1
    80006478:	ffffa097          	auipc	ra,0xffffa
    8000647c:	75a080e7          	jalr	1882(ra) # 80000bd2 <acquire>

  if(semaphores[sem].value < 0) { //
    80006480:	99ca                	add	s3,s3,s2
    80006482:	0009a783          	lw	a5,0(s3)
    80006486:	0407c363          	bltz	a5,800064cc <sem_down+0x82>
    return -1;
  }

  // By convention: 0 indicates that this semaphore is shared among threads of the same process.
  while(semaphores[sem].value == 0) {
    sleep(&semaphores[sem], &semaphores[sem].lock); // Blocks the process until the semaphore is free.
    8000648a:	894e                	mv	s2,s3
  while(semaphores[sem].value == 0) {
    8000648c:	eb91                	bnez	a5,800064a0 <sem_down+0x56>
    sleep(&semaphores[sem], &semaphores[sem].lock); // Blocks the process until the semaphore is free.
    8000648e:	85a6                	mv	a1,s1
    80006490:	854a                	mv	a0,s2
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	bc4080e7          	jalr	-1084(ra) # 80002056 <sleep>
  while(semaphores[sem].value == 0) {
    8000649a:	0009a783          	lw	a5,0(s3)
    8000649e:	dbe5                	beqz	a5,8000648e <sem_down+0x44>
  }
  semaphores[sem].value--; // sem_down when the semaphore is free.
    800064a0:	0a16                	sll	s4,s4,0x5
    800064a2:	0001c717          	auipc	a4,0x1c
    800064a6:	9ae70713          	add	a4,a4,-1618 # 80021e50 <semaphores>
    800064aa:	9752                	add	a4,a4,s4
    800064ac:	37fd                	addw	a5,a5,-1
    800064ae:	c31c                	sw	a5,0(a4)

  release(&semaphores[sem].lock);
    800064b0:	8526                	mv	a0,s1
    800064b2:	ffffa097          	auipc	ra,0xffffa
    800064b6:	7d4080e7          	jalr	2004(ra) # 80000c86 <release>

  return 0;
    800064ba:	4501                	li	a0,0
}
    800064bc:	70a2                	ld	ra,40(sp)
    800064be:	7402                	ld	s0,32(sp)
    800064c0:	64e2                	ld	s1,24(sp)
    800064c2:	6942                	ld	s2,16(sp)
    800064c4:	69a2                	ld	s3,8(sp)
    800064c6:	6a02                	ld	s4,0(sp)
    800064c8:	6145                	add	sp,sp,48
    800064ca:	8082                	ret
    release(&semaphores[sem].lock);
    800064cc:	8526                	mv	a0,s1
    800064ce:	ffffa097          	auipc	ra,0xffffa
    800064d2:	7b8080e7          	jalr	1976(ra) # 80000c86 <release>
    return -1;
    800064d6:	557d                	li	a0,-1
    800064d8:	b7d5                	j	800064bc <sem_down+0x72>
    return -1;
    800064da:	557d                	li	a0,-1
}
    800064dc:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
