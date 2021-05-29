
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	18010113          	addi	sp,sp,384 # 8000a180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fee70713          	addi	a4,a4,-18 # 8000a040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00007797          	auipc	a5,0x7
    80000068:	afc78793          	addi	a5,a5,-1284 # 80006b60 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb37ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	146080e7          	jalr	326(ra) # 80002264 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00012917          	auipc	s2,0x12
    80000198:	08490913          	addi	s2,s2,132 # 80012218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	9d4080e7          	jalr	-1580(ra) # 80001b86 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	da2080e7          	jalr	-606(ra) # 80001f64 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	010080e7          	jalr	16(ra) # 8000220e <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00012517          	auipc	a0,0x12
    80000216:	f6e50513          	addi	a0,a0,-146 # 80012180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	f5850513          	addi	a0,a0,-168 # 80012180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	faf72d23          	sw	a5,-70(a4) # 80012218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	ec850513          	addi	a0,a0,-312 # 80012180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	fdc080e7          	jalr	-36(ra) # 800022ba <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00012517          	auipc	a0,0x12
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80012180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00012717          	auipc	a4,0x12
    8000030e:	e7670713          	addi	a4,a4,-394 # 80012180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00012797          	auipc	a5,0x12
    80000338:	e4c78793          	addi	a5,a5,-436 # 80012180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00012797          	auipc	a5,0x12
    80000366:	eb67a783          	lw	a5,-330(a5) # 80012218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00012717          	auipc	a4,0x12
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80012180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00012497          	auipc	s1,0x12
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80012180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00012717          	auipc	a4,0x12
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80012180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00012717          	auipc	a4,0x12
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80012220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00012797          	auipc	a5,0x12
    80000402:	d8278793          	addi	a5,a5,-638 # 80012180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00012517          	auipc	a0,0x12
    8000042e:	dee50513          	addi	a0,a0,-530 # 80012218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	b96080e7          	jalr	-1130(ra) # 80001fc8 <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00009597          	auipc	a1,0x9
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80009010 <etext+0x10>
    8000044c:	00012517          	auipc	a0,0x12
    80000450:	d3450513          	addi	a0,a0,-716 # 80012180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00046797          	auipc	a5,0x46
    80000468:	6b478793          	addi	a5,a5,1716 # 80046b18 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00009617          	auipc	a2,0x9
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80009040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00012797          	auipc	a5,0x12
    8000053a:	d007a523          	sw	zero,-758(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    8000053e:	00009517          	auipc	a0,0x9
    80000542:	ada50513          	addi	a0,a0,-1318 # 80009018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00009517          	auipc	a0,0x9
    8000055c:	f5050513          	addi	a0,a0,-176 # 800094a8 <digits+0x468>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	0000a717          	auipc	a4,0xa
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 8000a000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00012d97          	auipc	s11,0x12
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80012240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00009b17          	auipc	s6,0x9
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80009040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00012517          	auipc	a0,0x12
    800005e8:	c4450513          	addi	a0,a0,-956 # 80012228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00009517          	auipc	a0,0x9
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80009028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00009497          	auipc	s1,0x9
    800006f4:	93048493          	addi	s1,s1,-1744 # 80009020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00012517          	auipc	a0,0x12
    80000746:	ae650513          	addi	a0,a0,-1306 # 80012228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00012497          	auipc	s1,0x12
    80000762:	aca48493          	addi	s1,s1,-1334 # 80012228 <pr>
    80000766:	00009597          	auipc	a1,0x9
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80009038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00009597          	auipc	a1,0x9
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80009058 <digits+0x18>
    800007be:	00012517          	auipc	a0,0x12
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80012248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	0000a797          	auipc	a5,0xa
    800007ee:	8167a783          	lw	a5,-2026(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00009797          	auipc	a5,0x9
    80000826:	7e67b783          	ld	a5,2022(a5) # 8000a008 <uart_tx_r>
    8000082a:	00009717          	auipc	a4,0x9
    8000082e:	7e673703          	ld	a4,2022(a4) # 8000a010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00012a17          	auipc	s4,0x12
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00009497          	auipc	s1,0x9
    80000858:	7b448493          	addi	s1,s1,1972 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00009997          	auipc	s3,0x9
    80000860:	7b498993          	addi	s3,s3,1972 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00001097          	auipc	ra,0x1
    80000882:	74a080e7          	jalr	1866(ra) # 80001fc8 <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00012517          	auipc	a0,0x12
    800008be:	98e50513          	addi	a0,a0,-1650 # 80012248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00009797          	auipc	a5,0x9
    800008ce:	7367a783          	lw	a5,1846(a5) # 8000a000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00009717          	auipc	a4,0x9
    800008da:	73a73703          	ld	a4,1850(a4) # 8000a010 <uart_tx_w>
    800008de:	00009797          	auipc	a5,0x9
    800008e2:	72a7b783          	ld	a5,1834(a5) # 8000a008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00012997          	auipc	s3,0x12
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80012248 <uart_tx_lock>
    800008f6:	00009497          	auipc	s1,0x9
    800008fa:	71248493          	addi	s1,s1,1810 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00009917          	auipc	s2,0x9
    80000902:	71290913          	addi	s2,s2,1810 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00001097          	auipc	ra,0x1
    8000090e:	65a080e7          	jalr	1626(ra) # 80001f64 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00012497          	auipc	s1,0x12
    80000924:	92848493          	addi	s1,s1,-1752 # 80012248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00009797          	auipc	a5,0x9
    80000938:	6ce7be23          	sd	a4,1756(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80012248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	0004a797          	auipc	a5,0x4a
    800009ee:	61678793          	addi	a5,a5,1558 # 8004b000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00012917          	auipc	s2,0x12
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80012280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00008517          	auipc	a0,0x8
    80000a40:	62450513          	addi	a0,a0,1572 # 80009060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00008597          	auipc	a1,0x8
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80009068 <digits+0x28>
    80000aa6:	00011517          	auipc	a0,0x11
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80012280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	0004a517          	auipc	a0,0x4a
    80000abe:	54650513          	addi	a0,a0,1350 # 8004b000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00011497          	auipc	s1,0x11
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80012280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	78c50513          	addi	a0,a0,1932 # 80012280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00011517          	auipc	a0,0x11
    80000b24:	76050513          	addi	a0,a0,1888 # 80012280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	00e080e7          	jalr	14(ra) # 80001b6a <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	fdc080e7          	jalr	-36(ra) # 80001b6a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	fd0080e7          	jalr	-48(ra) # 80001b6a <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	fb8080e7          	jalr	-72(ra) # 80001b6a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	f78080e7          	jalr	-136(ra) # 80001b6a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00008517          	auipc	a0,0x8
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80009070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	f4c080e7          	jalr	-180(ra) # 80001b6a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00008517          	auipc	a0,0x8
    80000c5a:	42250513          	addi	a0,a0,1058 # 80009078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00008517          	auipc	a0,0x8
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80009090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00008517          	auipc	a0,0x8
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80009098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	ce6080e7          	jalr	-794(ra) # 80001b5a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00009717          	auipc	a4,0x9
    80000e80:	19c70713          	addi	a4,a4,412 # 8000a018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	cca080e7          	jalr	-822(ra) # 80001b5a <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00008517          	auipc	a0,0x8
    80000e9e:	21e50513          	addi	a0,a0,542 # 800090b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	1c4080e7          	jalr	452(ra) # 80003076 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	ce6080e7          	jalr	-794(ra) # 80006ba0 <plicinithart>
  }
  scheduler();
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	eea080e7          	jalr	-278(ra) # 80001dac <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	5ce50513          	addi	a0,a0,1486 # 800094a8 <digits+0x468>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	5ae50513          	addi	a0,a0,1454 # 800094a8 <digits+0x468>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	b80080e7          	jalr	-1152(ra) # 80001aa2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	124080e7          	jalr	292(ra) # 8000304e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	144080e7          	jalr	324(ra) # 80003076 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	c50080e7          	jalr	-944(ra) # 80006b8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	c5e080e7          	jalr	-930(ra) # 80006ba0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	8ca080e7          	jalr	-1846(ra) # 80003814 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	f5c080e7          	jalr	-164(ra) # 80003eae <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	21c080e7          	jalr	540(ra) # 80005176 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	d60080e7          	jalr	-672(ra) # 80006cc2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	748080e7          	jalr	1864(ra) # 800026b2 <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00009717          	auipc	a4,0x9
    80000f7c:	0af72023          	sw	a5,160(a4) # 8000a018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00009797          	auipc	a5,0x9
    80000f8c:	0987b783          	ld	a5,152(a5) # 8000a020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00008517          	auipc	a0,0x8
    80000fd0:	10450513          	addi	a0,a0,260 # 800090d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00008517          	auipc	a0,0x8
    800010f4:	fe850513          	addi	a0,a0,-24 # 800090d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00008517          	auipc	a0,0x8
    80001140:	fa450513          	addi	a0,a0,-92 # 800090e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00008917          	auipc	s2,0x8
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80009000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80008697          	auipc	a3,0x80008
    800011c0:	e4468693          	addi	a3,a3,-444 # 9000 <_entry-0x7fff7000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00007617          	auipc	a2,0x7
    800011f4:	e1060613          	addi	a2,a2,-496 # 80008000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	7f4080e7          	jalr	2036(ra) # 80001a00 <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00009797          	auipc	a5,0x9
    80001236:	dea7b723          	sd	a0,-530(a5) # 8000a020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	711d                	addi	sp,sp,-96
    80001244:	ec86                	sd	ra,88(sp)
    80001246:	e8a2                	sd	s0,80(sp)
    80001248:	e4a6                	sd	s1,72(sp)
    8000124a:	e0ca                	sd	s2,64(sp)
    8000124c:	fc4e                	sd	s3,56(sp)
    8000124e:	f852                	sd	s4,48(sp)
    80001250:	f456                	sd	s5,40(sp)
    80001252:	f05a                	sd	s6,32(sp)
    80001254:	ec5e                	sd	s7,24(sp)
    80001256:	e862                	sd	s8,16(sp)
    80001258:	e466                	sd	s9,8(sp)
    8000125a:	e06a                	sd	s10,0(sp)
    8000125c:	1080                	addi	s0,sp,96
    8000125e:	8b2a                	mv	s6,a0
    80001260:	84ae                	mv	s1,a1
    80001262:	8932                	mv	s2,a2
    80001264:	8c36                	mv	s8,a3
  printf("hello from uvmunmap. npages: %d\n", npages);
    80001266:	85b2                	mv	a1,a2
    80001268:	00008517          	auipc	a0,0x8
    8000126c:	e8050513          	addi	a0,a0,-384 # 800090e8 <digits+0xa8>
    80001270:	fffff097          	auipc	ra,0xfffff
    80001274:	304080e7          	jalr	772(ra) # 80000574 <printf>
  if (myproc()->pid >2)
    80001278:	00001097          	auipc	ra,0x1
    8000127c:	90e080e7          	jalr	-1778(ra) # 80001b86 <myproc>
    80001280:	5918                	lw	a4,48(a0)
    80001282:	4789                	li	a5,2
    80001284:	02e7c063          	blt	a5,a4,800012a4 <uvmunmap+0x62>
    print_page_array(myproc(), myproc()->files_in_physicalmem);
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001288:	03449793          	slli	a5,s1,0x34
    8000128c:	ef8d                	bnez	a5,800012c6 <uvmunmap+0x84>
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    8000128e:	0932                	slli	s2,s2,0xc
    80001290:	00990bb3          	add	s7,s2,s1
    80001294:	1974f463          	bgeu	s1,s7,8000141c <uvmunmap+0x1da>
  {
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001298:	4a05                	li	s4,1
      // printf("kfree from uvmunmap\n");
      kfree((void*)pa);
    }
    #ifndef NONE
    struct proc *p = myproc();
    if((p->pid > 2) && (p->pagetable != pagetable))
    8000129a:	4c89                	li	s9,2
      for(int i = 0; i < MAX_TOTAL_PAGES - MAX_PSYC_PAGES + 1; i++){
        if(p->files_in_swap[i].va == a){
          // inswap = 1;
          p->files_in_swap[i].va = 0;
          p->files_in_swap[i].isAvailable = 1;
          p->num_of_pages--;
    8000129c:	6a85                	lui	s5,0x1
              }
              //else, head will be the next page
              else {
                p->index_of_head_p = p->files_in_physicalmem[i].index_of_next_p;
              }
              p->files_in_physicalmem[i].index_of_prev_p = -1;
    8000129e:	5d7d                	li	s10,-1
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    800012a0:	49c1                	li	s3,16
    800012a2:	a22d                	j	800013cc <uvmunmap+0x18a>
    print_page_array(myproc(), myproc()->files_in_physicalmem);
    800012a4:	00001097          	auipc	ra,0x1
    800012a8:	8e2080e7          	jalr	-1822(ra) # 80001b86 <myproc>
    800012ac:	89aa                	mv	s3,a0
    800012ae:	00001097          	auipc	ra,0x1
    800012b2:	8d8080e7          	jalr	-1832(ra) # 80001b86 <myproc>
    800012b6:	77050593          	addi	a1,a0,1904
    800012ba:	854e                	mv	a0,s3
    800012bc:	00002097          	auipc	ra,0x2
    800012c0:	82c080e7          	jalr	-2004(ra) # 80002ae8 <print_page_array>
    800012c4:	b7d1                	j	80001288 <uvmunmap+0x46>
    panic("uvmunmap: not aligned");
    800012c6:	00008517          	auipc	a0,0x8
    800012ca:	e4a50513          	addi	a0,a0,-438 # 80009110 <digits+0xd0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	25c080e7          	jalr	604(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800012d6:	00008517          	auipc	a0,0x8
    800012da:	e5250513          	addi	a0,a0,-430 # 80009128 <digits+0xe8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	24c080e7          	jalr	588(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00008517          	auipc	a0,0x8
    800012ea:	e5250513          	addi	a0,a0,-430 # 80009138 <digits+0xf8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	23c080e7          	jalr	572(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00008517          	auipc	a0,0x8
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80009150 <digits+0x110>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	22c080e7          	jalr	556(ra) # 8000052a <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6cc080e7          	jalr	1740(ra) # 800009d6 <kfree>
    80001312:	a0e5                	j	800013fa <uvmunmap+0x1b8>
          p->files_in_swap[i].va = 0;
    80001314:	0007b023          	sd	zero,0(a5)
          p->files_in_swap[i].isAvailable = 1;
    80001318:	ff47a423          	sw	s4,-24(a5)
          p->num_of_pages--;
    8000131c:	a7062703          	lw	a4,-1424(a2)
    80001320:	377d                	addiw	a4,a4,-1
    80001322:	a6e62823          	sw	a4,-1424(a2)
      for(int i = 0; i < MAX_TOTAL_PAGES - MAX_PSYC_PAGES + 1; i++){
    80001326:	03078793          	addi	a5,a5,48
    8000132a:	00d78663          	beq	a5,a3,80001336 <uvmunmap+0xf4>
        if(p->files_in_swap[i].va == a){
    8000132e:	6398                	ld	a4,0(a5)
    80001330:	fe971be3          	bne	a4,s1,80001326 <uvmunmap+0xe4>
    80001334:	b7c5                	j	80001314 <uvmunmap+0xd2>
    80001336:	015507b3          	add	a5,a0,s5
    8000133a:	a707a883          	lw	a7,-1424(a5)
    8000133e:	a747a803          	lw	a6,-1420(a5)
    80001342:	77050793          	addi	a5,a0,1904
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    80001346:	4701                	li	a4,0
            if(p->index_of_head_p == i){
    80001348:	01550333          	add	t1,a0,s5
    8000134c:	38fd                	addiw	a7,a7,-1
    8000134e:	387d                	addiw	a6,a6,-1
    80001350:	a005                	j	80001370 <uvmunmap+0x12e>
    80001352:	a8d32023          	sw	a3,-1408(t1)
              p->files_in_physicalmem[i].index_of_prev_p = -1;
    80001356:	03a5a423          	sw	s10,40(a1) # 4000028 <_entry-0x7bffffd8>
              p->files_in_physicalmem[i].index_of_next_p = -1;
    8000135a:	03a5a223          	sw	s10,36(a1)
            }
          #endif
        }
        p->num_of_pages--;
    8000135e:	40e8863b          	subw	a2,a7,a4
        p->num_of_pages_in_phys--;
    80001362:	40e806bb          	subw	a3,a6,a4
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    80001366:	2705                	addiw	a4,a4,1
    80001368:	03078793          	addi	a5,a5,48
    8000136c:	05370663          	beq	a4,s3,800013b8 <uvmunmap+0x176>
        if(p->files_in_physicalmem[i].va == a)
    80001370:	85be                	mv	a1,a5
    80001372:	6f94                	ld	a3,24(a5)
    80001374:	fe9695e3          	bne	a3,s1,8000135e <uvmunmap+0x11c>
          p->files_in_physicalmem[i].va = 0;
    80001378:	0007bc23          	sd	zero,24(a5)
          p->files_in_physicalmem[i].isAvailable = 1;
    8000137c:	0147a023          	sw	s4,0(a5)
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[i].index_of_prev_p;
    80001380:	53d0                	lw	a2,36(a5)
    80001382:	0287ae03          	lw	t3,40(a5)
    80001386:	00161693          	slli	a3,a2,0x1
    8000138a:	96b2                	add	a3,a3,a2
    8000138c:	0692                	slli	a3,a3,0x4
    8000138e:	96aa                	add	a3,a3,a0
    80001390:	79c6ac23          	sw	t3,1944(a3) # 1798 <_entry-0x7fffe868>
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[i].index_of_next_p;
    80001394:	0287ae03          	lw	t3,40(a5)
    80001398:	001e1693          	slli	a3,t3,0x1
    8000139c:	96f2                	add	a3,a3,t3
    8000139e:	0692                	slli	a3,a3,0x4
    800013a0:	96aa                	add	a3,a3,a0
    800013a2:	78c6aa23          	sw	a2,1940(a3)
            if(p->index_of_head_p == i){
    800013a6:	a8032683          	lw	a3,-1408(t1)
    800013aa:	fae69ae3          	bne	a3,a4,8000135e <uvmunmap+0x11c>
              if(p->index_of_head_p == p->files_in_physicalmem[i].index_of_next_p){
    800013ae:	53d4                	lw	a3,36(a5)
    800013b0:	fae691e3          	bne	a3,a4,80001352 <uvmunmap+0x110>
                p->index_of_head_p = -1;
    800013b4:	86ea                	mv	a3,s10
    800013b6:	bf71                	j	80001352 <uvmunmap+0x110>
    800013b8:	9556                	add	a0,a0,s5
    800013ba:	a6c52823          	sw	a2,-1424(a0)
    800013be:	a6d52a23          	sw	a3,-1420(a0)
      }
    }
    #endif
    *pte = 0;
    800013c2:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    800013c6:	94d6                	add	s1,s1,s5
    800013c8:	0574fa63          	bgeu	s1,s7,8000141c <uvmunmap+0x1da>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013cc:	4601                	li	a2,0
    800013ce:	85a6                	mv	a1,s1
    800013d0:	855a                	mv	a0,s6
    800013d2:	00000097          	auipc	ra,0x0
    800013d6:	bd4080e7          	jalr	-1068(ra) # 80000fa6 <walk>
    800013da:	892a                	mv	s2,a0
    800013dc:	ee050de3          	beqz	a0,800012d6 <uvmunmap+0x94>
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
    800013e0:	6108                	ld	a0,0(a0)
    800013e2:	20157793          	andi	a5,a0,513
    800013e6:	d381                	beqz	a5,800012e6 <uvmunmap+0xa4>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013e8:	3ff57793          	andi	a5,a0,1023
    800013ec:	f14785e3          	beq	a5,s4,800012f6 <uvmunmap+0xb4>
    if(do_free && (*pte & PTE_PG) == 0)
    800013f0:	000c0563          	beqz	s8,800013fa <uvmunmap+0x1b8>
    800013f4:	20057793          	andi	a5,a0,512
    800013f8:	d799                	beqz	a5,80001306 <uvmunmap+0xc4>
    struct proc *p = myproc();
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	78c080e7          	jalr	1932(ra) # 80001b86 <myproc>
    if((p->pid > 2) && (p->pagetable != pagetable))
    80001402:	591c                	lw	a5,48(a0)
    80001404:	fafcdfe3          	bge	s9,a5,800013c2 <uvmunmap+0x180>
    80001408:	693c                	ld	a5,80(a0)
    8000140a:	fb678ce3          	beq	a5,s6,800013c2 <uvmunmap+0x180>
    8000140e:	18850793          	addi	a5,a0,392
    80001412:	4b850693          	addi	a3,a0,1208
          p->num_of_pages--;
    80001416:	01550633          	add	a2,a0,s5
    8000141a:	bf11                	j	8000132e <uvmunmap+0xec>
  }
  printf("leaving uvmunmap\n");
    8000141c:	00008517          	auipc	a0,0x8
    80001420:	d4c50513          	addi	a0,a0,-692 # 80009168 <digits+0x128>
    80001424:	fffff097          	auipc	ra,0xfffff
    80001428:	150080e7          	jalr	336(ra) # 80000574 <printf>
  if(myproc()->pid >2)
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	75a080e7          	jalr	1882(ra) # 80001b86 <myproc>
    80001434:	5918                	lw	a4,48(a0)
    80001436:	4789                	li	a5,2
    80001438:	02e7c063          	blt	a5,a4,80001458 <uvmunmap+0x216>
    print_page_array(myproc(), myproc()->files_in_physicalmem);

}
    8000143c:	60e6                	ld	ra,88(sp)
    8000143e:	6446                	ld	s0,80(sp)
    80001440:	64a6                	ld	s1,72(sp)
    80001442:	6906                	ld	s2,64(sp)
    80001444:	79e2                	ld	s3,56(sp)
    80001446:	7a42                	ld	s4,48(sp)
    80001448:	7aa2                	ld	s5,40(sp)
    8000144a:	7b02                	ld	s6,32(sp)
    8000144c:	6be2                	ld	s7,24(sp)
    8000144e:	6c42                	ld	s8,16(sp)
    80001450:	6ca2                	ld	s9,8(sp)
    80001452:	6d02                	ld	s10,0(sp)
    80001454:	6125                	addi	sp,sp,96
    80001456:	8082                	ret
    print_page_array(myproc(), myproc()->files_in_physicalmem);
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	72e080e7          	jalr	1838(ra) # 80001b86 <myproc>
    80001460:	84aa                	mv	s1,a0
    80001462:	00000097          	auipc	ra,0x0
    80001466:	724080e7          	jalr	1828(ra) # 80001b86 <myproc>
    8000146a:	77050593          	addi	a1,a0,1904
    8000146e:	8526                	mv	a0,s1
    80001470:	00001097          	auipc	ra,0x1
    80001474:	678080e7          	jalr	1656(ra) # 80002ae8 <print_page_array>
}
    80001478:	b7d1                	j	8000143c <uvmunmap+0x1fa>

000000008000147a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000147a:	1101                	addi	sp,sp,-32
    8000147c:	ec06                	sd	ra,24(sp)
    8000147e:	e822                	sd	s0,16(sp)
    80001480:	e426                	sd	s1,8(sp)
    80001482:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001484:	fffff097          	auipc	ra,0xfffff
    80001488:	64e080e7          	jalr	1614(ra) # 80000ad2 <kalloc>
    8000148c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000148e:	c519                	beqz	a0,8000149c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001490:	6605                	lui	a2,0x1
    80001492:	4581                	li	a1,0
    80001494:	00000097          	auipc	ra,0x0
    80001498:	82a080e7          	jalr	-2006(ra) # 80000cbe <memset>
  return pagetable;
}
    8000149c:	8526                	mv	a0,s1
    8000149e:	60e2                	ld	ra,24(sp)
    800014a0:	6442                	ld	s0,16(sp)
    800014a2:	64a2                	ld	s1,8(sp)
    800014a4:	6105                	addi	sp,sp,32
    800014a6:	8082                	ret

00000000800014a8 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800014a8:	7179                	addi	sp,sp,-48
    800014aa:	f406                	sd	ra,40(sp)
    800014ac:	f022                	sd	s0,32(sp)
    800014ae:	ec26                	sd	s1,24(sp)
    800014b0:	e84a                	sd	s2,16(sp)
    800014b2:	e44e                	sd	s3,8(sp)
    800014b4:	e052                	sd	s4,0(sp)
    800014b6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014b8:	6785                	lui	a5,0x1
    800014ba:	04f67863          	bgeu	a2,a5,8000150a <uvminit+0x62>
    800014be:	8a2a                	mv	s4,a0
    800014c0:	89ae                	mv	s3,a1
    800014c2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	60e080e7          	jalr	1550(ra) # 80000ad2 <kalloc>
    800014cc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014ce:	6605                	lui	a2,0x1
    800014d0:	4581                	li	a1,0
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	7ec080e7          	jalr	2028(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014da:	4779                	li	a4,30
    800014dc:	86ca                	mv	a3,s2
    800014de:	6605                	lui	a2,0x1
    800014e0:	4581                	li	a1,0
    800014e2:	8552                	mv	a0,s4
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	baa080e7          	jalr	-1110(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    800014ec:	8626                	mv	a2,s1
    800014ee:	85ce                	mv	a1,s3
    800014f0:	854a                	mv	a0,s2
    800014f2:	00000097          	auipc	ra,0x0
    800014f6:	828080e7          	jalr	-2008(ra) # 80000d1a <memmove>
}
    800014fa:	70a2                	ld	ra,40(sp)
    800014fc:	7402                	ld	s0,32(sp)
    800014fe:	64e2                	ld	s1,24(sp)
    80001500:	6942                	ld	s2,16(sp)
    80001502:	69a2                	ld	s3,8(sp)
    80001504:	6a02                	ld	s4,0(sp)
    80001506:	6145                	addi	sp,sp,48
    80001508:	8082                	ret
    panic("inituvm: more than a page");
    8000150a:	00008517          	auipc	a0,0x8
    8000150e:	c7650513          	addi	a0,a0,-906 # 80009180 <digits+0x140>
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	018080e7          	jalr	24(ra) # 8000052a <panic>

000000008000151a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001524:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001526:	00b67d63          	bgeu	a2,a1,80001540 <uvmdealloc+0x26>
    8000152a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000152c:	6785                	lui	a5,0x1
    8000152e:	17fd                	addi	a5,a5,-1
    80001530:	00f60733          	add	a4,a2,a5
    80001534:	767d                	lui	a2,0xfffff
    80001536:	8f71                	and	a4,a4,a2
    80001538:	97ae                	add	a5,a5,a1
    8000153a:	8ff1                	and	a5,a5,a2
    8000153c:	00f76863          	bltu	a4,a5,8000154c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001540:	8526                	mv	a0,s1
    80001542:	60e2                	ld	ra,24(sp)
    80001544:	6442                	ld	s0,16(sp)
    80001546:	64a2                	ld	s1,8(sp)
    80001548:	6105                	addi	sp,sp,32
    8000154a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000154c:	8f99                	sub	a5,a5,a4
    8000154e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001550:	4685                	li	a3,1
    80001552:	0007861b          	sext.w	a2,a5
    80001556:	85ba                	mv	a1,a4
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	cea080e7          	jalr	-790(ra) # 80001242 <uvmunmap>
    80001560:	b7c5                	j	80001540 <uvmdealloc+0x26>

0000000080001562 <uvmalloc>:
  if(newsz < oldsz)
    80001562:	12b66163          	bltu	a2,a1,80001684 <uvmalloc+0x122>
{
    80001566:	711d                	addi	sp,sp,-96
    80001568:	ec86                	sd	ra,88(sp)
    8000156a:	e8a2                	sd	s0,80(sp)
    8000156c:	e4a6                	sd	s1,72(sp)
    8000156e:	e0ca                	sd	s2,64(sp)
    80001570:	fc4e                	sd	s3,56(sp)
    80001572:	f852                	sd	s4,48(sp)
    80001574:	f456                	sd	s5,40(sp)
    80001576:	f05a                	sd	s6,32(sp)
    80001578:	ec5e                	sd	s7,24(sp)
    8000157a:	e862                	sd	s8,16(sp)
    8000157c:	e466                	sd	s9,8(sp)
    8000157e:	e06a                	sd	s10,0(sp)
    80001580:	1080                	addi	s0,sp,96
    80001582:	8aaa                	mv	s5,a0
    80001584:	8bb2                	mv	s7,a2
  oldsz = PGROUNDUP(oldsz);
    80001586:	6b05                	lui	s6,0x1
    80001588:	1b7d                	addi	s6,s6,-1
    8000158a:	95da                	add	a1,a1,s6
    8000158c:	7b7d                	lui	s6,0xfffff
    8000158e:	0165fb33          	and	s6,a1,s6
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001592:	0ecb7b63          	bgeu	s6,a2,80001688 <uvmalloc+0x126>
    80001596:	8a5a                	mv	s4,s6
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    80001598:	6985                	lui	s3,0x1
    8000159a:	4c7d                	li	s8,31
    if (p->pid > 2) {
    8000159c:	4c89                	li	s9,2
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    8000159e:	4d3d                	li	s10,15
    800015a0:	a8b5                	j	8000161c <uvmalloc+0xba>
      printf("not enough free pages\n");
    800015a2:	00008517          	auipc	a0,0x8
    800015a6:	bfe50513          	addi	a0,a0,-1026 # 800091a0 <digits+0x160>
    800015aa:	fffff097          	auipc	ra,0xfffff
    800015ae:	fca080e7          	jalr	-54(ra) # 80000574 <printf>
      return 0;
    800015b2:	4501                	li	a0,0
}
    800015b4:	60e6                	ld	ra,88(sp)
    800015b6:	6446                	ld	s0,80(sp)
    800015b8:	64a6                	ld	s1,72(sp)
    800015ba:	6906                	ld	s2,64(sp)
    800015bc:	79e2                	ld	s3,56(sp)
    800015be:	7a42                	ld	s4,48(sp)
    800015c0:	7aa2                	ld	s5,40(sp)
    800015c2:	7b02                	ld	s6,32(sp)
    800015c4:	6be2                	ld	s7,24(sp)
    800015c6:	6c42                	ld	s8,16(sp)
    800015c8:	6ca2                	ld	s9,8(sp)
    800015ca:	6d02                	ld	s10,0(sp)
    800015cc:	6125                	addi	sp,sp,96
    800015ce:	8082                	ret
      uvmdealloc(pagetable, a, oldsz);
    800015d0:	865a                	mv	a2,s6
    800015d2:	85d2                	mv	a1,s4
    800015d4:	8556                	mv	a0,s5
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	f44080e7          	jalr	-188(ra) # 8000151a <uvmdealloc>
      return 0;
    800015de:	4501                	li	a0,0
    800015e0:	bfd1                	j	800015b4 <uvmalloc+0x52>
      kfree(mem);
    800015e2:	854a                	mv	a0,s2
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	3f2080e7          	jalr	1010(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015ec:	865a                	mv	a2,s6
    800015ee:	85d2                	mv	a1,s4
    800015f0:	8556                	mv	a0,s5
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	f28080e7          	jalr	-216(ra) # 8000151a <uvmdealloc>
      return 0;
    800015fa:	4501                	li	a0,0
    800015fc:	bf65                	j	800015b4 <uvmalloc+0x52>
        swap_to_swapFile(p);
    800015fe:	8526                	mv	a0,s1
    80001600:	00001097          	auipc	ra,0x1
    80001604:	6c0080e7          	jalr	1728(ra) # 80002cc0 <swap_to_swapFile>
        add_page_to_phys(p, pagetable, a);
    80001608:	8652                	mv	a2,s4
    8000160a:	85d6                	mv	a1,s5
    8000160c:	8526                	mv	a0,s1
    8000160e:	00001097          	auipc	ra,0x1
    80001612:	532080e7          	jalr	1330(ra) # 80002b40 <add_page_to_phys>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001616:	9a4e                	add	s4,s4,s3
    80001618:	077a7463          	bgeu	s4,s7,80001680 <uvmalloc+0x11e>
    struct proc* p = myproc();
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	56a080e7          	jalr	1386(ra) # 80001b86 <myproc>
    80001624:	84aa                	mv	s1,a0
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    80001626:	013507b3          	add	a5,a0,s3
    8000162a:	a707a783          	lw	a5,-1424(a5) # a70 <_entry-0x7ffff590>
    8000162e:	f6fc4ae3          	blt	s8,a5,800015a2 <uvmalloc+0x40>
    mem = kalloc();
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	4a0080e7          	jalr	1184(ra) # 80000ad2 <kalloc>
    8000163a:	892a                	mv	s2,a0
    if(mem == 0){
    8000163c:	d951                	beqz	a0,800015d0 <uvmalloc+0x6e>
    memset(mem, 0, PGSIZE);
    8000163e:	864e                	mv	a2,s3
    80001640:	4581                	li	a1,0
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	67c080e7          	jalr	1660(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000164a:	4779                	li	a4,30
    8000164c:	86ca                	mv	a3,s2
    8000164e:	864e                	mv	a2,s3
    80001650:	85d2                	mv	a1,s4
    80001652:	8556                	mv	a0,s5
    80001654:	00000097          	auipc	ra,0x0
    80001658:	a3a080e7          	jalr	-1478(ra) # 8000108e <mappages>
    8000165c:	f159                	bnez	a0,800015e2 <uvmalloc+0x80>
    if (p->pid > 2) {
    8000165e:	589c                	lw	a5,48(s1)
    80001660:	fafcdbe3          	bge	s9,a5,80001616 <uvmalloc+0xb4>
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80001664:	013487b3          	add	a5,s1,s3
    80001668:	a747a783          	lw	a5,-1420(a5)
    8000166c:	f8fd49e3          	blt	s10,a5,800015fe <uvmalloc+0x9c>
        add_page_to_phys(p, pagetable, a); //a= va
    80001670:	8652                	mv	a2,s4
    80001672:	85d6                	mv	a1,s5
    80001674:	8526                	mv	a0,s1
    80001676:	00001097          	auipc	ra,0x1
    8000167a:	4ca080e7          	jalr	1226(ra) # 80002b40 <add_page_to_phys>
    8000167e:	bf61                	j	80001616 <uvmalloc+0xb4>
  return newsz;
    80001680:	855e                	mv	a0,s7
    80001682:	bf0d                	j	800015b4 <uvmalloc+0x52>
    return oldsz;
    80001684:	852e                	mv	a0,a1
}
    80001686:	8082                	ret
  return newsz;
    80001688:	8532                	mv	a0,a2
    8000168a:	b72d                	j	800015b4 <uvmalloc+0x52>

000000008000168c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000168c:	7179                	addi	sp,sp,-48
    8000168e:	f406                	sd	ra,40(sp)
    80001690:	f022                	sd	s0,32(sp)
    80001692:	ec26                	sd	s1,24(sp)
    80001694:	e84a                	sd	s2,16(sp)
    80001696:	e44e                	sd	s3,8(sp)
    80001698:	e052                	sd	s4,0(sp)
    8000169a:	1800                	addi	s0,sp,48
    8000169c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000169e:	84aa                	mv	s1,a0
    800016a0:	6905                	lui	s2,0x1
    800016a2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016a4:	4985                	li	s3,1
    800016a6:	a821                	j	800016be <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016a8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800016aa:	0532                	slli	a0,a0,0xc
    800016ac:	00000097          	auipc	ra,0x0
    800016b0:	fe0080e7          	jalr	-32(ra) # 8000168c <freewalk>
      pagetable[i] = 0;
    800016b4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016b8:	04a1                	addi	s1,s1,8
    800016ba:	03248163          	beq	s1,s2,800016dc <freewalk+0x50>
    pte_t pte = pagetable[i];
    800016be:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016c0:	00f57793          	andi	a5,a0,15
    800016c4:	ff3782e3          	beq	a5,s3,800016a8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800016c8:	8905                	andi	a0,a0,1
    800016ca:	d57d                	beqz	a0,800016b8 <freewalk+0x2c>
      panic("freewalk: leaf");
    800016cc:	00008517          	auipc	a0,0x8
    800016d0:	aec50513          	addi	a0,a0,-1300 # 800091b8 <digits+0x178>
    800016d4:	fffff097          	auipc	ra,0xfffff
    800016d8:	e56080e7          	jalr	-426(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800016dc:	8552                	mv	a0,s4
    800016de:	fffff097          	auipc	ra,0xfffff
    800016e2:	2f8080e7          	jalr	760(ra) # 800009d6 <kfree>
}
    800016e6:	70a2                	ld	ra,40(sp)
    800016e8:	7402                	ld	s0,32(sp)
    800016ea:	64e2                	ld	s1,24(sp)
    800016ec:	6942                	ld	s2,16(sp)
    800016ee:	69a2                	ld	s3,8(sp)
    800016f0:	6a02                	ld	s4,0(sp)
    800016f2:	6145                	addi	sp,sp,48
    800016f4:	8082                	ret

00000000800016f6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016f6:	1101                	addi	sp,sp,-32
    800016f8:	ec06                	sd	ra,24(sp)
    800016fa:	e822                	sd	s0,16(sp)
    800016fc:	e426                	sd	s1,8(sp)
    800016fe:	1000                	addi	s0,sp,32
    80001700:	84aa                	mv	s1,a0
  if(sz > 0)
    80001702:	e999                	bnez	a1,80001718 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001704:	8526                	mv	a0,s1
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	f86080e7          	jalr	-122(ra) # 8000168c <freewalk>
}
    8000170e:	60e2                	ld	ra,24(sp)
    80001710:	6442                	ld	s0,16(sp)
    80001712:	64a2                	ld	s1,8(sp)
    80001714:	6105                	addi	sp,sp,32
    80001716:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001718:	6605                	lui	a2,0x1
    8000171a:	167d                	addi	a2,a2,-1
    8000171c:	962e                	add	a2,a2,a1
    8000171e:	4685                	li	a3,1
    80001720:	8231                	srli	a2,a2,0xc
    80001722:	4581                	li	a1,0
    80001724:	00000097          	auipc	ra,0x0
    80001728:	b1e080e7          	jalr	-1250(ra) # 80001242 <uvmunmap>
    8000172c:	bfe1                	j	80001704 <uvmfree+0xe>

000000008000172e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000172e:	c679                	beqz	a2,800017fc <uvmcopy+0xce>
{
    80001730:	715d                	addi	sp,sp,-80
    80001732:	e486                	sd	ra,72(sp)
    80001734:	e0a2                	sd	s0,64(sp)
    80001736:	fc26                	sd	s1,56(sp)
    80001738:	f84a                	sd	s2,48(sp)
    8000173a:	f44e                	sd	s3,40(sp)
    8000173c:	f052                	sd	s4,32(sp)
    8000173e:	ec56                	sd	s5,24(sp)
    80001740:	e85a                	sd	s6,16(sp)
    80001742:	e45e                	sd	s7,8(sp)
    80001744:	0880                	addi	s0,sp,80
    80001746:	8b2a                	mv	s6,a0
    80001748:	8aae                	mv	s5,a1
    8000174a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000174c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000174e:	4601                	li	a2,0
    80001750:	85ce                	mv	a1,s3
    80001752:	855a                	mv	a0,s6
    80001754:	00000097          	auipc	ra,0x0
    80001758:	852080e7          	jalr	-1966(ra) # 80000fa6 <walk>
    8000175c:	c531                	beqz	a0,800017a8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000175e:	6118                	ld	a4,0(a0)
    80001760:	00177793          	andi	a5,a4,1
    80001764:	cbb1                	beqz	a5,800017b8 <uvmcopy+0x8a>
    //   *new_pte |= PTE_PG;
    //   *new_pte &= ~PTE_V;
    //   continue;
    // }

    pa = PTE2PA(*pte);
    80001766:	00a75593          	srli	a1,a4,0xa
    8000176a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000176e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001772:	fffff097          	auipc	ra,0xfffff
    80001776:	360080e7          	jalr	864(ra) # 80000ad2 <kalloc>
    8000177a:	892a                	mv	s2,a0
    8000177c:	c939                	beqz	a0,800017d2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000177e:	6605                	lui	a2,0x1
    80001780:	85de                	mv	a1,s7
    80001782:	fffff097          	auipc	ra,0xfffff
    80001786:	598080e7          	jalr	1432(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000178a:	8726                	mv	a4,s1
    8000178c:	86ca                	mv	a3,s2
    8000178e:	6605                	lui	a2,0x1
    80001790:	85ce                	mv	a1,s3
    80001792:	8556                	mv	a0,s5
    80001794:	00000097          	auipc	ra,0x0
    80001798:	8fa080e7          	jalr	-1798(ra) # 8000108e <mappages>
    8000179c:	e515                	bnez	a0,800017c8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000179e:	6785                	lui	a5,0x1
    800017a0:	99be                	add	s3,s3,a5
    800017a2:	fb49e6e3          	bltu	s3,s4,8000174e <uvmcopy+0x20>
    800017a6:	a081                	j	800017e6 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800017a8:	00008517          	auipc	a0,0x8
    800017ac:	a2050513          	addi	a0,a0,-1504 # 800091c8 <digits+0x188>
    800017b0:	fffff097          	auipc	ra,0xfffff
    800017b4:	d7a080e7          	jalr	-646(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800017b8:	00008517          	auipc	a0,0x8
    800017bc:	a3050513          	addi	a0,a0,-1488 # 800091e8 <digits+0x1a8>
    800017c0:	fffff097          	auipc	ra,0xfffff
    800017c4:	d6a080e7          	jalr	-662(ra) # 8000052a <panic>
      kfree(mem);
    800017c8:	854a                	mv	a0,s2
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	20c080e7          	jalr	524(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017d2:	4685                	li	a3,1
    800017d4:	00c9d613          	srli	a2,s3,0xc
    800017d8:	4581                	li	a1,0
    800017da:	8556                	mv	a0,s5
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	a66080e7          	jalr	-1434(ra) # 80001242 <uvmunmap>
  return -1;
    800017e4:	557d                	li	a0,-1
}
    800017e6:	60a6                	ld	ra,72(sp)
    800017e8:	6406                	ld	s0,64(sp)
    800017ea:	74e2                	ld	s1,56(sp)
    800017ec:	7942                	ld	s2,48(sp)
    800017ee:	79a2                	ld	s3,40(sp)
    800017f0:	7a02                	ld	s4,32(sp)
    800017f2:	6ae2                	ld	s5,24(sp)
    800017f4:	6b42                	ld	s6,16(sp)
    800017f6:	6ba2                	ld	s7,8(sp)
    800017f8:	6161                	addi	sp,sp,80
    800017fa:	8082                	ret
  return 0;
    800017fc:	4501                	li	a0,0
}
    800017fe:	8082                	ret

0000000080001800 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001800:	1141                	addi	sp,sp,-16
    80001802:	e406                	sd	ra,8(sp)
    80001804:	e022                	sd	s0,0(sp)
    80001806:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    80001808:	4601                	li	a2,0
    8000180a:	fffff097          	auipc	ra,0xfffff
    8000180e:	79c080e7          	jalr	1948(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001812:	c901                	beqz	a0,80001822 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001814:	611c                	ld	a5,0(a0)
    80001816:	9bbd                	andi	a5,a5,-17
    80001818:	e11c                	sd	a5,0(a0)
}
    8000181a:	60a2                	ld	ra,8(sp)
    8000181c:	6402                	ld	s0,0(sp)
    8000181e:	0141                	addi	sp,sp,16
    80001820:	8082                	ret
    panic("uvmclear");
    80001822:	00008517          	auipc	a0,0x8
    80001826:	9e650513          	addi	a0,a0,-1562 # 80009208 <digits+0x1c8>
    8000182a:	fffff097          	auipc	ra,0xfffff
    8000182e:	d00080e7          	jalr	-768(ra) # 8000052a <panic>

0000000080001832 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001832:	c6bd                	beqz	a3,800018a0 <copyout+0x6e>
{
    80001834:	715d                	addi	sp,sp,-80
    80001836:	e486                	sd	ra,72(sp)
    80001838:	e0a2                	sd	s0,64(sp)
    8000183a:	fc26                	sd	s1,56(sp)
    8000183c:	f84a                	sd	s2,48(sp)
    8000183e:	f44e                	sd	s3,40(sp)
    80001840:	f052                	sd	s4,32(sp)
    80001842:	ec56                	sd	s5,24(sp)
    80001844:	e85a                	sd	s6,16(sp)
    80001846:	e45e                	sd	s7,8(sp)
    80001848:	e062                	sd	s8,0(sp)
    8000184a:	0880                	addi	s0,sp,80
    8000184c:	8b2a                	mv	s6,a0
    8000184e:	8c2e                	mv	s8,a1
    80001850:	8a32                	mv	s4,a2
    80001852:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001854:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001856:	6a85                	lui	s5,0x1
    80001858:	a015                	j	8000187c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000185a:	9562                	add	a0,a0,s8
    8000185c:	0004861b          	sext.w	a2,s1
    80001860:	85d2                	mv	a1,s4
    80001862:	41250533          	sub	a0,a0,s2
    80001866:	fffff097          	auipc	ra,0xfffff
    8000186a:	4b4080e7          	jalr	1204(ra) # 80000d1a <memmove>

    len -= n;
    8000186e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001872:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001874:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001878:	02098263          	beqz	s3,8000189c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000187c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001880:	85ca                	mv	a1,s2
    80001882:	855a                	mv	a0,s6
    80001884:	fffff097          	auipc	ra,0xfffff
    80001888:	7c8080e7          	jalr	1992(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    8000188c:	cd01                	beqz	a0,800018a4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000188e:	418904b3          	sub	s1,s2,s8
    80001892:	94d6                	add	s1,s1,s5
    if(n > len)
    80001894:	fc99f3e3          	bgeu	s3,s1,8000185a <copyout+0x28>
    80001898:	84ce                	mv	s1,s3
    8000189a:	b7c1                	j	8000185a <copyout+0x28>
  }
  return 0;
    8000189c:	4501                	li	a0,0
    8000189e:	a021                	j	800018a6 <copyout+0x74>
    800018a0:	4501                	li	a0,0
}
    800018a2:	8082                	ret
      return -1;
    800018a4:	557d                	li	a0,-1
}
    800018a6:	60a6                	ld	ra,72(sp)
    800018a8:	6406                	ld	s0,64(sp)
    800018aa:	74e2                	ld	s1,56(sp)
    800018ac:	7942                	ld	s2,48(sp)
    800018ae:	79a2                	ld	s3,40(sp)
    800018b0:	7a02                	ld	s4,32(sp)
    800018b2:	6ae2                	ld	s5,24(sp)
    800018b4:	6b42                	ld	s6,16(sp)
    800018b6:	6ba2                	ld	s7,8(sp)
    800018b8:	6c02                	ld	s8,0(sp)
    800018ba:	6161                	addi	sp,sp,80
    800018bc:	8082                	ret

00000000800018be <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018be:	caa5                	beqz	a3,8000192e <copyin+0x70>
{
    800018c0:	715d                	addi	sp,sp,-80
    800018c2:	e486                	sd	ra,72(sp)
    800018c4:	e0a2                	sd	s0,64(sp)
    800018c6:	fc26                	sd	s1,56(sp)
    800018c8:	f84a                	sd	s2,48(sp)
    800018ca:	f44e                	sd	s3,40(sp)
    800018cc:	f052                	sd	s4,32(sp)
    800018ce:	ec56                	sd	s5,24(sp)
    800018d0:	e85a                	sd	s6,16(sp)
    800018d2:	e45e                	sd	s7,8(sp)
    800018d4:	e062                	sd	s8,0(sp)
    800018d6:	0880                	addi	s0,sp,80
    800018d8:	8b2a                	mv	s6,a0
    800018da:	8a2e                	mv	s4,a1
    800018dc:	8c32                	mv	s8,a2
    800018de:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018e0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018e2:	6a85                	lui	s5,0x1
    800018e4:	a01d                	j	8000190a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018e6:	018505b3          	add	a1,a0,s8
    800018ea:	0004861b          	sext.w	a2,s1
    800018ee:	412585b3          	sub	a1,a1,s2
    800018f2:	8552                	mv	a0,s4
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	426080e7          	jalr	1062(ra) # 80000d1a <memmove>

    len -= n;
    800018fc:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001900:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001902:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001906:	02098263          	beqz	s3,8000192a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000190a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000190e:	85ca                	mv	a1,s2
    80001910:	855a                	mv	a0,s6
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	73a080e7          	jalr	1850(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    8000191a:	cd01                	beqz	a0,80001932 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000191c:	418904b3          	sub	s1,s2,s8
    80001920:	94d6                	add	s1,s1,s5
    if(n > len)
    80001922:	fc99f2e3          	bgeu	s3,s1,800018e6 <copyin+0x28>
    80001926:	84ce                	mv	s1,s3
    80001928:	bf7d                	j	800018e6 <copyin+0x28>
  }
  return 0;
    8000192a:	4501                	li	a0,0
    8000192c:	a021                	j	80001934 <copyin+0x76>
    8000192e:	4501                	li	a0,0
}
    80001930:	8082                	ret
      return -1;
    80001932:	557d                	li	a0,-1
}
    80001934:	60a6                	ld	ra,72(sp)
    80001936:	6406                	ld	s0,64(sp)
    80001938:	74e2                	ld	s1,56(sp)
    8000193a:	7942                	ld	s2,48(sp)
    8000193c:	79a2                	ld	s3,40(sp)
    8000193e:	7a02                	ld	s4,32(sp)
    80001940:	6ae2                	ld	s5,24(sp)
    80001942:	6b42                	ld	s6,16(sp)
    80001944:	6ba2                	ld	s7,8(sp)
    80001946:	6c02                	ld	s8,0(sp)
    80001948:	6161                	addi	sp,sp,80
    8000194a:	8082                	ret

000000008000194c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000194c:	c6c5                	beqz	a3,800019f4 <copyinstr+0xa8>
{
    8000194e:	715d                	addi	sp,sp,-80
    80001950:	e486                	sd	ra,72(sp)
    80001952:	e0a2                	sd	s0,64(sp)
    80001954:	fc26                	sd	s1,56(sp)
    80001956:	f84a                	sd	s2,48(sp)
    80001958:	f44e                	sd	s3,40(sp)
    8000195a:	f052                	sd	s4,32(sp)
    8000195c:	ec56                	sd	s5,24(sp)
    8000195e:	e85a                	sd	s6,16(sp)
    80001960:	e45e                	sd	s7,8(sp)
    80001962:	0880                	addi	s0,sp,80
    80001964:	8a2a                	mv	s4,a0
    80001966:	8b2e                	mv	s6,a1
    80001968:	8bb2                	mv	s7,a2
    8000196a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000196c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000196e:	6985                	lui	s3,0x1
    80001970:	a035                	j	8000199c <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001972:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001976:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001978:	0017b793          	seqz	a5,a5
    8000197c:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001980:	60a6                	ld	ra,72(sp)
    80001982:	6406                	ld	s0,64(sp)
    80001984:	74e2                	ld	s1,56(sp)
    80001986:	7942                	ld	s2,48(sp)
    80001988:	79a2                	ld	s3,40(sp)
    8000198a:	7a02                	ld	s4,32(sp)
    8000198c:	6ae2                	ld	s5,24(sp)
    8000198e:	6b42                	ld	s6,16(sp)
    80001990:	6ba2                	ld	s7,8(sp)
    80001992:	6161                	addi	sp,sp,80
    80001994:	8082                	ret
    srcva = va0 + PGSIZE;
    80001996:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000199a:	c8a9                	beqz	s1,800019ec <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000199c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019a0:	85ca                	mv	a1,s2
    800019a2:	8552                	mv	a0,s4
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	6a8080e7          	jalr	1704(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800019ac:	c131                	beqz	a0,800019f0 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800019ae:	41790833          	sub	a6,s2,s7
    800019b2:	984e                	add	a6,a6,s3
    if(n > max)
    800019b4:	0104f363          	bgeu	s1,a6,800019ba <copyinstr+0x6e>
    800019b8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019ba:	955e                	add	a0,a0,s7
    800019bc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019c0:	fc080be3          	beqz	a6,80001996 <copyinstr+0x4a>
    800019c4:	985a                	add	a6,a6,s6
    800019c6:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019c8:	41650633          	sub	a2,a0,s6
    800019cc:	14fd                	addi	s1,s1,-1
    800019ce:	9b26                	add	s6,s6,s1
    800019d0:	00f60733          	add	a4,a2,a5
    800019d4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb4000>
    800019d8:	df49                	beqz	a4,80001972 <copyinstr+0x26>
        *dst = *p;
    800019da:	00e78023          	sb	a4,0(a5)
      --max;
    800019de:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019e2:	0785                	addi	a5,a5,1
    while(n > 0){
    800019e4:	ff0796e3          	bne	a5,a6,800019d0 <copyinstr+0x84>
      dst++;
    800019e8:	8b42                	mv	s6,a6
    800019ea:	b775                	j	80001996 <copyinstr+0x4a>
    800019ec:	4781                	li	a5,0
    800019ee:	b769                	j	80001978 <copyinstr+0x2c>
      return -1;
    800019f0:	557d                	li	a0,-1
    800019f2:	b779                	j	80001980 <copyinstr+0x34>
  int got_null = 0;
    800019f4:	4781                	li	a5,0
  if(got_null){
    800019f6:	0017b793          	seqz	a5,a5
    800019fa:	40f00533          	neg	a0,a5
}
    800019fe:	8082                	ret

0000000080001a00 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001a00:	715d                	addi	sp,sp,-80
    80001a02:	e486                	sd	ra,72(sp)
    80001a04:	e0a2                	sd	s0,64(sp)
    80001a06:	fc26                	sd	s1,56(sp)
    80001a08:	f84a                	sd	s2,48(sp)
    80001a0a:	f44e                	sd	s3,40(sp)
    80001a0c:	f052                	sd	s4,32(sp)
    80001a0e:	ec56                	sd	s5,24(sp)
    80001a10:	e85a                	sd	s6,16(sp)
    80001a12:	e45e                	sd	s7,8(sp)
    80001a14:	e062                	sd	s8,0(sp)
    80001a16:	0880                	addi	s0,sp,80
    80001a18:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001a1a:	00011497          	auipc	s1,0x11
    80001a1e:	cb648493          	addi	s1,s1,-842 # 800126d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a22:	8c26                	mv	s8,s1
    80001a24:	00007b97          	auipc	s7,0x7
    80001a28:	5dcb8b93          	addi	s7,s7,1500 # 80009000 <etext>
    80001a2c:	04000937          	lui	s2,0x4000
    80001a30:	197d                	addi	s2,s2,-1
    80001a32:	0932                	slli	s2,s2,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a34:	6a05                	lui	s4,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a36:	a88a0b13          	addi	s6,s4,-1400 # a88 <_entry-0x7ffff578>
    80001a3a:	0003ba97          	auipc	s5,0x3b
    80001a3e:	e96a8a93          	addi	s5,s5,-362 # 8003c8d0 <tickslock>
    char *pa = kalloc();
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	090080e7          	jalr	144(ra) # 80000ad2 <kalloc>
    80001a4a:	862a                	mv	a2,a0
    if(pa == 0)
    80001a4c:	c139                	beqz	a0,80001a92 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    80001a4e:	418485b3          	sub	a1,s1,s8
    80001a52:	858d                	srai	a1,a1,0x3
    80001a54:	000bb783          	ld	a5,0(s7)
    80001a58:	02f585b3          	mul	a1,a1,a5
    80001a5c:	2585                	addiw	a1,a1,1
    80001a5e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a62:	4719                	li	a4,6
    80001a64:	86d2                	mv	a3,s4
    80001a66:	40b905b3          	sub	a1,s2,a1
    80001a6a:	854e                	mv	a0,s3
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	6b0080e7          	jalr	1712(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a74:	94da                	add	s1,s1,s6
    80001a76:	fd5496e3          	bne	s1,s5,80001a42 <proc_mapstacks+0x42>
  }
}
    80001a7a:	60a6                	ld	ra,72(sp)
    80001a7c:	6406                	ld	s0,64(sp)
    80001a7e:	74e2                	ld	s1,56(sp)
    80001a80:	7942                	ld	s2,48(sp)
    80001a82:	79a2                	ld	s3,40(sp)
    80001a84:	7a02                	ld	s4,32(sp)
    80001a86:	6ae2                	ld	s5,24(sp)
    80001a88:	6b42                	ld	s6,16(sp)
    80001a8a:	6ba2                	ld	s7,8(sp)
    80001a8c:	6c02                	ld	s8,0(sp)
    80001a8e:	6161                	addi	sp,sp,80
    80001a90:	8082                	ret
      panic("kalloc");
    80001a92:	00007517          	auipc	a0,0x7
    80001a96:	78650513          	addi	a0,a0,1926 # 80009218 <digits+0x1d8>
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	a90080e7          	jalr	-1392(ra) # 8000052a <panic>

0000000080001aa2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001aa2:	715d                	addi	sp,sp,-80
    80001aa4:	e486                	sd	ra,72(sp)
    80001aa6:	e0a2                	sd	s0,64(sp)
    80001aa8:	fc26                	sd	s1,56(sp)
    80001aaa:	f84a                	sd	s2,48(sp)
    80001aac:	f44e                	sd	s3,40(sp)
    80001aae:	f052                	sd	s4,32(sp)
    80001ab0:	ec56                	sd	s5,24(sp)
    80001ab2:	e85a                	sd	s6,16(sp)
    80001ab4:	e45e                	sd	s7,8(sp)
    80001ab6:	0880                	addi	s0,sp,80
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001ab8:	00007597          	auipc	a1,0x7
    80001abc:	76858593          	addi	a1,a1,1896 # 80009220 <digits+0x1e0>
    80001ac0:	00010517          	auipc	a0,0x10
    80001ac4:	7e050513          	addi	a0,a0,2016 # 800122a0 <pid_lock>
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	06a080e7          	jalr	106(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001ad0:	00007597          	auipc	a1,0x7
    80001ad4:	75858593          	addi	a1,a1,1880 # 80009228 <digits+0x1e8>
    80001ad8:	00010517          	auipc	a0,0x10
    80001adc:	7e050513          	addi	a0,a0,2016 # 800122b8 <wait_lock>
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	052080e7          	jalr	82(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae8:	00011497          	auipc	s1,0x11
    80001aec:	be848493          	addi	s1,s1,-1048 # 800126d0 <proc>
      initlock(&p->lock, "proc");
    80001af0:	00007b97          	auipc	s7,0x7
    80001af4:	748b8b93          	addi	s7,s7,1864 # 80009238 <digits+0x1f8>
      p->kstack = KSTACK((int) (p - proc));
    80001af8:	8b26                	mv	s6,s1
    80001afa:	00007a97          	auipc	s5,0x7
    80001afe:	506a8a93          	addi	s5,s5,1286 # 80009000 <etext>
    80001b02:	04000937          	lui	s2,0x4000
    80001b06:	197d                	addi	s2,s2,-1
    80001b08:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b0a:	6985                	lui	s3,0x1
    80001b0c:	a8898993          	addi	s3,s3,-1400 # a88 <_entry-0x7ffff578>
    80001b10:	0003ba17          	auipc	s4,0x3b
    80001b14:	dc0a0a13          	addi	s4,s4,-576 # 8003c8d0 <tickslock>
      initlock(&p->lock, "proc");
    80001b18:	85de                	mv	a1,s7
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	016080e7          	jalr	22(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001b24:	416487b3          	sub	a5,s1,s6
    80001b28:	878d                	srai	a5,a5,0x3
    80001b2a:	000ab703          	ld	a4,0(s5)
    80001b2e:	02e787b3          	mul	a5,a5,a4
    80001b32:	2785                	addiw	a5,a5,1
    80001b34:	00d7979b          	slliw	a5,a5,0xd
    80001b38:	40f907b3          	sub	a5,s2,a5
    80001b3c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b3e:	94ce                	add	s1,s1,s3
    80001b40:	fd449ce3          	bne	s1,s4,80001b18 <procinit+0x76>
  }
}
    80001b44:	60a6                	ld	ra,72(sp)
    80001b46:	6406                	ld	s0,64(sp)
    80001b48:	74e2                	ld	s1,56(sp)
    80001b4a:	7942                	ld	s2,48(sp)
    80001b4c:	79a2                	ld	s3,40(sp)
    80001b4e:	7a02                	ld	s4,32(sp)
    80001b50:	6ae2                	ld	s5,24(sp)
    80001b52:	6b42                	ld	s6,16(sp)
    80001b54:	6ba2                	ld	s7,8(sp)
    80001b56:	6161                	addi	sp,sp,80
    80001b58:	8082                	ret

0000000080001b5a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b5a:	1141                	addi	sp,sp,-16
    80001b5c:	e422                	sd	s0,8(sp)
    80001b5e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b60:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b62:	2501                	sext.w	a0,a0
    80001b64:	6422                	ld	s0,8(sp)
    80001b66:	0141                	addi	sp,sp,16
    80001b68:	8082                	ret

0000000080001b6a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001b6a:	1141                	addi	sp,sp,-16
    80001b6c:	e422                	sd	s0,8(sp)
    80001b6e:	0800                	addi	s0,sp,16
    80001b70:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b72:	2781                	sext.w	a5,a5
    80001b74:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b76:	00010517          	auipc	a0,0x10
    80001b7a:	75a50513          	addi	a0,a0,1882 # 800122d0 <cpus>
    80001b7e:	953e                	add	a0,a0,a5
    80001b80:	6422                	ld	s0,8(sp)
    80001b82:	0141                	addi	sp,sp,16
    80001b84:	8082                	ret

0000000080001b86 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001b86:	1101                	addi	sp,sp,-32
    80001b88:	ec06                	sd	ra,24(sp)
    80001b8a:	e822                	sd	s0,16(sp)
    80001b8c:	e426                	sd	s1,8(sp)
    80001b8e:	1000                	addi	s0,sp,32
  push_off();
    80001b90:	fffff097          	auipc	ra,0xfffff
    80001b94:	fe6080e7          	jalr	-26(ra) # 80000b76 <push_off>
    80001b98:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b9a:	2781                	sext.w	a5,a5
    80001b9c:	079e                	slli	a5,a5,0x7
    80001b9e:	00010717          	auipc	a4,0x10
    80001ba2:	70270713          	addi	a4,a4,1794 # 800122a0 <pid_lock>
    80001ba6:	97ba                	add	a5,a5,a4
    80001ba8:	7b84                	ld	s1,48(a5)
  pop_off();
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	06c080e7          	jalr	108(ra) # 80000c16 <pop_off>
  return p;
}
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	60e2                	ld	ra,24(sp)
    80001bb6:	6442                	ld	s0,16(sp)
    80001bb8:	64a2                	ld	s1,8(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001bbe:	1141                	addi	sp,sp,-16
    80001bc0:	e406                	sd	ra,8(sp)
    80001bc2:	e022                	sd	s0,0(sp)
    80001bc4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	fc0080e7          	jalr	-64(ra) # 80001b86 <myproc>
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	0a8080e7          	jalr	168(ra) # 80000c76 <release>

  if (first) {
    80001bd6:	00008797          	auipc	a5,0x8
    80001bda:	f4a7a783          	lw	a5,-182(a5) # 80009b20 <first.1>
    80001bde:	eb89                	bnez	a5,80001bf0 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001be0:	00001097          	auipc	ra,0x1
    80001be4:	4ae080e7          	jalr	1198(ra) # 8000308e <usertrapret>
}
    80001be8:	60a2                	ld	ra,8(sp)
    80001bea:	6402                	ld	s0,0(sp)
    80001bec:	0141                	addi	sp,sp,16
    80001bee:	8082                	ret
    first = 0;
    80001bf0:	00008797          	auipc	a5,0x8
    80001bf4:	f207a823          	sw	zero,-208(a5) # 80009b20 <first.1>
    fsinit(ROOTDEV);
    80001bf8:	4505                	li	a0,1
    80001bfa:	00002097          	auipc	ra,0x2
    80001bfe:	234080e7          	jalr	564(ra) # 80003e2e <fsinit>
    80001c02:	bff9                	j	80001be0 <forkret+0x22>

0000000080001c04 <allocpid>:
allocpid() {
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	e04a                	sd	s2,0(sp)
    80001c0e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c10:	00010917          	auipc	s2,0x10
    80001c14:	69090913          	addi	s2,s2,1680 # 800122a0 <pid_lock>
    80001c18:	854a                	mv	a0,s2
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	fa8080e7          	jalr	-88(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001c22:	00008797          	auipc	a5,0x8
    80001c26:	f0278793          	addi	a5,a5,-254 # 80009b24 <nextpid>
    80001c2a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c2c:	0014871b          	addiw	a4,s1,1
    80001c30:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c32:	854a                	mv	a0,s2
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	042080e7          	jalr	66(ra) # 80000c76 <release>
}
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6902                	ld	s2,0(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret

0000000080001c4a <proc_pagetable>:
{
    80001c4a:	1101                	addi	sp,sp,-32
    80001c4c:	ec06                	sd	ra,24(sp)
    80001c4e:	e822                	sd	s0,16(sp)
    80001c50:	e426                	sd	s1,8(sp)
    80001c52:	e04a                	sd	s2,0(sp)
    80001c54:	1000                	addi	s0,sp,32
    80001c56:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	822080e7          	jalr	-2014(ra) # 8000147a <uvmcreate>
    80001c60:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c62:	c121                	beqz	a0,80001ca2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c64:	4729                	li	a4,10
    80001c66:	00006697          	auipc	a3,0x6
    80001c6a:	39a68693          	addi	a3,a3,922 # 80008000 <_trampoline>
    80001c6e:	6605                	lui	a2,0x1
    80001c70:	040005b7          	lui	a1,0x4000
    80001c74:	15fd                	addi	a1,a1,-1
    80001c76:	05b2                	slli	a1,a1,0xc
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	416080e7          	jalr	1046(ra) # 8000108e <mappages>
    80001c80:	02054863          	bltz	a0,80001cb0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c84:	4719                	li	a4,6
    80001c86:	05893683          	ld	a3,88(s2)
    80001c8a:	6605                	lui	a2,0x1
    80001c8c:	020005b7          	lui	a1,0x2000
    80001c90:	15fd                	addi	a1,a1,-1
    80001c92:	05b6                	slli	a1,a1,0xd
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	3f8080e7          	jalr	1016(ra) # 8000108e <mappages>
    80001c9e:	02054163          	bltz	a0,80001cc0 <proc_pagetable+0x76>
}
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	60e2                	ld	ra,24(sp)
    80001ca6:	6442                	ld	s0,16(sp)
    80001ca8:	64a2                	ld	s1,8(sp)
    80001caa:	6902                	ld	s2,0(sp)
    80001cac:	6105                	addi	sp,sp,32
    80001cae:	8082                	ret
    uvmfree(pagetable, 0);
    80001cb0:	4581                	li	a1,0
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	a42080e7          	jalr	-1470(ra) # 800016f6 <uvmfree>
    return 0;
    80001cbc:	4481                	li	s1,0
    80001cbe:	b7d5                	j	80001ca2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cc0:	4681                	li	a3,0
    80001cc2:	4605                	li	a2,1
    80001cc4:	040005b7          	lui	a1,0x4000
    80001cc8:	15fd                	addi	a1,a1,-1
    80001cca:	05b2                	slli	a1,a1,0xc
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	574080e7          	jalr	1396(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cd6:	4581                	li	a1,0
    80001cd8:	8526                	mv	a0,s1
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	a1c080e7          	jalr	-1508(ra) # 800016f6 <uvmfree>
    return 0;
    80001ce2:	4481                	li	s1,0
    80001ce4:	bf7d                	j	80001ca2 <proc_pagetable+0x58>

0000000080001ce6 <proc_freepagetable>:
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	e04a                	sd	s2,0(sp)
    80001cf0:	1000                	addi	s0,sp,32
    80001cf2:	84aa                	mv	s1,a0
    80001cf4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cf6:	4681                	li	a3,0
    80001cf8:	4605                	li	a2,1
    80001cfa:	040005b7          	lui	a1,0x4000
    80001cfe:	15fd                	addi	a1,a1,-1
    80001d00:	05b2                	slli	a1,a1,0xc
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	540080e7          	jalr	1344(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d0a:	4681                	li	a3,0
    80001d0c:	4605                	li	a2,1
    80001d0e:	020005b7          	lui	a1,0x2000
    80001d12:	15fd                	addi	a1,a1,-1
    80001d14:	05b6                	slli	a1,a1,0xd
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	52a080e7          	jalr	1322(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d20:	85ca                	mv	a1,s2
    80001d22:	8526                	mv	a0,s1
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	9d2080e7          	jalr	-1582(ra) # 800016f6 <uvmfree>
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret

0000000080001d38 <growproc>:
{
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
    80001d44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d46:	00000097          	auipc	ra,0x0
    80001d4a:	e40080e7          	jalr	-448(ra) # 80001b86 <myproc>
    80001d4e:	892a                	mv	s2,a0
  sz = p->sz;
    80001d50:	652c                	ld	a1,72(a0)
    80001d52:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d56:	00904f63          	bgtz	s1,80001d74 <growproc+0x3c>
  } else if(n < 0){
    80001d5a:	0204cc63          	bltz	s1,80001d92 <growproc+0x5a>
  p->sz = sz;
    80001d5e:	1602                	slli	a2,a2,0x20
    80001d60:	9201                	srli	a2,a2,0x20
    80001d62:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d66:	4501                	li	a0,0
}
    80001d68:	60e2                	ld	ra,24(sp)
    80001d6a:	6442                	ld	s0,16(sp)
    80001d6c:	64a2                	ld	s1,8(sp)
    80001d6e:	6902                	ld	s2,0(sp)
    80001d70:	6105                	addi	sp,sp,32
    80001d72:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d74:	9e25                	addw	a2,a2,s1
    80001d76:	1602                	slli	a2,a2,0x20
    80001d78:	9201                	srli	a2,a2,0x20
    80001d7a:	1582                	slli	a1,a1,0x20
    80001d7c:	9181                	srli	a1,a1,0x20
    80001d7e:	6928                	ld	a0,80(a0)
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	7e2080e7          	jalr	2018(ra) # 80001562 <uvmalloc>
    80001d88:	0005061b          	sext.w	a2,a0
    80001d8c:	fa69                	bnez	a2,80001d5e <growproc+0x26>
      return -1;
    80001d8e:	557d                	li	a0,-1
    80001d90:	bfe1                	j	80001d68 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d92:	9e25                	addw	a2,a2,s1
    80001d94:	1602                	slli	a2,a2,0x20
    80001d96:	9201                	srli	a2,a2,0x20
    80001d98:	1582                	slli	a1,a1,0x20
    80001d9a:	9181                	srli	a1,a1,0x20
    80001d9c:	6928                	ld	a0,80(a0)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	77c080e7          	jalr	1916(ra) # 8000151a <uvmdealloc>
    80001da6:	0005061b          	sext.w	a2,a0
    80001daa:	bf55                	j	80001d5e <growproc+0x26>

0000000080001dac <scheduler>:
{
    80001dac:	715d                	addi	sp,sp,-80
    80001dae:	e486                	sd	ra,72(sp)
    80001db0:	e0a2                	sd	s0,64(sp)
    80001db2:	fc26                	sd	s1,56(sp)
    80001db4:	f84a                	sd	s2,48(sp)
    80001db6:	f44e                	sd	s3,40(sp)
    80001db8:	f052                	sd	s4,32(sp)
    80001dba:	ec56                	sd	s5,24(sp)
    80001dbc:	e85a                	sd	s6,16(sp)
    80001dbe:	e45e                	sd	s7,8(sp)
    80001dc0:	0880                	addi	s0,sp,80
    80001dc2:	8792                	mv	a5,tp
  int id = r_tp();
    80001dc4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dc6:	00779b13          	slli	s6,a5,0x7
    80001dca:	00010717          	auipc	a4,0x10
    80001dce:	4d670713          	addi	a4,a4,1238 # 800122a0 <pid_lock>
    80001dd2:	975a                	add	a4,a4,s6
    80001dd4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001dd8:	00010717          	auipc	a4,0x10
    80001ddc:	50070713          	addi	a4,a4,1280 # 800122d8 <cpus+0x8>
    80001de0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001de2:	4b91                	li	s7,4
        c->proc = p;
    80001de4:	079e                	slli	a5,a5,0x7
    80001de6:	00010a97          	auipc	s5,0x10
    80001dea:	4baa8a93          	addi	s5,s5,1210 # 800122a0 <pid_lock>
    80001dee:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df0:	6985                	lui	s3,0x1
    80001df2:	a8898993          	addi	s3,s3,-1400 # a88 <_entry-0x7ffff578>
    80001df6:	0003ba17          	auipc	s4,0x3b
    80001dfa:	adaa0a13          	addi	s4,s4,-1318 # 8003c8d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e02:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e06:	10079073          	csrw	sstatus,a5
    80001e0a:	00011497          	auipc	s1,0x11
    80001e0e:	8c648493          	addi	s1,s1,-1850 # 800126d0 <proc>
      if(p->state == RUNNABLE) {
    80001e12:	490d                	li	s2,3
    80001e14:	a809                	j	80001e26 <scheduler+0x7a>
      release(&p->lock);
    80001e16:	8526                	mv	a0,s1
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	e5e080e7          	jalr	-418(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e20:	94ce                	add	s1,s1,s3
    80001e22:	fd448ee3          	beq	s1,s4,80001dfe <scheduler+0x52>
      acquire(&p->lock);
    80001e26:	8526                	mv	a0,s1
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	d9a080e7          	jalr	-614(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001e30:	4c9c                	lw	a5,24(s1)
    80001e32:	ff2792e3          	bne	a5,s2,80001e16 <scheduler+0x6a>
        p->state = RUNNING;
    80001e36:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001e3a:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001e3e:	06048593          	addi	a1,s1,96
    80001e42:	855a                	mv	a0,s6
    80001e44:	00001097          	auipc	ra,0x1
    80001e48:	1a0080e7          	jalr	416(ra) # 80002fe4 <swtch>
        c->proc = 0;
    80001e4c:	020ab823          	sd	zero,48(s5)
    80001e50:	b7d9                	j	80001e16 <scheduler+0x6a>

0000000080001e52 <sched>:
{
    80001e52:	7179                	addi	sp,sp,-48
    80001e54:	f406                	sd	ra,40(sp)
    80001e56:	f022                	sd	s0,32(sp)
    80001e58:	ec26                	sd	s1,24(sp)
    80001e5a:	e84a                	sd	s2,16(sp)
    80001e5c:	e44e                	sd	s3,8(sp)
    80001e5e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e60:	00000097          	auipc	ra,0x0
    80001e64:	d26080e7          	jalr	-730(ra) # 80001b86 <myproc>
    80001e68:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	cde080e7          	jalr	-802(ra) # 80000b48 <holding>
    80001e72:	c93d                	beqz	a0,80001ee8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e74:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e76:	2781                	sext.w	a5,a5
    80001e78:	079e                	slli	a5,a5,0x7
    80001e7a:	00010717          	auipc	a4,0x10
    80001e7e:	42670713          	addi	a4,a4,1062 # 800122a0 <pid_lock>
    80001e82:	97ba                	add	a5,a5,a4
    80001e84:	0a87a703          	lw	a4,168(a5)
    80001e88:	4785                	li	a5,1
    80001e8a:	06f71763          	bne	a4,a5,80001ef8 <sched+0xa6>
  if(p->state == RUNNING)
    80001e8e:	4c98                	lw	a4,24(s1)
    80001e90:	4791                	li	a5,4
    80001e92:	06f70b63          	beq	a4,a5,80001f08 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e96:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e9a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e9c:	efb5                	bnez	a5,80001f18 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e9e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ea0:	00010917          	auipc	s2,0x10
    80001ea4:	40090913          	addi	s2,s2,1024 # 800122a0 <pid_lock>
    80001ea8:	2781                	sext.w	a5,a5
    80001eaa:	079e                	slli	a5,a5,0x7
    80001eac:	97ca                	add	a5,a5,s2
    80001eae:	0ac7a983          	lw	s3,172(a5)
    80001eb2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001eb4:	2781                	sext.w	a5,a5
    80001eb6:	079e                	slli	a5,a5,0x7
    80001eb8:	00010597          	auipc	a1,0x10
    80001ebc:	42058593          	addi	a1,a1,1056 # 800122d8 <cpus+0x8>
    80001ec0:	95be                	add	a1,a1,a5
    80001ec2:	06048513          	addi	a0,s1,96
    80001ec6:	00001097          	auipc	ra,0x1
    80001eca:	11e080e7          	jalr	286(ra) # 80002fe4 <swtch>
    80001ece:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ed0:	2781                	sext.w	a5,a5
    80001ed2:	079e                	slli	a5,a5,0x7
    80001ed4:	97ca                	add	a5,a5,s2
    80001ed6:	0b37a623          	sw	s3,172(a5)
}
    80001eda:	70a2                	ld	ra,40(sp)
    80001edc:	7402                	ld	s0,32(sp)
    80001ede:	64e2                	ld	s1,24(sp)
    80001ee0:	6942                	ld	s2,16(sp)
    80001ee2:	69a2                	ld	s3,8(sp)
    80001ee4:	6145                	addi	sp,sp,48
    80001ee6:	8082                	ret
    panic("sched p->lock");
    80001ee8:	00007517          	auipc	a0,0x7
    80001eec:	35850513          	addi	a0,a0,856 # 80009240 <digits+0x200>
    80001ef0:	ffffe097          	auipc	ra,0xffffe
    80001ef4:	63a080e7          	jalr	1594(ra) # 8000052a <panic>
    panic("sched locks");
    80001ef8:	00007517          	auipc	a0,0x7
    80001efc:	35850513          	addi	a0,a0,856 # 80009250 <digits+0x210>
    80001f00:	ffffe097          	auipc	ra,0xffffe
    80001f04:	62a080e7          	jalr	1578(ra) # 8000052a <panic>
    panic("sched running");
    80001f08:	00007517          	auipc	a0,0x7
    80001f0c:	35850513          	addi	a0,a0,856 # 80009260 <digits+0x220>
    80001f10:	ffffe097          	auipc	ra,0xffffe
    80001f14:	61a080e7          	jalr	1562(ra) # 8000052a <panic>
    panic("sched interruptible");
    80001f18:	00007517          	auipc	a0,0x7
    80001f1c:	35850513          	addi	a0,a0,856 # 80009270 <digits+0x230>
    80001f20:	ffffe097          	auipc	ra,0xffffe
    80001f24:	60a080e7          	jalr	1546(ra) # 8000052a <panic>

0000000080001f28 <yield>:
{
    80001f28:	1101                	addi	sp,sp,-32
    80001f2a:	ec06                	sd	ra,24(sp)
    80001f2c:	e822                	sd	s0,16(sp)
    80001f2e:	e426                	sd	s1,8(sp)
    80001f30:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	c54080e7          	jalr	-940(ra) # 80001b86 <myproc>
    80001f3a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	c86080e7          	jalr	-890(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80001f44:	478d                	li	a5,3
    80001f46:	cc9c                	sw	a5,24(s1)
  sched();
    80001f48:	00000097          	auipc	ra,0x0
    80001f4c:	f0a080e7          	jalr	-246(ra) # 80001e52 <sched>
  release(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	d24080e7          	jalr	-732(ra) # 80000c76 <release>
}
    80001f5a:	60e2                	ld	ra,24(sp)
    80001f5c:	6442                	ld	s0,16(sp)
    80001f5e:	64a2                	ld	s1,8(sp)
    80001f60:	6105                	addi	sp,sp,32
    80001f62:	8082                	ret

0000000080001f64 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	1800                	addi	s0,sp,48
    80001f72:	89aa                	mv	s3,a0
    80001f74:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	c10080e7          	jalr	-1008(ra) # 80001b86 <myproc>
    80001f7e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	c42080e7          	jalr	-958(ra) # 80000bc2 <acquire>
  release(lk);
    80001f88:	854a                	mv	a0,s2
    80001f8a:	fffff097          	auipc	ra,0xfffff
    80001f8e:	cec080e7          	jalr	-788(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80001f92:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f96:	4789                	li	a5,2
    80001f98:	cc9c                	sw	a5,24(s1)

  sched();
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	eb8080e7          	jalr	-328(ra) # 80001e52 <sched>

  // Tidy up.
  p->chan = 0;
    80001fa2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	cce080e7          	jalr	-818(ra) # 80000c76 <release>
  acquire(lk);
    80001fb0:	854a                	mv	a0,s2
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	c10080e7          	jalr	-1008(ra) # 80000bc2 <acquire>
}
    80001fba:	70a2                	ld	ra,40(sp)
    80001fbc:	7402                	ld	s0,32(sp)
    80001fbe:	64e2                	ld	s1,24(sp)
    80001fc0:	6942                	ld	s2,16(sp)
    80001fc2:	69a2                	ld	s3,8(sp)
    80001fc4:	6145                	addi	sp,sp,48
    80001fc6:	8082                	ret

0000000080001fc8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001fc8:	7139                	addi	sp,sp,-64
    80001fca:	fc06                	sd	ra,56(sp)
    80001fcc:	f822                	sd	s0,48(sp)
    80001fce:	f426                	sd	s1,40(sp)
    80001fd0:	f04a                	sd	s2,32(sp)
    80001fd2:	ec4e                	sd	s3,24(sp)
    80001fd4:	e852                	sd	s4,16(sp)
    80001fd6:	e456                	sd	s5,8(sp)
    80001fd8:	e05a                	sd	s6,0(sp)
    80001fda:	0080                	addi	s0,sp,64
    80001fdc:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001fde:	00010497          	auipc	s1,0x10
    80001fe2:	6f248493          	addi	s1,s1,1778 # 800126d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fe6:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001fe8:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fea:	6905                	lui	s2,0x1
    80001fec:	a8890913          	addi	s2,s2,-1400 # a88 <_entry-0x7ffff578>
    80001ff0:	0003b997          	auipc	s3,0x3b
    80001ff4:	8e098993          	addi	s3,s3,-1824 # 8003c8d0 <tickslock>
    80001ff8:	a809                	j	8000200a <wakeup+0x42>
      }
      release(&p->lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	c7a080e7          	jalr	-902(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	94ca                	add	s1,s1,s2
    80002006:	03348663          	beq	s1,s3,80002032 <wakeup+0x6a>
    if(p != myproc()){
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	b7c080e7          	jalr	-1156(ra) # 80001b86 <myproc>
    80002012:	fea489e3          	beq	s1,a0,80002004 <wakeup+0x3c>
      acquire(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	baa080e7          	jalr	-1110(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002020:	4c9c                	lw	a5,24(s1)
    80002022:	fd479ce3          	bne	a5,s4,80001ffa <wakeup+0x32>
    80002026:	709c                	ld	a5,32(s1)
    80002028:	fd5799e3          	bne	a5,s5,80001ffa <wakeup+0x32>
        p->state = RUNNABLE;
    8000202c:	0164ac23          	sw	s6,24(s1)
    80002030:	b7e9                	j	80001ffa <wakeup+0x32>
    }
  }
}
    80002032:	70e2                	ld	ra,56(sp)
    80002034:	7442                	ld	s0,48(sp)
    80002036:	74a2                	ld	s1,40(sp)
    80002038:	7902                	ld	s2,32(sp)
    8000203a:	69e2                	ld	s3,24(sp)
    8000203c:	6a42                	ld	s4,16(sp)
    8000203e:	6aa2                	ld	s5,8(sp)
    80002040:	6b02                	ld	s6,0(sp)
    80002042:	6121                	addi	sp,sp,64
    80002044:	8082                	ret

0000000080002046 <reparent>:
{
    80002046:	7139                	addi	sp,sp,-64
    80002048:	fc06                	sd	ra,56(sp)
    8000204a:	f822                	sd	s0,48(sp)
    8000204c:	f426                	sd	s1,40(sp)
    8000204e:	f04a                	sd	s2,32(sp)
    80002050:	ec4e                	sd	s3,24(sp)
    80002052:	e852                	sd	s4,16(sp)
    80002054:	e456                	sd	s5,8(sp)
    80002056:	0080                	addi	s0,sp,64
    80002058:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000205a:	00010497          	auipc	s1,0x10
    8000205e:	67648493          	addi	s1,s1,1654 # 800126d0 <proc>
      pp->parent = initproc;
    80002062:	00008a97          	auipc	s5,0x8
    80002066:	fcea8a93          	addi	s5,s5,-50 # 8000a030 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000206a:	6905                	lui	s2,0x1
    8000206c:	a8890913          	addi	s2,s2,-1400 # a88 <_entry-0x7ffff578>
    80002070:	0003ba17          	auipc	s4,0x3b
    80002074:	860a0a13          	addi	s4,s4,-1952 # 8003c8d0 <tickslock>
    80002078:	a021                	j	80002080 <reparent+0x3a>
    8000207a:	94ca                	add	s1,s1,s2
    8000207c:	01448d63          	beq	s1,s4,80002096 <reparent+0x50>
    if(pp->parent == p){
    80002080:	7c9c                	ld	a5,56(s1)
    80002082:	ff379ce3          	bne	a5,s3,8000207a <reparent+0x34>
      pp->parent = initproc;
    80002086:	000ab503          	ld	a0,0(s5)
    8000208a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	f3c080e7          	jalr	-196(ra) # 80001fc8 <wakeup>
    80002094:	b7dd                	j	8000207a <reparent+0x34>
}
    80002096:	70e2                	ld	ra,56(sp)
    80002098:	7442                	ld	s0,48(sp)
    8000209a:	74a2                	ld	s1,40(sp)
    8000209c:	7902                	ld	s2,32(sp)
    8000209e:	69e2                	ld	s3,24(sp)
    800020a0:	6a42                	ld	s4,16(sp)
    800020a2:	6aa2                	ld	s5,8(sp)
    800020a4:	6121                	addi	sp,sp,64
    800020a6:	8082                	ret

00000000800020a8 <exit>:
{
    800020a8:	7179                	addi	sp,sp,-48
    800020aa:	f406                	sd	ra,40(sp)
    800020ac:	f022                	sd	s0,32(sp)
    800020ae:	ec26                	sd	s1,24(sp)
    800020b0:	e84a                	sd	s2,16(sp)
    800020b2:	e44e                	sd	s3,8(sp)
    800020b4:	e052                	sd	s4,0(sp)
    800020b6:	1800                	addi	s0,sp,48
    800020b8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	acc080e7          	jalr	-1332(ra) # 80001b86 <myproc>
    800020c2:	89aa                	mv	s3,a0
  if(p == initproc)
    800020c4:	00008797          	auipc	a5,0x8
    800020c8:	f6c7b783          	ld	a5,-148(a5) # 8000a030 <initproc>
    800020cc:	0d050493          	addi	s1,a0,208
    800020d0:	15050913          	addi	s2,a0,336
    800020d4:	02a79363          	bne	a5,a0,800020fa <exit+0x52>
    panic("init exiting");
    800020d8:	00007517          	auipc	a0,0x7
    800020dc:	1b050513          	addi	a0,a0,432 # 80009288 <digits+0x248>
    800020e0:	ffffe097          	auipc	ra,0xffffe
    800020e4:	44a080e7          	jalr	1098(ra) # 8000052a <panic>
      fileclose(f);
    800020e8:	00003097          	auipc	ra,0x3
    800020ec:	172080e7          	jalr	370(ra) # 8000525a <fileclose>
      p->ofile[fd] = 0;
    800020f0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020f4:	04a1                	addi	s1,s1,8
    800020f6:	01248563          	beq	s1,s2,80002100 <exit+0x58>
    if(p->ofile[fd]){
    800020fa:	6088                	ld	a0,0(s1)
    800020fc:	f575                	bnez	a0,800020e8 <exit+0x40>
    800020fe:	bfdd                	j	800020f4 <exit+0x4c>
  if (p->pid > 2) {
    80002100:	0309a703          	lw	a4,48(s3)
    80002104:	4789                	li	a5,2
    80002106:	08e7c163          	blt	a5,a4,80002188 <exit+0xe0>
  begin_op();
    8000210a:	00003097          	auipc	ra,0x3
    8000210e:	c84080e7          	jalr	-892(ra) # 80004d8e <begin_op>
  iput(p->cwd);
    80002112:	1509b503          	ld	a0,336(s3)
    80002116:	00002097          	auipc	ra,0x2
    8000211a:	14a080e7          	jalr	330(ra) # 80004260 <iput>
  end_op();
    8000211e:	00003097          	auipc	ra,0x3
    80002122:	cf0080e7          	jalr	-784(ra) # 80004e0e <end_op>
  p->cwd = 0;
    80002126:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000212a:	00010497          	auipc	s1,0x10
    8000212e:	18e48493          	addi	s1,s1,398 # 800122b8 <wait_lock>
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	a8e080e7          	jalr	-1394(ra) # 80000bc2 <acquire>
  reparent(p);
    8000213c:	854e                	mv	a0,s3
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	f08080e7          	jalr	-248(ra) # 80002046 <reparent>
  wakeup(p->parent);
    80002146:	0389b503          	ld	a0,56(s3)
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	e7e080e7          	jalr	-386(ra) # 80001fc8 <wakeup>
  acquire(&p->lock);
    80002152:	854e                	mv	a0,s3
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	a6e080e7          	jalr	-1426(ra) # 80000bc2 <acquire>
  p->xstate = status;
    8000215c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002160:	4795                	li	a5,5
    80002162:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002166:	8526                	mv	a0,s1
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	b0e080e7          	jalr	-1266(ra) # 80000c76 <release>
  sched();
    80002170:	00000097          	auipc	ra,0x0
    80002174:	ce2080e7          	jalr	-798(ra) # 80001e52 <sched>
  panic("zombie exit");
    80002178:	00007517          	auipc	a0,0x7
    8000217c:	12050513          	addi	a0,a0,288 # 80009298 <digits+0x258>
    80002180:	ffffe097          	auipc	ra,0xffffe
    80002184:	3aa080e7          	jalr	938(ra) # 8000052a <panic>
	  removeSwapFile(p);
    80002188:	854e                	mv	a0,s3
    8000218a:	00002097          	auipc	ra,0x2
    8000218e:	77e080e7          	jalr	1918(ra) # 80004908 <removeSwapFile>
    80002192:	bfa5                	j	8000210a <exit+0x62>

0000000080002194 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002194:	7179                	addi	sp,sp,-48
    80002196:	f406                	sd	ra,40(sp)
    80002198:	f022                	sd	s0,32(sp)
    8000219a:	ec26                	sd	s1,24(sp)
    8000219c:	e84a                	sd	s2,16(sp)
    8000219e:	e44e                	sd	s3,8(sp)
    800021a0:	e052                	sd	s4,0(sp)
    800021a2:	1800                	addi	s0,sp,48
    800021a4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021a6:	00010497          	auipc	s1,0x10
    800021aa:	52a48493          	addi	s1,s1,1322 # 800126d0 <proc>
    800021ae:	6985                	lui	s3,0x1
    800021b0:	a8898993          	addi	s3,s3,-1400 # a88 <_entry-0x7ffff578>
    800021b4:	0003aa17          	auipc	s4,0x3a
    800021b8:	71ca0a13          	addi	s4,s4,1820 # 8003c8d0 <tickslock>
    acquire(&p->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	a04080e7          	jalr	-1532(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800021c6:	589c                	lw	a5,48(s1)
    800021c8:	01278c63          	beq	a5,s2,800021e0 <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	aa8080e7          	jalr	-1368(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800021d6:	94ce                	add	s1,s1,s3
    800021d8:	ff4492e3          	bne	s1,s4,800021bc <kill+0x28>
  }
  return -1;
    800021dc:	557d                	li	a0,-1
    800021de:	a829                	j	800021f8 <kill+0x64>
      p->killed = 1;
    800021e0:	4785                	li	a5,1
    800021e2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021e4:	4c98                	lw	a4,24(s1)
    800021e6:	4789                	li	a5,2
    800021e8:	02f70063          	beq	a4,a5,80002208 <kill+0x74>
      release(&p->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	a88080e7          	jalr	-1400(ra) # 80000c76 <release>
      return 0;
    800021f6:	4501                	li	a0,0
}
    800021f8:	70a2                	ld	ra,40(sp)
    800021fa:	7402                	ld	s0,32(sp)
    800021fc:	64e2                	ld	s1,24(sp)
    800021fe:	6942                	ld	s2,16(sp)
    80002200:	69a2                	ld	s3,8(sp)
    80002202:	6a02                	ld	s4,0(sp)
    80002204:	6145                	addi	sp,sp,48
    80002206:	8082                	ret
        p->state = RUNNABLE;
    80002208:	478d                	li	a5,3
    8000220a:	cc9c                	sw	a5,24(s1)
    8000220c:	b7c5                	j	800021ec <kill+0x58>

000000008000220e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220e:	7179                	addi	sp,sp,-48
    80002210:	f406                	sd	ra,40(sp)
    80002212:	f022                	sd	s0,32(sp)
    80002214:	ec26                	sd	s1,24(sp)
    80002216:	e84a                	sd	s2,16(sp)
    80002218:	e44e                	sd	s3,8(sp)
    8000221a:	e052                	sd	s4,0(sp)
    8000221c:	1800                	addi	s0,sp,48
    8000221e:	84aa                	mv	s1,a0
    80002220:	892e                	mv	s2,a1
    80002222:	89b2                	mv	s3,a2
    80002224:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	960080e7          	jalr	-1696(ra) # 80001b86 <myproc>
  if(user_dst){
    8000222e:	c08d                	beqz	s1,80002250 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002230:	86d2                	mv	a3,s4
    80002232:	864e                	mv	a2,s3
    80002234:	85ca                	mv	a1,s2
    80002236:	6928                	ld	a0,80(a0)
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	5fa080e7          	jalr	1530(ra) # 80001832 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002240:	70a2                	ld	ra,40(sp)
    80002242:	7402                	ld	s0,32(sp)
    80002244:	64e2                	ld	s1,24(sp)
    80002246:	6942                	ld	s2,16(sp)
    80002248:	69a2                	ld	s3,8(sp)
    8000224a:	6a02                	ld	s4,0(sp)
    8000224c:	6145                	addi	sp,sp,48
    8000224e:	8082                	ret
    memmove((char *)dst, src, len);
    80002250:	000a061b          	sext.w	a2,s4
    80002254:	85ce                	mv	a1,s3
    80002256:	854a                	mv	a0,s2
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	ac2080e7          	jalr	-1342(ra) # 80000d1a <memmove>
    return 0;
    80002260:	8526                	mv	a0,s1
    80002262:	bff9                	j	80002240 <either_copyout+0x32>

0000000080002264 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	e052                	sd	s4,0(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	892a                	mv	s2,a0
    80002276:	84ae                	mv	s1,a1
    80002278:	89b2                	mv	s3,a2
    8000227a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000227c:	00000097          	auipc	ra,0x0
    80002280:	90a080e7          	jalr	-1782(ra) # 80001b86 <myproc>
  if(user_src){
    80002284:	c08d                	beqz	s1,800022a6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002286:	86d2                	mv	a3,s4
    80002288:	864e                	mv	a2,s3
    8000228a:	85ca                	mv	a1,s2
    8000228c:	6928                	ld	a0,80(a0)
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	630080e7          	jalr	1584(ra) # 800018be <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002296:	70a2                	ld	ra,40(sp)
    80002298:	7402                	ld	s0,32(sp)
    8000229a:	64e2                	ld	s1,24(sp)
    8000229c:	6942                	ld	s2,16(sp)
    8000229e:	69a2                	ld	s3,8(sp)
    800022a0:	6a02                	ld	s4,0(sp)
    800022a2:	6145                	addi	sp,sp,48
    800022a4:	8082                	ret
    memmove(dst, (char*)src, len);
    800022a6:	000a061b          	sext.w	a2,s4
    800022aa:	85ce                	mv	a1,s3
    800022ac:	854a                	mv	a0,s2
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	a6c080e7          	jalr	-1428(ra) # 80000d1a <memmove>
    return 0;
    800022b6:	8526                	mv	a0,s1
    800022b8:	bff9                	j	80002296 <either_copyin+0x32>

00000000800022ba <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022ba:	715d                	addi	sp,sp,-80
    800022bc:	e486                	sd	ra,72(sp)
    800022be:	e0a2                	sd	s0,64(sp)
    800022c0:	fc26                	sd	s1,56(sp)
    800022c2:	f84a                	sd	s2,48(sp)
    800022c4:	f44e                	sd	s3,40(sp)
    800022c6:	f052                	sd	s4,32(sp)
    800022c8:	ec56                	sd	s5,24(sp)
    800022ca:	e85a                	sd	s6,16(sp)
    800022cc:	e45e                	sd	s7,8(sp)
    800022ce:	e062                	sd	s8,0(sp)
    800022d0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022d2:	00007517          	auipc	a0,0x7
    800022d6:	1d650513          	addi	a0,a0,470 # 800094a8 <digits+0x468>
    800022da:	ffffe097          	auipc	ra,0xffffe
    800022de:	29a080e7          	jalr	666(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022e2:	00010497          	auipc	s1,0x10
    800022e6:	54648493          	addi	s1,s1,1350 # 80012828 <proc+0x158>
    800022ea:	0003a997          	auipc	s3,0x3a
    800022ee:	73e98993          	addi	s3,s3,1854 # 8003ca28 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022f2:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    800022f4:	00007a17          	auipc	s4,0x7
    800022f8:	fb4a0a13          	addi	s4,s4,-76 # 800092a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    800022fc:	00007b17          	auipc	s6,0x7
    80002300:	fb4b0b13          	addi	s6,s6,-76 # 800092b0 <digits+0x270>
    printf("\n");
    80002304:	00007a97          	auipc	s5,0x7
    80002308:	1a4a8a93          	addi	s5,s5,420 # 800094a8 <digits+0x468>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230c:	00007c17          	auipc	s8,0x7
    80002310:	274c0c13          	addi	s8,s8,628 # 80009580 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002314:	6905                	lui	s2,0x1
    80002316:	a8890913          	addi	s2,s2,-1400 # a88 <_entry-0x7ffff578>
    8000231a:	a005                	j	8000233a <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    8000231c:	ed86a583          	lw	a1,-296(a3)
    80002320:	855a                	mv	a0,s6
    80002322:	ffffe097          	auipc	ra,0xffffe
    80002326:	252080e7          	jalr	594(ra) # 80000574 <printf>
    printf("\n");
    8000232a:	8556                	mv	a0,s5
    8000232c:	ffffe097          	auipc	ra,0xffffe
    80002330:	248080e7          	jalr	584(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002334:	94ca                	add	s1,s1,s2
    80002336:	03348263          	beq	s1,s3,8000235a <procdump+0xa0>
    if(p->state == UNUSED)
    8000233a:	86a6                	mv	a3,s1
    8000233c:	ec04a783          	lw	a5,-320(s1)
    80002340:	dbf5                	beqz	a5,80002334 <procdump+0x7a>
      state = "???";
    80002342:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002344:	fcfbece3          	bltu	s7,a5,8000231c <procdump+0x62>
    80002348:	02079713          	slli	a4,a5,0x20
    8000234c:	01d75793          	srli	a5,a4,0x1d
    80002350:	97e2                	add	a5,a5,s8
    80002352:	6390                	ld	a2,0(a5)
    80002354:	f661                	bnez	a2,8000231c <procdump+0x62>
      state = "???";
    80002356:	8652                	mv	a2,s4
    80002358:	b7d1                	j	8000231c <procdump+0x62>
  }
}
    8000235a:	60a6                	ld	ra,72(sp)
    8000235c:	6406                	ld	s0,64(sp)
    8000235e:	74e2                	ld	s1,56(sp)
    80002360:	7942                	ld	s2,48(sp)
    80002362:	79a2                	ld	s3,40(sp)
    80002364:	7a02                	ld	s4,32(sp)
    80002366:	6ae2                	ld	s5,24(sp)
    80002368:	6b42                	ld	s6,16(sp)
    8000236a:	6ba2                	ld	s7,8(sp)
    8000236c:	6c02                	ld	s8,0(sp)
    8000236e:	6161                	addi	sp,sp,80
    80002370:	8082                	ret

0000000080002372 <find_free_index>:
 ///////////////////////// - swap functions - /////////////////////////
// #ifndef NONE


  //returns a free index in physical memory
 int find_free_index(struct page_struct* pagearr) {
    80002372:	1141                	addi	sp,sp,-16
    80002374:	e422                	sd	s0,8(sp)
    80002376:	0800                	addi	s0,sp,16
    80002378:	87aa                	mv	a5,a0
  struct page_struct *arr;
  int i = 0;
    8000237a:	4501                	li	a0,0
  for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    8000237c:	46c1                	li	a3,16
    // printf("pid: %d, i: %d, pagearr[i].isAvailable: %d\n",myproc()->pid, i, pagearr[i].isAvailable);
    if(arr->isAvailable){
    8000237e:	4398                	lw	a4,0(a5)
    80002380:	e719                	bnez	a4,8000238e <find_free_index+0x1c>
      return i;
    }
    i++;
    80002382:	2505                	addiw	a0,a0,1
  for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    80002384:	03078793          	addi	a5,a5,48
    80002388:	fed51be3          	bne	a0,a3,8000237e <find_free_index+0xc>
  }
  return -1; //in case there no space
    8000238c:	557d                	li	a0,-1
 }
    8000238e:	6422                	ld	s0,8(sp)
    80002390:	0141                	addi	sp,sp,16
    80002392:	8082                	ret

0000000080002394 <init_meta_data>:

 void init_meta_data(struct proc* p) {
    80002394:	1141                	addi	sp,sp,-16
    80002396:	e422                	sd	s0,8(sp)
    80002398:	0800                	addi	s0,sp,16
  p->num_of_pages = 0;
    8000239a:	6785                	lui	a5,0x1
    8000239c:	97aa                	add	a5,a5,a0
    8000239e:	a607a823          	sw	zero,-1424(a5) # a70 <_entry-0x7ffff590>
  p->num_of_pages_in_phys = 0;
    800023a2:	a607aa23          	sw	zero,-1420(a5)
  struct page_struct *pa_swap;
  // printf("allocproc, p->pid: %d, p->files_in_swap: %d\n", p->pid, p->files_in_swap);
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_PSYC_PAGES] ; pa_swap++) {
    800023a6:	17050793          	addi	a5,a0,368
    800023aa:	47050593          	addi	a1,a0,1136
    pa_swap->pagetable = p->pagetable;
    pa_swap->isAvailable = 1;
    800023ae:	4605                	li	a2,1
    pa_swap->va = -1;
    800023b0:	577d                	li	a4,-1
    pa_swap->pagetable = p->pagetable;
    800023b2:	6934                	ld	a3,80(a0)
    800023b4:	e794                	sd	a3,8(a5)
    pa_swap->isAvailable = 1;
    800023b6:	c390                	sw	a2,0(a5)
    pa_swap->va = -1;
    800023b8:	ef98                	sd	a4,24(a5)
    pa_swap->offset = -1;
    800023ba:	d398                	sw	a4,32(a5)
    #ifdef NFUA
     pa_swap->counter_NFUA = 0;
    #endif
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
    800023bc:	d798                	sw	a4,40(a5)
      pa_swap->index_of_next_p = -1;
    800023be:	d3d8                	sw	a4,36(a5)
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_PSYC_PAGES] ; pa_swap++) {
    800023c0:	03078793          	addi	a5,a5,48
    800023c4:	fef597e3          	bne	a1,a5,800023b2 <init_meta_data+0x1e>
  }

  struct page_struct *pa_psyc;
  // printf("allocproc, p->pid: %d, p->files_in_physicalmem: %d\n", p->pid, p->files_in_physicalmem);

  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    800023c8:	77050793          	addi	a5,a0,1904
    800023cc:	6605                	lui	a2,0x1
    800023ce:	a7060613          	addi	a2,a2,-1424 # a70 <_entry-0x7ffff590>
    800023d2:	962a                	add	a2,a2,a0
    pa_psyc->pagetable = p->pagetable;
    pa_psyc->isAvailable = 1;
    800023d4:	4585                	li	a1,1
    pa_psyc->va = -1;
    800023d6:	577d                	li	a4,-1
    pa_psyc->pagetable = p->pagetable;
    800023d8:	6934                	ld	a3,80(a0)
    800023da:	e794                	sd	a3,8(a5)
    pa_psyc->isAvailable = 1;
    800023dc:	c38c                	sw	a1,0(a5)
    pa_psyc->va = -1;
    800023de:	ef98                	sd	a4,24(a5)
    pa_psyc->offset = -1;
    800023e0:	d398                	sw	a4,32(a5)
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
    800023e2:	48e52c23          	sw	a4,1176(a0)
      pa_swap->index_of_next_p = -1;
    800023e6:	48e52a23          	sw	a4,1172(a0)
  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    800023ea:	03078793          	addi	a5,a5,48
    800023ee:	fef615e3          	bne	a2,a5,800023d8 <init_meta_data+0x44>
    #endif
  }

  #ifdef SCFIFO
    p->index_of_head_p = -1;  //no pages in ram so no head
    800023f2:	6785                	lui	a5,0x1
    800023f4:	953e                	add	a0,a0,a5
    800023f6:	57fd                	li	a5,-1
    800023f8:	a8f52023          	sw	a5,-1408(a0)
  #endif
}
    800023fc:	6422                	ld	s0,8(sp)
    800023fe:	0141                	addi	sp,sp,16
    80002400:	8082                	ret

0000000080002402 <freeproc>:
{
    80002402:	1101                	addi	sp,sp,-32
    80002404:	ec06                	sd	ra,24(sp)
    80002406:	e822                	sd	s0,16(sp)
    80002408:	e426                	sd	s1,8(sp)
    8000240a:	1000                	addi	s0,sp,32
    8000240c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000240e:	6d28                	ld	a0,88(a0)
    80002410:	c509                	beqz	a0,8000241a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	5c4080e7          	jalr	1476(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    8000241a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000241e:	68a8                	ld	a0,80(s1)
    80002420:	c511                	beqz	a0,8000242c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002422:	64ac                	ld	a1,72(s1)
    80002424:	00000097          	auipc	ra,0x0
    80002428:	8c2080e7          	jalr	-1854(ra) # 80001ce6 <proc_freepagetable>
  p->pagetable = 0;
    8000242c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80002430:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80002434:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002438:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000243c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002440:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80002444:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002448:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000244c:	0004ac23          	sw	zero,24(s1)
  init_meta_data(p); //TODO not sure
    80002450:	8526                	mv	a0,s1
    80002452:	00000097          	auipc	ra,0x0
    80002456:	f42080e7          	jalr	-190(ra) # 80002394 <init_meta_data>
  printf("end freeproc\n");
    8000245a:	00007517          	auipc	a0,0x7
    8000245e:	e6650513          	addi	a0,a0,-410 # 800092c0 <digits+0x280>
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	112080e7          	jalr	274(ra) # 80000574 <printf>
}
    8000246a:	60e2                	ld	ra,24(sp)
    8000246c:	6442                	ld	s0,16(sp)
    8000246e:	64a2                	ld	s1,8(sp)
    80002470:	6105                	addi	sp,sp,32
    80002472:	8082                	ret

0000000080002474 <wait>:
{
    80002474:	715d                	addi	sp,sp,-80
    80002476:	e486                	sd	ra,72(sp)
    80002478:	e0a2                	sd	s0,64(sp)
    8000247a:	fc26                	sd	s1,56(sp)
    8000247c:	f84a                	sd	s2,48(sp)
    8000247e:	f44e                	sd	s3,40(sp)
    80002480:	f052                	sd	s4,32(sp)
    80002482:	ec56                	sd	s5,24(sp)
    80002484:	e85a                	sd	s6,16(sp)
    80002486:	e45e                	sd	s7,8(sp)
    80002488:	0880                	addi	s0,sp,80
    8000248a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	6fa080e7          	jalr	1786(ra) # 80001b86 <myproc>
    80002494:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002496:	00010517          	auipc	a0,0x10
    8000249a:	e2250513          	addi	a0,a0,-478 # 800122b8 <wait_lock>
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	724080e7          	jalr	1828(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800024a6:	4a95                	li	s5,5
        havekids = 1;
    800024a8:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    800024aa:	6985                	lui	s3,0x1
    800024ac:	a8898993          	addi	s3,s3,-1400 # a88 <_entry-0x7ffff578>
    800024b0:	0003aa17          	auipc	s4,0x3a
    800024b4:	420a0a13          	addi	s4,s4,1056 # 8003c8d0 <tickslock>
    havekids = 0;
    800024b8:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800024ba:	00010497          	auipc	s1,0x10
    800024be:	21648493          	addi	s1,s1,534 # 800126d0 <proc>
    800024c2:	a0b5                	j	8000252e <wait+0xba>
          pid = np->pid;
    800024c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024c8:	000b8e63          	beqz	s7,800024e4 <wait+0x70>
    800024cc:	4691                	li	a3,4
    800024ce:	02c48613          	addi	a2,s1,44
    800024d2:	85de                	mv	a1,s7
    800024d4:	05093503          	ld	a0,80(s2)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	35a080e7          	jalr	858(ra) # 80001832 <copyout>
    800024e0:	02054563          	bltz	a0,8000250a <wait+0x96>
          freeproc(np);
    800024e4:	8526                	mv	a0,s1
    800024e6:	00000097          	auipc	ra,0x0
    800024ea:	f1c080e7          	jalr	-228(ra) # 80002402 <freeproc>
          release(&np->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	786080e7          	jalr	1926(ra) # 80000c76 <release>
          release(&wait_lock);
    800024f8:	00010517          	auipc	a0,0x10
    800024fc:	dc050513          	addi	a0,a0,-576 # 800122b8 <wait_lock>
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	776080e7          	jalr	1910(ra) # 80000c76 <release>
          return pid;
    80002508:	a095                	j	8000256c <wait+0xf8>
            release(&np->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	76a080e7          	jalr	1898(ra) # 80000c76 <release>
            release(&wait_lock);
    80002514:	00010517          	auipc	a0,0x10
    80002518:	da450513          	addi	a0,a0,-604 # 800122b8 <wait_lock>
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	75a080e7          	jalr	1882(ra) # 80000c76 <release>
            return -1;
    80002524:	59fd                	li	s3,-1
    80002526:	a099                	j	8000256c <wait+0xf8>
    for(np = proc; np < &proc[NPROC]; np++){
    80002528:	94ce                	add	s1,s1,s3
    8000252a:	03448463          	beq	s1,s4,80002552 <wait+0xde>
      if(np->parent == p){
    8000252e:	7c9c                	ld	a5,56(s1)
    80002530:	ff279ce3          	bne	a5,s2,80002528 <wait+0xb4>
        acquire(&np->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	68c080e7          	jalr	1676(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    8000253e:	4c9c                	lw	a5,24(s1)
    80002540:	f95782e3          	beq	a5,s5,800024c4 <wait+0x50>
        release(&np->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	730080e7          	jalr	1840(ra) # 80000c76 <release>
        havekids = 1;
    8000254e:	875a                	mv	a4,s6
    80002550:	bfe1                	j	80002528 <wait+0xb4>
    if(!havekids || p->killed){
    80002552:	c701                	beqz	a4,8000255a <wait+0xe6>
    80002554:	02892783          	lw	a5,40(s2)
    80002558:	c795                	beqz	a5,80002584 <wait+0x110>
      release(&wait_lock);
    8000255a:	00010517          	auipc	a0,0x10
    8000255e:	d5e50513          	addi	a0,a0,-674 # 800122b8 <wait_lock>
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	714080e7          	jalr	1812(ra) # 80000c76 <release>
      return -1;
    8000256a:	59fd                	li	s3,-1
}
    8000256c:	854e                	mv	a0,s3
    8000256e:	60a6                	ld	ra,72(sp)
    80002570:	6406                	ld	s0,64(sp)
    80002572:	74e2                	ld	s1,56(sp)
    80002574:	7942                	ld	s2,48(sp)
    80002576:	79a2                	ld	s3,40(sp)
    80002578:	7a02                	ld	s4,32(sp)
    8000257a:	6ae2                	ld	s5,24(sp)
    8000257c:	6b42                	ld	s6,16(sp)
    8000257e:	6ba2                	ld	s7,8(sp)
    80002580:	6161                	addi	sp,sp,80
    80002582:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002584:	00010597          	auipc	a1,0x10
    80002588:	d3458593          	addi	a1,a1,-716 # 800122b8 <wait_lock>
    8000258c:	854a                	mv	a0,s2
    8000258e:	00000097          	auipc	ra,0x0
    80002592:	9d6080e7          	jalr	-1578(ra) # 80001f64 <sleep>
    havekids = 0;
    80002596:	b70d                	j	800024b8 <wait+0x44>

0000000080002598 <allocproc>:
{
    80002598:	7179                	addi	sp,sp,-48
    8000259a:	f406                	sd	ra,40(sp)
    8000259c:	f022                	sd	s0,32(sp)
    8000259e:	ec26                	sd	s1,24(sp)
    800025a0:	e84a                	sd	s2,16(sp)
    800025a2:	e44e                	sd	s3,8(sp)
    800025a4:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800025a6:	00010497          	auipc	s1,0x10
    800025aa:	12a48493          	addi	s1,s1,298 # 800126d0 <proc>
    800025ae:	6905                	lui	s2,0x1
    800025b0:	a8890913          	addi	s2,s2,-1400 # a88 <_entry-0x7ffff578>
    800025b4:	0003a997          	auipc	s3,0x3a
    800025b8:	31c98993          	addi	s3,s3,796 # 8003c8d0 <tickslock>
    acquire(&p->lock);
    800025bc:	8526                	mv	a0,s1
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	604080e7          	jalr	1540(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    800025c6:	4c9c                	lw	a5,24(s1)
    800025c8:	cb99                	beqz	a5,800025de <allocproc+0x46>
      release(&p->lock);
    800025ca:	8526                	mv	a0,s1
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	6aa080e7          	jalr	1706(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025d4:	94ca                	add	s1,s1,s2
    800025d6:	ff3493e3          	bne	s1,s3,800025bc <allocproc+0x24>
  return 0;
    800025da:	4481                	li	s1,0
    800025dc:	a059                	j	80002662 <allocproc+0xca>
  p->pid = allocpid();
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	626080e7          	jalr	1574(ra) # 80001c04 <allocpid>
    800025e6:	d888                	sw	a0,48(s1)
  p->state = USED;
    800025e8:	4785                	li	a5,1
    800025ea:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	4e6080e7          	jalr	1254(ra) # 80000ad2 <kalloc>
    800025f4:	892a                	mv	s2,a0
    800025f6:	eca8                	sd	a0,88(s1)
    800025f8:	cd2d                	beqz	a0,80002672 <allocproc+0xda>
  p->pagetable = proc_pagetable(p);
    800025fa:	8526                	mv	a0,s1
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	64e080e7          	jalr	1614(ra) # 80001c4a <proc_pagetable>
    80002604:	892a                	mv	s2,a0
    80002606:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002608:	c149                	beqz	a0,8000268a <allocproc+0xf2>
  memset(&p->context, 0, sizeof(p->context));
    8000260a:	07000613          	li	a2,112
    8000260e:	4581                	li	a1,0
    80002610:	06048513          	addi	a0,s1,96
    80002614:	ffffe097          	auipc	ra,0xffffe
    80002618:	6aa080e7          	jalr	1706(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    8000261c:	fffff797          	auipc	a5,0xfffff
    80002620:	5a278793          	addi	a5,a5,1442 # 80001bbe <forkret>
    80002624:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002626:	60bc                	ld	a5,64(s1)
    80002628:	6705                	lui	a4,0x1
    8000262a:	97ba                	add	a5,a5,a4
    8000262c:	f4bc                	sd	a5,104(s1)
  if (p->pid > 2){
    8000262e:	5898                	lw	a4,48(s1)
    80002630:	4789                	li	a5,2
    80002632:	02e7d363          	bge	a5,a4,80002658 <allocproc+0xc0>
    release(&p->lock);
    80002636:	8526                	mv	a0,s1
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	63e080e7          	jalr	1598(ra) # 80000c76 <release>
    if(createSwapFile(p) < 0)
    80002640:	8526                	mv	a0,s1
    80002642:	00002097          	auipc	ra,0x2
    80002646:	46e080e7          	jalr	1134(ra) # 80004ab0 <createSwapFile>
    8000264a:	04054c63          	bltz	a0,800026a2 <allocproc+0x10a>
    acquire(&p->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	572080e7          	jalr	1394(ra) # 80000bc2 <acquire>
  init_meta_data(p);
    80002658:	8526                	mv	a0,s1
    8000265a:	00000097          	auipc	ra,0x0
    8000265e:	d3a080e7          	jalr	-710(ra) # 80002394 <init_meta_data>
}
    80002662:	8526                	mv	a0,s1
    80002664:	70a2                	ld	ra,40(sp)
    80002666:	7402                	ld	s0,32(sp)
    80002668:	64e2                	ld	s1,24(sp)
    8000266a:	6942                	ld	s2,16(sp)
    8000266c:	69a2                	ld	s3,8(sp)
    8000266e:	6145                	addi	sp,sp,48
    80002670:	8082                	ret
    freeproc(p);
    80002672:	8526                	mv	a0,s1
    80002674:	00000097          	auipc	ra,0x0
    80002678:	d8e080e7          	jalr	-626(ra) # 80002402 <freeproc>
    release(&p->lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	5f8080e7          	jalr	1528(ra) # 80000c76 <release>
    return 0;
    80002686:	84ca                	mv	s1,s2
    80002688:	bfe9                	j	80002662 <allocproc+0xca>
    freeproc(p);
    8000268a:	8526                	mv	a0,s1
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	d76080e7          	jalr	-650(ra) # 80002402 <freeproc>
    release(&p->lock);
    80002694:	8526                	mv	a0,s1
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	5e0080e7          	jalr	1504(ra) # 80000c76 <release>
    return 0;
    8000269e:	84ca                	mv	s1,s2
    800026a0:	b7c9                	j	80002662 <allocproc+0xca>
      panic("allocproc swapfile creation failed\n");
    800026a2:	00007517          	auipc	a0,0x7
    800026a6:	c2e50513          	addi	a0,a0,-978 # 800092d0 <digits+0x290>
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	e80080e7          	jalr	-384(ra) # 8000052a <panic>

00000000800026b2 <userinit>:
{
    800026b2:	1101                	addi	sp,sp,-32
    800026b4:	ec06                	sd	ra,24(sp)
    800026b6:	e822                	sd	s0,16(sp)
    800026b8:	e426                	sd	s1,8(sp)
    800026ba:	1000                	addi	s0,sp,32
  p = allocproc();
    800026bc:	00000097          	auipc	ra,0x0
    800026c0:	edc080e7          	jalr	-292(ra) # 80002598 <allocproc>
    800026c4:	84aa                	mv	s1,a0
  initproc = p;
    800026c6:	00008797          	auipc	a5,0x8
    800026ca:	96a7b523          	sd	a0,-1686(a5) # 8000a030 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800026ce:	03400613          	li	a2,52
    800026d2:	00007597          	auipc	a1,0x7
    800026d6:	45e58593          	addi	a1,a1,1118 # 80009b30 <initcode>
    800026da:	6928                	ld	a0,80(a0)
    800026dc:	fffff097          	auipc	ra,0xfffff
    800026e0:	dcc080e7          	jalr	-564(ra) # 800014a8 <uvminit>
  p->sz = PGSIZE;
    800026e4:	6785                	lui	a5,0x1
    800026e6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800026e8:	6cb8                	ld	a4,88(s1)
    800026ea:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800026ee:	6cb8                	ld	a4,88(s1)
    800026f0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800026f2:	4641                	li	a2,16
    800026f4:	00007597          	auipc	a1,0x7
    800026f8:	c0458593          	addi	a1,a1,-1020 # 800092f8 <digits+0x2b8>
    800026fc:	15848513          	addi	a0,s1,344
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	710080e7          	jalr	1808(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002708:	00007517          	auipc	a0,0x7
    8000270c:	c0050513          	addi	a0,a0,-1024 # 80009308 <digits+0x2c8>
    80002710:	00002097          	auipc	ra,0x2
    80002714:	14c080e7          	jalr	332(ra) # 8000485c <namei>
    80002718:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000271c:	478d                	li	a5,3
    8000271e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002720:	8526                	mv	a0,s1
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	554080e7          	jalr	1364(ra) # 80000c76 <release>
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	64a2                	ld	s1,8(sp)
    80002730:	6105                	addi	sp,sp,32
    80002732:	8082                	ret

0000000080002734 <find_index_file_arr>:
  p->num_of_pages_in_phys++;
  return 0;
}


int find_index_file_arr(struct proc* p, uint64 address) {
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	1000                	addi	s0,sp,32
  // uint64 va = PGROUNDDOWN(address);
  for (int i=0; i<MAX_PSYC_PAGES; i++) {
    8000273e:	18850513          	addi	a0,a0,392
    80002742:	4481                	li	s1,0
    80002744:	4741                	li	a4,16
    if (p->files_in_swap[i].va == address) {
    80002746:	611c                	ld	a5,0(a0)
    80002748:	00b78e63          	beq	a5,a1,80002764 <find_index_file_arr+0x30>
  for (int i=0; i<MAX_PSYC_PAGES; i++) {
    8000274c:	2485                	addiw	s1,s1,1
    8000274e:	03050513          	addi	a0,a0,48
    80002752:	fee49ae3          	bne	s1,a4,80002746 <find_index_file_arr+0x12>
      printf("DEBUG found index in swapfilearr: %d\n", i);
      return i;
    }
  }
  return -1;
    80002756:	54fd                	li	s1,-1
}
    80002758:	8526                	mv	a0,s1
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6105                	addi	sp,sp,32
    80002762:	8082                	ret
      printf("DEBUG found index in swapfilearr: %d\n", i);
    80002764:	85a6                	mv	a1,s1
    80002766:	00007517          	auipc	a0,0x7
    8000276a:	baa50513          	addi	a0,a0,-1110 # 80009310 <digits+0x2d0>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	e06080e7          	jalr	-506(ra) # 80000574 <printf>
      return i;
    80002776:	b7cd                	j	80002758 <find_index_file_arr+0x24>

0000000080002778 <copy_file>:
  // printf("finishing swap to swapfile\n");
  return 0;
}


int copy_file(struct proc* dest, struct proc* source) {
    80002778:	715d                	addi	sp,sp,-80
    8000277a:	e486                	sd	ra,72(sp)
    8000277c:	e0a2                	sd	s0,64(sp)
    8000277e:	fc26                	sd	s1,56(sp)
    80002780:	f84a                	sd	s2,48(sp)
    80002782:	f44e                	sd	s3,40(sp)
    80002784:	f052                	sd	s4,32(sp)
    80002786:	ec56                	sd	s5,24(sp)
    80002788:	e85a                	sd	s6,16(sp)
    8000278a:	e45e                	sd	s7,8(sp)
    8000278c:	0880                	addi	s0,sp,80
    8000278e:	8aaa                	mv	s5,a0
    80002790:	8a2e                	mv	s4,a1
  //TODO maybe need to add file size
  char* buf = kalloc();
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	340080e7          	jalr	832(ra) # 80000ad2 <kalloc>
    8000279a:	89aa                	mv	s3,a0
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    8000279c:	4481                	li	s1,0
    8000279e:	6b85                	lui	s7,0x1
    800027a0:	6b41                	lui	s6,0x10
    readFromSwapFile(source, buf, i, PGSIZE);
    800027a2:	0004891b          	sext.w	s2,s1
    800027a6:	6685                	lui	a3,0x1
    800027a8:	864a                	mv	a2,s2
    800027aa:	85ce                	mv	a1,s3
    800027ac:	8552                	mv	a0,s4
    800027ae:	00002097          	auipc	ra,0x2
    800027b2:	3d6080e7          	jalr	982(ra) # 80004b84 <readFromSwapFile>
    writeToSwapFile(dest, buf, i, PGSIZE);
    800027b6:	6685                	lui	a3,0x1
    800027b8:	864a                	mv	a2,s2
    800027ba:	85ce                	mv	a1,s3
    800027bc:	8556                	mv	a0,s5
    800027be:	00002097          	auipc	ra,0x2
    800027c2:	3a2080e7          	jalr	930(ra) # 80004b60 <writeToSwapFile>
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    800027c6:	009b84bb          	addw	s1,s7,s1
    800027ca:	fd649ce3          	bne	s1,s6,800027a2 <copy_file+0x2a>
  }
  kfree(buf);
    800027ce:	854e                	mv	a0,s3
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	206080e7          	jalr	518(ra) # 800009d6 <kfree>
  return 0;
}
    800027d8:	4501                	li	a0,0
    800027da:	60a6                	ld	ra,72(sp)
    800027dc:	6406                	ld	s0,64(sp)
    800027de:	74e2                	ld	s1,56(sp)
    800027e0:	7942                	ld	s2,48(sp)
    800027e2:	79a2                	ld	s3,40(sp)
    800027e4:	7a02                	ld	s4,32(sp)
    800027e6:	6ae2                	ld	s5,24(sp)
    800027e8:	6b42                	ld	s6,16(sp)
    800027ea:	6ba2                	ld	s7,8(sp)
    800027ec:	6161                	addi	sp,sp,80
    800027ee:	8082                	ret

00000000800027f0 <fork>:
{
    800027f0:	7139                	addi	sp,sp,-64
    800027f2:	fc06                	sd	ra,56(sp)
    800027f4:	f822                	sd	s0,48(sp)
    800027f6:	f426                	sd	s1,40(sp)
    800027f8:	f04a                	sd	s2,32(sp)
    800027fa:	ec4e                	sd	s3,24(sp)
    800027fc:	e852                	sd	s4,16(sp)
    800027fe:	e456                	sd	s5,8(sp)
    80002800:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002802:	fffff097          	auipc	ra,0xfffff
    80002806:	384080e7          	jalr	900(ra) # 80001b86 <myproc>
    8000280a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000280c:	00000097          	auipc	ra,0x0
    80002810:	d8c080e7          	jalr	-628(ra) # 80002598 <allocproc>
    80002814:	c13d                	beqz	a0,8000287a <fork+0x8a>
    80002816:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002818:	048ab603          	ld	a2,72(s5)
    8000281c:	692c                	ld	a1,80(a0)
    8000281e:	050ab503          	ld	a0,80(s5)
    80002822:	fffff097          	auipc	ra,0xfffff
    80002826:	f0c080e7          	jalr	-244(ra) # 8000172e <uvmcopy>
    8000282a:	06054263          	bltz	a0,8000288e <fork+0x9e>
  np->sz = p->sz;
    8000282e:	048ab783          	ld	a5,72(s5)
    80002832:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002836:	058ab683          	ld	a3,88(s5)
    8000283a:	87b6                	mv	a5,a3
    8000283c:	0589b703          	ld	a4,88(s3)
    80002840:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002844:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002848:	6788                	ld	a0,8(a5)
    8000284a:	6b8c                	ld	a1,16(a5)
    8000284c:	6f90                	ld	a2,24(a5)
    8000284e:	01073023          	sd	a6,0(a4)
    80002852:	e708                	sd	a0,8(a4)
    80002854:	eb0c                	sd	a1,16(a4)
    80002856:	ef10                	sd	a2,24(a4)
    80002858:	02078793          	addi	a5,a5,32
    8000285c:	02070713          	addi	a4,a4,32
    80002860:	fed792e3          	bne	a5,a3,80002844 <fork+0x54>
  np->trapframe->a0 = 0;
    80002864:	0589b783          	ld	a5,88(s3)
    80002868:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000286c:	0d0a8493          	addi	s1,s5,208
    80002870:	0d098913          	addi	s2,s3,208
    80002874:	150a8a13          	addi	s4,s5,336
    80002878:	a089                	j	800028ba <fork+0xca>
    printf("fork allocproc failed\n");
    8000287a:	00007517          	auipc	a0,0x7
    8000287e:	abe50513          	addi	a0,a0,-1346 # 80009338 <digits+0x2f8>
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	cf2080e7          	jalr	-782(ra) # 80000574 <printf>
    return -1;
    8000288a:	54fd                	li	s1,-1
    8000288c:	aa19                	j	800029a2 <fork+0x1b2>
    freeproc(np);
    8000288e:	854e                	mv	a0,s3
    80002890:	00000097          	auipc	ra,0x0
    80002894:	b72080e7          	jalr	-1166(ra) # 80002402 <freeproc>
    release(&np->lock);
    80002898:	854e                	mv	a0,s3
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	3dc080e7          	jalr	988(ra) # 80000c76 <release>
    return -1;
    800028a2:	54fd                	li	s1,-1
    800028a4:	a8fd                	j	800029a2 <fork+0x1b2>
      np->ofile[i] = filedup(p->ofile[i]);
    800028a6:	00003097          	auipc	ra,0x3
    800028aa:	962080e7          	jalr	-1694(ra) # 80005208 <filedup>
    800028ae:	00a93023          	sd	a0,0(s2)
  for(i = 0; i < NOFILE; i++)
    800028b2:	04a1                	addi	s1,s1,8
    800028b4:	0921                	addi	s2,s2,8
    800028b6:	01448563          	beq	s1,s4,800028c0 <fork+0xd0>
    if(p->ofile[i])
    800028ba:	6088                	ld	a0,0(s1)
    800028bc:	f56d                	bnez	a0,800028a6 <fork+0xb6>
    800028be:	bfd5                	j	800028b2 <fork+0xc2>
  np->cwd = idup(p->cwd);
    800028c0:	150ab503          	ld	a0,336(s5)
    800028c4:	00001097          	auipc	ra,0x1
    800028c8:	7a4080e7          	jalr	1956(ra) # 80004068 <idup>
    800028cc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800028d0:	4641                	li	a2,16
    800028d2:	158a8593          	addi	a1,s5,344
    800028d6:	15898513          	addi	a0,s3,344
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	536080e7          	jalr	1334(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    800028e2:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    800028e6:	854e                	mv	a0,s3
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	38e080e7          	jalr	910(ra) # 80000c76 <release>
  if(np->pid > 2){
    800028f0:	0309a703          	lw	a4,48(s3)
    800028f4:	4789                	li	a5,2
    800028f6:	06e7d963          	bge	a5,a4,80002968 <fork+0x178>
    np->num_of_pages = p->num_of_pages;
    800028fa:	6305                	lui	t1,0x1
    800028fc:	006a8733          	add	a4,s5,t1
    80002900:	a7072683          	lw	a3,-1424(a4)
    80002904:	006987b3          	add	a5,s3,t1
    80002908:	a6d7a823          	sw	a3,-1424(a5)
    np->num_of_pages_in_phys = p->num_of_pages_in_phys;
    8000290c:	a7472683          	lw	a3,-1420(a4)
    80002910:	a6d7aa23          	sw	a3,-1420(a5)
      np->index_of_head_p = p->index_of_head_p;
    80002914:	a8072703          	lw	a4,-1408(a4)
    80002918:	a8e7a023          	sw	a4,-1408(a5)
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    8000291c:	770a8793          	addi	a5,s5,1904
    80002920:	77098713          	addi	a4,s3,1904
    80002924:	a7030313          	addi	t1,t1,-1424 # a70 <_entry-0x7ffff590>
    80002928:	9356                	add	t1,t1,s5
      np->files_in_physicalmem[i] = p->files_in_physicalmem[i];
    8000292a:	0007b883          	ld	a7,0(a5)
    8000292e:	0087b803          	ld	a6,8(a5)
    80002932:	6b88                	ld	a0,16(a5)
    80002934:	6f8c                	ld	a1,24(a5)
    80002936:	7390                	ld	a2,32(a5)
    80002938:	7794                	ld	a3,40(a5)
    8000293a:	01173023          	sd	a7,0(a4)
    8000293e:	01073423          	sd	a6,8(a4)
    80002942:	eb08                	sd	a0,16(a4)
    80002944:	ef0c                	sd	a1,24(a4)
    80002946:	f310                	sd	a2,32(a4)
    80002948:	f714                	sd	a3,40(a4)
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    8000294a:	03078793          	addi	a5,a5,48
    8000294e:	03070713          	addi	a4,a4,48
    80002952:	fc679ce3          	bne	a5,t1,8000292a <fork+0x13a>
    if(p->swapFile){
    80002956:	168ab783          	ld	a5,360(s5)
    8000295a:	c799                	beqz	a5,80002968 <fork+0x178>
      copy_file(np, p);
    8000295c:	85d6                	mv	a1,s5
    8000295e:	854e                	mv	a0,s3
    80002960:	00000097          	auipc	ra,0x0
    80002964:	e18080e7          	jalr	-488(ra) # 80002778 <copy_file>
  acquire(&wait_lock);
    80002968:	00010917          	auipc	s2,0x10
    8000296c:	95090913          	addi	s2,s2,-1712 # 800122b8 <wait_lock>
    80002970:	854a                	mv	a0,s2
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	250080e7          	jalr	592(ra) # 80000bc2 <acquire>
  np->parent = p;
    8000297a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000297e:	854a                	mv	a0,s2
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	2f6080e7          	jalr	758(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002988:	854e                	mv	a0,s3
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	238080e7          	jalr	568(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002992:	478d                	li	a5,3
    80002994:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002998:	854e                	mv	a0,s3
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	2dc080e7          	jalr	732(ra) # 80000c76 <release>
}
    800029a2:	8526                	mv	a0,s1
    800029a4:	70e2                	ld	ra,56(sp)
    800029a6:	7442                	ld	s0,48(sp)
    800029a8:	74a2                	ld	s1,40(sp)
    800029aa:	7902                	ld	s2,32(sp)
    800029ac:	69e2                	ld	s3,24(sp)
    800029ae:	6a42                	ld	s4,16(sp)
    800029b0:	6aa2                	ld	s5,8(sp)
    800029b2:	6121                	addi	sp,sp,64
    800029b4:	8082                	ret

00000000800029b6 <insert_from_swap_to_ram>:


int insert_from_swap_to_ram(struct proc* p, char* buff ,uint64 va) {
    800029b6:	7179                	addi	sp,sp,-48
    800029b8:	f406                	sd	ra,40(sp)
    800029ba:	f022                	sd	s0,32(sp)
    800029bc:	ec26                	sd	s1,24(sp)
    800029be:	e84a                	sd	s2,16(sp)
    800029c0:	e44e                	sd	s3,8(sp)
    800029c2:	1800                	addi	s0,sp,48
    800029c4:	84aa                	mv	s1,a0
    800029c6:	89ae                	mv	s3,a1
    800029c8:	8932                	mv	s2,a2
    pte_t* pte = walk(p->pagetable, va, 0); //we want to update the corresponding pte according to our changes
    800029ca:	4601                	li	a2,0
    800029cc:	85ca                	mv	a1,s2
    800029ce:	6928                	ld	a0,80(a0)
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	5d6080e7          	jalr	1494(ra) # 80000fa6 <walk>
    *pte |= PTE_V | PTE_W | PTE_U; //mark that page is in ram, is writable, and is a user page
    *pte &= ~PTE_PG;              //page was moved from swapfile
    800029d8:	611c                	ld	a5,0(a0)
    800029da:	dff7f793          	andi	a5,a5,-513
    800029de:	0157e793          	ori	a5,a5,21
    800029e2:	e11c                	sd	a5,0(a0)
    *pte |= *buff;                //TODO not sure
    800029e4:	0009c703          	lbu	a4,0(s3)
    800029e8:	8fd9                	or	a5,a5,a4
    800029ea:	e11c                	sd	a5,0(a0)

    int swap_ind = find_index_file_arr(p, va);
    800029ec:	85ca                	mv	a1,s2
    800029ee:	8526                	mv	a0,s1
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	d44080e7          	jalr	-700(ra) # 80002734 <find_index_file_arr>
    //if index is -1, according to swap_file_array the file isn't in swapfile
    if (swap_ind == -1) {
    800029f8:	57fd                	li	a5,-1
    800029fa:	0cf50763          	beq	a0,a5,80002ac8 <insert_from_swap_to_ram+0x112>
    800029fe:	892a                	mv	s2,a0
      panic("index in file is -1");
    }
    int offset = p->files_in_swap[swap_ind].offset;
    80002a00:	00151793          	slli	a5,a0,0x1
    80002a04:	97aa                	add	a5,a5,a0
    80002a06:	0792                	slli	a5,a5,0x4
    80002a08:	97a6                	add	a5,a5,s1
    80002a0a:	1907a603          	lw	a2,400(a5)
    if (offset == -1) {
    80002a0e:	57fd                	li	a5,-1
    80002a10:	0cf60463          	beq	a2,a5,80002ad8 <insert_from_swap_to_ram+0x122>
      panic("offset is -1");
    }
    readFromSwapFile(p, buff, offset, PGSIZE);
    80002a14:	6685                	lui	a3,0x1
    80002a16:	85ce                	mv	a1,s3
    80002a18:	8526                	mv	a0,s1
    80002a1a:	00002097          	auipc	ra,0x2
    80002a1e:	16a080e7          	jalr	362(ra) # 80004b84 <readFromSwapFile>

    //copy swap_arr[index] to mem_arr[index] and change swap_arr[index] to available
    int mem_ind = find_free_index(p->files_in_physicalmem);
    80002a22:	77048513          	addi	a0,s1,1904
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	94c080e7          	jalr	-1716(ra) # 80002372 <find_free_index>
    p->files_in_physicalmem[mem_ind].pagetable = p->files_in_swap[swap_ind].pagetable;
    80002a2e:	00151793          	slli	a5,a0,0x1
    80002a32:	97aa                	add	a5,a5,a0
    80002a34:	0792                	slli	a5,a5,0x4
    80002a36:	97a6                	add	a5,a5,s1
    80002a38:	00191713          	slli	a4,s2,0x1
    80002a3c:	012706b3          	add	a3,a4,s2
    80002a40:	0692                	slli	a3,a3,0x4
    80002a42:	96a6                	add	a3,a3,s1
    80002a44:	1786b603          	ld	a2,376(a3) # 1178 <_entry-0x7fffee88>
    80002a48:	76c7bc23          	sd	a2,1912(a5)
    p->files_in_physicalmem[mem_ind].page = p->files_in_swap[swap_ind].page;
    80002a4c:	1806b603          	ld	a2,384(a3)
    80002a50:	78c7b023          	sd	a2,1920(a5)
    p->files_in_physicalmem[mem_ind].va = p->files_in_swap[swap_ind].va;
    80002a54:	1886b683          	ld	a3,392(a3)
    80002a58:	78d7b423          	sd	a3,1928(a5)
    p->files_in_physicalmem[mem_ind].offset = -1;
    80002a5c:	56fd                	li	a3,-1
    80002a5e:	78d7a823          	sw	a3,1936(a5)
    p->files_in_physicalmem[mem_ind].isAvailable = 0;
    80002a62:	7607a823          	sw	zero,1904(a5)
    p->num_of_pages_in_phys++;
    80002a66:	6685                	lui	a3,0x1
    80002a68:	96a6                	add	a3,a3,s1
    80002a6a:	a746a603          	lw	a2,-1420(a3) # a74 <_entry-0x7ffff58c>
    80002a6e:	2605                	addiw	a2,a2,1
    80002a70:	a6c6aa23          	sw	a2,-1420(a3)

    p->files_in_swap[swap_ind].isAvailable = 1;
    80002a74:	974a                	add	a4,a4,s2
    80002a76:	0712                	slli	a4,a4,0x4
    80002a78:	9726                	add	a4,a4,s1
    80002a7a:	4605                	li	a2,1
    80002a7c:	16c72823          	sw	a2,368(a4)
      p->files_in_physicalmem[mem_ind].counter_LAPA = -1; //0xFFFFFF
    #endif
    //in scfifo we need to maintain the field values
    #ifdef SCFIFO
      //head's previous prev is curr's new prev
      p->files_in_physicalmem[mem_ind].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
    80002a80:	a806a603          	lw	a2,-1408(a3)
    80002a84:	00161713          	slli	a4,a2,0x1
    80002a88:	00c706b3          	add	a3,a4,a2
    80002a8c:	0692                	slli	a3,a3,0x4
    80002a8e:	96a6                	add	a3,a3,s1
    80002a90:	7986a683          	lw	a3,1944(a3)
    80002a94:	78d7ac23          	sw	a3,1944(a5)
      //curr is last. curr's next is head
      p->files_in_physicalmem[mem_ind].index_of_next_p = p->index_of_head_p;
    80002a98:	78c7aa23          	sw	a2,1940(a5)
      //head's prev is curr
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = mem_ind;
    80002a9c:	9732                	add	a4,a4,a2
    80002a9e:	0712                	slli	a4,a4,0x4
    80002aa0:	9726                	add	a4,a4,s1
    80002aa2:	78a72c23          	sw	a0,1944(a4)
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = mem_ind;
    80002aa6:	7987a703          	lw	a4,1944(a5)
    80002aaa:	00171793          	slli	a5,a4,0x1
    80002aae:	97ba                	add	a5,a5,a4
    80002ab0:	0792                	slli	a5,a5,0x4
    80002ab2:	94be                	add	s1,s1,a5
    80002ab4:	78a4aa23          	sw	a0,1940(s1)
    #endif
    return 0;
  }
    80002ab8:	4501                	li	a0,0
    80002aba:	70a2                	ld	ra,40(sp)
    80002abc:	7402                	ld	s0,32(sp)
    80002abe:	64e2                	ld	s1,24(sp)
    80002ac0:	6942                	ld	s2,16(sp)
    80002ac2:	69a2                	ld	s3,8(sp)
    80002ac4:	6145                	addi	sp,sp,48
    80002ac6:	8082                	ret
      panic("index in file is -1");
    80002ac8:	00007517          	auipc	a0,0x7
    80002acc:	88850513          	addi	a0,a0,-1912 # 80009350 <digits+0x310>
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	a5a080e7          	jalr	-1446(ra) # 8000052a <panic>
      panic("offset is -1");
    80002ad8:	00007517          	auipc	a0,0x7
    80002adc:	89050513          	addi	a0,a0,-1904 # 80009368 <digits+0x328>
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	a4a080e7          	jalr	-1462(ra) # 8000052a <panic>

0000000080002ae8 <print_page_array>:
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }
}
// #ifdef LAPA
void print_page_array(struct proc* p ,struct page_struct* pagearr) {
    80002ae8:	7139                	addi	sp,sp,-64
    80002aea:	fc06                	sd	ra,56(sp)
    80002aec:	f822                	sd	s0,48(sp)
    80002aee:	f426                	sd	s1,40(sp)
    80002af0:	f04a                	sd	s2,32(sp)
    80002af2:	ec4e                	sd	s3,24(sp)
    80002af4:	e852                	sd	s4,16(sp)
    80002af6:	e456                	sd	s5,8(sp)
    80002af8:	0080                	addi	s0,sp,64
    80002afa:	89aa                	mv	s3,a0
    80002afc:	84ae                	mv	s1,a1
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002afe:	4901                	li	s2,0
    struct page_struct curr = pagearr[i];
    printf("pid: %d, index: %d, page: %d, isAvailable: %d, va: %d, offset: %d, counter_LAPA: \n",
    80002b00:	00007a97          	auipc	s5,0x7
    80002b04:	878a8a93          	addi	s5,s5,-1928 # 80009378 <digits+0x338>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002b08:	4a41                	li	s4,16
    printf("pid: %d, index: %d, page: %d, isAvailable: %d, va: %d, offset: %d, counter_LAPA: \n",
    80002b0a:	0204a803          	lw	a6,32(s1)
    80002b0e:	6c9c                	ld	a5,24(s1)
    80002b10:	4098                	lw	a4,0(s1)
    80002b12:	6894                	ld	a3,16(s1)
    80002b14:	864a                	mv	a2,s2
    80002b16:	0309a583          	lw	a1,48(s3)
    80002b1a:	8556                	mv	a0,s5
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a58080e7          	jalr	-1448(ra) # 80000574 <printf>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002b24:	2905                	addiw	s2,s2,1
    80002b26:	03048493          	addi	s1,s1,48
    80002b2a:	ff4910e3          	bne	s2,s4,80002b0a <print_page_array+0x22>
    p->pid, i, curr.page, curr.isAvailable, curr.va, curr.offset);
  }
}
    80002b2e:	70e2                	ld	ra,56(sp)
    80002b30:	7442                	ld	s0,48(sp)
    80002b32:	74a2                	ld	s1,40(sp)
    80002b34:	7902                	ld	s2,32(sp)
    80002b36:	69e2                	ld	s3,24(sp)
    80002b38:	6a42                	ld	s4,16(sp)
    80002b3a:	6aa2                	ld	s5,8(sp)
    80002b3c:	6121                	addi	sp,sp,64
    80002b3e:	8082                	ret

0000000080002b40 <add_page_to_phys>:
int add_page_to_phys(struct proc* p, pagetable_t pagetable, uint64 va) {
    80002b40:	7139                	addi	sp,sp,-64
    80002b42:	fc06                	sd	ra,56(sp)
    80002b44:	f822                	sd	s0,48(sp)
    80002b46:	f426                	sd	s1,40(sp)
    80002b48:	f04a                	sd	s2,32(sp)
    80002b4a:	ec4e                	sd	s3,24(sp)
    80002b4c:	e852                	sd	s4,16(sp)
    80002b4e:	e456                	sd	s5,8(sp)
    80002b50:	e05a                	sd	s6,0(sp)
    80002b52:	0080                	addi	s0,sp,64
    80002b54:	84aa                	mv	s1,a0
    80002b56:	8aae                	mv	s5,a1
    80002b58:	8a32                	mv	s4,a2
  int index = find_free_index(p->files_in_physicalmem);
    80002b5a:	77050b13          	addi	s6,a0,1904
    80002b5e:	855a                	mv	a0,s6
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	812080e7          	jalr	-2030(ra) # 80002372 <find_free_index>
  if (index == -1){
    80002b68:	57fd                	li	a5,-1
    80002b6a:	0cf50563          	beq	a0,a5,80002c34 <add_page_to_phys+0xf4>
    80002b6e:	89aa                	mv	s3,a0
  p->files_in_physicalmem[index].isAvailable = 0;
    80002b70:	00151913          	slli	s2,a0,0x1
    80002b74:	992a                	add	s2,s2,a0
    80002b76:	0912                	slli	s2,s2,0x4
    80002b78:	9926                	add	s2,s2,s1
    80002b7a:	76092823          	sw	zero,1904(s2)
  p->files_in_physicalmem[index].pagetable = pagetable;
    80002b7e:	77593c23          	sd	s5,1912(s2)
  p->files_in_physicalmem[index].page = walk(pagetable, va, 0);
    80002b82:	4601                	li	a2,0
    80002b84:	85d2                	mv	a1,s4
    80002b86:	8556                	mv	a0,s5
    80002b88:	ffffe097          	auipc	ra,0xffffe
    80002b8c:	41e080e7          	jalr	1054(ra) # 80000fa6 <walk>
    80002b90:	85aa                	mv	a1,a0
    80002b92:	78a93023          	sd	a0,1920(s2)
  printf("DEBUG p->files_in_physicalmem[index].page: %d\n", p->files_in_physicalmem[index].page);
    80002b96:	00007517          	auipc	a0,0x7
    80002b9a:	85250513          	addi	a0,a0,-1966 # 800093e8 <digits+0x3a8>
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	9d6080e7          	jalr	-1578(ra) # 80000574 <printf>
  p->files_in_physicalmem[index].va = va;
    80002ba6:	79493423          	sd	s4,1928(s2)
  p->files_in_physicalmem[index].offset = -1;   //offset is a field for files in swap_file only
    80002baa:	5a7d                	li	s4,-1
    80002bac:	79492823          	sw	s4,1936(s2)
  print_page_array(p, p->files_in_physicalmem);
    80002bb0:	85da                	mv	a1,s6
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	f34080e7          	jalr	-204(ra) # 80002ae8 <print_page_array>
    if(p->index_of_head_p == -1){
    80002bbc:	6785                	lui	a5,0x1
    80002bbe:	97a6                	add	a5,a5,s1
    80002bc0:	a807a683          	lw	a3,-1408(a5) # a80 <_entry-0x7ffff580>
    80002bc4:	09468063          	beq	a3,s4,80002c44 <add_page_to_phys+0x104>
      p->files_in_physicalmem[index].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
    80002bc8:	00169713          	slli	a4,a3,0x1
    80002bcc:	00d707b3          	add	a5,a4,a3
    80002bd0:	0792                	slli	a5,a5,0x4
    80002bd2:	97a6                	add	a5,a5,s1
    80002bd4:	7987a603          	lw	a2,1944(a5)
    80002bd8:	00199793          	slli	a5,s3,0x1
    80002bdc:	97ce                	add	a5,a5,s3
    80002bde:	0792                	slli	a5,a5,0x4
    80002be0:	97a6                	add	a5,a5,s1
    80002be2:	78c7ac23          	sw	a2,1944(a5)
      p->files_in_physicalmem[index].index_of_next_p = p->index_of_head_p;
    80002be6:	78d7aa23          	sw	a3,1940(a5)
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = index;
    80002bea:	9736                	add	a4,a4,a3
    80002bec:	0712                	slli	a4,a4,0x4
    80002bee:	9726                	add	a4,a4,s1
    80002bf0:	79372c23          	sw	s3,1944(a4)
      p->files_in_physicalmem[p->files_in_physicalmem[index].index_of_prev_p].index_of_next_p = index;
    80002bf4:	7987a703          	lw	a4,1944(a5)
    80002bf8:	00171793          	slli	a5,a4,0x1
    80002bfc:	97ba                	add	a5,a5,a4
    80002bfe:	0792                	slli	a5,a5,0x4
    80002c00:	97a6                	add	a5,a5,s1
    80002c02:	7937aa23          	sw	s3,1940(a5)
  p->num_of_pages++;
    80002c06:	6505                	lui	a0,0x1
    80002c08:	94aa                	add	s1,s1,a0
    80002c0a:	a704a783          	lw	a5,-1424(s1)
    80002c0e:	2785                	addiw	a5,a5,1
    80002c10:	a6f4a823          	sw	a5,-1424(s1)
  p->num_of_pages_in_phys++;
    80002c14:	a744a783          	lw	a5,-1420(s1)
    80002c18:	2785                	addiw	a5,a5,1
    80002c1a:	a6f4aa23          	sw	a5,-1420(s1)
}
    80002c1e:	4501                	li	a0,0
    80002c20:	70e2                	ld	ra,56(sp)
    80002c22:	7442                	ld	s0,48(sp)
    80002c24:	74a2                	ld	s1,40(sp)
    80002c26:	7902                	ld	s2,32(sp)
    80002c28:	69e2                	ld	s3,24(sp)
    80002c2a:	6a42                	ld	s4,16(sp)
    80002c2c:	6aa2                	ld	s5,8(sp)
    80002c2e:	6b02                	ld	s6,0(sp)
    80002c30:	6121                	addi	sp,sp,64
    80002c32:	8082                	ret
    panic("no free index in ram\n");
    80002c34:	00006517          	auipc	a0,0x6
    80002c38:	79c50513          	addi	a0,a0,1948 # 800093d0 <digits+0x390>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	8ee080e7          	jalr	-1810(ra) # 8000052a <panic>
      p->index_of_head_p = index;
    80002c44:	6785                	lui	a5,0x1
    80002c46:	97a6                	add	a5,a5,s1
    80002c48:	a937a023          	sw	s3,-1408(a5) # a80 <_entry-0x7ffff580>
      p->files_in_physicalmem[index].index_of_prev_p = index;
    80002c4c:	79392c23          	sw	s3,1944(s2)
      p->files_in_physicalmem[index].index_of_next_p = index;
    80002c50:	79392a23          	sw	s3,1940(s2)
    80002c54:	bf4d                	j	80002c06 <add_page_to_phys+0xc6>

0000000080002c56 <calc_ndx_for_scfifo>:
  return selected;
}
#endif

#ifdef SCFIFO
int calc_ndx_for_scfifo(struct proc *p){
    80002c56:	1141                	addi	sp,sp,-16
    80002c58:	e422                	sd	s0,8(sp)
    80002c5a:	0800                	addi	s0,sp,16
  struct page_struct *ram_pages = p->files_in_physicalmem;
    80002c5c:	77050593          	addi	a1,a0,1904
  int toReturn = -1;
  int head_ndx = p->index_of_head_p;
    80002c60:	6785                	lui	a5,0x1
    80002c62:	953e                	add	a0,a0,a5
    80002c64:	a8052803          	lw	a6,-1408(a0)
  int curr_ndx = p->index_of_head_p;
    80002c68:	8542                	mv	a0,a6
  struct page_struct *curr_page;
  int found = 0;
  while(found != 1){
    curr_page = &ram_pages[curr_ndx];
    80002c6a:	00151793          	slli	a5,a0,0x1
    80002c6e:	97aa                	add	a5,a5,a0
    80002c70:	0792                	slli	a5,a5,0x4
    80002c72:	97ae                	add	a5,a5,a1
    //if page is not in physical memory, something's wrong
    // if()
    //if the page was accessed, give it a second chance
    if(*(curr_page->page) & PTE_A){
    80002c74:	6b94                	ld	a3,16(a5)
    80002c76:	6298                	ld	a4,0(a3)
    80002c78:	04077613          	andi	a2,a4,64
    80002c7c:	ca01                	beqz	a2,80002c8c <calc_ndx_for_scfifo+0x36>
      *(curr_page->page) &= ~PTE_A;
    80002c7e:	fbf77713          	andi	a4,a4,-65
    80002c82:	e298                	sd	a4,0(a3)
      curr_ndx = curr_page->index_of_next_p;
    80002c84:	53c8                	lw	a0,36(a5)
      found = 1;
      toReturn = curr_ndx;
    }
    //the oldest page that wasn't accessed should be removed
    //if we went through all pages, finish loop
    if (curr_ndx == head_ndx){
    80002c86:	fea812e3          	bne	a6,a0,80002c6a <calc_ndx_for_scfifo+0x14>
      found = 1;
      toReturn = head_ndx;
    80002c8a:	8542                	mv	a0,a6
    }
  }
  return toReturn;
}
    80002c8c:	6422                	ld	s0,8(sp)
    80002c8e:	0141                	addi	sp,sp,16
    80002c90:	8082                	ret

0000000080002c92 <calc_ndx_for_ramarr_removal>:
int calc_ndx_for_ramarr_removal(struct proc *p){
    80002c92:	1141                	addi	sp,sp,-16
    80002c94:	e406                	sd	ra,8(sp)
    80002c96:	e022                	sd	s0,0(sp)
    80002c98:	0800                	addi	s0,sp,16
    ndx = calc_ndx_for_scfifo(p);
    80002c9a:	00000097          	auipc	ra,0x0
    80002c9e:	fbc080e7          	jalr	-68(ra) # 80002c56 <calc_ndx_for_scfifo>
    if(ndx == -1){
    80002ca2:	57fd                	li	a5,-1
    80002ca4:	00f50663          	beq	a0,a5,80002cb0 <calc_ndx_for_ramarr_removal+0x1e>
}
    80002ca8:	60a2                	ld	ra,8(sp)
    80002caa:	6402                	ld	s0,0(sp)
    80002cac:	0141                	addi	sp,sp,16
    80002cae:	8082                	ret
      panic("scfifo ndx wasn't found");
    80002cb0:	00006517          	auipc	a0,0x6
    80002cb4:	76850513          	addi	a0,a0,1896 # 80009418 <digits+0x3d8>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	872080e7          	jalr	-1934(ra) # 8000052a <panic>

0000000080002cc0 <swap_to_swapFile>:
int swap_to_swapFile(struct proc* p) {
    80002cc0:	711d                	addi	sp,sp,-96
    80002cc2:	ec86                	sd	ra,88(sp)
    80002cc4:	e8a2                	sd	s0,80(sp)
    80002cc6:	e4a6                	sd	s1,72(sp)
    80002cc8:	e0ca                	sd	s2,64(sp)
    80002cca:	fc4e                	sd	s3,56(sp)
    80002ccc:	f852                	sd	s4,48(sp)
    80002cce:	f456                	sd	s5,40(sp)
    80002cd0:	f05a                	sd	s6,32(sp)
    80002cd2:	ec5e                	sd	s7,24(sp)
    80002cd4:	e862                	sd	s8,16(sp)
    80002cd6:	e466                	sd	s9,8(sp)
    80002cd8:	e06a                	sd	s10,0(sp)
    80002cda:	1080                	addi	s0,sp,96
    80002cdc:	84aa                	mv	s1,a0
  int mem_ind = calc_ndx_for_ramarr_removal(p);  //index of page to remove from ram array
    80002cde:	00000097          	auipc	ra,0x0
    80002ce2:	fb4080e7          	jalr	-76(ra) # 80002c92 <calc_ndx_for_ramarr_removal>
    80002ce6:	89aa                	mv	s3,a0
  int swap_ind = find_free_index(p->files_in_swap);
    80002ce8:	17048513          	addi	a0,s1,368
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	686080e7          	jalr	1670(ra) # 80002372 <find_free_index>
    80002cf4:	8b2a                	mv	s6,a0
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[mem_ind].index_of_prev_p;
    80002cf6:	00199713          	slli	a4,s3,0x1
    80002cfa:	974e                	add	a4,a4,s3
    80002cfc:	0712                	slli	a4,a4,0x4
    80002cfe:	9726                	add	a4,a4,s1
    80002d00:	79472683          	lw	a3,1940(a4)
    80002d04:	79872603          	lw	a2,1944(a4)
    80002d08:	00169713          	slli	a4,a3,0x1
    80002d0c:	9736                	add	a4,a4,a3
    80002d0e:	0712                	slli	a4,a4,0x4
    80002d10:	9726                	add	a4,a4,s1
    80002d12:	78c72c23          	sw	a2,1944(a4)
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[mem_ind].index_of_next_p;
    80002d16:	00161793          	slli	a5,a2,0x1
    80002d1a:	97b2                	add	a5,a5,a2
    80002d1c:	0792                	slli	a5,a5,0x4
    80002d1e:	97a6                	add	a5,a5,s1
    80002d20:	78d7aa23          	sw	a3,1940(a5) # 1794 <_entry-0x7fffe86c>
    if(p->index_of_head_p == mem_ind){
    80002d24:	6785                	lui	a5,0x1
    80002d26:	97a6                	add	a5,a5,s1
    80002d28:	a807a783          	lw	a5,-1408(a5) # a80 <_entry-0x7ffff580>
    80002d2c:	0d378263          	beq	a5,s3,80002df0 <swap_to_swapFile+0x130>
    p->files_in_swap[swap_ind].index_of_prev_p = -1;
    80002d30:	001b1b93          	slli	s7,s6,0x1
    80002d34:	016b8933          	add	s2,s7,s6
    80002d38:	0912                	slli	s2,s2,0x4
    80002d3a:	9926                	add	s2,s2,s1
    80002d3c:	57fd                	li	a5,-1
    80002d3e:	18f92c23          	sw	a5,408(s2)
    p->files_in_swap[swap_ind].index_of_next_p = -1;
    80002d42:	18f92a23          	sw	a5,404(s2)
  pagetable_t pagetable_to_swap_file = p->files_in_physicalmem[mem_ind].pagetable;
    80002d46:	00199a13          	slli	s4,s3,0x1
    80002d4a:	013a0ab3          	add	s5,s4,s3
    80002d4e:	0a92                	slli	s5,s5,0x4
    80002d50:	9aa6                	add	s5,s5,s1
    80002d52:	778abd03          	ld	s10,1912(s5)
  uint64 va_to_swap_file = p->files_in_physicalmem[mem_ind].va;
    80002d56:	788abc83          	ld	s9,1928(s5)
  uint64 pa = walkaddr(pagetable_to_swap_file, va_to_swap_file);
    80002d5a:	85e6                	mv	a1,s9
    80002d5c:	856a                	mv	a0,s10
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	2ee080e7          	jalr	750(ra) # 8000104c <walkaddr>
    80002d66:	85aa                	mv	a1,a0
  int offset = swap_ind*PGSIZE; //fine offset we want to insert to
    80002d68:	00cb1c1b          	slliw	s8,s6,0xc
  writeToSwapFile(p, (char *)pa, offset, PGSIZE);
    80002d6c:	6685                	lui	a3,0x1
    80002d6e:	000c061b          	sext.w	a2,s8
    80002d72:	8526                	mv	a0,s1
    80002d74:	00002097          	auipc	ra,0x2
    80002d78:	dec080e7          	jalr	-532(ra) # 80004b60 <writeToSwapFile>
  p->files_in_swap[swap_ind].pagetable = pagetable_to_swap_file;
    80002d7c:	17a93c23          	sd	s10,376(s2)
  p->files_in_swap[swap_ind].va = va_to_swap_file;
    80002d80:	19993423          	sd	s9,392(s2)
  p->files_in_swap[swap_ind].isAvailable = 0;
    80002d84:	16092823          	sw	zero,368(s2)
  p->files_in_swap[swap_ind].offset = offset;
    80002d88:	19892823          	sw	s8,400(s2)
  p->files_in_swap[swap_ind].page = p->files_in_physicalmem[mem_ind].page;
    80002d8c:	780ab903          	ld	s2,1920(s5)
    80002d90:	016b87b3          	add	a5,s7,s6
    80002d94:	0792                	slli	a5,a5,0x4
    80002d96:	97a6                	add	a5,a5,s1
    80002d98:	1927b023          	sd	s2,384(a5)
  char *pa_tofree = (char *)PTE2PA(*pte);
    80002d9c:	00093503          	ld	a0,0(s2)
    80002da0:	8129                	srli	a0,a0,0xa
  kfree(pa_tofree);
    80002da2:	0532                	slli	a0,a0,0xc
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	c32080e7          	jalr	-974(ra) # 800009d6 <kfree>
  (*pte) &= ~PTE_V;
    80002dac:	00093783          	ld	a5,0(s2)
    80002db0:	9bf9                	andi	a5,a5,-2
  (*pte) |= PTE_PG;
    80002db2:	2007e793          	ori	a5,a5,512
    80002db6:	00f93023          	sd	a5,0(s2)
  asm volatile("sfence.vma zero, zero");
    80002dba:	12000073          	sfence.vma
  p->files_in_physicalmem[mem_ind].isAvailable = 1;
    80002dbe:	4785                	li	a5,1
    80002dc0:	76faa823          	sw	a5,1904(s5)
  p->num_of_pages_in_phys--;
    80002dc4:	6505                	lui	a0,0x1
    80002dc6:	94aa                	add	s1,s1,a0
    80002dc8:	a744a783          	lw	a5,-1420(s1)
    80002dcc:	37fd                	addiw	a5,a5,-1
    80002dce:	a6f4aa23          	sw	a5,-1420(s1)
}
    80002dd2:	4501                	li	a0,0
    80002dd4:	60e6                	ld	ra,88(sp)
    80002dd6:	6446                	ld	s0,80(sp)
    80002dd8:	64a6                	ld	s1,72(sp)
    80002dda:	6906                	ld	s2,64(sp)
    80002ddc:	79e2                	ld	s3,56(sp)
    80002dde:	7a42                	ld	s4,48(sp)
    80002de0:	7aa2                	ld	s5,40(sp)
    80002de2:	7b02                	ld	s6,32(sp)
    80002de4:	6be2                	ld	s7,24(sp)
    80002de6:	6c42                	ld	s8,16(sp)
    80002de8:	6ca2                	ld	s9,8(sp)
    80002dea:	6d02                	ld	s10,0(sp)
    80002dec:	6125                	addi	sp,sp,96
    80002dee:	8082                	ret
      if(p->index_of_head_p == p->files_in_physicalmem[mem_ind].index_of_next_p){
    80002df0:	00199793          	slli	a5,s3,0x1
    80002df4:	97ce                	add	a5,a5,s3
    80002df6:	0792                	slli	a5,a5,0x4
    80002df8:	97a6                	add	a5,a5,s1
    80002dfa:	7947a703          	lw	a4,1940(a5)
    80002dfe:	03370163          	beq	a4,s3,80002e20 <swap_to_swapFile+0x160>
    80002e02:	6785                	lui	a5,0x1
    80002e04:	97a6                	add	a5,a5,s1
    80002e06:	a8e7a023          	sw	a4,-1408(a5) # a80 <_entry-0x7ffff580>
      p->files_in_physicalmem[mem_ind].index_of_prev_p = -1;
    80002e0a:	00199793          	slli	a5,s3,0x1
    80002e0e:	97ce                	add	a5,a5,s3
    80002e10:	0792                	slli	a5,a5,0x4
    80002e12:	97a6                	add	a5,a5,s1
    80002e14:	577d                	li	a4,-1
    80002e16:	78e7ac23          	sw	a4,1944(a5)
      p->files_in_physicalmem[mem_ind].index_of_next_p = -1;
    80002e1a:	78e7aa23          	sw	a4,1940(a5)
    80002e1e:	bf09                	j	80002d30 <swap_to_swapFile+0x70>
        p->index_of_head_p = -1;
    80002e20:	577d                	li	a4,-1
    80002e22:	b7c5                	j	80002e02 <swap_to_swapFile+0x142>

0000000080002e24 <swap_to_memory>:
int swap_to_memory(struct proc* p, uint64 address) {
    80002e24:	7179                	addi	sp,sp,-48
    80002e26:	f406                	sd	ra,40(sp)
    80002e28:	f022                	sd	s0,32(sp)
    80002e2a:	ec26                	sd	s1,24(sp)
    80002e2c:	e84a                	sd	s2,16(sp)
    80002e2e:	e44e                	sd	s3,8(sp)
    80002e30:	1800                	addi	s0,sp,48
    80002e32:	89aa                	mv	s3,a0
    80002e34:	84ae                	mv	s1,a1
  printf("swapping to memory\n");
    80002e36:	00006517          	auipc	a0,0x6
    80002e3a:	5fa50513          	addi	a0,a0,1530 # 80009430 <digits+0x3f0>
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	736080e7          	jalr	1846(ra) # 80000574 <printf>
  uint64 va = PGROUNDDOWN(address);
    80002e46:	75fd                	lui	a1,0xfffff
    80002e48:	8ced                	and	s1,s1,a1
  if ((buff = kalloc()) == 0) {
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	c88080e7          	jalr	-888(ra) # 80000ad2 <kalloc>
    80002e52:	cd1d                	beqz	a0,80002e90 <swap_to_memory+0x6c>
    80002e54:	892a                	mv	s2,a0
  if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80002e56:	6785                	lui	a5,0x1
    80002e58:	97ce                	add	a5,a5,s3
    80002e5a:	a747a703          	lw	a4,-1420(a5) # a74 <_entry-0x7ffff58c>
    80002e5e:	47bd                	li	a5,15
    80002e60:	04e7c063          	blt	a5,a4,80002ea0 <swap_to_memory+0x7c>
    insert_from_swap_to_ram(p, buff, va);
    80002e64:	8626                	mv	a2,s1
    80002e66:	85aa                	mv	a1,a0
    80002e68:	854e                	mv	a0,s3
    80002e6a:	00000097          	auipc	ra,0x0
    80002e6e:	b4c080e7          	jalr	-1204(ra) # 800029b6 <insert_from_swap_to_ram>
    memmove((void*)va, buff, PGSIZE); //copy page to va TODO check im not sure
    80002e72:	6605                	lui	a2,0x1
    80002e74:	85ca                	mv	a1,s2
    80002e76:	8526                	mv	a0,s1
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	ea2080e7          	jalr	-350(ra) # 80000d1a <memmove>
}
    80002e80:	4501                	li	a0,0
    80002e82:	70a2                	ld	ra,40(sp)
    80002e84:	7402                	ld	s0,32(sp)
    80002e86:	64e2                	ld	s1,24(sp)
    80002e88:	6942                	ld	s2,16(sp)
    80002e8a:	69a2                	ld	s3,8(sp)
    80002e8c:	6145                	addi	sp,sp,48
    80002e8e:	8082                	ret
    panic("kalloc failed");
    80002e90:	00006517          	auipc	a0,0x6
    80002e94:	5b850513          	addi	a0,a0,1464 # 80009448 <digits+0x408>
    80002e98:	ffffd097          	auipc	ra,0xffffd
    80002e9c:	692080e7          	jalr	1682(ra) # 8000052a <panic>
    printf("swap_to_memory, calling to swap to swapfile\n");
    80002ea0:	00006517          	auipc	a0,0x6
    80002ea4:	5b850513          	addi	a0,a0,1464 # 80009458 <digits+0x418>
    80002ea8:	ffffd097          	auipc	ra,0xffffd
    80002eac:	6cc080e7          	jalr	1740(ra) # 80000574 <printf>
    swap_to_swapFile(p);      //if there's no available place in ram, make some
    80002eb0:	854e                	mv	a0,s3
    80002eb2:	00000097          	auipc	ra,0x0
    80002eb6:	e0e080e7          	jalr	-498(ra) # 80002cc0 <swap_to_swapFile>
    insert_from_swap_to_ram(p, buff, va); //move from swapfile the page we wanted to insert to ram
    80002eba:	8626                	mv	a2,s1
    80002ebc:	85ca                	mv	a1,s2
    80002ebe:	854e                	mv	a0,s3
    80002ec0:	00000097          	auipc	ra,0x0
    80002ec4:	af6080e7          	jalr	-1290(ra) # 800029b6 <insert_from_swap_to_ram>
    memmove((void*)va, buff, PGSIZE); //copy page to va TODO check im not sure
    80002ec8:	6605                	lui	a2,0x1
    80002eca:	85ca                	mv	a1,s2
    80002ecc:	8526                	mv	a0,s1
    80002ece:	ffffe097          	auipc	ra,0xffffe
    80002ed2:	e4c080e7          	jalr	-436(ra) # 80000d1a <memmove>
    80002ed6:	b76d                	j	80002e80 <swap_to_memory+0x5c>

0000000080002ed8 <hanle_page_fault>:
void hanle_page_fault(struct proc* p) {
    80002ed8:	1101                	addi	sp,sp,-32
    80002eda:	ec06                	sd	ra,24(sp)
    80002edc:	e822                	sd	s0,16(sp)
    80002ede:	e426                	sd	s1,8(sp)
    80002ee0:	e04a                	sd	s2,0(sp)
    80002ee2:	1000                	addi	s0,sp,32
    80002ee4:	84aa                	mv	s1,a0
  printf("handle page faulr files in swap:\n");
    80002ee6:	00006517          	auipc	a0,0x6
    80002eea:	5a250513          	addi	a0,a0,1442 # 80009488 <digits+0x448>
    80002eee:	ffffd097          	auipc	ra,0xffffd
    80002ef2:	686080e7          	jalr	1670(ra) # 80000574 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ef6:	14302973          	csrr	s2,stval
  printf("fault address: %d\n", va);
    80002efa:	85ca                	mv	a1,s2
    80002efc:	00006517          	auipc	a0,0x6
    80002f00:	5b450513          	addi	a0,a0,1460 # 800094b0 <digits+0x470>
    80002f04:	ffffd097          	auipc	ra,0xffffd
    80002f08:	670080e7          	jalr	1648(ra) # 80000574 <printf>
  pte_t* pte = walk(p->pagetable, va, 0); //identify the page
    80002f0c:	4601                	li	a2,0
    80002f0e:	85ca                	mv	a1,s2
    80002f10:	68a8                	ld	a0,80(s1)
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	094080e7          	jalr	148(ra) # 80000fa6 <walk>
  if (*pte & PTE_PG) {
    80002f1a:	611c                	ld	a5,0(a0)
    80002f1c:	2007f793          	andi	a5,a5,512
    80002f20:	cf89                	beqz	a5,80002f3a <hanle_page_fault+0x62>
    swap_to_memory(p, va);
    80002f22:	85ca                	mv	a1,s2
    80002f24:	8526                	mv	a0,s1
    80002f26:	00000097          	auipc	ra,0x0
    80002f2a:	efe080e7          	jalr	-258(ra) # 80002e24 <swap_to_memory>
}
    80002f2e:	60e2                	ld	ra,24(sp)
    80002f30:	6442                	ld	s0,16(sp)
    80002f32:	64a2                	ld	s1,8(sp)
    80002f34:	6902                	ld	s2,0(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f3a:	142025f3          	csrr	a1,scause
    printf("usertrap1(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f3e:	5890                	lw	a2,48(s1)
    80002f40:	00006517          	auipc	a0,0x6
    80002f44:	58850513          	addi	a0,a0,1416 # 800094c8 <digits+0x488>
    80002f48:	ffffd097          	auipc	ra,0xffffd
    80002f4c:	62c080e7          	jalr	1580(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f50:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f54:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f58:	00006517          	auipc	a0,0x6
    80002f5c:	5a050513          	addi	a0,a0,1440 # 800094f8 <digits+0x4b8>
    80002f60:	ffffd097          	auipc	ra,0xffffd
    80002f64:	614080e7          	jalr	1556(ra) # 80000574 <printf>
    p->killed = 1;
    80002f68:	4785                	li	a5,1
    80002f6a:	d49c                	sw	a5,40(s1)
}
    80002f6c:	b7c9                	j	80002f2e <hanle_page_fault+0x56>

0000000080002f6e <printmem>:
}
#endif

// #endif

int printmem(void){
    80002f6e:	1101                	addi	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	e426                	sd	s1,8(sp)
    80002f76:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	c0e080e7          	jalr	-1010(ra) # 80001b86 <myproc>
  if(p->pid > 2){
    80002f80:	5918                	lw	a4,48(a0)
    80002f82:	4789                	li	a5,2
    80002f84:	04e7d763          	bge	a5,a4,80002fd2 <printmem+0x64>
    80002f88:	84aa                	mv	s1,a0
    printf("files in ram array:\n");
    80002f8a:	00006517          	auipc	a0,0x6
    80002f8e:	58e50513          	addi	a0,a0,1422 # 80009518 <digits+0x4d8>
    80002f92:	ffffd097          	auipc	ra,0xffffd
    80002f96:	5e2080e7          	jalr	1506(ra) # 80000574 <printf>
    print_page_array(p, p->files_in_physicalmem);
    80002f9a:	77048593          	addi	a1,s1,1904
    80002f9e:	8526                	mv	a0,s1
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	b48080e7          	jalr	-1208(ra) # 80002ae8 <print_page_array>
    printf("files in swap array:\n");
    80002fa8:	00006517          	auipc	a0,0x6
    80002fac:	58850513          	addi	a0,a0,1416 # 80009530 <digits+0x4f0>
    80002fb0:	ffffd097          	auipc	ra,0xffffd
    80002fb4:	5c4080e7          	jalr	1476(ra) # 80000574 <printf>
    print_page_array(p, p->files_in_swap);
    80002fb8:	17048593          	addi	a1,s1,368
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	b2a080e7          	jalr	-1238(ra) # 80002ae8 <print_page_array>
  }
  else{
    printf("pid < 2\n");
  }
  return 1;
    80002fc6:	4505                	li	a0,1
    80002fc8:	60e2                	ld	ra,24(sp)
    80002fca:	6442                	ld	s0,16(sp)
    80002fcc:	64a2                	ld	s1,8(sp)
    80002fce:	6105                	addi	sp,sp,32
    80002fd0:	8082                	ret
    printf("pid < 2\n");
    80002fd2:	00006517          	auipc	a0,0x6
    80002fd6:	57650513          	addi	a0,a0,1398 # 80009548 <digits+0x508>
    80002fda:	ffffd097          	auipc	ra,0xffffd
    80002fde:	59a080e7          	jalr	1434(ra) # 80000574 <printf>
    80002fe2:	b7d5                	j	80002fc6 <printmem+0x58>

0000000080002fe4 <swtch>:
    80002fe4:	00153023          	sd	ra,0(a0)
    80002fe8:	00253423          	sd	sp,8(a0)
    80002fec:	e900                	sd	s0,16(a0)
    80002fee:	ed04                	sd	s1,24(a0)
    80002ff0:	03253023          	sd	s2,32(a0)
    80002ff4:	03353423          	sd	s3,40(a0)
    80002ff8:	03453823          	sd	s4,48(a0)
    80002ffc:	03553c23          	sd	s5,56(a0)
    80003000:	05653023          	sd	s6,64(a0)
    80003004:	05753423          	sd	s7,72(a0)
    80003008:	05853823          	sd	s8,80(a0)
    8000300c:	05953c23          	sd	s9,88(a0)
    80003010:	07a53023          	sd	s10,96(a0)
    80003014:	07b53423          	sd	s11,104(a0)
    80003018:	0005b083          	ld	ra,0(a1) # fffffffffffff000 <end+0xffffffff7ffb4000>
    8000301c:	0085b103          	ld	sp,8(a1)
    80003020:	6980                	ld	s0,16(a1)
    80003022:	6d84                	ld	s1,24(a1)
    80003024:	0205b903          	ld	s2,32(a1)
    80003028:	0285b983          	ld	s3,40(a1)
    8000302c:	0305ba03          	ld	s4,48(a1)
    80003030:	0385ba83          	ld	s5,56(a1)
    80003034:	0405bb03          	ld	s6,64(a1)
    80003038:	0485bb83          	ld	s7,72(a1)
    8000303c:	0505bc03          	ld	s8,80(a1)
    80003040:	0585bc83          	ld	s9,88(a1)
    80003044:	0605bd03          	ld	s10,96(a1)
    80003048:	0685bd83          	ld	s11,104(a1)
    8000304c:	8082                	ret

000000008000304e <trapinit>:
extern int devintr();
extern void hanle_page_fault(struct proc* p);

void
trapinit(void)
{
    8000304e:	1141                	addi	sp,sp,-16
    80003050:	e406                	sd	ra,8(sp)
    80003052:	e022                	sd	s0,0(sp)
    80003054:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003056:	00006597          	auipc	a1,0x6
    8000305a:	55a58593          	addi	a1,a1,1370 # 800095b0 <states.0+0x30>
    8000305e:	0003a517          	auipc	a0,0x3a
    80003062:	87250513          	addi	a0,a0,-1934 # 8003c8d0 <tickslock>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	acc080e7          	jalr	-1332(ra) # 80000b32 <initlock>
}
    8000306e:	60a2                	ld	ra,8(sp)
    80003070:	6402                	ld	s0,0(sp)
    80003072:	0141                	addi	sp,sp,16
    80003074:	8082                	ret

0000000080003076 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003076:	1141                	addi	sp,sp,-16
    80003078:	e422                	sd	s0,8(sp)
    8000307a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000307c:	00004797          	auipc	a5,0x4
    80003080:	a5478793          	addi	a5,a5,-1452 # 80006ad0 <kernelvec>
    80003084:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003088:	6422                	ld	s0,8(sp)
    8000308a:	0141                	addi	sp,sp,16
    8000308c:	8082                	ret

000000008000308e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000308e:	1141                	addi	sp,sp,-16
    80003090:	e406                	sd	ra,8(sp)
    80003092:	e022                	sd	s0,0(sp)
    80003094:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003096:	fffff097          	auipc	ra,0xfffff
    8000309a:	af0080e7          	jalr	-1296(ra) # 80001b86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000309e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800030a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030a4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800030a8:	00005617          	auipc	a2,0x5
    800030ac:	f5860613          	addi	a2,a2,-168 # 80008000 <_trampoline>
    800030b0:	00005697          	auipc	a3,0x5
    800030b4:	f5068693          	addi	a3,a3,-176 # 80008000 <_trampoline>
    800030b8:	8e91                	sub	a3,a3,a2
    800030ba:	040007b7          	lui	a5,0x4000
    800030be:	17fd                	addi	a5,a5,-1
    800030c0:	07b2                	slli	a5,a5,0xc
    800030c2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800030c4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800030c8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800030ca:	180026f3          	csrr	a3,satp
    800030ce:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800030d0:	6d38                	ld	a4,88(a0)
    800030d2:	6134                	ld	a3,64(a0)
    800030d4:	6585                	lui	a1,0x1
    800030d6:	96ae                	add	a3,a3,a1
    800030d8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800030da:	6d38                	ld	a4,88(a0)
    800030dc:	00000697          	auipc	a3,0x0
    800030e0:	13868693          	addi	a3,a3,312 # 80003214 <usertrap>
    800030e4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800030e6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800030e8:	8692                	mv	a3,tp
    800030ea:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030ec:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800030f0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800030f4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030f8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800030fc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030fe:	6f18                	ld	a4,24(a4)
    80003100:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003104:	692c                	ld	a1,80(a0)
    80003106:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003108:	00005717          	auipc	a4,0x5
    8000310c:	f8870713          	addi	a4,a4,-120 # 80008090 <userret>
    80003110:	8f11                	sub	a4,a4,a2
    80003112:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003114:	577d                	li	a4,-1
    80003116:	177e                	slli	a4,a4,0x3f
    80003118:	8dd9                	or	a1,a1,a4
    8000311a:	02000537          	lui	a0,0x2000
    8000311e:	157d                	addi	a0,a0,-1
    80003120:	0536                	slli	a0,a0,0xd
    80003122:	9782                	jalr	a5
}
    80003124:	60a2                	ld	ra,8(sp)
    80003126:	6402                	ld	s0,0(sp)
    80003128:	0141                	addi	sp,sp,16
    8000312a:	8082                	ret

000000008000312c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003136:	00039497          	auipc	s1,0x39
    8000313a:	79a48493          	addi	s1,s1,1946 # 8003c8d0 <tickslock>
    8000313e:	8526                	mv	a0,s1
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	a82080e7          	jalr	-1406(ra) # 80000bc2 <acquire>
  ticks++;
    80003148:	00007517          	auipc	a0,0x7
    8000314c:	ef050513          	addi	a0,a0,-272 # 8000a038 <ticks>
    80003150:	411c                	lw	a5,0(a0)
    80003152:	2785                	addiw	a5,a5,1
    80003154:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003156:	fffff097          	auipc	ra,0xfffff
    8000315a:	e72080e7          	jalr	-398(ra) # 80001fc8 <wakeup>
  release(&tickslock);
    8000315e:	8526                	mv	a0,s1
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	b16080e7          	jalr	-1258(ra) # 80000c76 <release>
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000317c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003180:	00074d63          	bltz	a4,8000319a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003184:	57fd                	li	a5,-1
    80003186:	17fe                	slli	a5,a5,0x3f
    80003188:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000318a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000318c:	06f70363          	beq	a4,a5,800031f2 <devintr+0x80>
  }
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret
     (scause & 0xff) == 9){
    8000319a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000319e:	46a5                	li	a3,9
    800031a0:	fed792e3          	bne	a5,a3,80003184 <devintr+0x12>
    int irq = plic_claim();
    800031a4:	00004097          	auipc	ra,0x4
    800031a8:	a34080e7          	jalr	-1484(ra) # 80006bd8 <plic_claim>
    800031ac:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800031ae:	47a9                	li	a5,10
    800031b0:	02f50763          	beq	a0,a5,800031de <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800031b4:	4785                	li	a5,1
    800031b6:	02f50963          	beq	a0,a5,800031e8 <devintr+0x76>
    return 1;
    800031ba:	4505                	li	a0,1
    } else if(irq){
    800031bc:	d8f1                	beqz	s1,80003190 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800031be:	85a6                	mv	a1,s1
    800031c0:	00006517          	auipc	a0,0x6
    800031c4:	3f850513          	addi	a0,a0,1016 # 800095b8 <states.0+0x38>
    800031c8:	ffffd097          	auipc	ra,0xffffd
    800031cc:	3ac080e7          	jalr	940(ra) # 80000574 <printf>
      plic_complete(irq);
    800031d0:	8526                	mv	a0,s1
    800031d2:	00004097          	auipc	ra,0x4
    800031d6:	a2a080e7          	jalr	-1494(ra) # 80006bfc <plic_complete>
    return 1;
    800031da:	4505                	li	a0,1
    800031dc:	bf55                	j	80003190 <devintr+0x1e>
      uartintr();
    800031de:	ffffd097          	auipc	ra,0xffffd
    800031e2:	7a8080e7          	jalr	1960(ra) # 80000986 <uartintr>
    800031e6:	b7ed                	j	800031d0 <devintr+0x5e>
      virtio_disk_intr();
    800031e8:	00004097          	auipc	ra,0x4
    800031ec:	ea6080e7          	jalr	-346(ra) # 8000708e <virtio_disk_intr>
    800031f0:	b7c5                	j	800031d0 <devintr+0x5e>
    if(cpuid() == 0){
    800031f2:	fffff097          	auipc	ra,0xfffff
    800031f6:	968080e7          	jalr	-1688(ra) # 80001b5a <cpuid>
    800031fa:	c901                	beqz	a0,8000320a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800031fc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003200:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003202:	14479073          	csrw	sip,a5
    return 2;
    80003206:	4509                	li	a0,2
    80003208:	b761                	j	80003190 <devintr+0x1e>
      clockintr();
    8000320a:	00000097          	auipc	ra,0x0
    8000320e:	f22080e7          	jalr	-222(ra) # 8000312c <clockintr>
    80003212:	b7ed                	j	800031fc <devintr+0x8a>

0000000080003214 <usertrap>:
{
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	e04a                	sd	s2,0(sp)
    8000321e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003220:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003224:	1007f793          	andi	a5,a5,256
    80003228:	e3ad                	bnez	a5,8000328a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000322a:	00004797          	auipc	a5,0x4
    8000322e:	8a678793          	addi	a5,a5,-1882 # 80006ad0 <kernelvec>
    80003232:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003236:	fffff097          	auipc	ra,0xfffff
    8000323a:	950080e7          	jalr	-1712(ra) # 80001b86 <myproc>
    8000323e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003240:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003242:	14102773          	csrr	a4,sepc
    80003246:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003248:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000324c:	47a1                	li	a5,8
    8000324e:	04f70663          	beq	a4,a5,8000329a <usertrap+0x86>
  } else if(p->pid > 2 && (r_scause() == 12 || r_scause() == 13 || r_scause() == 15)) {
    80003252:	5918                	lw	a4,48(a0)
    80003254:	4789                	li	a5,2
    80003256:	02e7d163          	bge	a5,a4,80003278 <usertrap+0x64>
    8000325a:	14202773          	csrr	a4,scause
    8000325e:	47b1                	li	a5,12
    80003260:	06f70f63          	beq	a4,a5,800032de <usertrap+0xca>
    80003264:	14202773          	csrr	a4,scause
    80003268:	47b5                	li	a5,13
    8000326a:	06f70a63          	beq	a4,a5,800032de <usertrap+0xca>
    8000326e:	14202773          	csrr	a4,scause
    80003272:	47bd                	li	a5,15
    80003274:	06f70563          	beq	a4,a5,800032de <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	efa080e7          	jalr	-262(ra) # 80003172 <devintr>
    80003280:	892a                	mv	s2,a0
    80003282:	cd35                	beqz	a0,800032fe <usertrap+0xea>
  if(p->killed)
    80003284:	549c                	lw	a5,40(s1)
    80003286:	cfc5                	beqz	a5,8000333e <usertrap+0x12a>
    80003288:	a075                	j	80003334 <usertrap+0x120>
    panic("usertrap: not from user mode");
    8000328a:	00006517          	auipc	a0,0x6
    8000328e:	34e50513          	addi	a0,a0,846 # 800095d8 <states.0+0x58>
    80003292:	ffffd097          	auipc	ra,0xffffd
    80003296:	298080e7          	jalr	664(ra) # 8000052a <panic>
    if(p->killed)
    8000329a:	551c                	lw	a5,40(a0)
    8000329c:	eb9d                	bnez	a5,800032d2 <usertrap+0xbe>
    p->trapframe->epc += 4;
    8000329e:	6cb8                	ld	a4,88(s1)
    800032a0:	6f1c                	ld	a5,24(a4)
    800032a2:	0791                	addi	a5,a5,4
    800032a4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032a6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800032aa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800032ae:	10079073          	csrw	sstatus,a5
    syscall();
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	2de080e7          	jalr	734(ra) # 80003590 <syscall>
  if(p->killed)
    800032ba:	549c                	lw	a5,40(s1)
    800032bc:	ebbd                	bnez	a5,80003332 <usertrap+0x11e>
  usertrapret();
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	dd0080e7          	jalr	-560(ra) # 8000308e <usertrapret>
}
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6902                	ld	s2,0(sp)
    800032ce:	6105                	addi	sp,sp,32
    800032d0:	8082                	ret
      exit(-1);
    800032d2:	557d                	li	a0,-1
    800032d4:	fffff097          	auipc	ra,0xfffff
    800032d8:	dd4080e7          	jalr	-556(ra) # 800020a8 <exit>
    800032dc:	b7c9                	j	8000329e <usertrap+0x8a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032de:	142025f3          	csrr	a1,scause
    printf("before handke page fault, r_scause: %d\n", r_scause());
    800032e2:	00006517          	auipc	a0,0x6
    800032e6:	31650513          	addi	a0,a0,790 # 800095f8 <states.0+0x78>
    800032ea:	ffffd097          	auipc	ra,0xffffd
    800032ee:	28a080e7          	jalr	650(ra) # 80000574 <printf>
    hanle_page_fault(p);
    800032f2:	8526                	mv	a0,s1
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	be4080e7          	jalr	-1052(ra) # 80002ed8 <hanle_page_fault>
    800032fc:	bf7d                	j	800032ba <usertrap+0xa6>
    800032fe:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003302:	5890                	lw	a2,48(s1)
    80003304:	00006517          	auipc	a0,0x6
    80003308:	31c50513          	addi	a0,a0,796 # 80009620 <states.0+0xa0>
    8000330c:	ffffd097          	auipc	ra,0xffffd
    80003310:	268080e7          	jalr	616(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003314:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003318:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000331c:	00006517          	auipc	a0,0x6
    80003320:	1dc50513          	addi	a0,a0,476 # 800094f8 <digits+0x4b8>
    80003324:	ffffd097          	auipc	ra,0xffffd
    80003328:	250080e7          	jalr	592(ra) # 80000574 <printf>
    p->killed = 1;
    8000332c:	4785                	li	a5,1
    8000332e:	d49c                	sw	a5,40(s1)
  if(p->killed)
    80003330:	a011                	j	80003334 <usertrap+0x120>
    80003332:	4901                	li	s2,0
    exit(-1);
    80003334:	557d                	li	a0,-1
    80003336:	fffff097          	auipc	ra,0xfffff
    8000333a:	d72080e7          	jalr	-654(ra) # 800020a8 <exit>
  if(which_dev == 2)
    8000333e:	4789                	li	a5,2
    80003340:	f6f91fe3          	bne	s2,a5,800032be <usertrap+0xaa>
    yield();
    80003344:	fffff097          	auipc	ra,0xfffff
    80003348:	be4080e7          	jalr	-1052(ra) # 80001f28 <yield>
    8000334c:	bf8d                	j	800032be <usertrap+0xaa>

000000008000334e <kerneltrap>:
{
    8000334e:	7179                	addi	sp,sp,-48
    80003350:	f406                	sd	ra,40(sp)
    80003352:	f022                	sd	s0,32(sp)
    80003354:	ec26                	sd	s1,24(sp)
    80003356:	e84a                	sd	s2,16(sp)
    80003358:	e44e                	sd	s3,8(sp)
    8000335a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000335c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003360:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003364:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003368:	1004f793          	andi	a5,s1,256
    8000336c:	cb85                	beqz	a5,8000339c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000336e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003372:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003374:	ef85                	bnez	a5,800033ac <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003376:	00000097          	auipc	ra,0x0
    8000337a:	dfc080e7          	jalr	-516(ra) # 80003172 <devintr>
    8000337e:	cd1d                	beqz	a0,800033bc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003380:	4789                	li	a5,2
    80003382:	06f50a63          	beq	a0,a5,800033f6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003386:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000338a:	10049073          	csrw	sstatus,s1
}
    8000338e:	70a2                	ld	ra,40(sp)
    80003390:	7402                	ld	s0,32(sp)
    80003392:	64e2                	ld	s1,24(sp)
    80003394:	6942                	ld	s2,16(sp)
    80003396:	69a2                	ld	s3,8(sp)
    80003398:	6145                	addi	sp,sp,48
    8000339a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000339c:	00006517          	auipc	a0,0x6
    800033a0:	2b450513          	addi	a0,a0,692 # 80009650 <states.0+0xd0>
    800033a4:	ffffd097          	auipc	ra,0xffffd
    800033a8:	186080e7          	jalr	390(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800033ac:	00006517          	auipc	a0,0x6
    800033b0:	2cc50513          	addi	a0,a0,716 # 80009678 <states.0+0xf8>
    800033b4:	ffffd097          	auipc	ra,0xffffd
    800033b8:	176080e7          	jalr	374(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    800033bc:	85ce                	mv	a1,s3
    800033be:	00006517          	auipc	a0,0x6
    800033c2:	2da50513          	addi	a0,a0,730 # 80009698 <states.0+0x118>
    800033c6:	ffffd097          	auipc	ra,0xffffd
    800033ca:	1ae080e7          	jalr	430(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800033d2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800033d6:	00006517          	auipc	a0,0x6
    800033da:	2d250513          	addi	a0,a0,722 # 800096a8 <states.0+0x128>
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	196080e7          	jalr	406(ra) # 80000574 <printf>
    panic("kerneltrap");
    800033e6:	00006517          	auipc	a0,0x6
    800033ea:	2da50513          	addi	a0,a0,730 # 800096c0 <states.0+0x140>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	13c080e7          	jalr	316(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800033f6:	ffffe097          	auipc	ra,0xffffe
    800033fa:	790080e7          	jalr	1936(ra) # 80001b86 <myproc>
    800033fe:	d541                	beqz	a0,80003386 <kerneltrap+0x38>
    80003400:	ffffe097          	auipc	ra,0xffffe
    80003404:	786080e7          	jalr	1926(ra) # 80001b86 <myproc>
    80003408:	4d18                	lw	a4,24(a0)
    8000340a:	4791                	li	a5,4
    8000340c:	f6f71de3          	bne	a4,a5,80003386 <kerneltrap+0x38>
    yield();
    80003410:	fffff097          	auipc	ra,0xfffff
    80003414:	b18080e7          	jalr	-1256(ra) # 80001f28 <yield>
    80003418:	b7bd                	j	80003386 <kerneltrap+0x38>

000000008000341a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000341a:	1101                	addi	sp,sp,-32
    8000341c:	ec06                	sd	ra,24(sp)
    8000341e:	e822                	sd	s0,16(sp)
    80003420:	e426                	sd	s1,8(sp)
    80003422:	1000                	addi	s0,sp,32
    80003424:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003426:	ffffe097          	auipc	ra,0xffffe
    8000342a:	760080e7          	jalr	1888(ra) # 80001b86 <myproc>
  switch (n) {
    8000342e:	4795                	li	a5,5
    80003430:	0497e163          	bltu	a5,s1,80003472 <argraw+0x58>
    80003434:	048a                	slli	s1,s1,0x2
    80003436:	00006717          	auipc	a4,0x6
    8000343a:	2c270713          	addi	a4,a4,706 # 800096f8 <states.0+0x178>
    8000343e:	94ba                	add	s1,s1,a4
    80003440:	409c                	lw	a5,0(s1)
    80003442:	97ba                	add	a5,a5,a4
    80003444:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003446:	6d3c                	ld	a5,88(a0)
    80003448:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6105                	addi	sp,sp,32
    80003452:	8082                	ret
    return p->trapframe->a1;
    80003454:	6d3c                	ld	a5,88(a0)
    80003456:	7fa8                	ld	a0,120(a5)
    80003458:	bfcd                	j	8000344a <argraw+0x30>
    return p->trapframe->a2;
    8000345a:	6d3c                	ld	a5,88(a0)
    8000345c:	63c8                	ld	a0,128(a5)
    8000345e:	b7f5                	j	8000344a <argraw+0x30>
    return p->trapframe->a3;
    80003460:	6d3c                	ld	a5,88(a0)
    80003462:	67c8                	ld	a0,136(a5)
    80003464:	b7dd                	j	8000344a <argraw+0x30>
    return p->trapframe->a4;
    80003466:	6d3c                	ld	a5,88(a0)
    80003468:	6bc8                	ld	a0,144(a5)
    8000346a:	b7c5                	j	8000344a <argraw+0x30>
    return p->trapframe->a5;
    8000346c:	6d3c                	ld	a5,88(a0)
    8000346e:	6fc8                	ld	a0,152(a5)
    80003470:	bfe9                	j	8000344a <argraw+0x30>
  panic("argraw");
    80003472:	00006517          	auipc	a0,0x6
    80003476:	25e50513          	addi	a0,a0,606 # 800096d0 <states.0+0x150>
    8000347a:	ffffd097          	auipc	ra,0xffffd
    8000347e:	0b0080e7          	jalr	176(ra) # 8000052a <panic>

0000000080003482 <fetchaddr>:
{
    80003482:	1101                	addi	sp,sp,-32
    80003484:	ec06                	sd	ra,24(sp)
    80003486:	e822                	sd	s0,16(sp)
    80003488:	e426                	sd	s1,8(sp)
    8000348a:	e04a                	sd	s2,0(sp)
    8000348c:	1000                	addi	s0,sp,32
    8000348e:	84aa                	mv	s1,a0
    80003490:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003492:	ffffe097          	auipc	ra,0xffffe
    80003496:	6f4080e7          	jalr	1780(ra) # 80001b86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000349a:	653c                	ld	a5,72(a0)
    8000349c:	02f4f863          	bgeu	s1,a5,800034cc <fetchaddr+0x4a>
    800034a0:	00848713          	addi	a4,s1,8
    800034a4:	02e7e663          	bltu	a5,a4,800034d0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800034a8:	46a1                	li	a3,8
    800034aa:	8626                	mv	a2,s1
    800034ac:	85ca                	mv	a1,s2
    800034ae:	6928                	ld	a0,80(a0)
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	40e080e7          	jalr	1038(ra) # 800018be <copyin>
    800034b8:	00a03533          	snez	a0,a0
    800034bc:	40a00533          	neg	a0,a0
}
    800034c0:	60e2                	ld	ra,24(sp)
    800034c2:	6442                	ld	s0,16(sp)
    800034c4:	64a2                	ld	s1,8(sp)
    800034c6:	6902                	ld	s2,0(sp)
    800034c8:	6105                	addi	sp,sp,32
    800034ca:	8082                	ret
    return -1;
    800034cc:	557d                	li	a0,-1
    800034ce:	bfcd                	j	800034c0 <fetchaddr+0x3e>
    800034d0:	557d                	li	a0,-1
    800034d2:	b7fd                	j	800034c0 <fetchaddr+0x3e>

00000000800034d4 <fetchstr>:
{
    800034d4:	7179                	addi	sp,sp,-48
    800034d6:	f406                	sd	ra,40(sp)
    800034d8:	f022                	sd	s0,32(sp)
    800034da:	ec26                	sd	s1,24(sp)
    800034dc:	e84a                	sd	s2,16(sp)
    800034de:	e44e                	sd	s3,8(sp)
    800034e0:	1800                	addi	s0,sp,48
    800034e2:	892a                	mv	s2,a0
    800034e4:	84ae                	mv	s1,a1
    800034e6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	69e080e7          	jalr	1694(ra) # 80001b86 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800034f0:	86ce                	mv	a3,s3
    800034f2:	864a                	mv	a2,s2
    800034f4:	85a6                	mv	a1,s1
    800034f6:	6928                	ld	a0,80(a0)
    800034f8:	ffffe097          	auipc	ra,0xffffe
    800034fc:	454080e7          	jalr	1108(ra) # 8000194c <copyinstr>
  if(err < 0)
    80003500:	00054763          	bltz	a0,8000350e <fetchstr+0x3a>
  return strlen(buf);
    80003504:	8526                	mv	a0,s1
    80003506:	ffffe097          	auipc	ra,0xffffe
    8000350a:	93c080e7          	jalr	-1732(ra) # 80000e42 <strlen>
}
    8000350e:	70a2                	ld	ra,40(sp)
    80003510:	7402                	ld	s0,32(sp)
    80003512:	64e2                	ld	s1,24(sp)
    80003514:	6942                	ld	s2,16(sp)
    80003516:	69a2                	ld	s3,8(sp)
    80003518:	6145                	addi	sp,sp,48
    8000351a:	8082                	ret

000000008000351c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000351c:	1101                	addi	sp,sp,-32
    8000351e:	ec06                	sd	ra,24(sp)
    80003520:	e822                	sd	s0,16(sp)
    80003522:	e426                	sd	s1,8(sp)
    80003524:	1000                	addi	s0,sp,32
    80003526:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	ef2080e7          	jalr	-270(ra) # 8000341a <argraw>
    80003530:	c088                	sw	a0,0(s1)
  return 0;
}
    80003532:	4501                	li	a0,0
    80003534:	60e2                	ld	ra,24(sp)
    80003536:	6442                	ld	s0,16(sp)
    80003538:	64a2                	ld	s1,8(sp)
    8000353a:	6105                	addi	sp,sp,32
    8000353c:	8082                	ret

000000008000353e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000353e:	1101                	addi	sp,sp,-32
    80003540:	ec06                	sd	ra,24(sp)
    80003542:	e822                	sd	s0,16(sp)
    80003544:	e426                	sd	s1,8(sp)
    80003546:	1000                	addi	s0,sp,32
    80003548:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000354a:	00000097          	auipc	ra,0x0
    8000354e:	ed0080e7          	jalr	-304(ra) # 8000341a <argraw>
    80003552:	e088                	sd	a0,0(s1)
  return 0;
}
    80003554:	4501                	li	a0,0
    80003556:	60e2                	ld	ra,24(sp)
    80003558:	6442                	ld	s0,16(sp)
    8000355a:	64a2                	ld	s1,8(sp)
    8000355c:	6105                	addi	sp,sp,32
    8000355e:	8082                	ret

0000000080003560 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003560:	1101                	addi	sp,sp,-32
    80003562:	ec06                	sd	ra,24(sp)
    80003564:	e822                	sd	s0,16(sp)
    80003566:	e426                	sd	s1,8(sp)
    80003568:	e04a                	sd	s2,0(sp)
    8000356a:	1000                	addi	s0,sp,32
    8000356c:	84ae                	mv	s1,a1
    8000356e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003570:	00000097          	auipc	ra,0x0
    80003574:	eaa080e7          	jalr	-342(ra) # 8000341a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003578:	864a                	mv	a2,s2
    8000357a:	85a6                	mv	a1,s1
    8000357c:	00000097          	auipc	ra,0x0
    80003580:	f58080e7          	jalr	-168(ra) # 800034d4 <fetchstr>
}
    80003584:	60e2                	ld	ra,24(sp)
    80003586:	6442                	ld	s0,16(sp)
    80003588:	64a2                	ld	s1,8(sp)
    8000358a:	6902                	ld	s2,0(sp)
    8000358c:	6105                	addi	sp,sp,32
    8000358e:	8082                	ret

0000000080003590 <syscall>:
[SYS_printmem]  sys_printmem,
};

void
syscall(void)
{
    80003590:	1101                	addi	sp,sp,-32
    80003592:	ec06                	sd	ra,24(sp)
    80003594:	e822                	sd	s0,16(sp)
    80003596:	e426                	sd	s1,8(sp)
    80003598:	e04a                	sd	s2,0(sp)
    8000359a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000359c:	ffffe097          	auipc	ra,0xffffe
    800035a0:	5ea080e7          	jalr	1514(ra) # 80001b86 <myproc>
    800035a4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800035a6:	05853903          	ld	s2,88(a0)
    800035aa:	0a893783          	ld	a5,168(s2)
    800035ae:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800035b2:	37fd                	addiw	a5,a5,-1
    800035b4:	4755                	li	a4,21
    800035b6:	00f76f63          	bltu	a4,a5,800035d4 <syscall+0x44>
    800035ba:	00369713          	slli	a4,a3,0x3
    800035be:	00006797          	auipc	a5,0x6
    800035c2:	15278793          	addi	a5,a5,338 # 80009710 <syscalls>
    800035c6:	97ba                	add	a5,a5,a4
    800035c8:	639c                	ld	a5,0(a5)
    800035ca:	c789                	beqz	a5,800035d4 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800035cc:	9782                	jalr	a5
    800035ce:	06a93823          	sd	a0,112(s2)
    800035d2:	a839                	j	800035f0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800035d4:	15848613          	addi	a2,s1,344
    800035d8:	588c                	lw	a1,48(s1)
    800035da:	00006517          	auipc	a0,0x6
    800035de:	0fe50513          	addi	a0,a0,254 # 800096d8 <states.0+0x158>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	f92080e7          	jalr	-110(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800035ea:	6cbc                	ld	a5,88(s1)
    800035ec:	577d                	li	a4,-1
    800035ee:	fbb8                	sd	a4,112(a5)
  }
}
    800035f0:	60e2                	ld	ra,24(sp)
    800035f2:	6442                	ld	s0,16(sp)
    800035f4:	64a2                	ld	s1,8(sp)
    800035f6:	6902                	ld	s2,0(sp)
    800035f8:	6105                	addi	sp,sp,32
    800035fa:	8082                	ret

00000000800035fc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800035fc:	1101                	addi	sp,sp,-32
    800035fe:	ec06                	sd	ra,24(sp)
    80003600:	e822                	sd	s0,16(sp)
    80003602:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003604:	fec40593          	addi	a1,s0,-20
    80003608:	4501                	li	a0,0
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	f12080e7          	jalr	-238(ra) # 8000351c <argint>
    return -1;
    80003612:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003614:	00054963          	bltz	a0,80003626 <sys_exit+0x2a>
  exit(n);
    80003618:	fec42503          	lw	a0,-20(s0)
    8000361c:	fffff097          	auipc	ra,0xfffff
    80003620:	a8c080e7          	jalr	-1396(ra) # 800020a8 <exit>
  return 0;  // not reached
    80003624:	4781                	li	a5,0
}
    80003626:	853e                	mv	a0,a5
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	6105                	addi	sp,sp,32
    8000362e:	8082                	ret

0000000080003630 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003630:	1141                	addi	sp,sp,-16
    80003632:	e406                	sd	ra,8(sp)
    80003634:	e022                	sd	s0,0(sp)
    80003636:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003638:	ffffe097          	auipc	ra,0xffffe
    8000363c:	54e080e7          	jalr	1358(ra) # 80001b86 <myproc>
}
    80003640:	5908                	lw	a0,48(a0)
    80003642:	60a2                	ld	ra,8(sp)
    80003644:	6402                	ld	s0,0(sp)
    80003646:	0141                	addi	sp,sp,16
    80003648:	8082                	ret

000000008000364a <sys_fork>:

uint64
sys_fork(void)
{
    8000364a:	1141                	addi	sp,sp,-16
    8000364c:	e406                	sd	ra,8(sp)
    8000364e:	e022                	sd	s0,0(sp)
    80003650:	0800                	addi	s0,sp,16
  return fork();
    80003652:	fffff097          	auipc	ra,0xfffff
    80003656:	19e080e7          	jalr	414(ra) # 800027f0 <fork>
}
    8000365a:	60a2                	ld	ra,8(sp)
    8000365c:	6402                	ld	s0,0(sp)
    8000365e:	0141                	addi	sp,sp,16
    80003660:	8082                	ret

0000000080003662 <sys_wait>:

uint64
sys_wait(void)
{
    80003662:	1101                	addi	sp,sp,-32
    80003664:	ec06                	sd	ra,24(sp)
    80003666:	e822                	sd	s0,16(sp)
    80003668:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000366a:	fe840593          	addi	a1,s0,-24
    8000366e:	4501                	li	a0,0
    80003670:	00000097          	auipc	ra,0x0
    80003674:	ece080e7          	jalr	-306(ra) # 8000353e <argaddr>
    80003678:	87aa                	mv	a5,a0
    return -1;
    8000367a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000367c:	0007c863          	bltz	a5,8000368c <sys_wait+0x2a>
  return wait(p);
    80003680:	fe843503          	ld	a0,-24(s0)
    80003684:	fffff097          	auipc	ra,0xfffff
    80003688:	df0080e7          	jalr	-528(ra) # 80002474 <wait>
}
    8000368c:	60e2                	ld	ra,24(sp)
    8000368e:	6442                	ld	s0,16(sp)
    80003690:	6105                	addi	sp,sp,32
    80003692:	8082                	ret

0000000080003694 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003694:	7179                	addi	sp,sp,-48
    80003696:	f406                	sd	ra,40(sp)
    80003698:	f022                	sd	s0,32(sp)
    8000369a:	ec26                	sd	s1,24(sp)
    8000369c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000369e:	fdc40593          	addi	a1,s0,-36
    800036a2:	4501                	li	a0,0
    800036a4:	00000097          	auipc	ra,0x0
    800036a8:	e78080e7          	jalr	-392(ra) # 8000351c <argint>
    return -1;
    800036ac:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800036ae:	00054f63          	bltz	a0,800036cc <sys_sbrk+0x38>
  addr = myproc()->sz;
    800036b2:	ffffe097          	auipc	ra,0xffffe
    800036b6:	4d4080e7          	jalr	1236(ra) # 80001b86 <myproc>
    800036ba:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800036bc:	fdc42503          	lw	a0,-36(s0)
    800036c0:	ffffe097          	auipc	ra,0xffffe
    800036c4:	678080e7          	jalr	1656(ra) # 80001d38 <growproc>
    800036c8:	00054863          	bltz	a0,800036d8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800036cc:	8526                	mv	a0,s1
    800036ce:	70a2                	ld	ra,40(sp)
    800036d0:	7402                	ld	s0,32(sp)
    800036d2:	64e2                	ld	s1,24(sp)
    800036d4:	6145                	addi	sp,sp,48
    800036d6:	8082                	ret
    return -1;
    800036d8:	54fd                	li	s1,-1
    800036da:	bfcd                	j	800036cc <sys_sbrk+0x38>

00000000800036dc <sys_sleep>:

uint64
sys_sleep(void)
{
    800036dc:	7139                	addi	sp,sp,-64
    800036de:	fc06                	sd	ra,56(sp)
    800036e0:	f822                	sd	s0,48(sp)
    800036e2:	f426                	sd	s1,40(sp)
    800036e4:	f04a                	sd	s2,32(sp)
    800036e6:	ec4e                	sd	s3,24(sp)
    800036e8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800036ea:	fcc40593          	addi	a1,s0,-52
    800036ee:	4501                	li	a0,0
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	e2c080e7          	jalr	-468(ra) # 8000351c <argint>
    return -1;
    800036f8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800036fa:	06054563          	bltz	a0,80003764 <sys_sleep+0x88>
  acquire(&tickslock);
    800036fe:	00039517          	auipc	a0,0x39
    80003702:	1d250513          	addi	a0,a0,466 # 8003c8d0 <tickslock>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	4bc080e7          	jalr	1212(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000370e:	00007917          	auipc	s2,0x7
    80003712:	92a92903          	lw	s2,-1750(s2) # 8000a038 <ticks>
  while(ticks - ticks0 < n){
    80003716:	fcc42783          	lw	a5,-52(s0)
    8000371a:	cf85                	beqz	a5,80003752 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000371c:	00039997          	auipc	s3,0x39
    80003720:	1b498993          	addi	s3,s3,436 # 8003c8d0 <tickslock>
    80003724:	00007497          	auipc	s1,0x7
    80003728:	91448493          	addi	s1,s1,-1772 # 8000a038 <ticks>
    if(myproc()->killed){
    8000372c:	ffffe097          	auipc	ra,0xffffe
    80003730:	45a080e7          	jalr	1114(ra) # 80001b86 <myproc>
    80003734:	551c                	lw	a5,40(a0)
    80003736:	ef9d                	bnez	a5,80003774 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003738:	85ce                	mv	a1,s3
    8000373a:	8526                	mv	a0,s1
    8000373c:	fffff097          	auipc	ra,0xfffff
    80003740:	828080e7          	jalr	-2008(ra) # 80001f64 <sleep>
  while(ticks - ticks0 < n){
    80003744:	409c                	lw	a5,0(s1)
    80003746:	412787bb          	subw	a5,a5,s2
    8000374a:	fcc42703          	lw	a4,-52(s0)
    8000374e:	fce7efe3          	bltu	a5,a4,8000372c <sys_sleep+0x50>
  }
  release(&tickslock);
    80003752:	00039517          	auipc	a0,0x39
    80003756:	17e50513          	addi	a0,a0,382 # 8003c8d0 <tickslock>
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	51c080e7          	jalr	1308(ra) # 80000c76 <release>
  return 0;
    80003762:	4781                	li	a5,0
}
    80003764:	853e                	mv	a0,a5
    80003766:	70e2                	ld	ra,56(sp)
    80003768:	7442                	ld	s0,48(sp)
    8000376a:	74a2                	ld	s1,40(sp)
    8000376c:	7902                	ld	s2,32(sp)
    8000376e:	69e2                	ld	s3,24(sp)
    80003770:	6121                	addi	sp,sp,64
    80003772:	8082                	ret
      release(&tickslock);
    80003774:	00039517          	auipc	a0,0x39
    80003778:	15c50513          	addi	a0,a0,348 # 8003c8d0 <tickslock>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	4fa080e7          	jalr	1274(ra) # 80000c76 <release>
      return -1;
    80003784:	57fd                	li	a5,-1
    80003786:	bff9                	j	80003764 <sys_sleep+0x88>

0000000080003788 <sys_kill>:

uint64
sys_kill(void)
{
    80003788:	1101                	addi	sp,sp,-32
    8000378a:	ec06                	sd	ra,24(sp)
    8000378c:	e822                	sd	s0,16(sp)
    8000378e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003790:	fec40593          	addi	a1,s0,-20
    80003794:	4501                	li	a0,0
    80003796:	00000097          	auipc	ra,0x0
    8000379a:	d86080e7          	jalr	-634(ra) # 8000351c <argint>
    8000379e:	87aa                	mv	a5,a0
    return -1;
    800037a0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800037a2:	0007c863          	bltz	a5,800037b2 <sys_kill+0x2a>
  return kill(pid);
    800037a6:	fec42503          	lw	a0,-20(s0)
    800037aa:	fffff097          	auipc	ra,0xfffff
    800037ae:	9ea080e7          	jalr	-1558(ra) # 80002194 <kill>
}
    800037b2:	60e2                	ld	ra,24(sp)
    800037b4:	6442                	ld	s0,16(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret

00000000800037ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	e426                	sd	s1,8(sp)
    800037c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800037c4:	00039517          	auipc	a0,0x39
    800037c8:	10c50513          	addi	a0,a0,268 # 8003c8d0 <tickslock>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	3f6080e7          	jalr	1014(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800037d4:	00007497          	auipc	s1,0x7
    800037d8:	8644a483          	lw	s1,-1948(s1) # 8000a038 <ticks>
  release(&tickslock);
    800037dc:	00039517          	auipc	a0,0x39
    800037e0:	0f450513          	addi	a0,a0,244 # 8003c8d0 <tickslock>
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	492080e7          	jalr	1170(ra) # 80000c76 <release>
  return xticks;
}
    800037ec:	02049513          	slli	a0,s1,0x20
    800037f0:	9101                	srli	a0,a0,0x20
    800037f2:	60e2                	ld	ra,24(sp)
    800037f4:	6442                	ld	s0,16(sp)
    800037f6:	64a2                	ld	s1,8(sp)
    800037f8:	6105                	addi	sp,sp,32
    800037fa:	8082                	ret

00000000800037fc <sys_printmem>:

uint64
sys_printmem(void)
{
    800037fc:	1141                	addi	sp,sp,-16
    800037fe:	e406                	sd	ra,8(sp)
    80003800:	e022                	sd	s0,0(sp)
    80003802:	0800                	addi	s0,sp,16
  return printmem();
    80003804:	fffff097          	auipc	ra,0xfffff
    80003808:	76a080e7          	jalr	1898(ra) # 80002f6e <printmem>
    8000380c:	60a2                	ld	ra,8(sp)
    8000380e:	6402                	ld	s0,0(sp)
    80003810:	0141                	addi	sp,sp,16
    80003812:	8082                	ret

0000000080003814 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003814:	7179                	addi	sp,sp,-48
    80003816:	f406                	sd	ra,40(sp)
    80003818:	f022                	sd	s0,32(sp)
    8000381a:	ec26                	sd	s1,24(sp)
    8000381c:	e84a                	sd	s2,16(sp)
    8000381e:	e44e                	sd	s3,8(sp)
    80003820:	e052                	sd	s4,0(sp)
    80003822:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003824:	00006597          	auipc	a1,0x6
    80003828:	fa458593          	addi	a1,a1,-92 # 800097c8 <syscalls+0xb8>
    8000382c:	00039517          	auipc	a0,0x39
    80003830:	0bc50513          	addi	a0,a0,188 # 8003c8e8 <bcache>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	2fe080e7          	jalr	766(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000383c:	00041797          	auipc	a5,0x41
    80003840:	0ac78793          	addi	a5,a5,172 # 800448e8 <bcache+0x8000>
    80003844:	00041717          	auipc	a4,0x41
    80003848:	30c70713          	addi	a4,a4,780 # 80044b50 <bcache+0x8268>
    8000384c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003850:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003854:	00039497          	auipc	s1,0x39
    80003858:	0ac48493          	addi	s1,s1,172 # 8003c900 <bcache+0x18>
    b->next = bcache.head.next;
    8000385c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000385e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003860:	00006a17          	auipc	s4,0x6
    80003864:	f70a0a13          	addi	s4,s4,-144 # 800097d0 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003868:	2b893783          	ld	a5,696(s2)
    8000386c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000386e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003872:	85d2                	mv	a1,s4
    80003874:	01048513          	addi	a0,s1,16
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	7d4080e7          	jalr	2004(ra) # 8000504c <initsleeplock>
    bcache.head.next->prev = b;
    80003880:	2b893783          	ld	a5,696(s2)
    80003884:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003886:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000388a:	45848493          	addi	s1,s1,1112
    8000388e:	fd349de3          	bne	s1,s3,80003868 <binit+0x54>
  }
}
    80003892:	70a2                	ld	ra,40(sp)
    80003894:	7402                	ld	s0,32(sp)
    80003896:	64e2                	ld	s1,24(sp)
    80003898:	6942                	ld	s2,16(sp)
    8000389a:	69a2                	ld	s3,8(sp)
    8000389c:	6a02                	ld	s4,0(sp)
    8000389e:	6145                	addi	sp,sp,48
    800038a0:	8082                	ret

00000000800038a2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800038a2:	7179                	addi	sp,sp,-48
    800038a4:	f406                	sd	ra,40(sp)
    800038a6:	f022                	sd	s0,32(sp)
    800038a8:	ec26                	sd	s1,24(sp)
    800038aa:	e84a                	sd	s2,16(sp)
    800038ac:	e44e                	sd	s3,8(sp)
    800038ae:	1800                	addi	s0,sp,48
    800038b0:	892a                	mv	s2,a0
    800038b2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800038b4:	00039517          	auipc	a0,0x39
    800038b8:	03450513          	addi	a0,a0,52 # 8003c8e8 <bcache>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	306080e7          	jalr	774(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038c4:	00041497          	auipc	s1,0x41
    800038c8:	2dc4b483          	ld	s1,732(s1) # 80044ba0 <bcache+0x82b8>
    800038cc:	00041797          	auipc	a5,0x41
    800038d0:	28478793          	addi	a5,a5,644 # 80044b50 <bcache+0x8268>
    800038d4:	02f48f63          	beq	s1,a5,80003912 <bread+0x70>
    800038d8:	873e                	mv	a4,a5
    800038da:	a021                	j	800038e2 <bread+0x40>
    800038dc:	68a4                	ld	s1,80(s1)
    800038de:	02e48a63          	beq	s1,a4,80003912 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800038e2:	449c                	lw	a5,8(s1)
    800038e4:	ff279ce3          	bne	a5,s2,800038dc <bread+0x3a>
    800038e8:	44dc                	lw	a5,12(s1)
    800038ea:	ff3799e3          	bne	a5,s3,800038dc <bread+0x3a>
      b->refcnt++;
    800038ee:	40bc                	lw	a5,64(s1)
    800038f0:	2785                	addiw	a5,a5,1
    800038f2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038f4:	00039517          	auipc	a0,0x39
    800038f8:	ff450513          	addi	a0,a0,-12 # 8003c8e8 <bcache>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	37a080e7          	jalr	890(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003904:	01048513          	addi	a0,s1,16
    80003908:	00001097          	auipc	ra,0x1
    8000390c:	77e080e7          	jalr	1918(ra) # 80005086 <acquiresleep>
      return b;
    80003910:	a8b9                	j	8000396e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003912:	00041497          	auipc	s1,0x41
    80003916:	2864b483          	ld	s1,646(s1) # 80044b98 <bcache+0x82b0>
    8000391a:	00041797          	auipc	a5,0x41
    8000391e:	23678793          	addi	a5,a5,566 # 80044b50 <bcache+0x8268>
    80003922:	00f48863          	beq	s1,a5,80003932 <bread+0x90>
    80003926:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003928:	40bc                	lw	a5,64(s1)
    8000392a:	cf81                	beqz	a5,80003942 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000392c:	64a4                	ld	s1,72(s1)
    8000392e:	fee49de3          	bne	s1,a4,80003928 <bread+0x86>
  panic("bget: no buffers");
    80003932:	00006517          	auipc	a0,0x6
    80003936:	ea650513          	addi	a0,a0,-346 # 800097d8 <syscalls+0xc8>
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	bf0080e7          	jalr	-1040(ra) # 8000052a <panic>
      b->dev = dev;
    80003942:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003946:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000394a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000394e:	4785                	li	a5,1
    80003950:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003952:	00039517          	auipc	a0,0x39
    80003956:	f9650513          	addi	a0,a0,-106 # 8003c8e8 <bcache>
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	31c080e7          	jalr	796(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003962:	01048513          	addi	a0,s1,16
    80003966:	00001097          	auipc	ra,0x1
    8000396a:	720080e7          	jalr	1824(ra) # 80005086 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000396e:	409c                	lw	a5,0(s1)
    80003970:	cb89                	beqz	a5,80003982 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003972:	8526                	mv	a0,s1
    80003974:	70a2                	ld	ra,40(sp)
    80003976:	7402                	ld	s0,32(sp)
    80003978:	64e2                	ld	s1,24(sp)
    8000397a:	6942                	ld	s2,16(sp)
    8000397c:	69a2                	ld	s3,8(sp)
    8000397e:	6145                	addi	sp,sp,48
    80003980:	8082                	ret
    virtio_disk_rw(b, 0);
    80003982:	4581                	li	a1,0
    80003984:	8526                	mv	a0,s1
    80003986:	00003097          	auipc	ra,0x3
    8000398a:	480080e7          	jalr	1152(ra) # 80006e06 <virtio_disk_rw>
    b->valid = 1;
    8000398e:	4785                	li	a5,1
    80003990:	c09c                	sw	a5,0(s1)
  return b;
    80003992:	b7c5                	j	80003972 <bread+0xd0>

0000000080003994 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003994:	1101                	addi	sp,sp,-32
    80003996:	ec06                	sd	ra,24(sp)
    80003998:	e822                	sd	s0,16(sp)
    8000399a:	e426                	sd	s1,8(sp)
    8000399c:	1000                	addi	s0,sp,32
    8000399e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039a0:	0541                	addi	a0,a0,16
    800039a2:	00001097          	auipc	ra,0x1
    800039a6:	77e080e7          	jalr	1918(ra) # 80005120 <holdingsleep>
    800039aa:	cd01                	beqz	a0,800039c2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800039ac:	4585                	li	a1,1
    800039ae:	8526                	mv	a0,s1
    800039b0:	00003097          	auipc	ra,0x3
    800039b4:	456080e7          	jalr	1110(ra) # 80006e06 <virtio_disk_rw>
}
    800039b8:	60e2                	ld	ra,24(sp)
    800039ba:	6442                	ld	s0,16(sp)
    800039bc:	64a2                	ld	s1,8(sp)
    800039be:	6105                	addi	sp,sp,32
    800039c0:	8082                	ret
    panic("bwrite");
    800039c2:	00006517          	auipc	a0,0x6
    800039c6:	e2e50513          	addi	a0,a0,-466 # 800097f0 <syscalls+0xe0>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	b60080e7          	jalr	-1184(ra) # 8000052a <panic>

00000000800039d2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800039d2:	1101                	addi	sp,sp,-32
    800039d4:	ec06                	sd	ra,24(sp)
    800039d6:	e822                	sd	s0,16(sp)
    800039d8:	e426                	sd	s1,8(sp)
    800039da:	e04a                	sd	s2,0(sp)
    800039dc:	1000                	addi	s0,sp,32
    800039de:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039e0:	01050913          	addi	s2,a0,16
    800039e4:	854a                	mv	a0,s2
    800039e6:	00001097          	auipc	ra,0x1
    800039ea:	73a080e7          	jalr	1850(ra) # 80005120 <holdingsleep>
    800039ee:	c92d                	beqz	a0,80003a60 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800039f0:	854a                	mv	a0,s2
    800039f2:	00001097          	auipc	ra,0x1
    800039f6:	6ea080e7          	jalr	1770(ra) # 800050dc <releasesleep>

  acquire(&bcache.lock);
    800039fa:	00039517          	auipc	a0,0x39
    800039fe:	eee50513          	addi	a0,a0,-274 # 8003c8e8 <bcache>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	1c0080e7          	jalr	448(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003a0a:	40bc                	lw	a5,64(s1)
    80003a0c:	37fd                	addiw	a5,a5,-1
    80003a0e:	0007871b          	sext.w	a4,a5
    80003a12:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a14:	eb05                	bnez	a4,80003a44 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a16:	68bc                	ld	a5,80(s1)
    80003a18:	64b8                	ld	a4,72(s1)
    80003a1a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003a1c:	64bc                	ld	a5,72(s1)
    80003a1e:	68b8                	ld	a4,80(s1)
    80003a20:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a22:	00041797          	auipc	a5,0x41
    80003a26:	ec678793          	addi	a5,a5,-314 # 800448e8 <bcache+0x8000>
    80003a2a:	2b87b703          	ld	a4,696(a5)
    80003a2e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a30:	00041717          	auipc	a4,0x41
    80003a34:	12070713          	addi	a4,a4,288 # 80044b50 <bcache+0x8268>
    80003a38:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a3a:	2b87b703          	ld	a4,696(a5)
    80003a3e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a40:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a44:	00039517          	auipc	a0,0x39
    80003a48:	ea450513          	addi	a0,a0,-348 # 8003c8e8 <bcache>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	22a080e7          	jalr	554(ra) # 80000c76 <release>
}
    80003a54:	60e2                	ld	ra,24(sp)
    80003a56:	6442                	ld	s0,16(sp)
    80003a58:	64a2                	ld	s1,8(sp)
    80003a5a:	6902                	ld	s2,0(sp)
    80003a5c:	6105                	addi	sp,sp,32
    80003a5e:	8082                	ret
    panic("brelse");
    80003a60:	00006517          	auipc	a0,0x6
    80003a64:	d9850513          	addi	a0,a0,-616 # 800097f8 <syscalls+0xe8>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	ac2080e7          	jalr	-1342(ra) # 8000052a <panic>

0000000080003a70 <bpin>:

void
bpin(struct buf *b) {
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	e426                	sd	s1,8(sp)
    80003a78:	1000                	addi	s0,sp,32
    80003a7a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a7c:	00039517          	auipc	a0,0x39
    80003a80:	e6c50513          	addi	a0,a0,-404 # 8003c8e8 <bcache>
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	13e080e7          	jalr	318(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003a8c:	40bc                	lw	a5,64(s1)
    80003a8e:	2785                	addiw	a5,a5,1
    80003a90:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a92:	00039517          	auipc	a0,0x39
    80003a96:	e5650513          	addi	a0,a0,-426 # 8003c8e8 <bcache>
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	1dc080e7          	jalr	476(ra) # 80000c76 <release>
}
    80003aa2:	60e2                	ld	ra,24(sp)
    80003aa4:	6442                	ld	s0,16(sp)
    80003aa6:	64a2                	ld	s1,8(sp)
    80003aa8:	6105                	addi	sp,sp,32
    80003aaa:	8082                	ret

0000000080003aac <bunpin>:

void
bunpin(struct buf *b) {
    80003aac:	1101                	addi	sp,sp,-32
    80003aae:	ec06                	sd	ra,24(sp)
    80003ab0:	e822                	sd	s0,16(sp)
    80003ab2:	e426                	sd	s1,8(sp)
    80003ab4:	1000                	addi	s0,sp,32
    80003ab6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003ab8:	00039517          	auipc	a0,0x39
    80003abc:	e3050513          	addi	a0,a0,-464 # 8003c8e8 <bcache>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	102080e7          	jalr	258(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003ac8:	40bc                	lw	a5,64(s1)
    80003aca:	37fd                	addiw	a5,a5,-1
    80003acc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003ace:	00039517          	auipc	a0,0x39
    80003ad2:	e1a50513          	addi	a0,a0,-486 # 8003c8e8 <bcache>
    80003ad6:	ffffd097          	auipc	ra,0xffffd
    80003ada:	1a0080e7          	jalr	416(ra) # 80000c76 <release>
}
    80003ade:	60e2                	ld	ra,24(sp)
    80003ae0:	6442                	ld	s0,16(sp)
    80003ae2:	64a2                	ld	s1,8(sp)
    80003ae4:	6105                	addi	sp,sp,32
    80003ae6:	8082                	ret

0000000080003ae8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003ae8:	1101                	addi	sp,sp,-32
    80003aea:	ec06                	sd	ra,24(sp)
    80003aec:	e822                	sd	s0,16(sp)
    80003aee:	e426                	sd	s1,8(sp)
    80003af0:	e04a                	sd	s2,0(sp)
    80003af2:	1000                	addi	s0,sp,32
    80003af4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003af6:	00d5d59b          	srliw	a1,a1,0xd
    80003afa:	00041797          	auipc	a5,0x41
    80003afe:	4ca7a783          	lw	a5,1226(a5) # 80044fc4 <sb+0x1c>
    80003b02:	9dbd                	addw	a1,a1,a5
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	d9e080e7          	jalr	-610(ra) # 800038a2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b0c:	0074f713          	andi	a4,s1,7
    80003b10:	4785                	li	a5,1
    80003b12:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003b16:	14ce                	slli	s1,s1,0x33
    80003b18:	90d9                	srli	s1,s1,0x36
    80003b1a:	00950733          	add	a4,a0,s1
    80003b1e:	05874703          	lbu	a4,88(a4)
    80003b22:	00e7f6b3          	and	a3,a5,a4
    80003b26:	c69d                	beqz	a3,80003b54 <bfree+0x6c>
    80003b28:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b2a:	94aa                	add	s1,s1,a0
    80003b2c:	fff7c793          	not	a5,a5
    80003b30:	8ff9                	and	a5,a5,a4
    80003b32:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003b36:	00001097          	auipc	ra,0x1
    80003b3a:	430080e7          	jalr	1072(ra) # 80004f66 <log_write>
  brelse(bp);
    80003b3e:	854a                	mv	a0,s2
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	e92080e7          	jalr	-366(ra) # 800039d2 <brelse>
}
    80003b48:	60e2                	ld	ra,24(sp)
    80003b4a:	6442                	ld	s0,16(sp)
    80003b4c:	64a2                	ld	s1,8(sp)
    80003b4e:	6902                	ld	s2,0(sp)
    80003b50:	6105                	addi	sp,sp,32
    80003b52:	8082                	ret
    panic("freeing free block");
    80003b54:	00006517          	auipc	a0,0x6
    80003b58:	cac50513          	addi	a0,a0,-852 # 80009800 <syscalls+0xf0>
    80003b5c:	ffffd097          	auipc	ra,0xffffd
    80003b60:	9ce080e7          	jalr	-1586(ra) # 8000052a <panic>

0000000080003b64 <balloc>:
{
    80003b64:	711d                	addi	sp,sp,-96
    80003b66:	ec86                	sd	ra,88(sp)
    80003b68:	e8a2                	sd	s0,80(sp)
    80003b6a:	e4a6                	sd	s1,72(sp)
    80003b6c:	e0ca                	sd	s2,64(sp)
    80003b6e:	fc4e                	sd	s3,56(sp)
    80003b70:	f852                	sd	s4,48(sp)
    80003b72:	f456                	sd	s5,40(sp)
    80003b74:	f05a                	sd	s6,32(sp)
    80003b76:	ec5e                	sd	s7,24(sp)
    80003b78:	e862                	sd	s8,16(sp)
    80003b7a:	e466                	sd	s9,8(sp)
    80003b7c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b7e:	00041797          	auipc	a5,0x41
    80003b82:	42e7a783          	lw	a5,1070(a5) # 80044fac <sb+0x4>
    80003b86:	cbd1                	beqz	a5,80003c1a <balloc+0xb6>
    80003b88:	8baa                	mv	s7,a0
    80003b8a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b8c:	00041b17          	auipc	s6,0x41
    80003b90:	41cb0b13          	addi	s6,s6,1052 # 80044fa8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b94:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b96:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b98:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b9a:	6c89                	lui	s9,0x2
    80003b9c:	a831                	j	80003bb8 <balloc+0x54>
    brelse(bp);
    80003b9e:	854a                	mv	a0,s2
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	e32080e7          	jalr	-462(ra) # 800039d2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ba8:	015c87bb          	addw	a5,s9,s5
    80003bac:	00078a9b          	sext.w	s5,a5
    80003bb0:	004b2703          	lw	a4,4(s6)
    80003bb4:	06eaf363          	bgeu	s5,a4,80003c1a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003bb8:	41fad79b          	sraiw	a5,s5,0x1f
    80003bbc:	0137d79b          	srliw	a5,a5,0x13
    80003bc0:	015787bb          	addw	a5,a5,s5
    80003bc4:	40d7d79b          	sraiw	a5,a5,0xd
    80003bc8:	01cb2583          	lw	a1,28(s6)
    80003bcc:	9dbd                	addw	a1,a1,a5
    80003bce:	855e                	mv	a0,s7
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	cd2080e7          	jalr	-814(ra) # 800038a2 <bread>
    80003bd8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bda:	004b2503          	lw	a0,4(s6)
    80003bde:	000a849b          	sext.w	s1,s5
    80003be2:	8662                	mv	a2,s8
    80003be4:	faa4fde3          	bgeu	s1,a0,80003b9e <balloc+0x3a>
      m = 1 << (bi % 8);
    80003be8:	41f6579b          	sraiw	a5,a2,0x1f
    80003bec:	01d7d69b          	srliw	a3,a5,0x1d
    80003bf0:	00c6873b          	addw	a4,a3,a2
    80003bf4:	00777793          	andi	a5,a4,7
    80003bf8:	9f95                	subw	a5,a5,a3
    80003bfa:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bfe:	4037571b          	sraiw	a4,a4,0x3
    80003c02:	00e906b3          	add	a3,s2,a4
    80003c06:	0586c683          	lbu	a3,88(a3)
    80003c0a:	00d7f5b3          	and	a1,a5,a3
    80003c0e:	cd91                	beqz	a1,80003c2a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c10:	2605                	addiw	a2,a2,1
    80003c12:	2485                	addiw	s1,s1,1
    80003c14:	fd4618e3          	bne	a2,s4,80003be4 <balloc+0x80>
    80003c18:	b759                	j	80003b9e <balloc+0x3a>
  panic("balloc: out of blocks");
    80003c1a:	00006517          	auipc	a0,0x6
    80003c1e:	bfe50513          	addi	a0,a0,-1026 # 80009818 <syscalls+0x108>
    80003c22:	ffffd097          	auipc	ra,0xffffd
    80003c26:	908080e7          	jalr	-1784(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003c2a:	974a                	add	a4,a4,s2
    80003c2c:	8fd5                	or	a5,a5,a3
    80003c2e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003c32:	854a                	mv	a0,s2
    80003c34:	00001097          	auipc	ra,0x1
    80003c38:	332080e7          	jalr	818(ra) # 80004f66 <log_write>
        brelse(bp);
    80003c3c:	854a                	mv	a0,s2
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	d94080e7          	jalr	-620(ra) # 800039d2 <brelse>
  bp = bread(dev, bno);
    80003c46:	85a6                	mv	a1,s1
    80003c48:	855e                	mv	a0,s7
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	c58080e7          	jalr	-936(ra) # 800038a2 <bread>
    80003c52:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003c54:	40000613          	li	a2,1024
    80003c58:	4581                	li	a1,0
    80003c5a:	05850513          	addi	a0,a0,88
    80003c5e:	ffffd097          	auipc	ra,0xffffd
    80003c62:	060080e7          	jalr	96(ra) # 80000cbe <memset>
  log_write(bp);
    80003c66:	854a                	mv	a0,s2
    80003c68:	00001097          	auipc	ra,0x1
    80003c6c:	2fe080e7          	jalr	766(ra) # 80004f66 <log_write>
  brelse(bp);
    80003c70:	854a                	mv	a0,s2
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	d60080e7          	jalr	-672(ra) # 800039d2 <brelse>
}
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	60e6                	ld	ra,88(sp)
    80003c7e:	6446                	ld	s0,80(sp)
    80003c80:	64a6                	ld	s1,72(sp)
    80003c82:	6906                	ld	s2,64(sp)
    80003c84:	79e2                	ld	s3,56(sp)
    80003c86:	7a42                	ld	s4,48(sp)
    80003c88:	7aa2                	ld	s5,40(sp)
    80003c8a:	7b02                	ld	s6,32(sp)
    80003c8c:	6be2                	ld	s7,24(sp)
    80003c8e:	6c42                	ld	s8,16(sp)
    80003c90:	6ca2                	ld	s9,8(sp)
    80003c92:	6125                	addi	sp,sp,96
    80003c94:	8082                	ret

0000000080003c96 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c96:	7179                	addi	sp,sp,-48
    80003c98:	f406                	sd	ra,40(sp)
    80003c9a:	f022                	sd	s0,32(sp)
    80003c9c:	ec26                	sd	s1,24(sp)
    80003c9e:	e84a                	sd	s2,16(sp)
    80003ca0:	e44e                	sd	s3,8(sp)
    80003ca2:	e052                	sd	s4,0(sp)
    80003ca4:	1800                	addi	s0,sp,48
    80003ca6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003ca8:	47ad                	li	a5,11
    80003caa:	04b7fe63          	bgeu	a5,a1,80003d06 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003cae:	ff45849b          	addiw	s1,a1,-12
    80003cb2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003cb6:	0ff00793          	li	a5,255
    80003cba:	0ae7e463          	bltu	a5,a4,80003d62 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003cbe:	08052583          	lw	a1,128(a0)
    80003cc2:	c5b5                	beqz	a1,80003d2e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003cc4:	00092503          	lw	a0,0(s2)
    80003cc8:	00000097          	auipc	ra,0x0
    80003ccc:	bda080e7          	jalr	-1062(ra) # 800038a2 <bread>
    80003cd0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003cd2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003cd6:	02049713          	slli	a4,s1,0x20
    80003cda:	01e75593          	srli	a1,a4,0x1e
    80003cde:	00b784b3          	add	s1,a5,a1
    80003ce2:	0004a983          	lw	s3,0(s1)
    80003ce6:	04098e63          	beqz	s3,80003d42 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003cea:	8552                	mv	a0,s4
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	ce6080e7          	jalr	-794(ra) # 800039d2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003cf4:	854e                	mv	a0,s3
    80003cf6:	70a2                	ld	ra,40(sp)
    80003cf8:	7402                	ld	s0,32(sp)
    80003cfa:	64e2                	ld	s1,24(sp)
    80003cfc:	6942                	ld	s2,16(sp)
    80003cfe:	69a2                	ld	s3,8(sp)
    80003d00:	6a02                	ld	s4,0(sp)
    80003d02:	6145                	addi	sp,sp,48
    80003d04:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003d06:	02059793          	slli	a5,a1,0x20
    80003d0a:	01e7d593          	srli	a1,a5,0x1e
    80003d0e:	00b504b3          	add	s1,a0,a1
    80003d12:	0504a983          	lw	s3,80(s1)
    80003d16:	fc099fe3          	bnez	s3,80003cf4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003d1a:	4108                	lw	a0,0(a0)
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	e48080e7          	jalr	-440(ra) # 80003b64 <balloc>
    80003d24:	0005099b          	sext.w	s3,a0
    80003d28:	0534a823          	sw	s3,80(s1)
    80003d2c:	b7e1                	j	80003cf4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003d2e:	4108                	lw	a0,0(a0)
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	e34080e7          	jalr	-460(ra) # 80003b64 <balloc>
    80003d38:	0005059b          	sext.w	a1,a0
    80003d3c:	08b92023          	sw	a1,128(s2)
    80003d40:	b751                	j	80003cc4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003d42:	00092503          	lw	a0,0(s2)
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	e1e080e7          	jalr	-482(ra) # 80003b64 <balloc>
    80003d4e:	0005099b          	sext.w	s3,a0
    80003d52:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003d56:	8552                	mv	a0,s4
    80003d58:	00001097          	auipc	ra,0x1
    80003d5c:	20e080e7          	jalr	526(ra) # 80004f66 <log_write>
    80003d60:	b769                	j	80003cea <bmap+0x54>
  panic("bmap: out of range");
    80003d62:	00006517          	auipc	a0,0x6
    80003d66:	ace50513          	addi	a0,a0,-1330 # 80009830 <syscalls+0x120>
    80003d6a:	ffffc097          	auipc	ra,0xffffc
    80003d6e:	7c0080e7          	jalr	1984(ra) # 8000052a <panic>

0000000080003d72 <iget>:
{
    80003d72:	7179                	addi	sp,sp,-48
    80003d74:	f406                	sd	ra,40(sp)
    80003d76:	f022                	sd	s0,32(sp)
    80003d78:	ec26                	sd	s1,24(sp)
    80003d7a:	e84a                	sd	s2,16(sp)
    80003d7c:	e44e                	sd	s3,8(sp)
    80003d7e:	e052                	sd	s4,0(sp)
    80003d80:	1800                	addi	s0,sp,48
    80003d82:	89aa                	mv	s3,a0
    80003d84:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d86:	00041517          	auipc	a0,0x41
    80003d8a:	24250513          	addi	a0,a0,578 # 80044fc8 <itable>
    80003d8e:	ffffd097          	auipc	ra,0xffffd
    80003d92:	e34080e7          	jalr	-460(ra) # 80000bc2 <acquire>
  empty = 0;
    80003d96:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d98:	00041497          	auipc	s1,0x41
    80003d9c:	24848493          	addi	s1,s1,584 # 80044fe0 <itable+0x18>
    80003da0:	00043697          	auipc	a3,0x43
    80003da4:	cd068693          	addi	a3,a3,-816 # 80046a70 <log>
    80003da8:	a039                	j	80003db6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003daa:	02090b63          	beqz	s2,80003de0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003dae:	08848493          	addi	s1,s1,136
    80003db2:	02d48a63          	beq	s1,a3,80003de6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003db6:	449c                	lw	a5,8(s1)
    80003db8:	fef059e3          	blez	a5,80003daa <iget+0x38>
    80003dbc:	4098                	lw	a4,0(s1)
    80003dbe:	ff3716e3          	bne	a4,s3,80003daa <iget+0x38>
    80003dc2:	40d8                	lw	a4,4(s1)
    80003dc4:	ff4713e3          	bne	a4,s4,80003daa <iget+0x38>
      ip->ref++;
    80003dc8:	2785                	addiw	a5,a5,1
    80003dca:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003dcc:	00041517          	auipc	a0,0x41
    80003dd0:	1fc50513          	addi	a0,a0,508 # 80044fc8 <itable>
    80003dd4:	ffffd097          	auipc	ra,0xffffd
    80003dd8:	ea2080e7          	jalr	-350(ra) # 80000c76 <release>
      return ip;
    80003ddc:	8926                	mv	s2,s1
    80003dde:	a03d                	j	80003e0c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003de0:	f7f9                	bnez	a5,80003dae <iget+0x3c>
    80003de2:	8926                	mv	s2,s1
    80003de4:	b7e9                	j	80003dae <iget+0x3c>
  if(empty == 0)
    80003de6:	02090c63          	beqz	s2,80003e1e <iget+0xac>
  ip->dev = dev;
    80003dea:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003dee:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003df2:	4785                	li	a5,1
    80003df4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003df8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003dfc:	00041517          	auipc	a0,0x41
    80003e00:	1cc50513          	addi	a0,a0,460 # 80044fc8 <itable>
    80003e04:	ffffd097          	auipc	ra,0xffffd
    80003e08:	e72080e7          	jalr	-398(ra) # 80000c76 <release>
}
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	70a2                	ld	ra,40(sp)
    80003e10:	7402                	ld	s0,32(sp)
    80003e12:	64e2                	ld	s1,24(sp)
    80003e14:	6942                	ld	s2,16(sp)
    80003e16:	69a2                	ld	s3,8(sp)
    80003e18:	6a02                	ld	s4,0(sp)
    80003e1a:	6145                	addi	sp,sp,48
    80003e1c:	8082                	ret
    panic("iget: no inodes");
    80003e1e:	00006517          	auipc	a0,0x6
    80003e22:	a2a50513          	addi	a0,a0,-1494 # 80009848 <syscalls+0x138>
    80003e26:	ffffc097          	auipc	ra,0xffffc
    80003e2a:	704080e7          	jalr	1796(ra) # 8000052a <panic>

0000000080003e2e <fsinit>:
fsinit(int dev) {
    80003e2e:	7179                	addi	sp,sp,-48
    80003e30:	f406                	sd	ra,40(sp)
    80003e32:	f022                	sd	s0,32(sp)
    80003e34:	ec26                	sd	s1,24(sp)
    80003e36:	e84a                	sd	s2,16(sp)
    80003e38:	e44e                	sd	s3,8(sp)
    80003e3a:	1800                	addi	s0,sp,48
    80003e3c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e3e:	4585                	li	a1,1
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	a62080e7          	jalr	-1438(ra) # 800038a2 <bread>
    80003e48:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e4a:	00041997          	auipc	s3,0x41
    80003e4e:	15e98993          	addi	s3,s3,350 # 80044fa8 <sb>
    80003e52:	02000613          	li	a2,32
    80003e56:	05850593          	addi	a1,a0,88
    80003e5a:	854e                	mv	a0,s3
    80003e5c:	ffffd097          	auipc	ra,0xffffd
    80003e60:	ebe080e7          	jalr	-322(ra) # 80000d1a <memmove>
  brelse(bp);
    80003e64:	8526                	mv	a0,s1
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	b6c080e7          	jalr	-1172(ra) # 800039d2 <brelse>
  if(sb.magic != FSMAGIC)
    80003e6e:	0009a703          	lw	a4,0(s3)
    80003e72:	102037b7          	lui	a5,0x10203
    80003e76:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e7a:	02f71263          	bne	a4,a5,80003e9e <fsinit+0x70>
  initlog(dev, &sb);
    80003e7e:	00041597          	auipc	a1,0x41
    80003e82:	12a58593          	addi	a1,a1,298 # 80044fa8 <sb>
    80003e86:	854a                	mv	a0,s2
    80003e88:	00001097          	auipc	ra,0x1
    80003e8c:	e60080e7          	jalr	-416(ra) # 80004ce8 <initlog>
}
    80003e90:	70a2                	ld	ra,40(sp)
    80003e92:	7402                	ld	s0,32(sp)
    80003e94:	64e2                	ld	s1,24(sp)
    80003e96:	6942                	ld	s2,16(sp)
    80003e98:	69a2                	ld	s3,8(sp)
    80003e9a:	6145                	addi	sp,sp,48
    80003e9c:	8082                	ret
    panic("invalid file system");
    80003e9e:	00006517          	auipc	a0,0x6
    80003ea2:	9ba50513          	addi	a0,a0,-1606 # 80009858 <syscalls+0x148>
    80003ea6:	ffffc097          	auipc	ra,0xffffc
    80003eaa:	684080e7          	jalr	1668(ra) # 8000052a <panic>

0000000080003eae <iinit>:
{
    80003eae:	7179                	addi	sp,sp,-48
    80003eb0:	f406                	sd	ra,40(sp)
    80003eb2:	f022                	sd	s0,32(sp)
    80003eb4:	ec26                	sd	s1,24(sp)
    80003eb6:	e84a                	sd	s2,16(sp)
    80003eb8:	e44e                	sd	s3,8(sp)
    80003eba:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ebc:	00006597          	auipc	a1,0x6
    80003ec0:	9b458593          	addi	a1,a1,-1612 # 80009870 <syscalls+0x160>
    80003ec4:	00041517          	auipc	a0,0x41
    80003ec8:	10450513          	addi	a0,a0,260 # 80044fc8 <itable>
    80003ecc:	ffffd097          	auipc	ra,0xffffd
    80003ed0:	c66080e7          	jalr	-922(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ed4:	00041497          	auipc	s1,0x41
    80003ed8:	11c48493          	addi	s1,s1,284 # 80044ff0 <itable+0x28>
    80003edc:	00043997          	auipc	s3,0x43
    80003ee0:	ba498993          	addi	s3,s3,-1116 # 80046a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ee4:	00006917          	auipc	s2,0x6
    80003ee8:	99490913          	addi	s2,s2,-1644 # 80009878 <syscalls+0x168>
    80003eec:	85ca                	mv	a1,s2
    80003eee:	8526                	mv	a0,s1
    80003ef0:	00001097          	auipc	ra,0x1
    80003ef4:	15c080e7          	jalr	348(ra) # 8000504c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ef8:	08848493          	addi	s1,s1,136
    80003efc:	ff3498e3          	bne	s1,s3,80003eec <iinit+0x3e>
}
    80003f00:	70a2                	ld	ra,40(sp)
    80003f02:	7402                	ld	s0,32(sp)
    80003f04:	64e2                	ld	s1,24(sp)
    80003f06:	6942                	ld	s2,16(sp)
    80003f08:	69a2                	ld	s3,8(sp)
    80003f0a:	6145                	addi	sp,sp,48
    80003f0c:	8082                	ret

0000000080003f0e <ialloc>:
{
    80003f0e:	715d                	addi	sp,sp,-80
    80003f10:	e486                	sd	ra,72(sp)
    80003f12:	e0a2                	sd	s0,64(sp)
    80003f14:	fc26                	sd	s1,56(sp)
    80003f16:	f84a                	sd	s2,48(sp)
    80003f18:	f44e                	sd	s3,40(sp)
    80003f1a:	f052                	sd	s4,32(sp)
    80003f1c:	ec56                	sd	s5,24(sp)
    80003f1e:	e85a                	sd	s6,16(sp)
    80003f20:	e45e                	sd	s7,8(sp)
    80003f22:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f24:	00041717          	auipc	a4,0x41
    80003f28:	09072703          	lw	a4,144(a4) # 80044fb4 <sb+0xc>
    80003f2c:	4785                	li	a5,1
    80003f2e:	04e7fa63          	bgeu	a5,a4,80003f82 <ialloc+0x74>
    80003f32:	8aaa                	mv	s5,a0
    80003f34:	8bae                	mv	s7,a1
    80003f36:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f38:	00041a17          	auipc	s4,0x41
    80003f3c:	070a0a13          	addi	s4,s4,112 # 80044fa8 <sb>
    80003f40:	00048b1b          	sext.w	s6,s1
    80003f44:	0044d793          	srli	a5,s1,0x4
    80003f48:	018a2583          	lw	a1,24(s4)
    80003f4c:	9dbd                	addw	a1,a1,a5
    80003f4e:	8556                	mv	a0,s5
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	952080e7          	jalr	-1710(ra) # 800038a2 <bread>
    80003f58:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f5a:	05850993          	addi	s3,a0,88
    80003f5e:	00f4f793          	andi	a5,s1,15
    80003f62:	079a                	slli	a5,a5,0x6
    80003f64:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f66:	00099783          	lh	a5,0(s3)
    80003f6a:	c785                	beqz	a5,80003f92 <ialloc+0x84>
    brelse(bp);
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	a66080e7          	jalr	-1434(ra) # 800039d2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f74:	0485                	addi	s1,s1,1
    80003f76:	00ca2703          	lw	a4,12(s4)
    80003f7a:	0004879b          	sext.w	a5,s1
    80003f7e:	fce7e1e3          	bltu	a5,a4,80003f40 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003f82:	00006517          	auipc	a0,0x6
    80003f86:	8fe50513          	addi	a0,a0,-1794 # 80009880 <syscalls+0x170>
    80003f8a:	ffffc097          	auipc	ra,0xffffc
    80003f8e:	5a0080e7          	jalr	1440(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003f92:	04000613          	li	a2,64
    80003f96:	4581                	li	a1,0
    80003f98:	854e                	mv	a0,s3
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	d24080e7          	jalr	-732(ra) # 80000cbe <memset>
      dip->type = type;
    80003fa2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003fa6:	854a                	mv	a0,s2
    80003fa8:	00001097          	auipc	ra,0x1
    80003fac:	fbe080e7          	jalr	-66(ra) # 80004f66 <log_write>
      brelse(bp);
    80003fb0:	854a                	mv	a0,s2
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	a20080e7          	jalr	-1504(ra) # 800039d2 <brelse>
      return iget(dev, inum);
    80003fba:	85da                	mv	a1,s6
    80003fbc:	8556                	mv	a0,s5
    80003fbe:	00000097          	auipc	ra,0x0
    80003fc2:	db4080e7          	jalr	-588(ra) # 80003d72 <iget>
}
    80003fc6:	60a6                	ld	ra,72(sp)
    80003fc8:	6406                	ld	s0,64(sp)
    80003fca:	74e2                	ld	s1,56(sp)
    80003fcc:	7942                	ld	s2,48(sp)
    80003fce:	79a2                	ld	s3,40(sp)
    80003fd0:	7a02                	ld	s4,32(sp)
    80003fd2:	6ae2                	ld	s5,24(sp)
    80003fd4:	6b42                	ld	s6,16(sp)
    80003fd6:	6ba2                	ld	s7,8(sp)
    80003fd8:	6161                	addi	sp,sp,80
    80003fda:	8082                	ret

0000000080003fdc <iupdate>:
{
    80003fdc:	1101                	addi	sp,sp,-32
    80003fde:	ec06                	sd	ra,24(sp)
    80003fe0:	e822                	sd	s0,16(sp)
    80003fe2:	e426                	sd	s1,8(sp)
    80003fe4:	e04a                	sd	s2,0(sp)
    80003fe6:	1000                	addi	s0,sp,32
    80003fe8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fea:	415c                	lw	a5,4(a0)
    80003fec:	0047d79b          	srliw	a5,a5,0x4
    80003ff0:	00041597          	auipc	a1,0x41
    80003ff4:	fd05a583          	lw	a1,-48(a1) # 80044fc0 <sb+0x18>
    80003ff8:	9dbd                	addw	a1,a1,a5
    80003ffa:	4108                	lw	a0,0(a0)
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	8a6080e7          	jalr	-1882(ra) # 800038a2 <bread>
    80004004:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004006:	05850793          	addi	a5,a0,88
    8000400a:	40c8                	lw	a0,4(s1)
    8000400c:	893d                	andi	a0,a0,15
    8000400e:	051a                	slli	a0,a0,0x6
    80004010:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004012:	04449703          	lh	a4,68(s1)
    80004016:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000401a:	04649703          	lh	a4,70(s1)
    8000401e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004022:	04849703          	lh	a4,72(s1)
    80004026:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000402a:	04a49703          	lh	a4,74(s1)
    8000402e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004032:	44f8                	lw	a4,76(s1)
    80004034:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004036:	03400613          	li	a2,52
    8000403a:	05048593          	addi	a1,s1,80
    8000403e:	0531                	addi	a0,a0,12
    80004040:	ffffd097          	auipc	ra,0xffffd
    80004044:	cda080e7          	jalr	-806(ra) # 80000d1a <memmove>
  log_write(bp);
    80004048:	854a                	mv	a0,s2
    8000404a:	00001097          	auipc	ra,0x1
    8000404e:	f1c080e7          	jalr	-228(ra) # 80004f66 <log_write>
  brelse(bp);
    80004052:	854a                	mv	a0,s2
    80004054:	00000097          	auipc	ra,0x0
    80004058:	97e080e7          	jalr	-1666(ra) # 800039d2 <brelse>
}
    8000405c:	60e2                	ld	ra,24(sp)
    8000405e:	6442                	ld	s0,16(sp)
    80004060:	64a2                	ld	s1,8(sp)
    80004062:	6902                	ld	s2,0(sp)
    80004064:	6105                	addi	sp,sp,32
    80004066:	8082                	ret

0000000080004068 <idup>:
{
    80004068:	1101                	addi	sp,sp,-32
    8000406a:	ec06                	sd	ra,24(sp)
    8000406c:	e822                	sd	s0,16(sp)
    8000406e:	e426                	sd	s1,8(sp)
    80004070:	1000                	addi	s0,sp,32
    80004072:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004074:	00041517          	auipc	a0,0x41
    80004078:	f5450513          	addi	a0,a0,-172 # 80044fc8 <itable>
    8000407c:	ffffd097          	auipc	ra,0xffffd
    80004080:	b46080e7          	jalr	-1210(ra) # 80000bc2 <acquire>
  ip->ref++;
    80004084:	449c                	lw	a5,8(s1)
    80004086:	2785                	addiw	a5,a5,1
    80004088:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000408a:	00041517          	auipc	a0,0x41
    8000408e:	f3e50513          	addi	a0,a0,-194 # 80044fc8 <itable>
    80004092:	ffffd097          	auipc	ra,0xffffd
    80004096:	be4080e7          	jalr	-1052(ra) # 80000c76 <release>
}
    8000409a:	8526                	mv	a0,s1
    8000409c:	60e2                	ld	ra,24(sp)
    8000409e:	6442                	ld	s0,16(sp)
    800040a0:	64a2                	ld	s1,8(sp)
    800040a2:	6105                	addi	sp,sp,32
    800040a4:	8082                	ret

00000000800040a6 <ilock>:
{
    800040a6:	1101                	addi	sp,sp,-32
    800040a8:	ec06                	sd	ra,24(sp)
    800040aa:	e822                	sd	s0,16(sp)
    800040ac:	e426                	sd	s1,8(sp)
    800040ae:	e04a                	sd	s2,0(sp)
    800040b0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800040b2:	c115                	beqz	a0,800040d6 <ilock+0x30>
    800040b4:	84aa                	mv	s1,a0
    800040b6:	451c                	lw	a5,8(a0)
    800040b8:	00f05f63          	blez	a5,800040d6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800040bc:	0541                	addi	a0,a0,16
    800040be:	00001097          	auipc	ra,0x1
    800040c2:	fc8080e7          	jalr	-56(ra) # 80005086 <acquiresleep>
  if(ip->valid == 0){
    800040c6:	40bc                	lw	a5,64(s1)
    800040c8:	cf99                	beqz	a5,800040e6 <ilock+0x40>
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6902                	ld	s2,0(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret
    panic("ilock");
    800040d6:	00005517          	auipc	a0,0x5
    800040da:	7c250513          	addi	a0,a0,1986 # 80009898 <syscalls+0x188>
    800040de:	ffffc097          	auipc	ra,0xffffc
    800040e2:	44c080e7          	jalr	1100(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040e6:	40dc                	lw	a5,4(s1)
    800040e8:	0047d79b          	srliw	a5,a5,0x4
    800040ec:	00041597          	auipc	a1,0x41
    800040f0:	ed45a583          	lw	a1,-300(a1) # 80044fc0 <sb+0x18>
    800040f4:	9dbd                	addw	a1,a1,a5
    800040f6:	4088                	lw	a0,0(s1)
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	7aa080e7          	jalr	1962(ra) # 800038a2 <bread>
    80004100:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004102:	05850593          	addi	a1,a0,88
    80004106:	40dc                	lw	a5,4(s1)
    80004108:	8bbd                	andi	a5,a5,15
    8000410a:	079a                	slli	a5,a5,0x6
    8000410c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000410e:	00059783          	lh	a5,0(a1)
    80004112:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004116:	00259783          	lh	a5,2(a1)
    8000411a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000411e:	00459783          	lh	a5,4(a1)
    80004122:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004126:	00659783          	lh	a5,6(a1)
    8000412a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000412e:	459c                	lw	a5,8(a1)
    80004130:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004132:	03400613          	li	a2,52
    80004136:	05b1                	addi	a1,a1,12
    80004138:	05048513          	addi	a0,s1,80
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	bde080e7          	jalr	-1058(ra) # 80000d1a <memmove>
    brelse(bp);
    80004144:	854a                	mv	a0,s2
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	88c080e7          	jalr	-1908(ra) # 800039d2 <brelse>
    ip->valid = 1;
    8000414e:	4785                	li	a5,1
    80004150:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004152:	04449783          	lh	a5,68(s1)
    80004156:	fbb5                	bnez	a5,800040ca <ilock+0x24>
      panic("ilock: no type");
    80004158:	00005517          	auipc	a0,0x5
    8000415c:	74850513          	addi	a0,a0,1864 # 800098a0 <syscalls+0x190>
    80004160:	ffffc097          	auipc	ra,0xffffc
    80004164:	3ca080e7          	jalr	970(ra) # 8000052a <panic>

0000000080004168 <iunlock>:
{
    80004168:	1101                	addi	sp,sp,-32
    8000416a:	ec06                	sd	ra,24(sp)
    8000416c:	e822                	sd	s0,16(sp)
    8000416e:	e426                	sd	s1,8(sp)
    80004170:	e04a                	sd	s2,0(sp)
    80004172:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004174:	c905                	beqz	a0,800041a4 <iunlock+0x3c>
    80004176:	84aa                	mv	s1,a0
    80004178:	01050913          	addi	s2,a0,16
    8000417c:	854a                	mv	a0,s2
    8000417e:	00001097          	auipc	ra,0x1
    80004182:	fa2080e7          	jalr	-94(ra) # 80005120 <holdingsleep>
    80004186:	cd19                	beqz	a0,800041a4 <iunlock+0x3c>
    80004188:	449c                	lw	a5,8(s1)
    8000418a:	00f05d63          	blez	a5,800041a4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000418e:	854a                	mv	a0,s2
    80004190:	00001097          	auipc	ra,0x1
    80004194:	f4c080e7          	jalr	-180(ra) # 800050dc <releasesleep>
}
    80004198:	60e2                	ld	ra,24(sp)
    8000419a:	6442                	ld	s0,16(sp)
    8000419c:	64a2                	ld	s1,8(sp)
    8000419e:	6902                	ld	s2,0(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret
    panic("iunlock");
    800041a4:	00005517          	auipc	a0,0x5
    800041a8:	70c50513          	addi	a0,a0,1804 # 800098b0 <syscalls+0x1a0>
    800041ac:	ffffc097          	auipc	ra,0xffffc
    800041b0:	37e080e7          	jalr	894(ra) # 8000052a <panic>

00000000800041b4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800041b4:	7179                	addi	sp,sp,-48
    800041b6:	f406                	sd	ra,40(sp)
    800041b8:	f022                	sd	s0,32(sp)
    800041ba:	ec26                	sd	s1,24(sp)
    800041bc:	e84a                	sd	s2,16(sp)
    800041be:	e44e                	sd	s3,8(sp)
    800041c0:	e052                	sd	s4,0(sp)
    800041c2:	1800                	addi	s0,sp,48
    800041c4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800041c6:	05050493          	addi	s1,a0,80
    800041ca:	08050913          	addi	s2,a0,128
    800041ce:	a021                	j	800041d6 <itrunc+0x22>
    800041d0:	0491                	addi	s1,s1,4
    800041d2:	01248d63          	beq	s1,s2,800041ec <itrunc+0x38>
    if(ip->addrs[i]){
    800041d6:	408c                	lw	a1,0(s1)
    800041d8:	dde5                	beqz	a1,800041d0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800041da:	0009a503          	lw	a0,0(s3)
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	90a080e7          	jalr	-1782(ra) # 80003ae8 <bfree>
      ip->addrs[i] = 0;
    800041e6:	0004a023          	sw	zero,0(s1)
    800041ea:	b7dd                	j	800041d0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041ec:	0809a583          	lw	a1,128(s3)
    800041f0:	e185                	bnez	a1,80004210 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041f2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800041f6:	854e                	mv	a0,s3
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	de4080e7          	jalr	-540(ra) # 80003fdc <iupdate>
}
    80004200:	70a2                	ld	ra,40(sp)
    80004202:	7402                	ld	s0,32(sp)
    80004204:	64e2                	ld	s1,24(sp)
    80004206:	6942                	ld	s2,16(sp)
    80004208:	69a2                	ld	s3,8(sp)
    8000420a:	6a02                	ld	s4,0(sp)
    8000420c:	6145                	addi	sp,sp,48
    8000420e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004210:	0009a503          	lw	a0,0(s3)
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	68e080e7          	jalr	1678(ra) # 800038a2 <bread>
    8000421c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000421e:	05850493          	addi	s1,a0,88
    80004222:	45850913          	addi	s2,a0,1112
    80004226:	a021                	j	8000422e <itrunc+0x7a>
    80004228:	0491                	addi	s1,s1,4
    8000422a:	01248b63          	beq	s1,s2,80004240 <itrunc+0x8c>
      if(a[j])
    8000422e:	408c                	lw	a1,0(s1)
    80004230:	dde5                	beqz	a1,80004228 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004232:	0009a503          	lw	a0,0(s3)
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	8b2080e7          	jalr	-1870(ra) # 80003ae8 <bfree>
    8000423e:	b7ed                	j	80004228 <itrunc+0x74>
    brelse(bp);
    80004240:	8552                	mv	a0,s4
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	790080e7          	jalr	1936(ra) # 800039d2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000424a:	0809a583          	lw	a1,128(s3)
    8000424e:	0009a503          	lw	a0,0(s3)
    80004252:	00000097          	auipc	ra,0x0
    80004256:	896080e7          	jalr	-1898(ra) # 80003ae8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000425a:	0809a023          	sw	zero,128(s3)
    8000425e:	bf51                	j	800041f2 <itrunc+0x3e>

0000000080004260 <iput>:
{
    80004260:	1101                	addi	sp,sp,-32
    80004262:	ec06                	sd	ra,24(sp)
    80004264:	e822                	sd	s0,16(sp)
    80004266:	e426                	sd	s1,8(sp)
    80004268:	e04a                	sd	s2,0(sp)
    8000426a:	1000                	addi	s0,sp,32
    8000426c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000426e:	00041517          	auipc	a0,0x41
    80004272:	d5a50513          	addi	a0,a0,-678 # 80044fc8 <itable>
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	94c080e7          	jalr	-1716(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000427e:	4498                	lw	a4,8(s1)
    80004280:	4785                	li	a5,1
    80004282:	02f70363          	beq	a4,a5,800042a8 <iput+0x48>
  ip->ref--;
    80004286:	449c                	lw	a5,8(s1)
    80004288:	37fd                	addiw	a5,a5,-1
    8000428a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000428c:	00041517          	auipc	a0,0x41
    80004290:	d3c50513          	addi	a0,a0,-708 # 80044fc8 <itable>
    80004294:	ffffd097          	auipc	ra,0xffffd
    80004298:	9e2080e7          	jalr	-1566(ra) # 80000c76 <release>
}
    8000429c:	60e2                	ld	ra,24(sp)
    8000429e:	6442                	ld	s0,16(sp)
    800042a0:	64a2                	ld	s1,8(sp)
    800042a2:	6902                	ld	s2,0(sp)
    800042a4:	6105                	addi	sp,sp,32
    800042a6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042a8:	40bc                	lw	a5,64(s1)
    800042aa:	dff1                	beqz	a5,80004286 <iput+0x26>
    800042ac:	04a49783          	lh	a5,74(s1)
    800042b0:	fbf9                	bnez	a5,80004286 <iput+0x26>
    acquiresleep(&ip->lock);
    800042b2:	01048913          	addi	s2,s1,16
    800042b6:	854a                	mv	a0,s2
    800042b8:	00001097          	auipc	ra,0x1
    800042bc:	dce080e7          	jalr	-562(ra) # 80005086 <acquiresleep>
    release(&itable.lock);
    800042c0:	00041517          	auipc	a0,0x41
    800042c4:	d0850513          	addi	a0,a0,-760 # 80044fc8 <itable>
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	9ae080e7          	jalr	-1618(ra) # 80000c76 <release>
    itrunc(ip);
    800042d0:	8526                	mv	a0,s1
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	ee2080e7          	jalr	-286(ra) # 800041b4 <itrunc>
    ip->type = 0;
    800042da:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800042de:	8526                	mv	a0,s1
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	cfc080e7          	jalr	-772(ra) # 80003fdc <iupdate>
    ip->valid = 0;
    800042e8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042ec:	854a                	mv	a0,s2
    800042ee:	00001097          	auipc	ra,0x1
    800042f2:	dee080e7          	jalr	-530(ra) # 800050dc <releasesleep>
    acquire(&itable.lock);
    800042f6:	00041517          	auipc	a0,0x41
    800042fa:	cd250513          	addi	a0,a0,-814 # 80044fc8 <itable>
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	8c4080e7          	jalr	-1852(ra) # 80000bc2 <acquire>
    80004306:	b741                	j	80004286 <iput+0x26>

0000000080004308 <iunlockput>:
{
    80004308:	1101                	addi	sp,sp,-32
    8000430a:	ec06                	sd	ra,24(sp)
    8000430c:	e822                	sd	s0,16(sp)
    8000430e:	e426                	sd	s1,8(sp)
    80004310:	1000                	addi	s0,sp,32
    80004312:	84aa                	mv	s1,a0
  iunlock(ip);
    80004314:	00000097          	auipc	ra,0x0
    80004318:	e54080e7          	jalr	-428(ra) # 80004168 <iunlock>
  iput(ip);
    8000431c:	8526                	mv	a0,s1
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	f42080e7          	jalr	-190(ra) # 80004260 <iput>
}
    80004326:	60e2                	ld	ra,24(sp)
    80004328:	6442                	ld	s0,16(sp)
    8000432a:	64a2                	ld	s1,8(sp)
    8000432c:	6105                	addi	sp,sp,32
    8000432e:	8082                	ret

0000000080004330 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004330:	1141                	addi	sp,sp,-16
    80004332:	e422                	sd	s0,8(sp)
    80004334:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004336:	411c                	lw	a5,0(a0)
    80004338:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000433a:	415c                	lw	a5,4(a0)
    8000433c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000433e:	04451783          	lh	a5,68(a0)
    80004342:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004346:	04a51783          	lh	a5,74(a0)
    8000434a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000434e:	04c56783          	lwu	a5,76(a0)
    80004352:	e99c                	sd	a5,16(a1)
}
    80004354:	6422                	ld	s0,8(sp)
    80004356:	0141                	addi	sp,sp,16
    80004358:	8082                	ret

000000008000435a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000435a:	457c                	lw	a5,76(a0)
    8000435c:	0ed7e963          	bltu	a5,a3,8000444e <readi+0xf4>
{
    80004360:	7159                	addi	sp,sp,-112
    80004362:	f486                	sd	ra,104(sp)
    80004364:	f0a2                	sd	s0,96(sp)
    80004366:	eca6                	sd	s1,88(sp)
    80004368:	e8ca                	sd	s2,80(sp)
    8000436a:	e4ce                	sd	s3,72(sp)
    8000436c:	e0d2                	sd	s4,64(sp)
    8000436e:	fc56                	sd	s5,56(sp)
    80004370:	f85a                	sd	s6,48(sp)
    80004372:	f45e                	sd	s7,40(sp)
    80004374:	f062                	sd	s8,32(sp)
    80004376:	ec66                	sd	s9,24(sp)
    80004378:	e86a                	sd	s10,16(sp)
    8000437a:	e46e                	sd	s11,8(sp)
    8000437c:	1880                	addi	s0,sp,112
    8000437e:	8baa                	mv	s7,a0
    80004380:	8c2e                	mv	s8,a1
    80004382:	8ab2                	mv	s5,a2
    80004384:	84b6                	mv	s1,a3
    80004386:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004388:	9f35                	addw	a4,a4,a3
    return 0;
    8000438a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000438c:	0ad76063          	bltu	a4,a3,8000442c <readi+0xd2>
  if(off + n > ip->size)
    80004390:	00e7f463          	bgeu	a5,a4,80004398 <readi+0x3e>
    n = ip->size - off;
    80004394:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004398:	0a0b0963          	beqz	s6,8000444a <readi+0xf0>
    8000439c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000439e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800043a2:	5cfd                	li	s9,-1
    800043a4:	a82d                	j	800043de <readi+0x84>
    800043a6:	020a1d93          	slli	s11,s4,0x20
    800043aa:	020ddd93          	srli	s11,s11,0x20
    800043ae:	05890793          	addi	a5,s2,88
    800043b2:	86ee                	mv	a3,s11
    800043b4:	963e                	add	a2,a2,a5
    800043b6:	85d6                	mv	a1,s5
    800043b8:	8562                	mv	a0,s8
    800043ba:	ffffe097          	auipc	ra,0xffffe
    800043be:	e54080e7          	jalr	-428(ra) # 8000220e <either_copyout>
    800043c2:	05950d63          	beq	a0,s9,8000441c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800043c6:	854a                	mv	a0,s2
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	60a080e7          	jalr	1546(ra) # 800039d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043d0:	013a09bb          	addw	s3,s4,s3
    800043d4:	009a04bb          	addw	s1,s4,s1
    800043d8:	9aee                	add	s5,s5,s11
    800043da:	0569f763          	bgeu	s3,s6,80004428 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800043de:	000ba903          	lw	s2,0(s7) # 1000 <_entry-0x7ffff000>
    800043e2:	00a4d59b          	srliw	a1,s1,0xa
    800043e6:	855e                	mv	a0,s7
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	8ae080e7          	jalr	-1874(ra) # 80003c96 <bmap>
    800043f0:	0005059b          	sext.w	a1,a0
    800043f4:	854a                	mv	a0,s2
    800043f6:	fffff097          	auipc	ra,0xfffff
    800043fa:	4ac080e7          	jalr	1196(ra) # 800038a2 <bread>
    800043fe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004400:	3ff4f613          	andi	a2,s1,1023
    80004404:	40cd07bb          	subw	a5,s10,a2
    80004408:	413b073b          	subw	a4,s6,s3
    8000440c:	8a3e                	mv	s4,a5
    8000440e:	2781                	sext.w	a5,a5
    80004410:	0007069b          	sext.w	a3,a4
    80004414:	f8f6f9e3          	bgeu	a3,a5,800043a6 <readi+0x4c>
    80004418:	8a3a                	mv	s4,a4
    8000441a:	b771                	j	800043a6 <readi+0x4c>
      brelse(bp);
    8000441c:	854a                	mv	a0,s2
    8000441e:	fffff097          	auipc	ra,0xfffff
    80004422:	5b4080e7          	jalr	1460(ra) # 800039d2 <brelse>
      tot = -1;
    80004426:	59fd                	li	s3,-1
  }
  return tot;
    80004428:	0009851b          	sext.w	a0,s3
}
    8000442c:	70a6                	ld	ra,104(sp)
    8000442e:	7406                	ld	s0,96(sp)
    80004430:	64e6                	ld	s1,88(sp)
    80004432:	6946                	ld	s2,80(sp)
    80004434:	69a6                	ld	s3,72(sp)
    80004436:	6a06                	ld	s4,64(sp)
    80004438:	7ae2                	ld	s5,56(sp)
    8000443a:	7b42                	ld	s6,48(sp)
    8000443c:	7ba2                	ld	s7,40(sp)
    8000443e:	7c02                	ld	s8,32(sp)
    80004440:	6ce2                	ld	s9,24(sp)
    80004442:	6d42                	ld	s10,16(sp)
    80004444:	6da2                	ld	s11,8(sp)
    80004446:	6165                	addi	sp,sp,112
    80004448:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000444a:	89da                	mv	s3,s6
    8000444c:	bff1                	j	80004428 <readi+0xce>
    return 0;
    8000444e:	4501                	li	a0,0
}
    80004450:	8082                	ret

0000000080004452 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004452:	457c                	lw	a5,76(a0)
    80004454:	10d7e863          	bltu	a5,a3,80004564 <writei+0x112>
{
    80004458:	7159                	addi	sp,sp,-112
    8000445a:	f486                	sd	ra,104(sp)
    8000445c:	f0a2                	sd	s0,96(sp)
    8000445e:	eca6                	sd	s1,88(sp)
    80004460:	e8ca                	sd	s2,80(sp)
    80004462:	e4ce                	sd	s3,72(sp)
    80004464:	e0d2                	sd	s4,64(sp)
    80004466:	fc56                	sd	s5,56(sp)
    80004468:	f85a                	sd	s6,48(sp)
    8000446a:	f45e                	sd	s7,40(sp)
    8000446c:	f062                	sd	s8,32(sp)
    8000446e:	ec66                	sd	s9,24(sp)
    80004470:	e86a                	sd	s10,16(sp)
    80004472:	e46e                	sd	s11,8(sp)
    80004474:	1880                	addi	s0,sp,112
    80004476:	8b2a                	mv	s6,a0
    80004478:	8c2e                	mv	s8,a1
    8000447a:	8ab2                	mv	s5,a2
    8000447c:	8936                	mv	s2,a3
    8000447e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004480:	00e687bb          	addw	a5,a3,a4
    80004484:	0ed7e263          	bltu	a5,a3,80004568 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004488:	00043737          	lui	a4,0x43
    8000448c:	0ef76063          	bltu	a4,a5,8000456c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004490:	0c0b8863          	beqz	s7,80004560 <writei+0x10e>
    80004494:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004496:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000449a:	5cfd                	li	s9,-1
    8000449c:	a091                	j	800044e0 <writei+0x8e>
    8000449e:	02099d93          	slli	s11,s3,0x20
    800044a2:	020ddd93          	srli	s11,s11,0x20
    800044a6:	05848793          	addi	a5,s1,88
    800044aa:	86ee                	mv	a3,s11
    800044ac:	8656                	mv	a2,s5
    800044ae:	85e2                	mv	a1,s8
    800044b0:	953e                	add	a0,a0,a5
    800044b2:	ffffe097          	auipc	ra,0xffffe
    800044b6:	db2080e7          	jalr	-590(ra) # 80002264 <either_copyin>
    800044ba:	07950263          	beq	a0,s9,8000451e <writei+0xcc>

      brelse(bp);
      break;
    }
    log_write(bp);
    800044be:	8526                	mv	a0,s1
    800044c0:	00001097          	auipc	ra,0x1
    800044c4:	aa6080e7          	jalr	-1370(ra) # 80004f66 <log_write>
    brelse(bp);
    800044c8:	8526                	mv	a0,s1
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	508080e7          	jalr	1288(ra) # 800039d2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044d2:	01498a3b          	addw	s4,s3,s4
    800044d6:	0129893b          	addw	s2,s3,s2
    800044da:	9aee                	add	s5,s5,s11
    800044dc:	057a7663          	bgeu	s4,s7,80004528 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800044e0:	000b2483          	lw	s1,0(s6)
    800044e4:	00a9559b          	srliw	a1,s2,0xa
    800044e8:	855a                	mv	a0,s6
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	7ac080e7          	jalr	1964(ra) # 80003c96 <bmap>
    800044f2:	0005059b          	sext.w	a1,a0
    800044f6:	8526                	mv	a0,s1
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	3aa080e7          	jalr	938(ra) # 800038a2 <bread>
    80004500:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004502:	3ff97513          	andi	a0,s2,1023
    80004506:	40ad07bb          	subw	a5,s10,a0
    8000450a:	414b873b          	subw	a4,s7,s4
    8000450e:	89be                	mv	s3,a5
    80004510:	2781                	sext.w	a5,a5
    80004512:	0007069b          	sext.w	a3,a4
    80004516:	f8f6f4e3          	bgeu	a3,a5,8000449e <writei+0x4c>
    8000451a:	89ba                	mv	s3,a4
    8000451c:	b749                	j	8000449e <writei+0x4c>
      brelse(bp);
    8000451e:	8526                	mv	a0,s1
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	4b2080e7          	jalr	1202(ra) # 800039d2 <brelse>
  }

  if(off > ip->size)
    80004528:	04cb2783          	lw	a5,76(s6)
    8000452c:	0127f463          	bgeu	a5,s2,80004534 <writei+0xe2>
    ip->size = off;
    80004530:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004534:	855a                	mv	a0,s6
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	aa6080e7          	jalr	-1370(ra) # 80003fdc <iupdate>

  return tot;
    8000453e:	000a051b          	sext.w	a0,s4
}
    80004542:	70a6                	ld	ra,104(sp)
    80004544:	7406                	ld	s0,96(sp)
    80004546:	64e6                	ld	s1,88(sp)
    80004548:	6946                	ld	s2,80(sp)
    8000454a:	69a6                	ld	s3,72(sp)
    8000454c:	6a06                	ld	s4,64(sp)
    8000454e:	7ae2                	ld	s5,56(sp)
    80004550:	7b42                	ld	s6,48(sp)
    80004552:	7ba2                	ld	s7,40(sp)
    80004554:	7c02                	ld	s8,32(sp)
    80004556:	6ce2                	ld	s9,24(sp)
    80004558:	6d42                	ld	s10,16(sp)
    8000455a:	6da2                	ld	s11,8(sp)
    8000455c:	6165                	addi	sp,sp,112
    8000455e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004560:	8a5e                	mv	s4,s7
    80004562:	bfc9                	j	80004534 <writei+0xe2>
    return -1;
    80004564:	557d                	li	a0,-1
}
    80004566:	8082                	ret
    return -1;
    80004568:	557d                	li	a0,-1
    8000456a:	bfe1                	j	80004542 <writei+0xf0>
    return -1;
    8000456c:	557d                	li	a0,-1
    8000456e:	bfd1                	j	80004542 <writei+0xf0>

0000000080004570 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004570:	1141                	addi	sp,sp,-16
    80004572:	e406                	sd	ra,8(sp)
    80004574:	e022                	sd	s0,0(sp)
    80004576:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004578:	4639                	li	a2,14
    8000457a:	ffffd097          	auipc	ra,0xffffd
    8000457e:	81c080e7          	jalr	-2020(ra) # 80000d96 <strncmp>
}
    80004582:	60a2                	ld	ra,8(sp)
    80004584:	6402                	ld	s0,0(sp)
    80004586:	0141                	addi	sp,sp,16
    80004588:	8082                	ret

000000008000458a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	ec4e                	sd	s3,24(sp)
    80004596:	e852                	sd	s4,16(sp)
    80004598:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000459a:	04451703          	lh	a4,68(a0)
    8000459e:	4785                	li	a5,1
    800045a0:	00f71a63          	bne	a4,a5,800045b4 <dirlookup+0x2a>
    800045a4:	892a                	mv	s2,a0
    800045a6:	89ae                	mv	s3,a1
    800045a8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800045aa:	457c                	lw	a5,76(a0)
    800045ac:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800045ae:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045b0:	e79d                	bnez	a5,800045de <dirlookup+0x54>
    800045b2:	a8a5                	j	8000462a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800045b4:	00005517          	auipc	a0,0x5
    800045b8:	30450513          	addi	a0,a0,772 # 800098b8 <syscalls+0x1a8>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("dirlookup read");
    800045c4:	00005517          	auipc	a0,0x5
    800045c8:	30c50513          	addi	a0,a0,780 # 800098d0 <syscalls+0x1c0>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045d4:	24c1                	addiw	s1,s1,16
    800045d6:	04c92783          	lw	a5,76(s2)
    800045da:	04f4f763          	bgeu	s1,a5,80004628 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045de:	4741                	li	a4,16
    800045e0:	86a6                	mv	a3,s1
    800045e2:	fc040613          	addi	a2,s0,-64
    800045e6:	4581                	li	a1,0
    800045e8:	854a                	mv	a0,s2
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	d70080e7          	jalr	-656(ra) # 8000435a <readi>
    800045f2:	47c1                	li	a5,16
    800045f4:	fcf518e3          	bne	a0,a5,800045c4 <dirlookup+0x3a>
    if(de.inum == 0)
    800045f8:	fc045783          	lhu	a5,-64(s0)
    800045fc:	dfe1                	beqz	a5,800045d4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800045fe:	fc240593          	addi	a1,s0,-62
    80004602:	854e                	mv	a0,s3
    80004604:	00000097          	auipc	ra,0x0
    80004608:	f6c080e7          	jalr	-148(ra) # 80004570 <namecmp>
    8000460c:	f561                	bnez	a0,800045d4 <dirlookup+0x4a>
      if(poff)
    8000460e:	000a0463          	beqz	s4,80004616 <dirlookup+0x8c>
        *poff = off;
    80004612:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004616:	fc045583          	lhu	a1,-64(s0)
    8000461a:	00092503          	lw	a0,0(s2)
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	754080e7          	jalr	1876(ra) # 80003d72 <iget>
    80004626:	a011                	j	8000462a <dirlookup+0xa0>
  return 0;
    80004628:	4501                	li	a0,0
}
    8000462a:	70e2                	ld	ra,56(sp)
    8000462c:	7442                	ld	s0,48(sp)
    8000462e:	74a2                	ld	s1,40(sp)
    80004630:	7902                	ld	s2,32(sp)
    80004632:	69e2                	ld	s3,24(sp)
    80004634:	6a42                	ld	s4,16(sp)
    80004636:	6121                	addi	sp,sp,64
    80004638:	8082                	ret

000000008000463a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000463a:	711d                	addi	sp,sp,-96
    8000463c:	ec86                	sd	ra,88(sp)
    8000463e:	e8a2                	sd	s0,80(sp)
    80004640:	e4a6                	sd	s1,72(sp)
    80004642:	e0ca                	sd	s2,64(sp)
    80004644:	fc4e                	sd	s3,56(sp)
    80004646:	f852                	sd	s4,48(sp)
    80004648:	f456                	sd	s5,40(sp)
    8000464a:	f05a                	sd	s6,32(sp)
    8000464c:	ec5e                	sd	s7,24(sp)
    8000464e:	e862                	sd	s8,16(sp)
    80004650:	e466                	sd	s9,8(sp)
    80004652:	1080                	addi	s0,sp,96
    80004654:	84aa                	mv	s1,a0
    80004656:	8aae                	mv	s5,a1
    80004658:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000465a:	00054703          	lbu	a4,0(a0)
    8000465e:	02f00793          	li	a5,47
    80004662:	02f70363          	beq	a4,a5,80004688 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004666:	ffffd097          	auipc	ra,0xffffd
    8000466a:	520080e7          	jalr	1312(ra) # 80001b86 <myproc>
    8000466e:	15053503          	ld	a0,336(a0)
    80004672:	00000097          	auipc	ra,0x0
    80004676:	9f6080e7          	jalr	-1546(ra) # 80004068 <idup>
    8000467a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000467c:	02f00913          	li	s2,47
  len = path - s;
    80004680:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004682:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004684:	4b85                	li	s7,1
    80004686:	a865                	j	8000473e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004688:	4585                	li	a1,1
    8000468a:	4505                	li	a0,1
    8000468c:	fffff097          	auipc	ra,0xfffff
    80004690:	6e6080e7          	jalr	1766(ra) # 80003d72 <iget>
    80004694:	89aa                	mv	s3,a0
    80004696:	b7dd                	j	8000467c <namex+0x42>
      iunlockput(ip);
    80004698:	854e                	mv	a0,s3
    8000469a:	00000097          	auipc	ra,0x0
    8000469e:	c6e080e7          	jalr	-914(ra) # 80004308 <iunlockput>
      return 0;
    800046a2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800046a4:	854e                	mv	a0,s3
    800046a6:	60e6                	ld	ra,88(sp)
    800046a8:	6446                	ld	s0,80(sp)
    800046aa:	64a6                	ld	s1,72(sp)
    800046ac:	6906                	ld	s2,64(sp)
    800046ae:	79e2                	ld	s3,56(sp)
    800046b0:	7a42                	ld	s4,48(sp)
    800046b2:	7aa2                	ld	s5,40(sp)
    800046b4:	7b02                	ld	s6,32(sp)
    800046b6:	6be2                	ld	s7,24(sp)
    800046b8:	6c42                	ld	s8,16(sp)
    800046ba:	6ca2                	ld	s9,8(sp)
    800046bc:	6125                	addi	sp,sp,96
    800046be:	8082                	ret
      iunlock(ip);
    800046c0:	854e                	mv	a0,s3
    800046c2:	00000097          	auipc	ra,0x0
    800046c6:	aa6080e7          	jalr	-1370(ra) # 80004168 <iunlock>
      return ip;
    800046ca:	bfe9                	j	800046a4 <namex+0x6a>
      iunlockput(ip);
    800046cc:	854e                	mv	a0,s3
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	c3a080e7          	jalr	-966(ra) # 80004308 <iunlockput>
      return 0;
    800046d6:	89e6                	mv	s3,s9
    800046d8:	b7f1                	j	800046a4 <namex+0x6a>
  len = path - s;
    800046da:	40b48633          	sub	a2,s1,a1
    800046de:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800046e2:	099c5463          	bge	s8,s9,8000476a <namex+0x130>
    memmove(name, s, DIRSIZ);
    800046e6:	4639                	li	a2,14
    800046e8:	8552                	mv	a0,s4
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	630080e7          	jalr	1584(ra) # 80000d1a <memmove>
  while(*path == '/')
    800046f2:	0004c783          	lbu	a5,0(s1)
    800046f6:	01279763          	bne	a5,s2,80004704 <namex+0xca>
    path++;
    800046fa:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046fc:	0004c783          	lbu	a5,0(s1)
    80004700:	ff278de3          	beq	a5,s2,800046fa <namex+0xc0>
    ilock(ip);
    80004704:	854e                	mv	a0,s3
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	9a0080e7          	jalr	-1632(ra) # 800040a6 <ilock>
    if(ip->type != T_DIR){
    8000470e:	04499783          	lh	a5,68(s3)
    80004712:	f97793e3          	bne	a5,s7,80004698 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004716:	000a8563          	beqz	s5,80004720 <namex+0xe6>
    8000471a:	0004c783          	lbu	a5,0(s1)
    8000471e:	d3cd                	beqz	a5,800046c0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004720:	865a                	mv	a2,s6
    80004722:	85d2                	mv	a1,s4
    80004724:	854e                	mv	a0,s3
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	e64080e7          	jalr	-412(ra) # 8000458a <dirlookup>
    8000472e:	8caa                	mv	s9,a0
    80004730:	dd51                	beqz	a0,800046cc <namex+0x92>
    iunlockput(ip);
    80004732:	854e                	mv	a0,s3
    80004734:	00000097          	auipc	ra,0x0
    80004738:	bd4080e7          	jalr	-1068(ra) # 80004308 <iunlockput>
    ip = next;
    8000473c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000473e:	0004c783          	lbu	a5,0(s1)
    80004742:	05279763          	bne	a5,s2,80004790 <namex+0x156>
    path++;
    80004746:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004748:	0004c783          	lbu	a5,0(s1)
    8000474c:	ff278de3          	beq	a5,s2,80004746 <namex+0x10c>
  if(*path == 0)
    80004750:	c79d                	beqz	a5,8000477e <namex+0x144>
    path++;
    80004752:	85a6                	mv	a1,s1
  len = path - s;
    80004754:	8cda                	mv	s9,s6
    80004756:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004758:	01278963          	beq	a5,s2,8000476a <namex+0x130>
    8000475c:	dfbd                	beqz	a5,800046da <namex+0xa0>
    path++;
    8000475e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004760:	0004c783          	lbu	a5,0(s1)
    80004764:	ff279ce3          	bne	a5,s2,8000475c <namex+0x122>
    80004768:	bf8d                	j	800046da <namex+0xa0>
    memmove(name, s, len);
    8000476a:	2601                	sext.w	a2,a2
    8000476c:	8552                	mv	a0,s4
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	5ac080e7          	jalr	1452(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004776:	9cd2                	add	s9,s9,s4
    80004778:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000477c:	bf9d                	j	800046f2 <namex+0xb8>
  if(nameiparent){
    8000477e:	f20a83e3          	beqz	s5,800046a4 <namex+0x6a>
    iput(ip);
    80004782:	854e                	mv	a0,s3
    80004784:	00000097          	auipc	ra,0x0
    80004788:	adc080e7          	jalr	-1316(ra) # 80004260 <iput>
    return 0;
    8000478c:	4981                	li	s3,0
    8000478e:	bf19                	j	800046a4 <namex+0x6a>
  if(*path == 0)
    80004790:	d7fd                	beqz	a5,8000477e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004792:	0004c783          	lbu	a5,0(s1)
    80004796:	85a6                	mv	a1,s1
    80004798:	b7d1                	j	8000475c <namex+0x122>

000000008000479a <dirlink>:
{
    8000479a:	7139                	addi	sp,sp,-64
    8000479c:	fc06                	sd	ra,56(sp)
    8000479e:	f822                	sd	s0,48(sp)
    800047a0:	f426                	sd	s1,40(sp)
    800047a2:	f04a                	sd	s2,32(sp)
    800047a4:	ec4e                	sd	s3,24(sp)
    800047a6:	e852                	sd	s4,16(sp)
    800047a8:	0080                	addi	s0,sp,64
    800047aa:	892a                	mv	s2,a0
    800047ac:	8a2e                	mv	s4,a1
    800047ae:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800047b0:	4601                	li	a2,0
    800047b2:	00000097          	auipc	ra,0x0
    800047b6:	dd8080e7          	jalr	-552(ra) # 8000458a <dirlookup>
    800047ba:	e93d                	bnez	a0,80004830 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047bc:	04c92483          	lw	s1,76(s2)
    800047c0:	c49d                	beqz	s1,800047ee <dirlink+0x54>
    800047c2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047c4:	4741                	li	a4,16
    800047c6:	86a6                	mv	a3,s1
    800047c8:	fc040613          	addi	a2,s0,-64
    800047cc:	4581                	li	a1,0
    800047ce:	854a                	mv	a0,s2
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	b8a080e7          	jalr	-1142(ra) # 8000435a <readi>
    800047d8:	47c1                	li	a5,16
    800047da:	06f51163          	bne	a0,a5,8000483c <dirlink+0xa2>
    if(de.inum == 0)
    800047de:	fc045783          	lhu	a5,-64(s0)
    800047e2:	c791                	beqz	a5,800047ee <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047e4:	24c1                	addiw	s1,s1,16
    800047e6:	04c92783          	lw	a5,76(s2)
    800047ea:	fcf4ede3          	bltu	s1,a5,800047c4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800047ee:	4639                	li	a2,14
    800047f0:	85d2                	mv	a1,s4
    800047f2:	fc240513          	addi	a0,s0,-62
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	5dc080e7          	jalr	1500(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800047fe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004802:	4741                	li	a4,16
    80004804:	86a6                	mv	a3,s1
    80004806:	fc040613          	addi	a2,s0,-64
    8000480a:	4581                	li	a1,0
    8000480c:	854a                	mv	a0,s2
    8000480e:	00000097          	auipc	ra,0x0
    80004812:	c44080e7          	jalr	-956(ra) # 80004452 <writei>
    80004816:	872a                	mv	a4,a0
    80004818:	47c1                	li	a5,16
  return 0;
    8000481a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000481c:	02f71863          	bne	a4,a5,8000484c <dirlink+0xb2>
}
    80004820:	70e2                	ld	ra,56(sp)
    80004822:	7442                	ld	s0,48(sp)
    80004824:	74a2                	ld	s1,40(sp)
    80004826:	7902                	ld	s2,32(sp)
    80004828:	69e2                	ld	s3,24(sp)
    8000482a:	6a42                	ld	s4,16(sp)
    8000482c:	6121                	addi	sp,sp,64
    8000482e:	8082                	ret
    iput(ip);
    80004830:	00000097          	auipc	ra,0x0
    80004834:	a30080e7          	jalr	-1488(ra) # 80004260 <iput>
    return -1;
    80004838:	557d                	li	a0,-1
    8000483a:	b7dd                	j	80004820 <dirlink+0x86>
      panic("dirlink read");
    8000483c:	00005517          	auipc	a0,0x5
    80004840:	0a450513          	addi	a0,a0,164 # 800098e0 <syscalls+0x1d0>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	ce6080e7          	jalr	-794(ra) # 8000052a <panic>
    panic("dirlink");
    8000484c:	00005517          	auipc	a0,0x5
    80004850:	21c50513          	addi	a0,a0,540 # 80009a68 <syscalls+0x358>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	cd6080e7          	jalr	-810(ra) # 8000052a <panic>

000000008000485c <namei>:

struct inode*
namei(char *path)
{
    8000485c:	1101                	addi	sp,sp,-32
    8000485e:	ec06                	sd	ra,24(sp)
    80004860:	e822                	sd	s0,16(sp)
    80004862:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004864:	fe040613          	addi	a2,s0,-32
    80004868:	4581                	li	a1,0
    8000486a:	00000097          	auipc	ra,0x0
    8000486e:	dd0080e7          	jalr	-560(ra) # 8000463a <namex>
}
    80004872:	60e2                	ld	ra,24(sp)
    80004874:	6442                	ld	s0,16(sp)
    80004876:	6105                	addi	sp,sp,32
    80004878:	8082                	ret

000000008000487a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000487a:	1141                	addi	sp,sp,-16
    8000487c:	e406                	sd	ra,8(sp)
    8000487e:	e022                	sd	s0,0(sp)
    80004880:	0800                	addi	s0,sp,16
    80004882:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004884:	4585                	li	a1,1
    80004886:	00000097          	auipc	ra,0x0
    8000488a:	db4080e7          	jalr	-588(ra) # 8000463a <namex>
}
    8000488e:	60a2                	ld	ra,8(sp)
    80004890:	6402                	ld	s0,0(sp)
    80004892:	0141                	addi	sp,sp,16
    80004894:	8082                	ret

0000000080004896 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004896:	1101                	addi	sp,sp,-32
    80004898:	ec22                	sd	s0,24(sp)
    8000489a:	1000                	addi	s0,sp,32
    8000489c:	872a                	mv	a4,a0
    8000489e:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800048a0:	00005797          	auipc	a5,0x5
    800048a4:	05078793          	addi	a5,a5,80 # 800098f0 <syscalls+0x1e0>
    800048a8:	6394                	ld	a3,0(a5)
    800048aa:	fed43023          	sd	a3,-32(s0)
    800048ae:	0087d683          	lhu	a3,8(a5)
    800048b2:	fed41423          	sh	a3,-24(s0)
    800048b6:	00a7c783          	lbu	a5,10(a5)
    800048ba:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    800048be:	87ae                	mv	a5,a1
    if(i<0){
    800048c0:	02074b63          	bltz	a4,800048f6 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800048c4:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800048c6:	4629                	li	a2,10
        ++p;
    800048c8:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800048ca:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800048ce:	feed                	bnez	a3,800048c8 <itoa+0x32>
    *p = '\0';
    800048d0:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800048d4:	4629                	li	a2,10
    800048d6:	17fd                	addi	a5,a5,-1
    800048d8:	02c766bb          	remw	a3,a4,a2
    800048dc:	ff040593          	addi	a1,s0,-16
    800048e0:	96ae                	add	a3,a3,a1
    800048e2:	ff06c683          	lbu	a3,-16(a3)
    800048e6:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800048ea:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800048ee:	f765                	bnez	a4,800048d6 <itoa+0x40>
    return b;
}
    800048f0:	6462                	ld	s0,24(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret
        *p++ = '-';
    800048f6:	00158793          	addi	a5,a1,1
    800048fa:	02d00693          	li	a3,45
    800048fe:	00d58023          	sb	a3,0(a1)
        i *= -1;
    80004902:	40e0073b          	negw	a4,a4
    80004906:	bf7d                	j	800048c4 <itoa+0x2e>

0000000080004908 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004908:	711d                	addi	sp,sp,-96
    8000490a:	ec86                	sd	ra,88(sp)
    8000490c:	e8a2                	sd	s0,80(sp)
    8000490e:	e4a6                	sd	s1,72(sp)
    80004910:	e0ca                	sd	s2,64(sp)
    80004912:	1080                	addi	s0,sp,96
    80004914:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004916:	4619                	li	a2,6
    80004918:	00005597          	auipc	a1,0x5
    8000491c:	fe858593          	addi	a1,a1,-24 # 80009900 <syscalls+0x1f0>
    80004920:	fd040513          	addi	a0,s0,-48
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	3f6080e7          	jalr	1014(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    8000492c:	fd640593          	addi	a1,s0,-42
    80004930:	5888                	lw	a0,48(s1)
    80004932:	00000097          	auipc	ra,0x0
    80004936:	f64080e7          	jalr	-156(ra) # 80004896 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    8000493a:	1684b503          	ld	a0,360(s1)
    8000493e:	16050763          	beqz	a0,80004aac <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004942:	00001097          	auipc	ra,0x1
    80004946:	918080e7          	jalr	-1768(ra) # 8000525a <fileclose>

  begin_op();
    8000494a:	00000097          	auipc	ra,0x0
    8000494e:	444080e7          	jalr	1092(ra) # 80004d8e <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004952:	fb040593          	addi	a1,s0,-80
    80004956:	fd040513          	addi	a0,s0,-48
    8000495a:	00000097          	auipc	ra,0x0
    8000495e:	f20080e7          	jalr	-224(ra) # 8000487a <nameiparent>
    80004962:	892a                	mv	s2,a0
    80004964:	cd69                	beqz	a0,80004a3e <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	740080e7          	jalr	1856(ra) # 800040a6 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000496e:	00005597          	auipc	a1,0x5
    80004972:	f9a58593          	addi	a1,a1,-102 # 80009908 <syscalls+0x1f8>
    80004976:	fb040513          	addi	a0,s0,-80
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	bf6080e7          	jalr	-1034(ra) # 80004570 <namecmp>
    80004982:	c57d                	beqz	a0,80004a70 <removeSwapFile+0x168>
    80004984:	00005597          	auipc	a1,0x5
    80004988:	f8c58593          	addi	a1,a1,-116 # 80009910 <syscalls+0x200>
    8000498c:	fb040513          	addi	a0,s0,-80
    80004990:	00000097          	auipc	ra,0x0
    80004994:	be0080e7          	jalr	-1056(ra) # 80004570 <namecmp>
    80004998:	cd61                	beqz	a0,80004a70 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000499a:	fac40613          	addi	a2,s0,-84
    8000499e:	fb040593          	addi	a1,s0,-80
    800049a2:	854a                	mv	a0,s2
    800049a4:	00000097          	auipc	ra,0x0
    800049a8:	be6080e7          	jalr	-1050(ra) # 8000458a <dirlookup>
    800049ac:	84aa                	mv	s1,a0
    800049ae:	c169                	beqz	a0,80004a70 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	6f6080e7          	jalr	1782(ra) # 800040a6 <ilock>

  if(ip->nlink < 1)
    800049b8:	04a49783          	lh	a5,74(s1)
    800049bc:	08f05763          	blez	a5,80004a4a <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800049c0:	04449703          	lh	a4,68(s1)
    800049c4:	4785                	li	a5,1
    800049c6:	08f70a63          	beq	a4,a5,80004a5a <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800049ca:	4641                	li	a2,16
    800049cc:	4581                	li	a1,0
    800049ce:	fc040513          	addi	a0,s0,-64
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	2ec080e7          	jalr	748(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049da:	4741                	li	a4,16
    800049dc:	fac42683          	lw	a3,-84(s0)
    800049e0:	fc040613          	addi	a2,s0,-64
    800049e4:	4581                	li	a1,0
    800049e6:	854a                	mv	a0,s2
    800049e8:	00000097          	auipc	ra,0x0
    800049ec:	a6a080e7          	jalr	-1430(ra) # 80004452 <writei>
    800049f0:	47c1                	li	a5,16
    800049f2:	08f51a63          	bne	a0,a5,80004a86 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800049f6:	04449703          	lh	a4,68(s1)
    800049fa:	4785                	li	a5,1
    800049fc:	08f70d63          	beq	a4,a5,80004a96 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80004a00:	854a                	mv	a0,s2
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	906080e7          	jalr	-1786(ra) # 80004308 <iunlockput>

  ip->nlink--;
    80004a0a:	04a4d783          	lhu	a5,74(s1)
    80004a0e:	37fd                	addiw	a5,a5,-1
    80004a10:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a14:	8526                	mv	a0,s1
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	5c6080e7          	jalr	1478(ra) # 80003fdc <iupdate>
  iunlockput(ip);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	8e8080e7          	jalr	-1816(ra) # 80004308 <iunlockput>

  end_op();
    80004a28:	00000097          	auipc	ra,0x0
    80004a2c:	3e6080e7          	jalr	998(ra) # 80004e0e <end_op>

  return 0;
    80004a30:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    80004a32:	60e6                	ld	ra,88(sp)
    80004a34:	6446                	ld	s0,80(sp)
    80004a36:	64a6                	ld	s1,72(sp)
    80004a38:	6906                	ld	s2,64(sp)
    80004a3a:	6125                	addi	sp,sp,96
    80004a3c:	8082                	ret
    end_op();
    80004a3e:	00000097          	auipc	ra,0x0
    80004a42:	3d0080e7          	jalr	976(ra) # 80004e0e <end_op>
    return -1;
    80004a46:	557d                	li	a0,-1
    80004a48:	b7ed                	j	80004a32 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004a4a:	00005517          	auipc	a0,0x5
    80004a4e:	ece50513          	addi	a0,a0,-306 # 80009918 <syscalls+0x208>
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	ad8080e7          	jalr	-1320(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a5a:	8526                	mv	a0,s1
    80004a5c:	00001097          	auipc	ra,0x1
    80004a60:	7d0080e7          	jalr	2000(ra) # 8000622c <isdirempty>
    80004a64:	f13d                	bnez	a0,800049ca <removeSwapFile+0xc2>
    iunlockput(ip);
    80004a66:	8526                	mv	a0,s1
    80004a68:	00000097          	auipc	ra,0x0
    80004a6c:	8a0080e7          	jalr	-1888(ra) # 80004308 <iunlockput>
    iunlockput(dp);
    80004a70:	854a                	mv	a0,s2
    80004a72:	00000097          	auipc	ra,0x0
    80004a76:	896080e7          	jalr	-1898(ra) # 80004308 <iunlockput>
    end_op();
    80004a7a:	00000097          	auipc	ra,0x0
    80004a7e:	394080e7          	jalr	916(ra) # 80004e0e <end_op>
    return -1;
    80004a82:	557d                	li	a0,-1
    80004a84:	b77d                	j	80004a32 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004a86:	00005517          	auipc	a0,0x5
    80004a8a:	eaa50513          	addi	a0,a0,-342 # 80009930 <syscalls+0x220>
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	a9c080e7          	jalr	-1380(ra) # 8000052a <panic>
    dp->nlink--;
    80004a96:	04a95783          	lhu	a5,74(s2)
    80004a9a:	37fd                	addiw	a5,a5,-1
    80004a9c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004aa0:	854a                	mv	a0,s2
    80004aa2:	fffff097          	auipc	ra,0xfffff
    80004aa6:	53a080e7          	jalr	1338(ra) # 80003fdc <iupdate>
    80004aaa:	bf99                	j	80004a00 <removeSwapFile+0xf8>
    return -1;
    80004aac:	557d                	li	a0,-1
    80004aae:	b751                	j	80004a32 <removeSwapFile+0x12a>

0000000080004ab0 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004ab0:	7179                	addi	sp,sp,-48
    80004ab2:	f406                	sd	ra,40(sp)
    80004ab4:	f022                	sd	s0,32(sp)
    80004ab6:	ec26                	sd	s1,24(sp)
    80004ab8:	e84a                	sd	s2,16(sp)
    80004aba:	1800                	addi	s0,sp,48
    80004abc:	84aa                	mv	s1,a0

  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004abe:	4619                	li	a2,6
    80004ac0:	00005597          	auipc	a1,0x5
    80004ac4:	e4058593          	addi	a1,a1,-448 # 80009900 <syscalls+0x1f0>
    80004ac8:	fd040513          	addi	a0,s0,-48
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	24e080e7          	jalr	590(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004ad4:	fd640593          	addi	a1,s0,-42
    80004ad8:	5888                	lw	a0,48(s1)
    80004ada:	00000097          	auipc	ra,0x0
    80004ade:	dbc080e7          	jalr	-580(ra) # 80004896 <itoa>

  begin_op();
    80004ae2:	00000097          	auipc	ra,0x0
    80004ae6:	2ac080e7          	jalr	684(ra) # 80004d8e <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004aea:	4681                	li	a3,0
    80004aec:	4601                	li	a2,0
    80004aee:	4589                	li	a1,2
    80004af0:	fd040513          	addi	a0,s0,-48
    80004af4:	00002097          	auipc	ra,0x2
    80004af8:	92c080e7          	jalr	-1748(ra) # 80006420 <create>
    80004afc:	892a                	mv	s2,a0
  iunlock(in);
    80004afe:	fffff097          	auipc	ra,0xfffff
    80004b02:	66a080e7          	jalr	1642(ra) # 80004168 <iunlock>
  p->swapFile = filealloc();
    80004b06:	00000097          	auipc	ra,0x0
    80004b0a:	698080e7          	jalr	1688(ra) # 8000519e <filealloc>
    80004b0e:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    80004b12:	cd1d                	beqz	a0,80004b50 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004b14:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004b18:	1684b703          	ld	a4,360(s1)
    80004b1c:	4789                	li	a5,2
    80004b1e:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004b20:	1684b703          	ld	a4,360(s1)
    80004b24:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004b28:	1684b703          	ld	a4,360(s1)
    80004b2c:	4685                	li	a3,1
    80004b2e:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004b32:	1684b703          	ld	a4,360(s1)
    80004b36:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004b3a:	00000097          	auipc	ra,0x0
    80004b3e:	2d4080e7          	jalr	724(ra) # 80004e0e <end_op>

    return 0;
}
    80004b42:	4501                	li	a0,0
    80004b44:	70a2                	ld	ra,40(sp)
    80004b46:	7402                	ld	s0,32(sp)
    80004b48:	64e2                	ld	s1,24(sp)
    80004b4a:	6942                	ld	s2,16(sp)
    80004b4c:	6145                	addi	sp,sp,48
    80004b4e:	8082                	ret
    panic("no slot for files on /store");
    80004b50:	00005517          	auipc	a0,0x5
    80004b54:	df050513          	addi	a0,a0,-528 # 80009940 <syscalls+0x230>
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	9d2080e7          	jalr	-1582(ra) # 8000052a <panic>

0000000080004b60 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b60:	1141                	addi	sp,sp,-16
    80004b62:	e406                	sd	ra,8(sp)
    80004b64:	e022                	sd	s0,0(sp)
    80004b66:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b68:	16853783          	ld	a5,360(a0)
    80004b6c:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004b6e:	8636                	mv	a2,a3
    80004b70:	16853503          	ld	a0,360(a0)
    80004b74:	00001097          	auipc	ra,0x1
    80004b78:	ad8080e7          	jalr	-1320(ra) # 8000564c <kfilewrite>
}
    80004b7c:	60a2                	ld	ra,8(sp)
    80004b7e:	6402                	ld	s0,0(sp)
    80004b80:	0141                	addi	sp,sp,16
    80004b82:	8082                	ret

0000000080004b84 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b84:	1141                	addi	sp,sp,-16
    80004b86:	e406                	sd	ra,8(sp)
    80004b88:	e022                	sd	s0,0(sp)
    80004b8a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b8c:	16853783          	ld	a5,360(a0)
    80004b90:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004b92:	8636                	mv	a2,a3
    80004b94:	16853503          	ld	a0,360(a0)
    80004b98:	00001097          	auipc	ra,0x1
    80004b9c:	9f2080e7          	jalr	-1550(ra) # 8000558a <kfileread>
    80004ba0:	60a2                	ld	ra,8(sp)
    80004ba2:	6402                	ld	s0,0(sp)
    80004ba4:	0141                	addi	sp,sp,16
    80004ba6:	8082                	ret

0000000080004ba8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004ba8:	1101                	addi	sp,sp,-32
    80004baa:	ec06                	sd	ra,24(sp)
    80004bac:	e822                	sd	s0,16(sp)
    80004bae:	e426                	sd	s1,8(sp)
    80004bb0:	e04a                	sd	s2,0(sp)
    80004bb2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004bb4:	00042917          	auipc	s2,0x42
    80004bb8:	ebc90913          	addi	s2,s2,-324 # 80046a70 <log>
    80004bbc:	01892583          	lw	a1,24(s2)
    80004bc0:	02892503          	lw	a0,40(s2)
    80004bc4:	fffff097          	auipc	ra,0xfffff
    80004bc8:	cde080e7          	jalr	-802(ra) # 800038a2 <bread>
    80004bcc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004bce:	02c92683          	lw	a3,44(s2)
    80004bd2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004bd4:	02d05863          	blez	a3,80004c04 <write_head+0x5c>
    80004bd8:	00042797          	auipc	a5,0x42
    80004bdc:	ec878793          	addi	a5,a5,-312 # 80046aa0 <log+0x30>
    80004be0:	05c50713          	addi	a4,a0,92
    80004be4:	36fd                	addiw	a3,a3,-1
    80004be6:	02069613          	slli	a2,a3,0x20
    80004bea:	01e65693          	srli	a3,a2,0x1e
    80004bee:	00042617          	auipc	a2,0x42
    80004bf2:	eb660613          	addi	a2,a2,-330 # 80046aa4 <log+0x34>
    80004bf6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004bf8:	4390                	lw	a2,0(a5)
    80004bfa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004bfc:	0791                	addi	a5,a5,4
    80004bfe:	0711                	addi	a4,a4,4
    80004c00:	fed79ce3          	bne	a5,a3,80004bf8 <write_head+0x50>
  }
  bwrite(buf);
    80004c04:	8526                	mv	a0,s1
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	d8e080e7          	jalr	-626(ra) # 80003994 <bwrite>
  brelse(buf);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	dc2080e7          	jalr	-574(ra) # 800039d2 <brelse>
}
    80004c18:	60e2                	ld	ra,24(sp)
    80004c1a:	6442                	ld	s0,16(sp)
    80004c1c:	64a2                	ld	s1,8(sp)
    80004c1e:	6902                	ld	s2,0(sp)
    80004c20:	6105                	addi	sp,sp,32
    80004c22:	8082                	ret

0000000080004c24 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c24:	00042797          	auipc	a5,0x42
    80004c28:	e787a783          	lw	a5,-392(a5) # 80046a9c <log+0x2c>
    80004c2c:	0af05d63          	blez	a5,80004ce6 <install_trans+0xc2>
{
    80004c30:	7139                	addi	sp,sp,-64
    80004c32:	fc06                	sd	ra,56(sp)
    80004c34:	f822                	sd	s0,48(sp)
    80004c36:	f426                	sd	s1,40(sp)
    80004c38:	f04a                	sd	s2,32(sp)
    80004c3a:	ec4e                	sd	s3,24(sp)
    80004c3c:	e852                	sd	s4,16(sp)
    80004c3e:	e456                	sd	s5,8(sp)
    80004c40:	e05a                	sd	s6,0(sp)
    80004c42:	0080                	addi	s0,sp,64
    80004c44:	8b2a                	mv	s6,a0
    80004c46:	00042a97          	auipc	s5,0x42
    80004c4a:	e5aa8a93          	addi	s5,s5,-422 # 80046aa0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c4e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c50:	00042997          	auipc	s3,0x42
    80004c54:	e2098993          	addi	s3,s3,-480 # 80046a70 <log>
    80004c58:	a00d                	j	80004c7a <install_trans+0x56>
    brelse(lbuf);
    80004c5a:	854a                	mv	a0,s2
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	d76080e7          	jalr	-650(ra) # 800039d2 <brelse>
    brelse(dbuf);
    80004c64:	8526                	mv	a0,s1
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	d6c080e7          	jalr	-660(ra) # 800039d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c6e:	2a05                	addiw	s4,s4,1
    80004c70:	0a91                	addi	s5,s5,4
    80004c72:	02c9a783          	lw	a5,44(s3)
    80004c76:	04fa5e63          	bge	s4,a5,80004cd2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004c7a:	0189a583          	lw	a1,24(s3)
    80004c7e:	014585bb          	addw	a1,a1,s4
    80004c82:	2585                	addiw	a1,a1,1
    80004c84:	0289a503          	lw	a0,40(s3)
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	c1a080e7          	jalr	-998(ra) # 800038a2 <bread>
    80004c90:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004c92:	000aa583          	lw	a1,0(s5)
    80004c96:	0289a503          	lw	a0,40(s3)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	c08080e7          	jalr	-1016(ra) # 800038a2 <bread>
    80004ca2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004ca4:	40000613          	li	a2,1024
    80004ca8:	05890593          	addi	a1,s2,88
    80004cac:	05850513          	addi	a0,a0,88
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	06a080e7          	jalr	106(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004cb8:	8526                	mv	a0,s1
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	cda080e7          	jalr	-806(ra) # 80003994 <bwrite>
    if(recovering == 0)
    80004cc2:	f80b1ce3          	bnez	s6,80004c5a <install_trans+0x36>
      bunpin(dbuf);
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	de4080e7          	jalr	-540(ra) # 80003aac <bunpin>
    80004cd0:	b769                	j	80004c5a <install_trans+0x36>
}
    80004cd2:	70e2                	ld	ra,56(sp)
    80004cd4:	7442                	ld	s0,48(sp)
    80004cd6:	74a2                	ld	s1,40(sp)
    80004cd8:	7902                	ld	s2,32(sp)
    80004cda:	69e2                	ld	s3,24(sp)
    80004cdc:	6a42                	ld	s4,16(sp)
    80004cde:	6aa2                	ld	s5,8(sp)
    80004ce0:	6b02                	ld	s6,0(sp)
    80004ce2:	6121                	addi	sp,sp,64
    80004ce4:	8082                	ret
    80004ce6:	8082                	ret

0000000080004ce8 <initlog>:
{
    80004ce8:	7179                	addi	sp,sp,-48
    80004cea:	f406                	sd	ra,40(sp)
    80004cec:	f022                	sd	s0,32(sp)
    80004cee:	ec26                	sd	s1,24(sp)
    80004cf0:	e84a                	sd	s2,16(sp)
    80004cf2:	e44e                	sd	s3,8(sp)
    80004cf4:	1800                	addi	s0,sp,48
    80004cf6:	892a                	mv	s2,a0
    80004cf8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004cfa:	00042497          	auipc	s1,0x42
    80004cfe:	d7648493          	addi	s1,s1,-650 # 80046a70 <log>
    80004d02:	00005597          	auipc	a1,0x5
    80004d06:	c5e58593          	addi	a1,a1,-930 # 80009960 <syscalls+0x250>
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	e26080e7          	jalr	-474(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004d14:	0149a583          	lw	a1,20(s3)
    80004d18:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004d1a:	0109a783          	lw	a5,16(s3)
    80004d1e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004d20:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004d24:	854a                	mv	a0,s2
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	b7c080e7          	jalr	-1156(ra) # 800038a2 <bread>
  log.lh.n = lh->n;
    80004d2e:	4d34                	lw	a3,88(a0)
    80004d30:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004d32:	02d05663          	blez	a3,80004d5e <initlog+0x76>
    80004d36:	05c50793          	addi	a5,a0,92
    80004d3a:	00042717          	auipc	a4,0x42
    80004d3e:	d6670713          	addi	a4,a4,-666 # 80046aa0 <log+0x30>
    80004d42:	36fd                	addiw	a3,a3,-1
    80004d44:	02069613          	slli	a2,a3,0x20
    80004d48:	01e65693          	srli	a3,a2,0x1e
    80004d4c:	06050613          	addi	a2,a0,96
    80004d50:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004d52:	4390                	lw	a2,0(a5)
    80004d54:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004d56:	0791                	addi	a5,a5,4
    80004d58:	0711                	addi	a4,a4,4
    80004d5a:	fed79ce3          	bne	a5,a3,80004d52 <initlog+0x6a>
  brelse(buf);
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	c74080e7          	jalr	-908(ra) # 800039d2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004d66:	4505                	li	a0,1
    80004d68:	00000097          	auipc	ra,0x0
    80004d6c:	ebc080e7          	jalr	-324(ra) # 80004c24 <install_trans>
  log.lh.n = 0;
    80004d70:	00042797          	auipc	a5,0x42
    80004d74:	d207a623          	sw	zero,-724(a5) # 80046a9c <log+0x2c>
  write_head(); // clear the log
    80004d78:	00000097          	auipc	ra,0x0
    80004d7c:	e30080e7          	jalr	-464(ra) # 80004ba8 <write_head>
}
    80004d80:	70a2                	ld	ra,40(sp)
    80004d82:	7402                	ld	s0,32(sp)
    80004d84:	64e2                	ld	s1,24(sp)
    80004d86:	6942                	ld	s2,16(sp)
    80004d88:	69a2                	ld	s3,8(sp)
    80004d8a:	6145                	addi	sp,sp,48
    80004d8c:	8082                	ret

0000000080004d8e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004d8e:	1101                	addi	sp,sp,-32
    80004d90:	ec06                	sd	ra,24(sp)
    80004d92:	e822                	sd	s0,16(sp)
    80004d94:	e426                	sd	s1,8(sp)
    80004d96:	e04a                	sd	s2,0(sp)
    80004d98:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004d9a:	00042517          	auipc	a0,0x42
    80004d9e:	cd650513          	addi	a0,a0,-810 # 80046a70 <log>
    80004da2:	ffffc097          	auipc	ra,0xffffc
    80004da6:	e20080e7          	jalr	-480(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004daa:	00042497          	auipc	s1,0x42
    80004dae:	cc648493          	addi	s1,s1,-826 # 80046a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004db2:	4979                	li	s2,30
    80004db4:	a039                	j	80004dc2 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004db6:	85a6                	mv	a1,s1
    80004db8:	8526                	mv	a0,s1
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	1aa080e7          	jalr	426(ra) # 80001f64 <sleep>
    if(log.committing){
    80004dc2:	50dc                	lw	a5,36(s1)
    80004dc4:	fbed                	bnez	a5,80004db6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004dc6:	509c                	lw	a5,32(s1)
    80004dc8:	0017871b          	addiw	a4,a5,1
    80004dcc:	0007069b          	sext.w	a3,a4
    80004dd0:	0027179b          	slliw	a5,a4,0x2
    80004dd4:	9fb9                	addw	a5,a5,a4
    80004dd6:	0017979b          	slliw	a5,a5,0x1
    80004dda:	54d8                	lw	a4,44(s1)
    80004ddc:	9fb9                	addw	a5,a5,a4
    80004dde:	00f95963          	bge	s2,a5,80004df0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004de2:	85a6                	mv	a1,s1
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffd097          	auipc	ra,0xffffd
    80004dea:	17e080e7          	jalr	382(ra) # 80001f64 <sleep>
    80004dee:	bfd1                	j	80004dc2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004df0:	00042517          	auipc	a0,0x42
    80004df4:	c8050513          	addi	a0,a0,-896 # 80046a70 <log>
    80004df8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	e7c080e7          	jalr	-388(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004e02:	60e2                	ld	ra,24(sp)
    80004e04:	6442                	ld	s0,16(sp)
    80004e06:	64a2                	ld	s1,8(sp)
    80004e08:	6902                	ld	s2,0(sp)
    80004e0a:	6105                	addi	sp,sp,32
    80004e0c:	8082                	ret

0000000080004e0e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004e0e:	7139                	addi	sp,sp,-64
    80004e10:	fc06                	sd	ra,56(sp)
    80004e12:	f822                	sd	s0,48(sp)
    80004e14:	f426                	sd	s1,40(sp)
    80004e16:	f04a                	sd	s2,32(sp)
    80004e18:	ec4e                	sd	s3,24(sp)
    80004e1a:	e852                	sd	s4,16(sp)
    80004e1c:	e456                	sd	s5,8(sp)
    80004e1e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004e20:	00042497          	auipc	s1,0x42
    80004e24:	c5048493          	addi	s1,s1,-944 # 80046a70 <log>
    80004e28:	8526                	mv	a0,s1
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	d98080e7          	jalr	-616(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004e32:	509c                	lw	a5,32(s1)
    80004e34:	37fd                	addiw	a5,a5,-1
    80004e36:	0007891b          	sext.w	s2,a5
    80004e3a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004e3c:	50dc                	lw	a5,36(s1)
    80004e3e:	e7b9                	bnez	a5,80004e8c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004e40:	04091e63          	bnez	s2,80004e9c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004e44:	00042497          	auipc	s1,0x42
    80004e48:	c2c48493          	addi	s1,s1,-980 # 80046a70 <log>
    80004e4c:	4785                	li	a5,1
    80004e4e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004e50:	8526                	mv	a0,s1
    80004e52:	ffffc097          	auipc	ra,0xffffc
    80004e56:	e24080e7          	jalr	-476(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004e5a:	54dc                	lw	a5,44(s1)
    80004e5c:	06f04763          	bgtz	a5,80004eca <end_op+0xbc>
    acquire(&log.lock);
    80004e60:	00042497          	auipc	s1,0x42
    80004e64:	c1048493          	addi	s1,s1,-1008 # 80046a70 <log>
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffc097          	auipc	ra,0xffffc
    80004e6e:	d58080e7          	jalr	-680(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004e72:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004e76:	8526                	mv	a0,s1
    80004e78:	ffffd097          	auipc	ra,0xffffd
    80004e7c:	150080e7          	jalr	336(ra) # 80001fc8 <wakeup>
    release(&log.lock);
    80004e80:	8526                	mv	a0,s1
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	df4080e7          	jalr	-524(ra) # 80000c76 <release>
}
    80004e8a:	a03d                	j	80004eb8 <end_op+0xaa>
    panic("log.committing");
    80004e8c:	00005517          	auipc	a0,0x5
    80004e90:	adc50513          	addi	a0,a0,-1316 # 80009968 <syscalls+0x258>
    80004e94:	ffffb097          	auipc	ra,0xffffb
    80004e98:	696080e7          	jalr	1686(ra) # 8000052a <panic>
    wakeup(&log);
    80004e9c:	00042497          	auipc	s1,0x42
    80004ea0:	bd448493          	addi	s1,s1,-1068 # 80046a70 <log>
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffd097          	auipc	ra,0xffffd
    80004eaa:	122080e7          	jalr	290(ra) # 80001fc8 <wakeup>
  release(&log.lock);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	dc6080e7          	jalr	-570(ra) # 80000c76 <release>
}
    80004eb8:	70e2                	ld	ra,56(sp)
    80004eba:	7442                	ld	s0,48(sp)
    80004ebc:	74a2                	ld	s1,40(sp)
    80004ebe:	7902                	ld	s2,32(sp)
    80004ec0:	69e2                	ld	s3,24(sp)
    80004ec2:	6a42                	ld	s4,16(sp)
    80004ec4:	6aa2                	ld	s5,8(sp)
    80004ec6:	6121                	addi	sp,sp,64
    80004ec8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004eca:	00042a97          	auipc	s5,0x42
    80004ece:	bd6a8a93          	addi	s5,s5,-1066 # 80046aa0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004ed2:	00042a17          	auipc	s4,0x42
    80004ed6:	b9ea0a13          	addi	s4,s4,-1122 # 80046a70 <log>
    80004eda:	018a2583          	lw	a1,24(s4)
    80004ede:	012585bb          	addw	a1,a1,s2
    80004ee2:	2585                	addiw	a1,a1,1
    80004ee4:	028a2503          	lw	a0,40(s4)
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	9ba080e7          	jalr	-1606(ra) # 800038a2 <bread>
    80004ef0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004ef2:	000aa583          	lw	a1,0(s5)
    80004ef6:	028a2503          	lw	a0,40(s4)
    80004efa:	fffff097          	auipc	ra,0xfffff
    80004efe:	9a8080e7          	jalr	-1624(ra) # 800038a2 <bread>
    80004f02:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004f04:	40000613          	li	a2,1024
    80004f08:	05850593          	addi	a1,a0,88
    80004f0c:	05848513          	addi	a0,s1,88
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	e0a080e7          	jalr	-502(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004f18:	8526                	mv	a0,s1
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	a7a080e7          	jalr	-1414(ra) # 80003994 <bwrite>
    brelse(from);
    80004f22:	854e                	mv	a0,s3
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	aae080e7          	jalr	-1362(ra) # 800039d2 <brelse>
    brelse(to);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	fffff097          	auipc	ra,0xfffff
    80004f32:	aa4080e7          	jalr	-1372(ra) # 800039d2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004f36:	2905                	addiw	s2,s2,1
    80004f38:	0a91                	addi	s5,s5,4
    80004f3a:	02ca2783          	lw	a5,44(s4)
    80004f3e:	f8f94ee3          	blt	s2,a5,80004eda <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004f42:	00000097          	auipc	ra,0x0
    80004f46:	c66080e7          	jalr	-922(ra) # 80004ba8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004f4a:	4501                	li	a0,0
    80004f4c:	00000097          	auipc	ra,0x0
    80004f50:	cd8080e7          	jalr	-808(ra) # 80004c24 <install_trans>
    log.lh.n = 0;
    80004f54:	00042797          	auipc	a5,0x42
    80004f58:	b407a423          	sw	zero,-1208(a5) # 80046a9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004f5c:	00000097          	auipc	ra,0x0
    80004f60:	c4c080e7          	jalr	-948(ra) # 80004ba8 <write_head>
    80004f64:	bdf5                	j	80004e60 <end_op+0x52>

0000000080004f66 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004f66:	1101                	addi	sp,sp,-32
    80004f68:	ec06                	sd	ra,24(sp)
    80004f6a:	e822                	sd	s0,16(sp)
    80004f6c:	e426                	sd	s1,8(sp)
    80004f6e:	e04a                	sd	s2,0(sp)
    80004f70:	1000                	addi	s0,sp,32
    80004f72:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004f74:	00042917          	auipc	s2,0x42
    80004f78:	afc90913          	addi	s2,s2,-1284 # 80046a70 <log>
    80004f7c:	854a                	mv	a0,s2
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	c44080e7          	jalr	-956(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004f86:	02c92603          	lw	a2,44(s2)
    80004f8a:	47f5                	li	a5,29
    80004f8c:	06c7c563          	blt	a5,a2,80004ff6 <log_write+0x90>
    80004f90:	00042797          	auipc	a5,0x42
    80004f94:	afc7a783          	lw	a5,-1284(a5) # 80046a8c <log+0x1c>
    80004f98:	37fd                	addiw	a5,a5,-1
    80004f9a:	04f65e63          	bge	a2,a5,80004ff6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004f9e:	00042797          	auipc	a5,0x42
    80004fa2:	af27a783          	lw	a5,-1294(a5) # 80046a90 <log+0x20>
    80004fa6:	06f05063          	blez	a5,80005006 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004faa:	4781                	li	a5,0
    80004fac:	06c05563          	blez	a2,80005016 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004fb0:	44cc                	lw	a1,12(s1)
    80004fb2:	00042717          	auipc	a4,0x42
    80004fb6:	aee70713          	addi	a4,a4,-1298 # 80046aa0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004fba:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004fbc:	4314                	lw	a3,0(a4)
    80004fbe:	04b68c63          	beq	a3,a1,80005016 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004fc2:	2785                	addiw	a5,a5,1
    80004fc4:	0711                	addi	a4,a4,4
    80004fc6:	fef61be3          	bne	a2,a5,80004fbc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004fca:	0621                	addi	a2,a2,8
    80004fcc:	060a                	slli	a2,a2,0x2
    80004fce:	00042797          	auipc	a5,0x42
    80004fd2:	aa278793          	addi	a5,a5,-1374 # 80046a70 <log>
    80004fd6:	963e                	add	a2,a2,a5
    80004fd8:	44dc                	lw	a5,12(s1)
    80004fda:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	fffff097          	auipc	ra,0xfffff
    80004fe2:	a92080e7          	jalr	-1390(ra) # 80003a70 <bpin>
    log.lh.n++;
    80004fe6:	00042717          	auipc	a4,0x42
    80004fea:	a8a70713          	addi	a4,a4,-1398 # 80046a70 <log>
    80004fee:	575c                	lw	a5,44(a4)
    80004ff0:	2785                	addiw	a5,a5,1
    80004ff2:	d75c                	sw	a5,44(a4)
    80004ff4:	a835                	j	80005030 <log_write+0xca>
    panic("too big a transaction");
    80004ff6:	00005517          	auipc	a0,0x5
    80004ffa:	98250513          	addi	a0,a0,-1662 # 80009978 <syscalls+0x268>
    80004ffe:	ffffb097          	auipc	ra,0xffffb
    80005002:	52c080e7          	jalr	1324(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80005006:	00005517          	auipc	a0,0x5
    8000500a:	98a50513          	addi	a0,a0,-1654 # 80009990 <syscalls+0x280>
    8000500e:	ffffb097          	auipc	ra,0xffffb
    80005012:	51c080e7          	jalr	1308(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80005016:	00878713          	addi	a4,a5,8
    8000501a:	00271693          	slli	a3,a4,0x2
    8000501e:	00042717          	auipc	a4,0x42
    80005022:	a5270713          	addi	a4,a4,-1454 # 80046a70 <log>
    80005026:	9736                	add	a4,a4,a3
    80005028:	44d4                	lw	a3,12(s1)
    8000502a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000502c:	faf608e3          	beq	a2,a5,80004fdc <log_write+0x76>
  }
  release(&log.lock);
    80005030:	00042517          	auipc	a0,0x42
    80005034:	a4050513          	addi	a0,a0,-1472 # 80046a70 <log>
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	c3e080e7          	jalr	-962(ra) # 80000c76 <release>
}
    80005040:	60e2                	ld	ra,24(sp)
    80005042:	6442                	ld	s0,16(sp)
    80005044:	64a2                	ld	s1,8(sp)
    80005046:	6902                	ld	s2,0(sp)
    80005048:	6105                	addi	sp,sp,32
    8000504a:	8082                	ret

000000008000504c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000504c:	1101                	addi	sp,sp,-32
    8000504e:	ec06                	sd	ra,24(sp)
    80005050:	e822                	sd	s0,16(sp)
    80005052:	e426                	sd	s1,8(sp)
    80005054:	e04a                	sd	s2,0(sp)
    80005056:	1000                	addi	s0,sp,32
    80005058:	84aa                	mv	s1,a0
    8000505a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000505c:	00005597          	auipc	a1,0x5
    80005060:	95458593          	addi	a1,a1,-1708 # 800099b0 <syscalls+0x2a0>
    80005064:	0521                	addi	a0,a0,8
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	acc080e7          	jalr	-1332(ra) # 80000b32 <initlock>
  lk->name = name;
    8000506e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005072:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005076:	0204a423          	sw	zero,40(s1)
}
    8000507a:	60e2                	ld	ra,24(sp)
    8000507c:	6442                	ld	s0,16(sp)
    8000507e:	64a2                	ld	s1,8(sp)
    80005080:	6902                	ld	s2,0(sp)
    80005082:	6105                	addi	sp,sp,32
    80005084:	8082                	ret

0000000080005086 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005086:	1101                	addi	sp,sp,-32
    80005088:	ec06                	sd	ra,24(sp)
    8000508a:	e822                	sd	s0,16(sp)
    8000508c:	e426                	sd	s1,8(sp)
    8000508e:	e04a                	sd	s2,0(sp)
    80005090:	1000                	addi	s0,sp,32
    80005092:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005094:	00850913          	addi	s2,a0,8
    80005098:	854a                	mv	a0,s2
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	b28080e7          	jalr	-1240(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    800050a2:	409c                	lw	a5,0(s1)
    800050a4:	cb89                	beqz	a5,800050b6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800050a6:	85ca                	mv	a1,s2
    800050a8:	8526                	mv	a0,s1
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	eba080e7          	jalr	-326(ra) # 80001f64 <sleep>
  while (lk->locked) {
    800050b2:	409c                	lw	a5,0(s1)
    800050b4:	fbed                	bnez	a5,800050a6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800050b6:	4785                	li	a5,1
    800050b8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800050ba:	ffffd097          	auipc	ra,0xffffd
    800050be:	acc080e7          	jalr	-1332(ra) # 80001b86 <myproc>
    800050c2:	591c                	lw	a5,48(a0)
    800050c4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800050c6:	854a                	mv	a0,s2
    800050c8:	ffffc097          	auipc	ra,0xffffc
    800050cc:	bae080e7          	jalr	-1106(ra) # 80000c76 <release>
}
    800050d0:	60e2                	ld	ra,24(sp)
    800050d2:	6442                	ld	s0,16(sp)
    800050d4:	64a2                	ld	s1,8(sp)
    800050d6:	6902                	ld	s2,0(sp)
    800050d8:	6105                	addi	sp,sp,32
    800050da:	8082                	ret

00000000800050dc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800050dc:	1101                	addi	sp,sp,-32
    800050de:	ec06                	sd	ra,24(sp)
    800050e0:	e822                	sd	s0,16(sp)
    800050e2:	e426                	sd	s1,8(sp)
    800050e4:	e04a                	sd	s2,0(sp)
    800050e6:	1000                	addi	s0,sp,32
    800050e8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800050ea:	00850913          	addi	s2,a0,8
    800050ee:	854a                	mv	a0,s2
    800050f0:	ffffc097          	auipc	ra,0xffffc
    800050f4:	ad2080e7          	jalr	-1326(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800050f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800050fc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005100:	8526                	mv	a0,s1
    80005102:	ffffd097          	auipc	ra,0xffffd
    80005106:	ec6080e7          	jalr	-314(ra) # 80001fc8 <wakeup>
  release(&lk->lk);
    8000510a:	854a                	mv	a0,s2
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	b6a080e7          	jalr	-1174(ra) # 80000c76 <release>
}
    80005114:	60e2                	ld	ra,24(sp)
    80005116:	6442                	ld	s0,16(sp)
    80005118:	64a2                	ld	s1,8(sp)
    8000511a:	6902                	ld	s2,0(sp)
    8000511c:	6105                	addi	sp,sp,32
    8000511e:	8082                	ret

0000000080005120 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005120:	7179                	addi	sp,sp,-48
    80005122:	f406                	sd	ra,40(sp)
    80005124:	f022                	sd	s0,32(sp)
    80005126:	ec26                	sd	s1,24(sp)
    80005128:	e84a                	sd	s2,16(sp)
    8000512a:	e44e                	sd	s3,8(sp)
    8000512c:	1800                	addi	s0,sp,48
    8000512e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005130:	00850913          	addi	s2,a0,8
    80005134:	854a                	mv	a0,s2
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	a8c080e7          	jalr	-1396(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000513e:	409c                	lw	a5,0(s1)
    80005140:	ef99                	bnez	a5,8000515e <holdingsleep+0x3e>
    80005142:	4481                	li	s1,0
  release(&lk->lk);
    80005144:	854a                	mv	a0,s2
    80005146:	ffffc097          	auipc	ra,0xffffc
    8000514a:	b30080e7          	jalr	-1232(ra) # 80000c76 <release>
  return r;
}
    8000514e:	8526                	mv	a0,s1
    80005150:	70a2                	ld	ra,40(sp)
    80005152:	7402                	ld	s0,32(sp)
    80005154:	64e2                	ld	s1,24(sp)
    80005156:	6942                	ld	s2,16(sp)
    80005158:	69a2                	ld	s3,8(sp)
    8000515a:	6145                	addi	sp,sp,48
    8000515c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000515e:	0284a983          	lw	s3,40(s1)
    80005162:	ffffd097          	auipc	ra,0xffffd
    80005166:	a24080e7          	jalr	-1500(ra) # 80001b86 <myproc>
    8000516a:	5904                	lw	s1,48(a0)
    8000516c:	413484b3          	sub	s1,s1,s3
    80005170:	0014b493          	seqz	s1,s1
    80005174:	bfc1                	j	80005144 <holdingsleep+0x24>

0000000080005176 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005176:	1141                	addi	sp,sp,-16
    80005178:	e406                	sd	ra,8(sp)
    8000517a:	e022                	sd	s0,0(sp)
    8000517c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000517e:	00005597          	auipc	a1,0x5
    80005182:	84258593          	addi	a1,a1,-1982 # 800099c0 <syscalls+0x2b0>
    80005186:	00042517          	auipc	a0,0x42
    8000518a:	a3250513          	addi	a0,a0,-1486 # 80046bb8 <ftable>
    8000518e:	ffffc097          	auipc	ra,0xffffc
    80005192:	9a4080e7          	jalr	-1628(ra) # 80000b32 <initlock>
}
    80005196:	60a2                	ld	ra,8(sp)
    80005198:	6402                	ld	s0,0(sp)
    8000519a:	0141                	addi	sp,sp,16
    8000519c:	8082                	ret

000000008000519e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000519e:	1101                	addi	sp,sp,-32
    800051a0:	ec06                	sd	ra,24(sp)
    800051a2:	e822                	sd	s0,16(sp)
    800051a4:	e426                	sd	s1,8(sp)
    800051a6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800051a8:	00042517          	auipc	a0,0x42
    800051ac:	a1050513          	addi	a0,a0,-1520 # 80046bb8 <ftable>
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	a12080e7          	jalr	-1518(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800051b8:	00042497          	auipc	s1,0x42
    800051bc:	a1848493          	addi	s1,s1,-1512 # 80046bd0 <ftable+0x18>
    800051c0:	00043717          	auipc	a4,0x43
    800051c4:	9b070713          	addi	a4,a4,-1616 # 80047b70 <ftable+0xfb8>
    if(f->ref == 0){
    800051c8:	40dc                	lw	a5,4(s1)
    800051ca:	cf99                	beqz	a5,800051e8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800051cc:	02848493          	addi	s1,s1,40
    800051d0:	fee49ce3          	bne	s1,a4,800051c8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800051d4:	00042517          	auipc	a0,0x42
    800051d8:	9e450513          	addi	a0,a0,-1564 # 80046bb8 <ftable>
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	a9a080e7          	jalr	-1382(ra) # 80000c76 <release>
  return 0;
    800051e4:	4481                	li	s1,0
    800051e6:	a819                	j	800051fc <filealloc+0x5e>
      f->ref = 1;
    800051e8:	4785                	li	a5,1
    800051ea:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800051ec:	00042517          	auipc	a0,0x42
    800051f0:	9cc50513          	addi	a0,a0,-1588 # 80046bb8 <ftable>
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	a82080e7          	jalr	-1406(ra) # 80000c76 <release>
}
    800051fc:	8526                	mv	a0,s1
    800051fe:	60e2                	ld	ra,24(sp)
    80005200:	6442                	ld	s0,16(sp)
    80005202:	64a2                	ld	s1,8(sp)
    80005204:	6105                	addi	sp,sp,32
    80005206:	8082                	ret

0000000080005208 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005208:	1101                	addi	sp,sp,-32
    8000520a:	ec06                	sd	ra,24(sp)
    8000520c:	e822                	sd	s0,16(sp)
    8000520e:	e426                	sd	s1,8(sp)
    80005210:	1000                	addi	s0,sp,32
    80005212:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005214:	00042517          	auipc	a0,0x42
    80005218:	9a450513          	addi	a0,a0,-1628 # 80046bb8 <ftable>
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	9a6080e7          	jalr	-1626(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005224:	40dc                	lw	a5,4(s1)
    80005226:	02f05263          	blez	a5,8000524a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000522a:	2785                	addiw	a5,a5,1
    8000522c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000522e:	00042517          	auipc	a0,0x42
    80005232:	98a50513          	addi	a0,a0,-1654 # 80046bb8 <ftable>
    80005236:	ffffc097          	auipc	ra,0xffffc
    8000523a:	a40080e7          	jalr	-1472(ra) # 80000c76 <release>
  return f;
}
    8000523e:	8526                	mv	a0,s1
    80005240:	60e2                	ld	ra,24(sp)
    80005242:	6442                	ld	s0,16(sp)
    80005244:	64a2                	ld	s1,8(sp)
    80005246:	6105                	addi	sp,sp,32
    80005248:	8082                	ret
    panic("filedup");
    8000524a:	00004517          	auipc	a0,0x4
    8000524e:	77e50513          	addi	a0,a0,1918 # 800099c8 <syscalls+0x2b8>
    80005252:	ffffb097          	auipc	ra,0xffffb
    80005256:	2d8080e7          	jalr	728(ra) # 8000052a <panic>

000000008000525a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000525a:	7139                	addi	sp,sp,-64
    8000525c:	fc06                	sd	ra,56(sp)
    8000525e:	f822                	sd	s0,48(sp)
    80005260:	f426                	sd	s1,40(sp)
    80005262:	f04a                	sd	s2,32(sp)
    80005264:	ec4e                	sd	s3,24(sp)
    80005266:	e852                	sd	s4,16(sp)
    80005268:	e456                	sd	s5,8(sp)
    8000526a:	0080                	addi	s0,sp,64
    8000526c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000526e:	00042517          	auipc	a0,0x42
    80005272:	94a50513          	addi	a0,a0,-1718 # 80046bb8 <ftable>
    80005276:	ffffc097          	auipc	ra,0xffffc
    8000527a:	94c080e7          	jalr	-1716(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000527e:	40dc                	lw	a5,4(s1)
    80005280:	06f05163          	blez	a5,800052e2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005284:	37fd                	addiw	a5,a5,-1
    80005286:	0007871b          	sext.w	a4,a5
    8000528a:	c0dc                	sw	a5,4(s1)
    8000528c:	06e04363          	bgtz	a4,800052f2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005290:	0004a903          	lw	s2,0(s1)
    80005294:	0094ca83          	lbu	s5,9(s1)
    80005298:	0104ba03          	ld	s4,16(s1)
    8000529c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800052a0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800052a4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800052a8:	00042517          	auipc	a0,0x42
    800052ac:	91050513          	addi	a0,a0,-1776 # 80046bb8 <ftable>
    800052b0:	ffffc097          	auipc	ra,0xffffc
    800052b4:	9c6080e7          	jalr	-1594(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800052b8:	4785                	li	a5,1
    800052ba:	04f90d63          	beq	s2,a5,80005314 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800052be:	3979                	addiw	s2,s2,-2
    800052c0:	4785                	li	a5,1
    800052c2:	0527e063          	bltu	a5,s2,80005302 <fileclose+0xa8>
    begin_op();
    800052c6:	00000097          	auipc	ra,0x0
    800052ca:	ac8080e7          	jalr	-1336(ra) # 80004d8e <begin_op>
    iput(ff.ip);
    800052ce:	854e                	mv	a0,s3
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	f90080e7          	jalr	-112(ra) # 80004260 <iput>
    end_op();
    800052d8:	00000097          	auipc	ra,0x0
    800052dc:	b36080e7          	jalr	-1226(ra) # 80004e0e <end_op>
    800052e0:	a00d                	j	80005302 <fileclose+0xa8>
    panic("fileclose");
    800052e2:	00004517          	auipc	a0,0x4
    800052e6:	6ee50513          	addi	a0,a0,1774 # 800099d0 <syscalls+0x2c0>
    800052ea:	ffffb097          	auipc	ra,0xffffb
    800052ee:	240080e7          	jalr	576(ra) # 8000052a <panic>
    release(&ftable.lock);
    800052f2:	00042517          	auipc	a0,0x42
    800052f6:	8c650513          	addi	a0,a0,-1850 # 80046bb8 <ftable>
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	97c080e7          	jalr	-1668(ra) # 80000c76 <release>
  }
}
    80005302:	70e2                	ld	ra,56(sp)
    80005304:	7442                	ld	s0,48(sp)
    80005306:	74a2                	ld	s1,40(sp)
    80005308:	7902                	ld	s2,32(sp)
    8000530a:	69e2                	ld	s3,24(sp)
    8000530c:	6a42                	ld	s4,16(sp)
    8000530e:	6aa2                	ld	s5,8(sp)
    80005310:	6121                	addi	sp,sp,64
    80005312:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005314:	85d6                	mv	a1,s5
    80005316:	8552                	mv	a0,s4
    80005318:	00000097          	auipc	ra,0x0
    8000531c:	542080e7          	jalr	1346(ra) # 8000585a <pipeclose>
    80005320:	b7cd                	j	80005302 <fileclose+0xa8>

0000000080005322 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005322:	715d                	addi	sp,sp,-80
    80005324:	e486                	sd	ra,72(sp)
    80005326:	e0a2                	sd	s0,64(sp)
    80005328:	fc26                	sd	s1,56(sp)
    8000532a:	f84a                	sd	s2,48(sp)
    8000532c:	f44e                	sd	s3,40(sp)
    8000532e:	0880                	addi	s0,sp,80
    80005330:	84aa                	mv	s1,a0
    80005332:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005334:	ffffd097          	auipc	ra,0xffffd
    80005338:	852080e7          	jalr	-1966(ra) # 80001b86 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000533c:	409c                	lw	a5,0(s1)
    8000533e:	37f9                	addiw	a5,a5,-2
    80005340:	4705                	li	a4,1
    80005342:	04f76763          	bltu	a4,a5,80005390 <filestat+0x6e>
    80005346:	892a                	mv	s2,a0
    ilock(f->ip);
    80005348:	6c88                	ld	a0,24(s1)
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	d5c080e7          	jalr	-676(ra) # 800040a6 <ilock>
    stati(f->ip, &st);
    80005352:	fb840593          	addi	a1,s0,-72
    80005356:	6c88                	ld	a0,24(s1)
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	fd8080e7          	jalr	-40(ra) # 80004330 <stati>
    iunlock(f->ip);
    80005360:	6c88                	ld	a0,24(s1)
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	e06080e7          	jalr	-506(ra) # 80004168 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000536a:	46e1                	li	a3,24
    8000536c:	fb840613          	addi	a2,s0,-72
    80005370:	85ce                	mv	a1,s3
    80005372:	05093503          	ld	a0,80(s2)
    80005376:	ffffc097          	auipc	ra,0xffffc
    8000537a:	4bc080e7          	jalr	1212(ra) # 80001832 <copyout>
    8000537e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005382:	60a6                	ld	ra,72(sp)
    80005384:	6406                	ld	s0,64(sp)
    80005386:	74e2                	ld	s1,56(sp)
    80005388:	7942                	ld	s2,48(sp)
    8000538a:	79a2                	ld	s3,40(sp)
    8000538c:	6161                	addi	sp,sp,80
    8000538e:	8082                	ret
  return -1;
    80005390:	557d                	li	a0,-1
    80005392:	bfc5                	j	80005382 <filestat+0x60>

0000000080005394 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005394:	7179                	addi	sp,sp,-48
    80005396:	f406                	sd	ra,40(sp)
    80005398:	f022                	sd	s0,32(sp)
    8000539a:	ec26                	sd	s1,24(sp)
    8000539c:	e84a                	sd	s2,16(sp)
    8000539e:	e44e                	sd	s3,8(sp)
    800053a0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800053a2:	00854783          	lbu	a5,8(a0)
    800053a6:	c3d5                	beqz	a5,8000544a <fileread+0xb6>
    800053a8:	84aa                	mv	s1,a0
    800053aa:	89ae                	mv	s3,a1
    800053ac:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800053ae:	411c                	lw	a5,0(a0)
    800053b0:	4705                	li	a4,1
    800053b2:	04e78963          	beq	a5,a4,80005404 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800053b6:	470d                	li	a4,3
    800053b8:	04e78d63          	beq	a5,a4,80005412 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800053bc:	4709                	li	a4,2
    800053be:	06e79e63          	bne	a5,a4,8000543a <fileread+0xa6>
    ilock(f->ip);
    800053c2:	6d08                	ld	a0,24(a0)
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	ce2080e7          	jalr	-798(ra) # 800040a6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800053cc:	874a                	mv	a4,s2
    800053ce:	5094                	lw	a3,32(s1)
    800053d0:	864e                	mv	a2,s3
    800053d2:	4585                	li	a1,1
    800053d4:	6c88                	ld	a0,24(s1)
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	f84080e7          	jalr	-124(ra) # 8000435a <readi>
    800053de:	892a                	mv	s2,a0
    800053e0:	00a05563          	blez	a0,800053ea <fileread+0x56>
      f->off += r;
    800053e4:	509c                	lw	a5,32(s1)
    800053e6:	9fa9                	addw	a5,a5,a0
    800053e8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800053ea:	6c88                	ld	a0,24(s1)
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	d7c080e7          	jalr	-644(ra) # 80004168 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800053f4:	854a                	mv	a0,s2
    800053f6:	70a2                	ld	ra,40(sp)
    800053f8:	7402                	ld	s0,32(sp)
    800053fa:	64e2                	ld	s1,24(sp)
    800053fc:	6942                	ld	s2,16(sp)
    800053fe:	69a2                	ld	s3,8(sp)
    80005400:	6145                	addi	sp,sp,48
    80005402:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005404:	6908                	ld	a0,16(a0)
    80005406:	00000097          	auipc	ra,0x0
    8000540a:	5b6080e7          	jalr	1462(ra) # 800059bc <piperead>
    8000540e:	892a                	mv	s2,a0
    80005410:	b7d5                	j	800053f4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005412:	02451783          	lh	a5,36(a0)
    80005416:	03079693          	slli	a3,a5,0x30
    8000541a:	92c1                	srli	a3,a3,0x30
    8000541c:	4725                	li	a4,9
    8000541e:	02d76863          	bltu	a4,a3,8000544e <fileread+0xba>
    80005422:	0792                	slli	a5,a5,0x4
    80005424:	00041717          	auipc	a4,0x41
    80005428:	6f470713          	addi	a4,a4,1780 # 80046b18 <devsw>
    8000542c:	97ba                	add	a5,a5,a4
    8000542e:	639c                	ld	a5,0(a5)
    80005430:	c38d                	beqz	a5,80005452 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005432:	4505                	li	a0,1
    80005434:	9782                	jalr	a5
    80005436:	892a                	mv	s2,a0
    80005438:	bf75                	j	800053f4 <fileread+0x60>
    panic("fileread");
    8000543a:	00004517          	auipc	a0,0x4
    8000543e:	5a650513          	addi	a0,a0,1446 # 800099e0 <syscalls+0x2d0>
    80005442:	ffffb097          	auipc	ra,0xffffb
    80005446:	0e8080e7          	jalr	232(ra) # 8000052a <panic>
    return -1;
    8000544a:	597d                	li	s2,-1
    8000544c:	b765                	j	800053f4 <fileread+0x60>
      return -1;
    8000544e:	597d                	li	s2,-1
    80005450:	b755                	j	800053f4 <fileread+0x60>
    80005452:	597d                	li	s2,-1
    80005454:	b745                	j	800053f4 <fileread+0x60>

0000000080005456 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005456:	715d                	addi	sp,sp,-80
    80005458:	e486                	sd	ra,72(sp)
    8000545a:	e0a2                	sd	s0,64(sp)
    8000545c:	fc26                	sd	s1,56(sp)
    8000545e:	f84a                	sd	s2,48(sp)
    80005460:	f44e                	sd	s3,40(sp)
    80005462:	f052                	sd	s4,32(sp)
    80005464:	ec56                	sd	s5,24(sp)
    80005466:	e85a                	sd	s6,16(sp)
    80005468:	e45e                	sd	s7,8(sp)
    8000546a:	e062                	sd	s8,0(sp)
    8000546c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000546e:	00954783          	lbu	a5,9(a0)
    80005472:	10078663          	beqz	a5,8000557e <filewrite+0x128>
    80005476:	892a                	mv	s2,a0
    80005478:	8aae                	mv	s5,a1
    8000547a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000547c:	411c                	lw	a5,0(a0)
    8000547e:	4705                	li	a4,1
    80005480:	02e78263          	beq	a5,a4,800054a4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005484:	470d                	li	a4,3
    80005486:	02e78663          	beq	a5,a4,800054b2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000548a:	4709                	li	a4,2
    8000548c:	0ee79163          	bne	a5,a4,8000556e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005490:	0ac05d63          	blez	a2,8000554a <filewrite+0xf4>
    int i = 0;
    80005494:	4981                	li	s3,0
    80005496:	6b05                	lui	s6,0x1
    80005498:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000549c:	6b85                	lui	s7,0x1
    8000549e:	c00b8b9b          	addiw	s7,s7,-1024
    800054a2:	a861                	j	8000553a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800054a4:	6908                	ld	a0,16(a0)
    800054a6:	00000097          	auipc	ra,0x0
    800054aa:	424080e7          	jalr	1060(ra) # 800058ca <pipewrite>
    800054ae:	8a2a                	mv	s4,a0
    800054b0:	a045                	j	80005550 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800054b2:	02451783          	lh	a5,36(a0)
    800054b6:	03079693          	slli	a3,a5,0x30
    800054ba:	92c1                	srli	a3,a3,0x30
    800054bc:	4725                	li	a4,9
    800054be:	0cd76263          	bltu	a4,a3,80005582 <filewrite+0x12c>
    800054c2:	0792                	slli	a5,a5,0x4
    800054c4:	00041717          	auipc	a4,0x41
    800054c8:	65470713          	addi	a4,a4,1620 # 80046b18 <devsw>
    800054cc:	97ba                	add	a5,a5,a4
    800054ce:	679c                	ld	a5,8(a5)
    800054d0:	cbdd                	beqz	a5,80005586 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800054d2:	4505                	li	a0,1
    800054d4:	9782                	jalr	a5
    800054d6:	8a2a                	mv	s4,a0
    800054d8:	a8a5                	j	80005550 <filewrite+0xfa>
    800054da:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800054de:	00000097          	auipc	ra,0x0
    800054e2:	8b0080e7          	jalr	-1872(ra) # 80004d8e <begin_op>
      ilock(f->ip);
    800054e6:	01893503          	ld	a0,24(s2)
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	bbc080e7          	jalr	-1092(ra) # 800040a6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800054f2:	8762                	mv	a4,s8
    800054f4:	02092683          	lw	a3,32(s2)
    800054f8:	01598633          	add	a2,s3,s5
    800054fc:	4585                	li	a1,1
    800054fe:	01893503          	ld	a0,24(s2)
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	f50080e7          	jalr	-176(ra) # 80004452 <writei>
    8000550a:	84aa                	mv	s1,a0
    8000550c:	00a05763          	blez	a0,8000551a <filewrite+0xc4>
        f->off += r;
    80005510:	02092783          	lw	a5,32(s2)
    80005514:	9fa9                	addw	a5,a5,a0
    80005516:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000551a:	01893503          	ld	a0,24(s2)
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	c4a080e7          	jalr	-950(ra) # 80004168 <iunlock>
      end_op();
    80005526:	00000097          	auipc	ra,0x0
    8000552a:	8e8080e7          	jalr	-1816(ra) # 80004e0e <end_op>

      if(r != n1){
    8000552e:	009c1f63          	bne	s8,s1,8000554c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005532:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005536:	0149db63          	bge	s3,s4,8000554c <filewrite+0xf6>
      int n1 = n - i;
    8000553a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000553e:	84be                	mv	s1,a5
    80005540:	2781                	sext.w	a5,a5
    80005542:	f8fb5ce3          	bge	s6,a5,800054da <filewrite+0x84>
    80005546:	84de                	mv	s1,s7
    80005548:	bf49                	j	800054da <filewrite+0x84>
    int i = 0;
    8000554a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000554c:	013a1f63          	bne	s4,s3,8000556a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005550:	8552                	mv	a0,s4
    80005552:	60a6                	ld	ra,72(sp)
    80005554:	6406                	ld	s0,64(sp)
    80005556:	74e2                	ld	s1,56(sp)
    80005558:	7942                	ld	s2,48(sp)
    8000555a:	79a2                	ld	s3,40(sp)
    8000555c:	7a02                	ld	s4,32(sp)
    8000555e:	6ae2                	ld	s5,24(sp)
    80005560:	6b42                	ld	s6,16(sp)
    80005562:	6ba2                	ld	s7,8(sp)
    80005564:	6c02                	ld	s8,0(sp)
    80005566:	6161                	addi	sp,sp,80
    80005568:	8082                	ret
    ret = (i == n ? n : -1);
    8000556a:	5a7d                	li	s4,-1
    8000556c:	b7d5                	j	80005550 <filewrite+0xfa>
    panic("filewrite");
    8000556e:	00004517          	auipc	a0,0x4
    80005572:	48250513          	addi	a0,a0,1154 # 800099f0 <syscalls+0x2e0>
    80005576:	ffffb097          	auipc	ra,0xffffb
    8000557a:	fb4080e7          	jalr	-76(ra) # 8000052a <panic>
    return -1;
    8000557e:	5a7d                	li	s4,-1
    80005580:	bfc1                	j	80005550 <filewrite+0xfa>
      return -1;
    80005582:	5a7d                	li	s4,-1
    80005584:	b7f1                	j	80005550 <filewrite+0xfa>
    80005586:	5a7d                	li	s4,-1
    80005588:	b7e1                	j	80005550 <filewrite+0xfa>

000000008000558a <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    8000558a:	7179                	addi	sp,sp,-48
    8000558c:	f406                	sd	ra,40(sp)
    8000558e:	f022                	sd	s0,32(sp)
    80005590:	ec26                	sd	s1,24(sp)
    80005592:	e84a                	sd	s2,16(sp)
    80005594:	e44e                	sd	s3,8(sp)
    80005596:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005598:	00854783          	lbu	a5,8(a0)
    8000559c:	c3d5                	beqz	a5,80005640 <kfileread+0xb6>
    8000559e:	84aa                	mv	s1,a0
    800055a0:	89ae                	mv	s3,a1
    800055a2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800055a4:	411c                	lw	a5,0(a0)
    800055a6:	4705                	li	a4,1
    800055a8:	04e78963          	beq	a5,a4,800055fa <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800055ac:	470d                	li	a4,3
    800055ae:	04e78d63          	beq	a5,a4,80005608 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800055b2:	4709                	li	a4,2
    800055b4:	06e79e63          	bne	a5,a4,80005630 <kfileread+0xa6>
    ilock(f->ip);
    800055b8:	6d08                	ld	a0,24(a0)
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	aec080e7          	jalr	-1300(ra) # 800040a6 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    800055c2:	874a                	mv	a4,s2
    800055c4:	5094                	lw	a3,32(s1)
    800055c6:	864e                	mv	a2,s3
    800055c8:	4581                	li	a1,0
    800055ca:	6c88                	ld	a0,24(s1)
    800055cc:	fffff097          	auipc	ra,0xfffff
    800055d0:	d8e080e7          	jalr	-626(ra) # 8000435a <readi>
    800055d4:	892a                	mv	s2,a0
    800055d6:	00a05563          	blez	a0,800055e0 <kfileread+0x56>
      f->off += r;
    800055da:	509c                	lw	a5,32(s1)
    800055dc:	9fa9                	addw	a5,a5,a0
    800055de:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800055e0:	6c88                	ld	a0,24(s1)
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	b86080e7          	jalr	-1146(ra) # 80004168 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800055ea:	854a                	mv	a0,s2
    800055ec:	70a2                	ld	ra,40(sp)
    800055ee:	7402                	ld	s0,32(sp)
    800055f0:	64e2                	ld	s1,24(sp)
    800055f2:	6942                	ld	s2,16(sp)
    800055f4:	69a2                	ld	s3,8(sp)
    800055f6:	6145                	addi	sp,sp,48
    800055f8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800055fa:	6908                	ld	a0,16(a0)
    800055fc:	00000097          	auipc	ra,0x0
    80005600:	3c0080e7          	jalr	960(ra) # 800059bc <piperead>
    80005604:	892a                	mv	s2,a0
    80005606:	b7d5                	j	800055ea <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005608:	02451783          	lh	a5,36(a0)
    8000560c:	03079693          	slli	a3,a5,0x30
    80005610:	92c1                	srli	a3,a3,0x30
    80005612:	4725                	li	a4,9
    80005614:	02d76863          	bltu	a4,a3,80005644 <kfileread+0xba>
    80005618:	0792                	slli	a5,a5,0x4
    8000561a:	00041717          	auipc	a4,0x41
    8000561e:	4fe70713          	addi	a4,a4,1278 # 80046b18 <devsw>
    80005622:	97ba                	add	a5,a5,a4
    80005624:	639c                	ld	a5,0(a5)
    80005626:	c38d                	beqz	a5,80005648 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005628:	4505                	li	a0,1
    8000562a:	9782                	jalr	a5
    8000562c:	892a                	mv	s2,a0
    8000562e:	bf75                	j	800055ea <kfileread+0x60>
    panic("fileread");
    80005630:	00004517          	auipc	a0,0x4
    80005634:	3b050513          	addi	a0,a0,944 # 800099e0 <syscalls+0x2d0>
    80005638:	ffffb097          	auipc	ra,0xffffb
    8000563c:	ef2080e7          	jalr	-270(ra) # 8000052a <panic>
    return -1;
    80005640:	597d                	li	s2,-1
    80005642:	b765                	j	800055ea <kfileread+0x60>
      return -1;
    80005644:	597d                	li	s2,-1
    80005646:	b755                	j	800055ea <kfileread+0x60>
    80005648:	597d                	li	s2,-1
    8000564a:	b745                	j	800055ea <kfileread+0x60>

000000008000564c <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    8000564c:	715d                	addi	sp,sp,-80
    8000564e:	e486                	sd	ra,72(sp)
    80005650:	e0a2                	sd	s0,64(sp)
    80005652:	fc26                	sd	s1,56(sp)
    80005654:	f84a                	sd	s2,48(sp)
    80005656:	f44e                	sd	s3,40(sp)
    80005658:	f052                	sd	s4,32(sp)
    8000565a:	ec56                	sd	s5,24(sp)
    8000565c:	e85a                	sd	s6,16(sp)
    8000565e:	e45e                	sd	s7,8(sp)
    80005660:	e062                	sd	s8,0(sp)
    80005662:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005664:	00954783          	lbu	a5,9(a0)
    80005668:	10078663          	beqz	a5,80005774 <kfilewrite+0x128>
    8000566c:	892a                	mv	s2,a0
    8000566e:	8aae                	mv	s5,a1
    80005670:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005672:	411c                	lw	a5,0(a0)
    80005674:	4705                	li	a4,1
    80005676:	02e78263          	beq	a5,a4,8000569a <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);

  } else if(f->type == FD_DEVICE){
    8000567a:	470d                	li	a4,3
    8000567c:	02e78663          	beq	a5,a4,800056a8 <kfilewrite+0x5c>

    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;

    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005680:	4709                	li	a4,2
    80005682:	0ee79163          	bne	a5,a4,80005764 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005686:	0ac05d63          	blez	a2,80005740 <kfilewrite+0xf4>
    int i = 0;
    8000568a:	4981                	li	s3,0
    8000568c:	6b05                	lui	s6,0x1
    8000568e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005692:	6b85                	lui	s7,0x1
    80005694:	c00b8b9b          	addiw	s7,s7,-1024
    80005698:	a861                	j	80005730 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000569a:	6908                	ld	a0,16(a0)
    8000569c:	00000097          	auipc	ra,0x0
    800056a0:	22e080e7          	jalr	558(ra) # 800058ca <pipewrite>
    800056a4:	8a2a                	mv	s4,a0
    800056a6:	a045                	j	80005746 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800056a8:	02451783          	lh	a5,36(a0)
    800056ac:	03079693          	slli	a3,a5,0x30
    800056b0:	92c1                	srli	a3,a3,0x30
    800056b2:	4725                	li	a4,9
    800056b4:	0cd76263          	bltu	a4,a3,80005778 <kfilewrite+0x12c>
    800056b8:	0792                	slli	a5,a5,0x4
    800056ba:	00041717          	auipc	a4,0x41
    800056be:	45e70713          	addi	a4,a4,1118 # 80046b18 <devsw>
    800056c2:	97ba                	add	a5,a5,a4
    800056c4:	679c                	ld	a5,8(a5)
    800056c6:	cbdd                	beqz	a5,8000577c <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800056c8:	4505                	li	a0,1
    800056ca:	9782                	jalr	a5
    800056cc:	8a2a                	mv	s4,a0
    800056ce:	a8a5                	j	80005746 <kfilewrite+0xfa>
    800056d0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800056d4:	fffff097          	auipc	ra,0xfffff
    800056d8:	6ba080e7          	jalr	1722(ra) # 80004d8e <begin_op>
      ilock(f->ip);
    800056dc:	01893503          	ld	a0,24(s2)
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	9c6080e7          	jalr	-1594(ra) # 800040a6 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800056e8:	8762                	mv	a4,s8
    800056ea:	02092683          	lw	a3,32(s2)
    800056ee:	01598633          	add	a2,s3,s5
    800056f2:	4581                	li	a1,0
    800056f4:	01893503          	ld	a0,24(s2)
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	d5a080e7          	jalr	-678(ra) # 80004452 <writei>
    80005700:	84aa                	mv	s1,a0
    80005702:	00a05763          	blez	a0,80005710 <kfilewrite+0xc4>
        f->off += r;
    80005706:	02092783          	lw	a5,32(s2)
    8000570a:	9fa9                	addw	a5,a5,a0
    8000570c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005710:	01893503          	ld	a0,24(s2)
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	a54080e7          	jalr	-1452(ra) # 80004168 <iunlock>
      end_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	6f2080e7          	jalr	1778(ra) # 80004e0e <end_op>

      if(r != n1){
    80005724:	009c1f63          	bne	s8,s1,80005742 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005728:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000572c:	0149db63          	bge	s3,s4,80005742 <kfilewrite+0xf6>
      int n1 = n - i;
    80005730:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005734:	84be                	mv	s1,a5
    80005736:	2781                	sext.w	a5,a5
    80005738:	f8fb5ce3          	bge	s6,a5,800056d0 <kfilewrite+0x84>
    8000573c:	84de                	mv	s1,s7
    8000573e:	bf49                	j	800056d0 <kfilewrite+0x84>
    int i = 0;
    80005740:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005742:	013a1f63          	bne	s4,s3,80005760 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005746:	8552                	mv	a0,s4
    80005748:	60a6                	ld	ra,72(sp)
    8000574a:	6406                	ld	s0,64(sp)
    8000574c:	74e2                	ld	s1,56(sp)
    8000574e:	7942                	ld	s2,48(sp)
    80005750:	79a2                	ld	s3,40(sp)
    80005752:	7a02                	ld	s4,32(sp)
    80005754:	6ae2                	ld	s5,24(sp)
    80005756:	6b42                	ld	s6,16(sp)
    80005758:	6ba2                	ld	s7,8(sp)
    8000575a:	6c02                	ld	s8,0(sp)
    8000575c:	6161                	addi	sp,sp,80
    8000575e:	8082                	ret
    ret = (i == n ? n : -1);
    80005760:	5a7d                	li	s4,-1
    80005762:	b7d5                	j	80005746 <kfilewrite+0xfa>
    panic("filewrite");
    80005764:	00004517          	auipc	a0,0x4
    80005768:	28c50513          	addi	a0,a0,652 # 800099f0 <syscalls+0x2e0>
    8000576c:	ffffb097          	auipc	ra,0xffffb
    80005770:	dbe080e7          	jalr	-578(ra) # 8000052a <panic>
    return -1;
    80005774:	5a7d                	li	s4,-1
    80005776:	bfc1                	j	80005746 <kfilewrite+0xfa>
      return -1;
    80005778:	5a7d                	li	s4,-1
    8000577a:	b7f1                	j	80005746 <kfilewrite+0xfa>
    8000577c:	5a7d                	li	s4,-1
    8000577e:	b7e1                	j	80005746 <kfilewrite+0xfa>

0000000080005780 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005780:	7179                	addi	sp,sp,-48
    80005782:	f406                	sd	ra,40(sp)
    80005784:	f022                	sd	s0,32(sp)
    80005786:	ec26                	sd	s1,24(sp)
    80005788:	e84a                	sd	s2,16(sp)
    8000578a:	e44e                	sd	s3,8(sp)
    8000578c:	e052                	sd	s4,0(sp)
    8000578e:	1800                	addi	s0,sp,48
    80005790:	84aa                	mv	s1,a0
    80005792:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005794:	0005b023          	sd	zero,0(a1)
    80005798:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000579c:	00000097          	auipc	ra,0x0
    800057a0:	a02080e7          	jalr	-1534(ra) # 8000519e <filealloc>
    800057a4:	e088                	sd	a0,0(s1)
    800057a6:	c551                	beqz	a0,80005832 <pipealloc+0xb2>
    800057a8:	00000097          	auipc	ra,0x0
    800057ac:	9f6080e7          	jalr	-1546(ra) # 8000519e <filealloc>
    800057b0:	00aa3023          	sd	a0,0(s4)
    800057b4:	c92d                	beqz	a0,80005826 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800057b6:	ffffb097          	auipc	ra,0xffffb
    800057ba:	31c080e7          	jalr	796(ra) # 80000ad2 <kalloc>
    800057be:	892a                	mv	s2,a0
    800057c0:	c125                	beqz	a0,80005820 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800057c2:	4985                	li	s3,1
    800057c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800057c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800057cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800057d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800057d4:	00004597          	auipc	a1,0x4
    800057d8:	22c58593          	addi	a1,a1,556 # 80009a00 <syscalls+0x2f0>
    800057dc:	ffffb097          	auipc	ra,0xffffb
    800057e0:	356080e7          	jalr	854(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800057e4:	609c                	ld	a5,0(s1)
    800057e6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800057ea:	609c                	ld	a5,0(s1)
    800057ec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800057f0:	609c                	ld	a5,0(s1)
    800057f2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800057f6:	609c                	ld	a5,0(s1)
    800057f8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800057fc:	000a3783          	ld	a5,0(s4)
    80005800:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005804:	000a3783          	ld	a5,0(s4)
    80005808:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000580c:	000a3783          	ld	a5,0(s4)
    80005810:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005814:	000a3783          	ld	a5,0(s4)
    80005818:	0127b823          	sd	s2,16(a5)
  return 0;
    8000581c:	4501                	li	a0,0
    8000581e:	a025                	j	80005846 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005820:	6088                	ld	a0,0(s1)
    80005822:	e501                	bnez	a0,8000582a <pipealloc+0xaa>
    80005824:	a039                	j	80005832 <pipealloc+0xb2>
    80005826:	6088                	ld	a0,0(s1)
    80005828:	c51d                	beqz	a0,80005856 <pipealloc+0xd6>
    fileclose(*f0);
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	a30080e7          	jalr	-1488(ra) # 8000525a <fileclose>
  if(*f1)
    80005832:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005836:	557d                	li	a0,-1
  if(*f1)
    80005838:	c799                	beqz	a5,80005846 <pipealloc+0xc6>
    fileclose(*f1);
    8000583a:	853e                	mv	a0,a5
    8000583c:	00000097          	auipc	ra,0x0
    80005840:	a1e080e7          	jalr	-1506(ra) # 8000525a <fileclose>
  return -1;
    80005844:	557d                	li	a0,-1
}
    80005846:	70a2                	ld	ra,40(sp)
    80005848:	7402                	ld	s0,32(sp)
    8000584a:	64e2                	ld	s1,24(sp)
    8000584c:	6942                	ld	s2,16(sp)
    8000584e:	69a2                	ld	s3,8(sp)
    80005850:	6a02                	ld	s4,0(sp)
    80005852:	6145                	addi	sp,sp,48
    80005854:	8082                	ret
  return -1;
    80005856:	557d                	li	a0,-1
    80005858:	b7fd                	j	80005846 <pipealloc+0xc6>

000000008000585a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000585a:	1101                	addi	sp,sp,-32
    8000585c:	ec06                	sd	ra,24(sp)
    8000585e:	e822                	sd	s0,16(sp)
    80005860:	e426                	sd	s1,8(sp)
    80005862:	e04a                	sd	s2,0(sp)
    80005864:	1000                	addi	s0,sp,32
    80005866:	84aa                	mv	s1,a0
    80005868:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000586a:	ffffb097          	auipc	ra,0xffffb
    8000586e:	358080e7          	jalr	856(ra) # 80000bc2 <acquire>
  if(writable){
    80005872:	02090d63          	beqz	s2,800058ac <pipeclose+0x52>
    pi->writeopen = 0;
    80005876:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000587a:	21848513          	addi	a0,s1,536
    8000587e:	ffffc097          	auipc	ra,0xffffc
    80005882:	74a080e7          	jalr	1866(ra) # 80001fc8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005886:	2204b783          	ld	a5,544(s1)
    8000588a:	eb95                	bnez	a5,800058be <pipeclose+0x64>
    release(&pi->lock);
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffb097          	auipc	ra,0xffffb
    80005892:	3e8080e7          	jalr	1000(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffb097          	auipc	ra,0xffffb
    8000589c:	13e080e7          	jalr	318(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800058a0:	60e2                	ld	ra,24(sp)
    800058a2:	6442                	ld	s0,16(sp)
    800058a4:	64a2                	ld	s1,8(sp)
    800058a6:	6902                	ld	s2,0(sp)
    800058a8:	6105                	addi	sp,sp,32
    800058aa:	8082                	ret
    pi->readopen = 0;
    800058ac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800058b0:	21c48513          	addi	a0,s1,540
    800058b4:	ffffc097          	auipc	ra,0xffffc
    800058b8:	714080e7          	jalr	1812(ra) # 80001fc8 <wakeup>
    800058bc:	b7e9                	j	80005886 <pipeclose+0x2c>
    release(&pi->lock);
    800058be:	8526                	mv	a0,s1
    800058c0:	ffffb097          	auipc	ra,0xffffb
    800058c4:	3b6080e7          	jalr	950(ra) # 80000c76 <release>
}
    800058c8:	bfe1                	j	800058a0 <pipeclose+0x46>

00000000800058ca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800058ca:	711d                	addi	sp,sp,-96
    800058cc:	ec86                	sd	ra,88(sp)
    800058ce:	e8a2                	sd	s0,80(sp)
    800058d0:	e4a6                	sd	s1,72(sp)
    800058d2:	e0ca                	sd	s2,64(sp)
    800058d4:	fc4e                	sd	s3,56(sp)
    800058d6:	f852                	sd	s4,48(sp)
    800058d8:	f456                	sd	s5,40(sp)
    800058da:	f05a                	sd	s6,32(sp)
    800058dc:	ec5e                	sd	s7,24(sp)
    800058de:	e862                	sd	s8,16(sp)
    800058e0:	1080                	addi	s0,sp,96
    800058e2:	84aa                	mv	s1,a0
    800058e4:	8aae                	mv	s5,a1
    800058e6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800058e8:	ffffc097          	auipc	ra,0xffffc
    800058ec:	29e080e7          	jalr	670(ra) # 80001b86 <myproc>
    800058f0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800058f2:	8526                	mv	a0,s1
    800058f4:	ffffb097          	auipc	ra,0xffffb
    800058f8:	2ce080e7          	jalr	718(ra) # 80000bc2 <acquire>
  while(i < n){
    800058fc:	0b405363          	blez	s4,800059a2 <pipewrite+0xd8>
  int i = 0;
    80005900:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005902:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005904:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005908:	21c48b93          	addi	s7,s1,540
    8000590c:	a089                	j	8000594e <pipewrite+0x84>
      release(&pi->lock);
    8000590e:	8526                	mv	a0,s1
    80005910:	ffffb097          	auipc	ra,0xffffb
    80005914:	366080e7          	jalr	870(ra) # 80000c76 <release>
      return -1;
    80005918:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000591a:	854a                	mv	a0,s2
    8000591c:	60e6                	ld	ra,88(sp)
    8000591e:	6446                	ld	s0,80(sp)
    80005920:	64a6                	ld	s1,72(sp)
    80005922:	6906                	ld	s2,64(sp)
    80005924:	79e2                	ld	s3,56(sp)
    80005926:	7a42                	ld	s4,48(sp)
    80005928:	7aa2                	ld	s5,40(sp)
    8000592a:	7b02                	ld	s6,32(sp)
    8000592c:	6be2                	ld	s7,24(sp)
    8000592e:	6c42                	ld	s8,16(sp)
    80005930:	6125                	addi	sp,sp,96
    80005932:	8082                	ret
      wakeup(&pi->nread);
    80005934:	8562                	mv	a0,s8
    80005936:	ffffc097          	auipc	ra,0xffffc
    8000593a:	692080e7          	jalr	1682(ra) # 80001fc8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000593e:	85a6                	mv	a1,s1
    80005940:	855e                	mv	a0,s7
    80005942:	ffffc097          	auipc	ra,0xffffc
    80005946:	622080e7          	jalr	1570(ra) # 80001f64 <sleep>
  while(i < n){
    8000594a:	05495d63          	bge	s2,s4,800059a4 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000594e:	2204a783          	lw	a5,544(s1)
    80005952:	dfd5                	beqz	a5,8000590e <pipewrite+0x44>
    80005954:	0289a783          	lw	a5,40(s3)
    80005958:	fbdd                	bnez	a5,8000590e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000595a:	2184a783          	lw	a5,536(s1)
    8000595e:	21c4a703          	lw	a4,540(s1)
    80005962:	2007879b          	addiw	a5,a5,512
    80005966:	fcf707e3          	beq	a4,a5,80005934 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000596a:	4685                	li	a3,1
    8000596c:	01590633          	add	a2,s2,s5
    80005970:	faf40593          	addi	a1,s0,-81
    80005974:	0509b503          	ld	a0,80(s3)
    80005978:	ffffc097          	auipc	ra,0xffffc
    8000597c:	f46080e7          	jalr	-186(ra) # 800018be <copyin>
    80005980:	03650263          	beq	a0,s6,800059a4 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005984:	21c4a783          	lw	a5,540(s1)
    80005988:	0017871b          	addiw	a4,a5,1
    8000598c:	20e4ae23          	sw	a4,540(s1)
    80005990:	1ff7f793          	andi	a5,a5,511
    80005994:	97a6                	add	a5,a5,s1
    80005996:	faf44703          	lbu	a4,-81(s0)
    8000599a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000599e:	2905                	addiw	s2,s2,1
    800059a0:	b76d                	j	8000594a <pipewrite+0x80>
  int i = 0;
    800059a2:	4901                	li	s2,0
  wakeup(&pi->nread);
    800059a4:	21848513          	addi	a0,s1,536
    800059a8:	ffffc097          	auipc	ra,0xffffc
    800059ac:	620080e7          	jalr	1568(ra) # 80001fc8 <wakeup>
  release(&pi->lock);
    800059b0:	8526                	mv	a0,s1
    800059b2:	ffffb097          	auipc	ra,0xffffb
    800059b6:	2c4080e7          	jalr	708(ra) # 80000c76 <release>
  return i;
    800059ba:	b785                	j	8000591a <pipewrite+0x50>

00000000800059bc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800059bc:	715d                	addi	sp,sp,-80
    800059be:	e486                	sd	ra,72(sp)
    800059c0:	e0a2                	sd	s0,64(sp)
    800059c2:	fc26                	sd	s1,56(sp)
    800059c4:	f84a                	sd	s2,48(sp)
    800059c6:	f44e                	sd	s3,40(sp)
    800059c8:	f052                	sd	s4,32(sp)
    800059ca:	ec56                	sd	s5,24(sp)
    800059cc:	e85a                	sd	s6,16(sp)
    800059ce:	0880                	addi	s0,sp,80
    800059d0:	84aa                	mv	s1,a0
    800059d2:	892e                	mv	s2,a1
    800059d4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800059d6:	ffffc097          	auipc	ra,0xffffc
    800059da:	1b0080e7          	jalr	432(ra) # 80001b86 <myproc>
    800059de:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800059e0:	8526                	mv	a0,s1
    800059e2:	ffffb097          	auipc	ra,0xffffb
    800059e6:	1e0080e7          	jalr	480(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059ea:	2184a703          	lw	a4,536(s1)
    800059ee:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059f2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059f6:	02f71463          	bne	a4,a5,80005a1e <piperead+0x62>
    800059fa:	2244a783          	lw	a5,548(s1)
    800059fe:	c385                	beqz	a5,80005a1e <piperead+0x62>
    if(pr->killed){
    80005a00:	028a2783          	lw	a5,40(s4)
    80005a04:	ebc1                	bnez	a5,80005a94 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a06:	85a6                	mv	a1,s1
    80005a08:	854e                	mv	a0,s3
    80005a0a:	ffffc097          	auipc	ra,0xffffc
    80005a0e:	55a080e7          	jalr	1370(ra) # 80001f64 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a12:	2184a703          	lw	a4,536(s1)
    80005a16:	21c4a783          	lw	a5,540(s1)
    80005a1a:	fef700e3          	beq	a4,a5,800059fa <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a1e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a20:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a22:	05505363          	blez	s5,80005a68 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005a26:	2184a783          	lw	a5,536(s1)
    80005a2a:	21c4a703          	lw	a4,540(s1)
    80005a2e:	02f70d63          	beq	a4,a5,80005a68 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005a32:	0017871b          	addiw	a4,a5,1
    80005a36:	20e4ac23          	sw	a4,536(s1)
    80005a3a:	1ff7f793          	andi	a5,a5,511
    80005a3e:	97a6                	add	a5,a5,s1
    80005a40:	0187c783          	lbu	a5,24(a5)
    80005a44:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a48:	4685                	li	a3,1
    80005a4a:	fbf40613          	addi	a2,s0,-65
    80005a4e:	85ca                	mv	a1,s2
    80005a50:	050a3503          	ld	a0,80(s4)
    80005a54:	ffffc097          	auipc	ra,0xffffc
    80005a58:	dde080e7          	jalr	-546(ra) # 80001832 <copyout>
    80005a5c:	01650663          	beq	a0,s6,80005a68 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a60:	2985                	addiw	s3,s3,1
    80005a62:	0905                	addi	s2,s2,1
    80005a64:	fd3a91e3          	bne	s5,s3,80005a26 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005a68:	21c48513          	addi	a0,s1,540
    80005a6c:	ffffc097          	auipc	ra,0xffffc
    80005a70:	55c080e7          	jalr	1372(ra) # 80001fc8 <wakeup>
  release(&pi->lock);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffb097          	auipc	ra,0xffffb
    80005a7a:	200080e7          	jalr	512(ra) # 80000c76 <release>
  return i;
}
    80005a7e:	854e                	mv	a0,s3
    80005a80:	60a6                	ld	ra,72(sp)
    80005a82:	6406                	ld	s0,64(sp)
    80005a84:	74e2                	ld	s1,56(sp)
    80005a86:	7942                	ld	s2,48(sp)
    80005a88:	79a2                	ld	s3,40(sp)
    80005a8a:	7a02                	ld	s4,32(sp)
    80005a8c:	6ae2                	ld	s5,24(sp)
    80005a8e:	6b42                	ld	s6,16(sp)
    80005a90:	6161                	addi	sp,sp,80
    80005a92:	8082                	ret
      release(&pi->lock);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	1e0080e7          	jalr	480(ra) # 80000c76 <release>
      return -1;
    80005a9e:	59fd                	li	s3,-1
    80005aa0:	bff9                	j	80005a7e <piperead+0xc2>

0000000080005aa2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005aa2:	de010113          	addi	sp,sp,-544
    80005aa6:	20113c23          	sd	ra,536(sp)
    80005aaa:	20813823          	sd	s0,528(sp)
    80005aae:	20913423          	sd	s1,520(sp)
    80005ab2:	21213023          	sd	s2,512(sp)
    80005ab6:	ffce                	sd	s3,504(sp)
    80005ab8:	fbd2                	sd	s4,496(sp)
    80005aba:	f7d6                	sd	s5,488(sp)
    80005abc:	f3da                	sd	s6,480(sp)
    80005abe:	efde                	sd	s7,472(sp)
    80005ac0:	ebe2                	sd	s8,464(sp)
    80005ac2:	e7e6                	sd	s9,456(sp)
    80005ac4:	e3ea                	sd	s10,448(sp)
    80005ac6:	ff6e                	sd	s11,440(sp)
    80005ac8:	1400                	addi	s0,sp,544
    80005aca:	892a                	mv	s2,a0
    80005acc:	dea43423          	sd	a0,-536(s0)
    80005ad0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005ad4:	ffffc097          	auipc	ra,0xffffc
    80005ad8:	0b2080e7          	jalr	178(ra) # 80001b86 <myproc>
    80005adc:	84aa                	mv	s1,a0

  begin_op();
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	2b0080e7          	jalr	688(ra) # 80004d8e <begin_op>

  if((ip = namei(path)) == 0){
    80005ae6:	854a                	mv	a0,s2
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	d74080e7          	jalr	-652(ra) # 8000485c <namei>
    80005af0:	c93d                	beqz	a0,80005b66 <exec+0xc4>
    80005af2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	5b2080e7          	jalr	1458(ra) # 800040a6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005afc:	04000713          	li	a4,64
    80005b00:	4681                	li	a3,0
    80005b02:	e4840613          	addi	a2,s0,-440
    80005b06:	4581                	li	a1,0
    80005b08:	8556                	mv	a0,s5
    80005b0a:	fffff097          	auipc	ra,0xfffff
    80005b0e:	850080e7          	jalr	-1968(ra) # 8000435a <readi>
    80005b12:	04000793          	li	a5,64
    80005b16:	00f51a63          	bne	a0,a5,80005b2a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005b1a:	e4842703          	lw	a4,-440(s0)
    80005b1e:	464c47b7          	lui	a5,0x464c4
    80005b22:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005b26:	04f70663          	beq	a4,a5,80005b72 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005b2a:	8556                	mv	a0,s5
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	7dc080e7          	jalr	2012(ra) # 80004308 <iunlockput>
    end_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	2da080e7          	jalr	730(ra) # 80004e0e <end_op>
  }
  return -1;
    80005b3c:	557d                	li	a0,-1
}
    80005b3e:	21813083          	ld	ra,536(sp)
    80005b42:	21013403          	ld	s0,528(sp)
    80005b46:	20813483          	ld	s1,520(sp)
    80005b4a:	20013903          	ld	s2,512(sp)
    80005b4e:	79fe                	ld	s3,504(sp)
    80005b50:	7a5e                	ld	s4,496(sp)
    80005b52:	7abe                	ld	s5,488(sp)
    80005b54:	7b1e                	ld	s6,480(sp)
    80005b56:	6bfe                	ld	s7,472(sp)
    80005b58:	6c5e                	ld	s8,464(sp)
    80005b5a:	6cbe                	ld	s9,456(sp)
    80005b5c:	6d1e                	ld	s10,448(sp)
    80005b5e:	7dfa                	ld	s11,440(sp)
    80005b60:	22010113          	addi	sp,sp,544
    80005b64:	8082                	ret
    end_op();
    80005b66:	fffff097          	auipc	ra,0xfffff
    80005b6a:	2a8080e7          	jalr	680(ra) # 80004e0e <end_op>
    return -1;
    80005b6e:	557d                	li	a0,-1
    80005b70:	b7f9                	j	80005b3e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005b72:	8526                	mv	a0,s1
    80005b74:	ffffc097          	auipc	ra,0xffffc
    80005b78:	0d6080e7          	jalr	214(ra) # 80001c4a <proc_pagetable>
    80005b7c:	8b2a                	mv	s6,a0
    80005b7e:	d555                	beqz	a0,80005b2a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b80:	e6842783          	lw	a5,-408(s0)
    80005b84:	e8045703          	lhu	a4,-384(s0)
    80005b88:	c735                	beqz	a4,80005bf4 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005b8a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b8c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005b90:	6a05                	lui	s4,0x1
    80005b92:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005b96:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005b9a:	6d85                	lui	s11,0x1
    80005b9c:	7d7d                	lui	s10,0xfffff
    80005b9e:	a4bd                	j	80005e0c <exec+0x36a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005ba0:	00004517          	auipc	a0,0x4
    80005ba4:	e6850513          	addi	a0,a0,-408 # 80009a08 <syscalls+0x2f8>
    80005ba8:	ffffb097          	auipc	ra,0xffffb
    80005bac:	982080e7          	jalr	-1662(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005bb0:	874a                	mv	a4,s2
    80005bb2:	009c86bb          	addw	a3,s9,s1
    80005bb6:	4581                	li	a1,0
    80005bb8:	8556                	mv	a0,s5
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	7a0080e7          	jalr	1952(ra) # 8000435a <readi>
    80005bc2:	2501                	sext.w	a0,a0
    80005bc4:	1ea91463          	bne	s2,a0,80005dac <exec+0x30a>
  for(i = 0; i < sz; i += PGSIZE){
    80005bc8:	009d84bb          	addw	s1,s11,s1
    80005bcc:	013d09bb          	addw	s3,s10,s3
    80005bd0:	2174fe63          	bgeu	s1,s7,80005dec <exec+0x34a>
    pa = walkaddr(pagetable, va + i);
    80005bd4:	02049593          	slli	a1,s1,0x20
    80005bd8:	9181                	srli	a1,a1,0x20
    80005bda:	95e2                	add	a1,a1,s8
    80005bdc:	855a                	mv	a0,s6
    80005bde:	ffffb097          	auipc	ra,0xffffb
    80005be2:	46e080e7          	jalr	1134(ra) # 8000104c <walkaddr>
    80005be6:	862a                	mv	a2,a0
    if(pa == 0)
    80005be8:	dd45                	beqz	a0,80005ba0 <exec+0xfe>
      n = PGSIZE;
    80005bea:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005bec:	fd49f2e3          	bgeu	s3,s4,80005bb0 <exec+0x10e>
      n = sz - i;
    80005bf0:	894e                	mv	s2,s3
    80005bf2:	bf7d                	j	80005bb0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005bf4:	4481                	li	s1,0
  iunlockput(ip);
    80005bf6:	8556                	mv	a0,s5
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	710080e7          	jalr	1808(ra) # 80004308 <iunlockput>
  end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	20e080e7          	jalr	526(ra) # 80004e0e <end_op>
  p = myproc();
    80005c08:	ffffc097          	auipc	ra,0xffffc
    80005c0c:	f7e080e7          	jalr	-130(ra) # 80001b86 <myproc>
    80005c10:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005c12:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005c16:	6785                	lui	a5,0x1
    80005c18:	17fd                	addi	a5,a5,-1
    80005c1a:	94be                	add	s1,s1,a5
    80005c1c:	77fd                	lui	a5,0xfffff
    80005c1e:	8fe5                	and	a5,a5,s1
    80005c20:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005c24:	6609                	lui	a2,0x2
    80005c26:	963e                	add	a2,a2,a5
    80005c28:	85be                	mv	a1,a5
    80005c2a:	855a                	mv	a0,s6
    80005c2c:	ffffc097          	auipc	ra,0xffffc
    80005c30:	936080e7          	jalr	-1738(ra) # 80001562 <uvmalloc>
    80005c34:	8c2a                	mv	s8,a0
  ip = 0;
    80005c36:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005c38:	16050a63          	beqz	a0,80005dac <exec+0x30a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005c3c:	75f9                	lui	a1,0xffffe
    80005c3e:	95aa                	add	a1,a1,a0
    80005c40:	855a                	mv	a0,s6
    80005c42:	ffffc097          	auipc	ra,0xffffc
    80005c46:	bbe080e7          	jalr	-1090(ra) # 80001800 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c4a:	7afd                	lui	s5,0xfffff
    80005c4c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005c4e:	df043783          	ld	a5,-528(s0)
    80005c52:	6388                	ld	a0,0(a5)
    80005c54:	c925                	beqz	a0,80005cc4 <exec+0x222>
    80005c56:	e8840993          	addi	s3,s0,-376
    80005c5a:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005c5e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005c60:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005c62:	ffffb097          	auipc	ra,0xffffb
    80005c66:	1e0080e7          	jalr	480(ra) # 80000e42 <strlen>
    80005c6a:	0015079b          	addiw	a5,a0,1
    80005c6e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c72:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005c76:	15596f63          	bltu	s2,s5,80005dd4 <exec+0x332>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c7a:	df043d83          	ld	s11,-528(s0)
    80005c7e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005c82:	8552                	mv	a0,s4
    80005c84:	ffffb097          	auipc	ra,0xffffb
    80005c88:	1be080e7          	jalr	446(ra) # 80000e42 <strlen>
    80005c8c:	0015069b          	addiw	a3,a0,1
    80005c90:	8652                	mv	a2,s4
    80005c92:	85ca                	mv	a1,s2
    80005c94:	855a                	mv	a0,s6
    80005c96:	ffffc097          	auipc	ra,0xffffc
    80005c9a:	b9c080e7          	jalr	-1124(ra) # 80001832 <copyout>
    80005c9e:	12054f63          	bltz	a0,80005ddc <exec+0x33a>
    ustack[argc] = sp;
    80005ca2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005ca6:	0485                	addi	s1,s1,1
    80005ca8:	008d8793          	addi	a5,s11,8
    80005cac:	def43823          	sd	a5,-528(s0)
    80005cb0:	008db503          	ld	a0,8(s11)
    80005cb4:	c911                	beqz	a0,80005cc8 <exec+0x226>
    if(argc >= MAXARG)
    80005cb6:	09a1                	addi	s3,s3,8
    80005cb8:	fb9995e3          	bne	s3,s9,80005c62 <exec+0x1c0>
  sz = sz1;
    80005cbc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cc0:	4a81                	li	s5,0
    80005cc2:	a0ed                	j	80005dac <exec+0x30a>
  sp = sz;
    80005cc4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005cc6:	4481                	li	s1,0
  ustack[argc] = 0;
    80005cc8:	00349793          	slli	a5,s1,0x3
    80005ccc:	f9040713          	addi	a4,s0,-112
    80005cd0:	97ba                	add	a5,a5,a4
    80005cd2:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffb3ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005cd6:	00148693          	addi	a3,s1,1
    80005cda:	068e                	slli	a3,a3,0x3
    80005cdc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005ce0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005ce4:	01597663          	bgeu	s2,s5,80005cf0 <exec+0x24e>
  sz = sz1;
    80005ce8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cec:	4a81                	li	s5,0
    80005cee:	a87d                	j	80005dac <exec+0x30a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005cf0:	e8840613          	addi	a2,s0,-376
    80005cf4:	85ca                	mv	a1,s2
    80005cf6:	855a                	mv	a0,s6
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	b3a080e7          	jalr	-1222(ra) # 80001832 <copyout>
    80005d00:	0e054263          	bltz	a0,80005de4 <exec+0x342>
  p->trapframe->a1 = sp;
    80005d04:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005d08:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005d0c:	de843783          	ld	a5,-536(s0)
    80005d10:	0007c703          	lbu	a4,0(a5)
    80005d14:	cf11                	beqz	a4,80005d30 <exec+0x28e>
    80005d16:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005d18:	02f00693          	li	a3,47
    80005d1c:	a039                	j	80005d2a <exec+0x288>
      last = s+1;
    80005d1e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005d22:	0785                	addi	a5,a5,1
    80005d24:	fff7c703          	lbu	a4,-1(a5)
    80005d28:	c701                	beqz	a4,80005d30 <exec+0x28e>
    if(*s == '/')
    80005d2a:	fed71ce3          	bne	a4,a3,80005d22 <exec+0x280>
    80005d2e:	bfc5                	j	80005d1e <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005d30:	4641                	li	a2,16
    80005d32:	de843583          	ld	a1,-536(s0)
    80005d36:	158b8513          	addi	a0,s7,344
    80005d3a:	ffffb097          	auipc	ra,0xffffb
    80005d3e:	0d6080e7          	jalr	214(ra) # 80000e10 <safestrcpy>
  if(myproc()->pid >2)
    80005d42:	ffffc097          	auipc	ra,0xffffc
    80005d46:	e44080e7          	jalr	-444(ra) # 80001b86 <myproc>
    80005d4a:	5918                	lw	a4,48(a0)
    80005d4c:	4789                	li	a5,2
    80005d4e:	02e7d663          	bge	a5,a4,80005d7a <exec+0x2d8>
    80005d52:	170b8793          	addi	a5,s7,368
    80005d56:	470b8693          	addi	a3,s7,1136
    80005d5a:	a029                	j	80005d64 <exec+0x2c2>
    for (int i=0; i<MAX_PSYC_PAGES; i++)
    80005d5c:	03078793          	addi	a5,a5,48
    80005d60:	00d78d63          	beq	a5,a3,80005d7a <exec+0x2d8>
      if(p->files_in_physicalmem[i].isAvailable==0)
    80005d64:	873e                	mv	a4,a5
    80005d66:	6007a603          	lw	a2,1536(a5)
    80005d6a:	e219                	bnez	a2,80005d70 <exec+0x2ce>
        p->files_in_physicalmem[i].pagetable = pagetable;
    80005d6c:	6167b423          	sd	s6,1544(a5)
      if(p->files_in_swap[i].isAvailable==0)
    80005d70:	4310                	lw	a2,0(a4)
    80005d72:	f66d                	bnez	a2,80005d5c <exec+0x2ba>
        p->files_in_swap[i].pagetable = pagetable;
    80005d74:	01673423          	sd	s6,8(a4)
    80005d78:	b7d5                	j	80005d5c <exec+0x2ba>
  oldpagetable = p->pagetable;
    80005d7a:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005d7e:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005d82:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005d86:	058bb783          	ld	a5,88(s7)
    80005d8a:	e6043703          	ld	a4,-416(s0)
    80005d8e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005d90:	058bb783          	ld	a5,88(s7)
    80005d94:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005d98:	85ea                	mv	a1,s10
    80005d9a:	ffffc097          	auipc	ra,0xffffc
    80005d9e:	f4c080e7          	jalr	-180(ra) # 80001ce6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005da2:	0004851b          	sext.w	a0,s1
    80005da6:	bb61                	j	80005b3e <exec+0x9c>
    80005da8:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005dac:	df843583          	ld	a1,-520(s0)
    80005db0:	855a                	mv	a0,s6
    80005db2:	ffffc097          	auipc	ra,0xffffc
    80005db6:	f34080e7          	jalr	-204(ra) # 80001ce6 <proc_freepagetable>
  if(ip){
    80005dba:	d60a98e3          	bnez	s5,80005b2a <exec+0x88>
  return -1;
    80005dbe:	557d                	li	a0,-1
    80005dc0:	bbbd                	j	80005b3e <exec+0x9c>
    80005dc2:	de943c23          	sd	s1,-520(s0)
    80005dc6:	b7dd                	j	80005dac <exec+0x30a>
    80005dc8:	de943c23          	sd	s1,-520(s0)
    80005dcc:	b7c5                	j	80005dac <exec+0x30a>
    80005dce:	de943c23          	sd	s1,-520(s0)
    80005dd2:	bfe9                	j	80005dac <exec+0x30a>
  sz = sz1;
    80005dd4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005dd8:	4a81                	li	s5,0
    80005dda:	bfc9                	j	80005dac <exec+0x30a>
  sz = sz1;
    80005ddc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005de0:	4a81                	li	s5,0
    80005de2:	b7e9                	j	80005dac <exec+0x30a>
  sz = sz1;
    80005de4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005de8:	4a81                	li	s5,0
    80005dea:	b7c9                	j	80005dac <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005dec:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005df0:	e0843783          	ld	a5,-504(s0)
    80005df4:	0017869b          	addiw	a3,a5,1
    80005df8:	e0d43423          	sd	a3,-504(s0)
    80005dfc:	e0043783          	ld	a5,-512(s0)
    80005e00:	0387879b          	addiw	a5,a5,56
    80005e04:	e8045703          	lhu	a4,-384(s0)
    80005e08:	dee6d7e3          	bge	a3,a4,80005bf6 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005e0c:	2781                	sext.w	a5,a5
    80005e0e:	e0f43023          	sd	a5,-512(s0)
    80005e12:	03800713          	li	a4,56
    80005e16:	86be                	mv	a3,a5
    80005e18:	e1040613          	addi	a2,s0,-496
    80005e1c:	4581                	li	a1,0
    80005e1e:	8556                	mv	a0,s5
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	53a080e7          	jalr	1338(ra) # 8000435a <readi>
    80005e28:	03800793          	li	a5,56
    80005e2c:	f6f51ee3          	bne	a0,a5,80005da8 <exec+0x306>
    if(ph.type != ELF_PROG_LOAD)
    80005e30:	e1042783          	lw	a5,-496(s0)
    80005e34:	4705                	li	a4,1
    80005e36:	fae79de3          	bne	a5,a4,80005df0 <exec+0x34e>
    if(ph.memsz < ph.filesz)
    80005e3a:	e3843603          	ld	a2,-456(s0)
    80005e3e:	e3043783          	ld	a5,-464(s0)
    80005e42:	f8f660e3          	bltu	a2,a5,80005dc2 <exec+0x320>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005e46:	e2043783          	ld	a5,-480(s0)
    80005e4a:	963e                	add	a2,a2,a5
    80005e4c:	f6f66ee3          	bltu	a2,a5,80005dc8 <exec+0x326>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005e50:	85a6                	mv	a1,s1
    80005e52:	855a                	mv	a0,s6
    80005e54:	ffffb097          	auipc	ra,0xffffb
    80005e58:	70e080e7          	jalr	1806(ra) # 80001562 <uvmalloc>
    80005e5c:	dea43c23          	sd	a0,-520(s0)
    80005e60:	d53d                	beqz	a0,80005dce <exec+0x32c>
    if(ph.vaddr % PGSIZE != 0)
    80005e62:	e2043c03          	ld	s8,-480(s0)
    80005e66:	de043783          	ld	a5,-544(s0)
    80005e6a:	00fc77b3          	and	a5,s8,a5
    80005e6e:	ff9d                	bnez	a5,80005dac <exec+0x30a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005e70:	e1842c83          	lw	s9,-488(s0)
    80005e74:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005e78:	f60b8ae3          	beqz	s7,80005dec <exec+0x34a>
    80005e7c:	89de                	mv	s3,s7
    80005e7e:	4481                	li	s1,0
    80005e80:	bb91                	j	80005bd4 <exec+0x132>

0000000080005e82 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005e82:	7179                	addi	sp,sp,-48
    80005e84:	f406                	sd	ra,40(sp)
    80005e86:	f022                	sd	s0,32(sp)
    80005e88:	ec26                	sd	s1,24(sp)
    80005e8a:	e84a                	sd	s2,16(sp)
    80005e8c:	1800                	addi	s0,sp,48
    80005e8e:	892e                	mv	s2,a1
    80005e90:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005e92:	fdc40593          	addi	a1,s0,-36
    80005e96:	ffffd097          	auipc	ra,0xffffd
    80005e9a:	686080e7          	jalr	1670(ra) # 8000351c <argint>
    80005e9e:	04054063          	bltz	a0,80005ede <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005ea2:	fdc42703          	lw	a4,-36(s0)
    80005ea6:	47bd                	li	a5,15
    80005ea8:	02e7ed63          	bltu	a5,a4,80005ee2 <argfd+0x60>
    80005eac:	ffffc097          	auipc	ra,0xffffc
    80005eb0:	cda080e7          	jalr	-806(ra) # 80001b86 <myproc>
    80005eb4:	fdc42703          	lw	a4,-36(s0)
    80005eb8:	01a70793          	addi	a5,a4,26
    80005ebc:	078e                	slli	a5,a5,0x3
    80005ebe:	953e                	add	a0,a0,a5
    80005ec0:	611c                	ld	a5,0(a0)
    80005ec2:	c395                	beqz	a5,80005ee6 <argfd+0x64>
    return -1;
  if(pfd)
    80005ec4:	00090463          	beqz	s2,80005ecc <argfd+0x4a>
    *pfd = fd;
    80005ec8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005ecc:	4501                	li	a0,0
  if(pf)
    80005ece:	c091                	beqz	s1,80005ed2 <argfd+0x50>
    *pf = f;
    80005ed0:	e09c                	sd	a5,0(s1)
}
    80005ed2:	70a2                	ld	ra,40(sp)
    80005ed4:	7402                	ld	s0,32(sp)
    80005ed6:	64e2                	ld	s1,24(sp)
    80005ed8:	6942                	ld	s2,16(sp)
    80005eda:	6145                	addi	sp,sp,48
    80005edc:	8082                	ret
    return -1;
    80005ede:	557d                	li	a0,-1
    80005ee0:	bfcd                	j	80005ed2 <argfd+0x50>
    return -1;
    80005ee2:	557d                	li	a0,-1
    80005ee4:	b7fd                	j	80005ed2 <argfd+0x50>
    80005ee6:	557d                	li	a0,-1
    80005ee8:	b7ed                	j	80005ed2 <argfd+0x50>

0000000080005eea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005eea:	1101                	addi	sp,sp,-32
    80005eec:	ec06                	sd	ra,24(sp)
    80005eee:	e822                	sd	s0,16(sp)
    80005ef0:	e426                	sd	s1,8(sp)
    80005ef2:	1000                	addi	s0,sp,32
    80005ef4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ef6:	ffffc097          	auipc	ra,0xffffc
    80005efa:	c90080e7          	jalr	-880(ra) # 80001b86 <myproc>
    80005efe:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005f00:	0d050793          	addi	a5,a0,208
    80005f04:	4501                	li	a0,0
    80005f06:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005f08:	6398                	ld	a4,0(a5)
    80005f0a:	cb19                	beqz	a4,80005f20 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005f0c:	2505                	addiw	a0,a0,1
    80005f0e:	07a1                	addi	a5,a5,8
    80005f10:	fed51ce3          	bne	a0,a3,80005f08 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005f14:	557d                	li	a0,-1
}
    80005f16:	60e2                	ld	ra,24(sp)
    80005f18:	6442                	ld	s0,16(sp)
    80005f1a:	64a2                	ld	s1,8(sp)
    80005f1c:	6105                	addi	sp,sp,32
    80005f1e:	8082                	ret
      p->ofile[fd] = f;
    80005f20:	01a50793          	addi	a5,a0,26
    80005f24:	078e                	slli	a5,a5,0x3
    80005f26:	963e                	add	a2,a2,a5
    80005f28:	e204                	sd	s1,0(a2)
      return fd;
    80005f2a:	b7f5                	j	80005f16 <fdalloc+0x2c>

0000000080005f2c <sys_dup>:

uint64
sys_dup(void)
{
    80005f2c:	7179                	addi	sp,sp,-48
    80005f2e:	f406                	sd	ra,40(sp)
    80005f30:	f022                	sd	s0,32(sp)
    80005f32:	ec26                	sd	s1,24(sp)
    80005f34:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005f36:	fd840613          	addi	a2,s0,-40
    80005f3a:	4581                	li	a1,0
    80005f3c:	4501                	li	a0,0
    80005f3e:	00000097          	auipc	ra,0x0
    80005f42:	f44080e7          	jalr	-188(ra) # 80005e82 <argfd>
    return -1;
    80005f46:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005f48:	02054363          	bltz	a0,80005f6e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005f4c:	fd843503          	ld	a0,-40(s0)
    80005f50:	00000097          	auipc	ra,0x0
    80005f54:	f9a080e7          	jalr	-102(ra) # 80005eea <fdalloc>
    80005f58:	84aa                	mv	s1,a0
    return -1;
    80005f5a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005f5c:	00054963          	bltz	a0,80005f6e <sys_dup+0x42>
  filedup(f);
    80005f60:	fd843503          	ld	a0,-40(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	2a4080e7          	jalr	676(ra) # 80005208 <filedup>
  return fd;
    80005f6c:	87a6                	mv	a5,s1
}
    80005f6e:	853e                	mv	a0,a5
    80005f70:	70a2                	ld	ra,40(sp)
    80005f72:	7402                	ld	s0,32(sp)
    80005f74:	64e2                	ld	s1,24(sp)
    80005f76:	6145                	addi	sp,sp,48
    80005f78:	8082                	ret

0000000080005f7a <sys_read>:

uint64
sys_read(void)
{
    80005f7a:	7179                	addi	sp,sp,-48
    80005f7c:	f406                	sd	ra,40(sp)
    80005f7e:	f022                	sd	s0,32(sp)
    80005f80:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f82:	fe840613          	addi	a2,s0,-24
    80005f86:	4581                	li	a1,0
    80005f88:	4501                	li	a0,0
    80005f8a:	00000097          	auipc	ra,0x0
    80005f8e:	ef8080e7          	jalr	-264(ra) # 80005e82 <argfd>
    return -1;
    80005f92:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f94:	04054163          	bltz	a0,80005fd6 <sys_read+0x5c>
    80005f98:	fe440593          	addi	a1,s0,-28
    80005f9c:	4509                	li	a0,2
    80005f9e:	ffffd097          	auipc	ra,0xffffd
    80005fa2:	57e080e7          	jalr	1406(ra) # 8000351c <argint>
    return -1;
    80005fa6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fa8:	02054763          	bltz	a0,80005fd6 <sys_read+0x5c>
    80005fac:	fd840593          	addi	a1,s0,-40
    80005fb0:	4505                	li	a0,1
    80005fb2:	ffffd097          	auipc	ra,0xffffd
    80005fb6:	58c080e7          	jalr	1420(ra) # 8000353e <argaddr>
    return -1;
    80005fba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fbc:	00054d63          	bltz	a0,80005fd6 <sys_read+0x5c>
  return fileread(f, p, n);
    80005fc0:	fe442603          	lw	a2,-28(s0)
    80005fc4:	fd843583          	ld	a1,-40(s0)
    80005fc8:	fe843503          	ld	a0,-24(s0)
    80005fcc:	fffff097          	auipc	ra,0xfffff
    80005fd0:	3c8080e7          	jalr	968(ra) # 80005394 <fileread>
    80005fd4:	87aa                	mv	a5,a0
}
    80005fd6:	853e                	mv	a0,a5
    80005fd8:	70a2                	ld	ra,40(sp)
    80005fda:	7402                	ld	s0,32(sp)
    80005fdc:	6145                	addi	sp,sp,48
    80005fde:	8082                	ret

0000000080005fe0 <sys_write>:

uint64
sys_write(void)
{
    80005fe0:	7179                	addi	sp,sp,-48
    80005fe2:	f406                	sd	ra,40(sp)
    80005fe4:	f022                	sd	s0,32(sp)
    80005fe6:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005fe8:	fe840613          	addi	a2,s0,-24
    80005fec:	4581                	li	a1,0
    80005fee:	4501                	li	a0,0
    80005ff0:	00000097          	auipc	ra,0x0
    80005ff4:	e92080e7          	jalr	-366(ra) # 80005e82 <argfd>
    return -1;
    80005ff8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ffa:	04054163          	bltz	a0,8000603c <sys_write+0x5c>
    80005ffe:	fe440593          	addi	a1,s0,-28
    80006002:	4509                	li	a0,2
    80006004:	ffffd097          	auipc	ra,0xffffd
    80006008:	518080e7          	jalr	1304(ra) # 8000351c <argint>
    return -1;
    8000600c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000600e:	02054763          	bltz	a0,8000603c <sys_write+0x5c>
    80006012:	fd840593          	addi	a1,s0,-40
    80006016:	4505                	li	a0,1
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	526080e7          	jalr	1318(ra) # 8000353e <argaddr>
    return -1;
    80006020:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006022:	00054d63          	bltz	a0,8000603c <sys_write+0x5c>

  return filewrite(f, p, n);
    80006026:	fe442603          	lw	a2,-28(s0)
    8000602a:	fd843583          	ld	a1,-40(s0)
    8000602e:	fe843503          	ld	a0,-24(s0)
    80006032:	fffff097          	auipc	ra,0xfffff
    80006036:	424080e7          	jalr	1060(ra) # 80005456 <filewrite>
    8000603a:	87aa                	mv	a5,a0
}
    8000603c:	853e                	mv	a0,a5
    8000603e:	70a2                	ld	ra,40(sp)
    80006040:	7402                	ld	s0,32(sp)
    80006042:	6145                	addi	sp,sp,48
    80006044:	8082                	ret

0000000080006046 <sys_close>:

uint64
sys_close(void)
{
    80006046:	1101                	addi	sp,sp,-32
    80006048:	ec06                	sd	ra,24(sp)
    8000604a:	e822                	sd	s0,16(sp)
    8000604c:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    8000604e:	fe040613          	addi	a2,s0,-32
    80006052:	fec40593          	addi	a1,s0,-20
    80006056:	4501                	li	a0,0
    80006058:	00000097          	auipc	ra,0x0
    8000605c:	e2a080e7          	jalr	-470(ra) # 80005e82 <argfd>
    return -1;
    80006060:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006062:	02054463          	bltz	a0,8000608a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006066:	ffffc097          	auipc	ra,0xffffc
    8000606a:	b20080e7          	jalr	-1248(ra) # 80001b86 <myproc>
    8000606e:	fec42783          	lw	a5,-20(s0)
    80006072:	07e9                	addi	a5,a5,26
    80006074:	078e                	slli	a5,a5,0x3
    80006076:	97aa                	add	a5,a5,a0
    80006078:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000607c:	fe043503          	ld	a0,-32(s0)
    80006080:	fffff097          	auipc	ra,0xfffff
    80006084:	1da080e7          	jalr	474(ra) # 8000525a <fileclose>
  return 0;
    80006088:	4781                	li	a5,0
}
    8000608a:	853e                	mv	a0,a5
    8000608c:	60e2                	ld	ra,24(sp)
    8000608e:	6442                	ld	s0,16(sp)
    80006090:	6105                	addi	sp,sp,32
    80006092:	8082                	ret

0000000080006094 <sys_fstat>:

uint64
sys_fstat(void)
{
    80006094:	1101                	addi	sp,sp,-32
    80006096:	ec06                	sd	ra,24(sp)
    80006098:	e822                	sd	s0,16(sp)
    8000609a:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000609c:	fe840613          	addi	a2,s0,-24
    800060a0:	4581                	li	a1,0
    800060a2:	4501                	li	a0,0
    800060a4:	00000097          	auipc	ra,0x0
    800060a8:	dde080e7          	jalr	-546(ra) # 80005e82 <argfd>
    return -1;
    800060ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800060ae:	02054563          	bltz	a0,800060d8 <sys_fstat+0x44>
    800060b2:	fe040593          	addi	a1,s0,-32
    800060b6:	4505                	li	a0,1
    800060b8:	ffffd097          	auipc	ra,0xffffd
    800060bc:	486080e7          	jalr	1158(ra) # 8000353e <argaddr>
    return -1;
    800060c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800060c2:	00054b63          	bltz	a0,800060d8 <sys_fstat+0x44>
  return filestat(f, st);
    800060c6:	fe043583          	ld	a1,-32(s0)
    800060ca:	fe843503          	ld	a0,-24(s0)
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	254080e7          	jalr	596(ra) # 80005322 <filestat>
    800060d6:	87aa                	mv	a5,a0
}
    800060d8:	853e                	mv	a0,a5
    800060da:	60e2                	ld	ra,24(sp)
    800060dc:	6442                	ld	s0,16(sp)
    800060de:	6105                	addi	sp,sp,32
    800060e0:	8082                	ret

00000000800060e2 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    800060e2:	7169                	addi	sp,sp,-304
    800060e4:	f606                	sd	ra,296(sp)
    800060e6:	f222                	sd	s0,288(sp)
    800060e8:	ee26                	sd	s1,280(sp)
    800060ea:	ea4a                	sd	s2,272(sp)
    800060ec:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800060ee:	08000613          	li	a2,128
    800060f2:	ed040593          	addi	a1,s0,-304
    800060f6:	4501                	li	a0,0
    800060f8:	ffffd097          	auipc	ra,0xffffd
    800060fc:	468080e7          	jalr	1128(ra) # 80003560 <argstr>
    return -1;
    80006100:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006102:	10054e63          	bltz	a0,8000621e <sys_link+0x13c>
    80006106:	08000613          	li	a2,128
    8000610a:	f5040593          	addi	a1,s0,-176
    8000610e:	4505                	li	a0,1
    80006110:	ffffd097          	auipc	ra,0xffffd
    80006114:	450080e7          	jalr	1104(ra) # 80003560 <argstr>
    return -1;
    80006118:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000611a:	10054263          	bltz	a0,8000621e <sys_link+0x13c>

  begin_op();
    8000611e:	fffff097          	auipc	ra,0xfffff
    80006122:	c70080e7          	jalr	-912(ra) # 80004d8e <begin_op>
  if((ip = namei(old)) == 0){
    80006126:	ed040513          	addi	a0,s0,-304
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	732080e7          	jalr	1842(ra) # 8000485c <namei>
    80006132:	84aa                	mv	s1,a0
    80006134:	c551                	beqz	a0,800061c0 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80006136:	ffffe097          	auipc	ra,0xffffe
    8000613a:	f70080e7          	jalr	-144(ra) # 800040a6 <ilock>
  if(ip->type == T_DIR){
    8000613e:	04449703          	lh	a4,68(s1)
    80006142:	4785                	li	a5,1
    80006144:	08f70463          	beq	a4,a5,800061cc <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006148:	04a4d783          	lhu	a5,74(s1)
    8000614c:	2785                	addiw	a5,a5,1
    8000614e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006152:	8526                	mv	a0,s1
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	e88080e7          	jalr	-376(ra) # 80003fdc <iupdate>
  iunlock(ip);
    8000615c:	8526                	mv	a0,s1
    8000615e:	ffffe097          	auipc	ra,0xffffe
    80006162:	00a080e7          	jalr	10(ra) # 80004168 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80006166:	fd040593          	addi	a1,s0,-48
    8000616a:	f5040513          	addi	a0,s0,-176
    8000616e:	ffffe097          	auipc	ra,0xffffe
    80006172:	70c080e7          	jalr	1804(ra) # 8000487a <nameiparent>
    80006176:	892a                	mv	s2,a0
    80006178:	c935                	beqz	a0,800061ec <sys_link+0x10a>
    goto bad;
  ilock(dp);
    8000617a:	ffffe097          	auipc	ra,0xffffe
    8000617e:	f2c080e7          	jalr	-212(ra) # 800040a6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006182:	00092703          	lw	a4,0(s2)
    80006186:	409c                	lw	a5,0(s1)
    80006188:	04f71d63          	bne	a4,a5,800061e2 <sys_link+0x100>
    8000618c:	40d0                	lw	a2,4(s1)
    8000618e:	fd040593          	addi	a1,s0,-48
    80006192:	854a                	mv	a0,s2
    80006194:	ffffe097          	auipc	ra,0xffffe
    80006198:	606080e7          	jalr	1542(ra) # 8000479a <dirlink>
    8000619c:	04054363          	bltz	a0,800061e2 <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800061a0:	854a                	mv	a0,s2
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	166080e7          	jalr	358(ra) # 80004308 <iunlockput>
  iput(ip);
    800061aa:	8526                	mv	a0,s1
    800061ac:	ffffe097          	auipc	ra,0xffffe
    800061b0:	0b4080e7          	jalr	180(ra) # 80004260 <iput>

  end_op();
    800061b4:	fffff097          	auipc	ra,0xfffff
    800061b8:	c5a080e7          	jalr	-934(ra) # 80004e0e <end_op>

  return 0;
    800061bc:	4781                	li	a5,0
    800061be:	a085                	j	8000621e <sys_link+0x13c>
    end_op();
    800061c0:	fffff097          	auipc	ra,0xfffff
    800061c4:	c4e080e7          	jalr	-946(ra) # 80004e0e <end_op>
    return -1;
    800061c8:	57fd                	li	a5,-1
    800061ca:	a891                	j	8000621e <sys_link+0x13c>
    iunlockput(ip);
    800061cc:	8526                	mv	a0,s1
    800061ce:	ffffe097          	auipc	ra,0xffffe
    800061d2:	13a080e7          	jalr	314(ra) # 80004308 <iunlockput>
    end_op();
    800061d6:	fffff097          	auipc	ra,0xfffff
    800061da:	c38080e7          	jalr	-968(ra) # 80004e0e <end_op>
    return -1;
    800061de:	57fd                	li	a5,-1
    800061e0:	a83d                	j	8000621e <sys_link+0x13c>
    iunlockput(dp);
    800061e2:	854a                	mv	a0,s2
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	124080e7          	jalr	292(ra) # 80004308 <iunlockput>

bad:
  ilock(ip);
    800061ec:	8526                	mv	a0,s1
    800061ee:	ffffe097          	auipc	ra,0xffffe
    800061f2:	eb8080e7          	jalr	-328(ra) # 800040a6 <ilock>
  ip->nlink--;
    800061f6:	04a4d783          	lhu	a5,74(s1)
    800061fa:	37fd                	addiw	a5,a5,-1
    800061fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006200:	8526                	mv	a0,s1
    80006202:	ffffe097          	auipc	ra,0xffffe
    80006206:	dda080e7          	jalr	-550(ra) # 80003fdc <iupdate>
  iunlockput(ip);
    8000620a:	8526                	mv	a0,s1
    8000620c:	ffffe097          	auipc	ra,0xffffe
    80006210:	0fc080e7          	jalr	252(ra) # 80004308 <iunlockput>
  end_op();
    80006214:	fffff097          	auipc	ra,0xfffff
    80006218:	bfa080e7          	jalr	-1030(ra) # 80004e0e <end_op>
  return -1;
    8000621c:	57fd                	li	a5,-1
}
    8000621e:	853e                	mv	a0,a5
    80006220:	70b2                	ld	ra,296(sp)
    80006222:	7412                	ld	s0,288(sp)
    80006224:	64f2                	ld	s1,280(sp)
    80006226:	6952                	ld	s2,272(sp)
    80006228:	6155                	addi	sp,sp,304
    8000622a:	8082                	ret

000000008000622c <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000622c:	4578                	lw	a4,76(a0)
    8000622e:	02000793          	li	a5,32
    80006232:	04e7fa63          	bgeu	a5,a4,80006286 <isdirempty+0x5a>
{
    80006236:	7179                	addi	sp,sp,-48
    80006238:	f406                	sd	ra,40(sp)
    8000623a:	f022                	sd	s0,32(sp)
    8000623c:	ec26                	sd	s1,24(sp)
    8000623e:	e84a                	sd	s2,16(sp)
    80006240:	1800                	addi	s0,sp,48
    80006242:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006244:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006248:	4741                	li	a4,16
    8000624a:	86a6                	mv	a3,s1
    8000624c:	fd040613          	addi	a2,s0,-48
    80006250:	4581                	li	a1,0
    80006252:	854a                	mv	a0,s2
    80006254:	ffffe097          	auipc	ra,0xffffe
    80006258:	106080e7          	jalr	262(ra) # 8000435a <readi>
    8000625c:	47c1                	li	a5,16
    8000625e:	00f51c63          	bne	a0,a5,80006276 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80006262:	fd045783          	lhu	a5,-48(s0)
    80006266:	e395                	bnez	a5,8000628a <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006268:	24c1                	addiw	s1,s1,16
    8000626a:	04c92783          	lw	a5,76(s2)
    8000626e:	fcf4ede3          	bltu	s1,a5,80006248 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80006272:	4505                	li	a0,1
    80006274:	a821                	j	8000628c <isdirempty+0x60>
      panic("isdirempty: readi");
    80006276:	00003517          	auipc	a0,0x3
    8000627a:	7b250513          	addi	a0,a0,1970 # 80009a28 <syscalls+0x318>
    8000627e:	ffffa097          	auipc	ra,0xffffa
    80006282:	2ac080e7          	jalr	684(ra) # 8000052a <panic>
  return 1;
    80006286:	4505                	li	a0,1
}
    80006288:	8082                	ret
      return 0;
    8000628a:	4501                	li	a0,0
}
    8000628c:	70a2                	ld	ra,40(sp)
    8000628e:	7402                	ld	s0,32(sp)
    80006290:	64e2                	ld	s1,24(sp)
    80006292:	6942                	ld	s2,16(sp)
    80006294:	6145                	addi	sp,sp,48
    80006296:	8082                	ret

0000000080006298 <sys_unlink>:

uint64
sys_unlink(void)
{
    80006298:	7155                	addi	sp,sp,-208
    8000629a:	e586                	sd	ra,200(sp)
    8000629c:	e1a2                	sd	s0,192(sp)
    8000629e:	fd26                	sd	s1,184(sp)
    800062a0:	f94a                	sd	s2,176(sp)
    800062a2:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800062a4:	08000613          	li	a2,128
    800062a8:	f4040593          	addi	a1,s0,-192
    800062ac:	4501                	li	a0,0
    800062ae:	ffffd097          	auipc	ra,0xffffd
    800062b2:	2b2080e7          	jalr	690(ra) # 80003560 <argstr>
    800062b6:	16054363          	bltz	a0,8000641c <sys_unlink+0x184>
    return -1;

  begin_op();
    800062ba:	fffff097          	auipc	ra,0xfffff
    800062be:	ad4080e7          	jalr	-1324(ra) # 80004d8e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800062c2:	fc040593          	addi	a1,s0,-64
    800062c6:	f4040513          	addi	a0,s0,-192
    800062ca:	ffffe097          	auipc	ra,0xffffe
    800062ce:	5b0080e7          	jalr	1456(ra) # 8000487a <nameiparent>
    800062d2:	84aa                	mv	s1,a0
    800062d4:	c961                	beqz	a0,800063a4 <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    800062d6:	ffffe097          	auipc	ra,0xffffe
    800062da:	dd0080e7          	jalr	-560(ra) # 800040a6 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800062de:	00003597          	auipc	a1,0x3
    800062e2:	62a58593          	addi	a1,a1,1578 # 80009908 <syscalls+0x1f8>
    800062e6:	fc040513          	addi	a0,s0,-64
    800062ea:	ffffe097          	auipc	ra,0xffffe
    800062ee:	286080e7          	jalr	646(ra) # 80004570 <namecmp>
    800062f2:	c175                	beqz	a0,800063d6 <sys_unlink+0x13e>
    800062f4:	00003597          	auipc	a1,0x3
    800062f8:	61c58593          	addi	a1,a1,1564 # 80009910 <syscalls+0x200>
    800062fc:	fc040513          	addi	a0,s0,-64
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	270080e7          	jalr	624(ra) # 80004570 <namecmp>
    80006308:	c579                	beqz	a0,800063d6 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000630a:	f3c40613          	addi	a2,s0,-196
    8000630e:	fc040593          	addi	a1,s0,-64
    80006312:	8526                	mv	a0,s1
    80006314:	ffffe097          	auipc	ra,0xffffe
    80006318:	276080e7          	jalr	630(ra) # 8000458a <dirlookup>
    8000631c:	892a                	mv	s2,a0
    8000631e:	cd45                	beqz	a0,800063d6 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80006320:	ffffe097          	auipc	ra,0xffffe
    80006324:	d86080e7          	jalr	-634(ra) # 800040a6 <ilock>

  if(ip->nlink < 1)
    80006328:	04a91783          	lh	a5,74(s2)
    8000632c:	08f05263          	blez	a5,800063b0 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006330:	04491703          	lh	a4,68(s2)
    80006334:	4785                	li	a5,1
    80006336:	08f70563          	beq	a4,a5,800063c0 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    8000633a:	4641                	li	a2,16
    8000633c:	4581                	li	a1,0
    8000633e:	fd040513          	addi	a0,s0,-48
    80006342:	ffffb097          	auipc	ra,0xffffb
    80006346:	97c080e7          	jalr	-1668(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000634a:	4741                	li	a4,16
    8000634c:	f3c42683          	lw	a3,-196(s0)
    80006350:	fd040613          	addi	a2,s0,-48
    80006354:	4581                	li	a1,0
    80006356:	8526                	mv	a0,s1
    80006358:	ffffe097          	auipc	ra,0xffffe
    8000635c:	0fa080e7          	jalr	250(ra) # 80004452 <writei>
    80006360:	47c1                	li	a5,16
    80006362:	08f51a63          	bne	a0,a5,800063f6 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80006366:	04491703          	lh	a4,68(s2)
    8000636a:	4785                	li	a5,1
    8000636c:	08f70d63          	beq	a4,a5,80006406 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80006370:	8526                	mv	a0,s1
    80006372:	ffffe097          	auipc	ra,0xffffe
    80006376:	f96080e7          	jalr	-106(ra) # 80004308 <iunlockput>

  ip->nlink--;
    8000637a:	04a95783          	lhu	a5,74(s2)
    8000637e:	37fd                	addiw	a5,a5,-1
    80006380:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006384:	854a                	mv	a0,s2
    80006386:	ffffe097          	auipc	ra,0xffffe
    8000638a:	c56080e7          	jalr	-938(ra) # 80003fdc <iupdate>
  iunlockput(ip);
    8000638e:	854a                	mv	a0,s2
    80006390:	ffffe097          	auipc	ra,0xffffe
    80006394:	f78080e7          	jalr	-136(ra) # 80004308 <iunlockput>

  end_op();
    80006398:	fffff097          	auipc	ra,0xfffff
    8000639c:	a76080e7          	jalr	-1418(ra) # 80004e0e <end_op>

  return 0;
    800063a0:	4501                	li	a0,0
    800063a2:	a0a1                	j	800063ea <sys_unlink+0x152>
    end_op();
    800063a4:	fffff097          	auipc	ra,0xfffff
    800063a8:	a6a080e7          	jalr	-1430(ra) # 80004e0e <end_op>
    return -1;
    800063ac:	557d                	li	a0,-1
    800063ae:	a835                	j	800063ea <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800063b0:	00003517          	auipc	a0,0x3
    800063b4:	56850513          	addi	a0,a0,1384 # 80009918 <syscalls+0x208>
    800063b8:	ffffa097          	auipc	ra,0xffffa
    800063bc:	172080e7          	jalr	370(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800063c0:	854a                	mv	a0,s2
    800063c2:	00000097          	auipc	ra,0x0
    800063c6:	e6a080e7          	jalr	-406(ra) # 8000622c <isdirempty>
    800063ca:	f925                	bnez	a0,8000633a <sys_unlink+0xa2>
    iunlockput(ip);
    800063cc:	854a                	mv	a0,s2
    800063ce:	ffffe097          	auipc	ra,0xffffe
    800063d2:	f3a080e7          	jalr	-198(ra) # 80004308 <iunlockput>

bad:
  iunlockput(dp);
    800063d6:	8526                	mv	a0,s1
    800063d8:	ffffe097          	auipc	ra,0xffffe
    800063dc:	f30080e7          	jalr	-208(ra) # 80004308 <iunlockput>
  end_op();
    800063e0:	fffff097          	auipc	ra,0xfffff
    800063e4:	a2e080e7          	jalr	-1490(ra) # 80004e0e <end_op>
  return -1;
    800063e8:	557d                	li	a0,-1
}
    800063ea:	60ae                	ld	ra,200(sp)
    800063ec:	640e                	ld	s0,192(sp)
    800063ee:	74ea                	ld	s1,184(sp)
    800063f0:	794a                	ld	s2,176(sp)
    800063f2:	6169                	addi	sp,sp,208
    800063f4:	8082                	ret
    panic("unlink: writei");
    800063f6:	00003517          	auipc	a0,0x3
    800063fa:	53a50513          	addi	a0,a0,1338 # 80009930 <syscalls+0x220>
    800063fe:	ffffa097          	auipc	ra,0xffffa
    80006402:	12c080e7          	jalr	300(ra) # 8000052a <panic>
    dp->nlink--;
    80006406:	04a4d783          	lhu	a5,74(s1)
    8000640a:	37fd                	addiw	a5,a5,-1
    8000640c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006410:	8526                	mv	a0,s1
    80006412:	ffffe097          	auipc	ra,0xffffe
    80006416:	bca080e7          	jalr	-1078(ra) # 80003fdc <iupdate>
    8000641a:	bf99                	j	80006370 <sys_unlink+0xd8>
    return -1;
    8000641c:	557d                	li	a0,-1
    8000641e:	b7f1                	j	800063ea <sys_unlink+0x152>

0000000080006420 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80006420:	715d                	addi	sp,sp,-80
    80006422:	e486                	sd	ra,72(sp)
    80006424:	e0a2                	sd	s0,64(sp)
    80006426:	fc26                	sd	s1,56(sp)
    80006428:	f84a                	sd	s2,48(sp)
    8000642a:	f44e                	sd	s3,40(sp)
    8000642c:	f052                	sd	s4,32(sp)
    8000642e:	ec56                	sd	s5,24(sp)
    80006430:	0880                	addi	s0,sp,80
    80006432:	89ae                	mv	s3,a1
    80006434:	8ab2                	mv	s5,a2
    80006436:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006438:	fb040593          	addi	a1,s0,-80
    8000643c:	ffffe097          	auipc	ra,0xffffe
    80006440:	43e080e7          	jalr	1086(ra) # 8000487a <nameiparent>
    80006444:	892a                	mv	s2,a0
    80006446:	12050e63          	beqz	a0,80006582 <create+0x162>
    return 0;

  ilock(dp);
    8000644a:	ffffe097          	auipc	ra,0xffffe
    8000644e:	c5c080e7          	jalr	-932(ra) # 800040a6 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    80006452:	4601                	li	a2,0
    80006454:	fb040593          	addi	a1,s0,-80
    80006458:	854a                	mv	a0,s2
    8000645a:	ffffe097          	auipc	ra,0xffffe
    8000645e:	130080e7          	jalr	304(ra) # 8000458a <dirlookup>
    80006462:	84aa                	mv	s1,a0
    80006464:	c921                	beqz	a0,800064b4 <create+0x94>
    iunlockput(dp);
    80006466:	854a                	mv	a0,s2
    80006468:	ffffe097          	auipc	ra,0xffffe
    8000646c:	ea0080e7          	jalr	-352(ra) # 80004308 <iunlockput>
    ilock(ip);
    80006470:	8526                	mv	a0,s1
    80006472:	ffffe097          	auipc	ra,0xffffe
    80006476:	c34080e7          	jalr	-972(ra) # 800040a6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000647a:	2981                	sext.w	s3,s3
    8000647c:	4789                	li	a5,2
    8000647e:	02f99463          	bne	s3,a5,800064a6 <create+0x86>
    80006482:	0444d783          	lhu	a5,68(s1)
    80006486:	37f9                	addiw	a5,a5,-2
    80006488:	17c2                	slli	a5,a5,0x30
    8000648a:	93c1                	srli	a5,a5,0x30
    8000648c:	4705                	li	a4,1
    8000648e:	00f76c63          	bltu	a4,a5,800064a6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80006492:	8526                	mv	a0,s1
    80006494:	60a6                	ld	ra,72(sp)
    80006496:	6406                	ld	s0,64(sp)
    80006498:	74e2                	ld	s1,56(sp)
    8000649a:	7942                	ld	s2,48(sp)
    8000649c:	79a2                	ld	s3,40(sp)
    8000649e:	7a02                	ld	s4,32(sp)
    800064a0:	6ae2                	ld	s5,24(sp)
    800064a2:	6161                	addi	sp,sp,80
    800064a4:	8082                	ret
    iunlockput(ip);
    800064a6:	8526                	mv	a0,s1
    800064a8:	ffffe097          	auipc	ra,0xffffe
    800064ac:	e60080e7          	jalr	-416(ra) # 80004308 <iunlockput>
    return 0;
    800064b0:	4481                	li	s1,0
    800064b2:	b7c5                	j	80006492 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800064b4:	85ce                	mv	a1,s3
    800064b6:	00092503          	lw	a0,0(s2)
    800064ba:	ffffe097          	auipc	ra,0xffffe
    800064be:	a54080e7          	jalr	-1452(ra) # 80003f0e <ialloc>
    800064c2:	84aa                	mv	s1,a0
    800064c4:	c521                	beqz	a0,8000650c <create+0xec>
  ilock(ip);
    800064c6:	ffffe097          	auipc	ra,0xffffe
    800064ca:	be0080e7          	jalr	-1056(ra) # 800040a6 <ilock>
  ip->major = major;
    800064ce:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800064d2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800064d6:	4a05                	li	s4,1
    800064d8:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800064dc:	8526                	mv	a0,s1
    800064de:	ffffe097          	auipc	ra,0xffffe
    800064e2:	afe080e7          	jalr	-1282(ra) # 80003fdc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800064e6:	2981                	sext.w	s3,s3
    800064e8:	03498a63          	beq	s3,s4,8000651c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800064ec:	40d0                	lw	a2,4(s1)
    800064ee:	fb040593          	addi	a1,s0,-80
    800064f2:	854a                	mv	a0,s2
    800064f4:	ffffe097          	auipc	ra,0xffffe
    800064f8:	2a6080e7          	jalr	678(ra) # 8000479a <dirlink>
    800064fc:	06054b63          	bltz	a0,80006572 <create+0x152>
  iunlockput(dp);
    80006500:	854a                	mv	a0,s2
    80006502:	ffffe097          	auipc	ra,0xffffe
    80006506:	e06080e7          	jalr	-506(ra) # 80004308 <iunlockput>
  return ip;
    8000650a:	b761                	j	80006492 <create+0x72>
    panic("create: ialloc");
    8000650c:	00003517          	auipc	a0,0x3
    80006510:	53450513          	addi	a0,a0,1332 # 80009a40 <syscalls+0x330>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	016080e7          	jalr	22(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    8000651c:	04a95783          	lhu	a5,74(s2)
    80006520:	2785                	addiw	a5,a5,1
    80006522:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006526:	854a                	mv	a0,s2
    80006528:	ffffe097          	auipc	ra,0xffffe
    8000652c:	ab4080e7          	jalr	-1356(ra) # 80003fdc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006530:	40d0                	lw	a2,4(s1)
    80006532:	00003597          	auipc	a1,0x3
    80006536:	3d658593          	addi	a1,a1,982 # 80009908 <syscalls+0x1f8>
    8000653a:	8526                	mv	a0,s1
    8000653c:	ffffe097          	auipc	ra,0xffffe
    80006540:	25e080e7          	jalr	606(ra) # 8000479a <dirlink>
    80006544:	00054f63          	bltz	a0,80006562 <create+0x142>
    80006548:	00492603          	lw	a2,4(s2)
    8000654c:	00003597          	auipc	a1,0x3
    80006550:	3c458593          	addi	a1,a1,964 # 80009910 <syscalls+0x200>
    80006554:	8526                	mv	a0,s1
    80006556:	ffffe097          	auipc	ra,0xffffe
    8000655a:	244080e7          	jalr	580(ra) # 8000479a <dirlink>
    8000655e:	f80557e3          	bgez	a0,800064ec <create+0xcc>
      panic("create dots");
    80006562:	00003517          	auipc	a0,0x3
    80006566:	4ee50513          	addi	a0,a0,1262 # 80009a50 <syscalls+0x340>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	fc0080e7          	jalr	-64(ra) # 8000052a <panic>
    panic("create: dirlink");
    80006572:	00003517          	auipc	a0,0x3
    80006576:	4ee50513          	addi	a0,a0,1262 # 80009a60 <syscalls+0x350>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	fb0080e7          	jalr	-80(ra) # 8000052a <panic>
    return 0;
    80006582:	84aa                	mv	s1,a0
    80006584:	b739                	j	80006492 <create+0x72>

0000000080006586 <sys_open>:

uint64
sys_open(void)
{
    80006586:	7131                	addi	sp,sp,-192
    80006588:	fd06                	sd	ra,184(sp)
    8000658a:	f922                	sd	s0,176(sp)
    8000658c:	f526                	sd	s1,168(sp)
    8000658e:	f14a                	sd	s2,160(sp)
    80006590:	ed4e                	sd	s3,152(sp)
    80006592:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006594:	08000613          	li	a2,128
    80006598:	f5040593          	addi	a1,s0,-176
    8000659c:	4501                	li	a0,0
    8000659e:	ffffd097          	auipc	ra,0xffffd
    800065a2:	fc2080e7          	jalr	-62(ra) # 80003560 <argstr>
    return -1;
    800065a6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800065a8:	0c054163          	bltz	a0,8000666a <sys_open+0xe4>
    800065ac:	f4c40593          	addi	a1,s0,-180
    800065b0:	4505                	li	a0,1
    800065b2:	ffffd097          	auipc	ra,0xffffd
    800065b6:	f6a080e7          	jalr	-150(ra) # 8000351c <argint>
    800065ba:	0a054863          	bltz	a0,8000666a <sys_open+0xe4>

  begin_op();
    800065be:	ffffe097          	auipc	ra,0xffffe
    800065c2:	7d0080e7          	jalr	2000(ra) # 80004d8e <begin_op>

  if(omode & O_CREATE){
    800065c6:	f4c42783          	lw	a5,-180(s0)
    800065ca:	2007f793          	andi	a5,a5,512
    800065ce:	cbdd                	beqz	a5,80006684 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800065d0:	4681                	li	a3,0
    800065d2:	4601                	li	a2,0
    800065d4:	4589                	li	a1,2
    800065d6:	f5040513          	addi	a0,s0,-176
    800065da:	00000097          	auipc	ra,0x0
    800065de:	e46080e7          	jalr	-442(ra) # 80006420 <create>
    800065e2:	892a                	mv	s2,a0
    if(ip == 0){
    800065e4:	c959                	beqz	a0,8000667a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800065e6:	04491703          	lh	a4,68(s2)
    800065ea:	478d                	li	a5,3
    800065ec:	00f71763          	bne	a4,a5,800065fa <sys_open+0x74>
    800065f0:	04695703          	lhu	a4,70(s2)
    800065f4:	47a5                	li	a5,9
    800065f6:	0ce7ec63          	bltu	a5,a4,800066ce <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800065fa:	fffff097          	auipc	ra,0xfffff
    800065fe:	ba4080e7          	jalr	-1116(ra) # 8000519e <filealloc>
    80006602:	89aa                	mv	s3,a0
    80006604:	10050263          	beqz	a0,80006708 <sys_open+0x182>
    80006608:	00000097          	auipc	ra,0x0
    8000660c:	8e2080e7          	jalr	-1822(ra) # 80005eea <fdalloc>
    80006610:	84aa                	mv	s1,a0
    80006612:	0e054663          	bltz	a0,800066fe <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006616:	04491703          	lh	a4,68(s2)
    8000661a:	478d                	li	a5,3
    8000661c:	0cf70463          	beq	a4,a5,800066e4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006620:	4789                	li	a5,2
    80006622:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006626:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000662a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000662e:	f4c42783          	lw	a5,-180(s0)
    80006632:	0017c713          	xori	a4,a5,1
    80006636:	8b05                	andi	a4,a4,1
    80006638:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000663c:	0037f713          	andi	a4,a5,3
    80006640:	00e03733          	snez	a4,a4
    80006644:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006648:	4007f793          	andi	a5,a5,1024
    8000664c:	c791                	beqz	a5,80006658 <sys_open+0xd2>
    8000664e:	04491703          	lh	a4,68(s2)
    80006652:	4789                	li	a5,2
    80006654:	08f70f63          	beq	a4,a5,800066f2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006658:	854a                	mv	a0,s2
    8000665a:	ffffe097          	auipc	ra,0xffffe
    8000665e:	b0e080e7          	jalr	-1266(ra) # 80004168 <iunlock>
  end_op();
    80006662:	ffffe097          	auipc	ra,0xffffe
    80006666:	7ac080e7          	jalr	1964(ra) # 80004e0e <end_op>

  return fd;
}
    8000666a:	8526                	mv	a0,s1
    8000666c:	70ea                	ld	ra,184(sp)
    8000666e:	744a                	ld	s0,176(sp)
    80006670:	74aa                	ld	s1,168(sp)
    80006672:	790a                	ld	s2,160(sp)
    80006674:	69ea                	ld	s3,152(sp)
    80006676:	6129                	addi	sp,sp,192
    80006678:	8082                	ret
      end_op();
    8000667a:	ffffe097          	auipc	ra,0xffffe
    8000667e:	794080e7          	jalr	1940(ra) # 80004e0e <end_op>
      return -1;
    80006682:	b7e5                	j	8000666a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006684:	f5040513          	addi	a0,s0,-176
    80006688:	ffffe097          	auipc	ra,0xffffe
    8000668c:	1d4080e7          	jalr	468(ra) # 8000485c <namei>
    80006690:	892a                	mv	s2,a0
    80006692:	c905                	beqz	a0,800066c2 <sys_open+0x13c>
    ilock(ip);
    80006694:	ffffe097          	auipc	ra,0xffffe
    80006698:	a12080e7          	jalr	-1518(ra) # 800040a6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000669c:	04491703          	lh	a4,68(s2)
    800066a0:	4785                	li	a5,1
    800066a2:	f4f712e3          	bne	a4,a5,800065e6 <sys_open+0x60>
    800066a6:	f4c42783          	lw	a5,-180(s0)
    800066aa:	dba1                	beqz	a5,800065fa <sys_open+0x74>
      iunlockput(ip);
    800066ac:	854a                	mv	a0,s2
    800066ae:	ffffe097          	auipc	ra,0xffffe
    800066b2:	c5a080e7          	jalr	-934(ra) # 80004308 <iunlockput>
      end_op();
    800066b6:	ffffe097          	auipc	ra,0xffffe
    800066ba:	758080e7          	jalr	1880(ra) # 80004e0e <end_op>
      return -1;
    800066be:	54fd                	li	s1,-1
    800066c0:	b76d                	j	8000666a <sys_open+0xe4>
      end_op();
    800066c2:	ffffe097          	auipc	ra,0xffffe
    800066c6:	74c080e7          	jalr	1868(ra) # 80004e0e <end_op>
      return -1;
    800066ca:	54fd                	li	s1,-1
    800066cc:	bf79                	j	8000666a <sys_open+0xe4>
    iunlockput(ip);
    800066ce:	854a                	mv	a0,s2
    800066d0:	ffffe097          	auipc	ra,0xffffe
    800066d4:	c38080e7          	jalr	-968(ra) # 80004308 <iunlockput>
    end_op();
    800066d8:	ffffe097          	auipc	ra,0xffffe
    800066dc:	736080e7          	jalr	1846(ra) # 80004e0e <end_op>
    return -1;
    800066e0:	54fd                	li	s1,-1
    800066e2:	b761                	j	8000666a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800066e4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800066e8:	04691783          	lh	a5,70(s2)
    800066ec:	02f99223          	sh	a5,36(s3)
    800066f0:	bf2d                	j	8000662a <sys_open+0xa4>
    itrunc(ip);
    800066f2:	854a                	mv	a0,s2
    800066f4:	ffffe097          	auipc	ra,0xffffe
    800066f8:	ac0080e7          	jalr	-1344(ra) # 800041b4 <itrunc>
    800066fc:	bfb1                	j	80006658 <sys_open+0xd2>
      fileclose(f);
    800066fe:	854e                	mv	a0,s3
    80006700:	fffff097          	auipc	ra,0xfffff
    80006704:	b5a080e7          	jalr	-1190(ra) # 8000525a <fileclose>
    iunlockput(ip);
    80006708:	854a                	mv	a0,s2
    8000670a:	ffffe097          	auipc	ra,0xffffe
    8000670e:	bfe080e7          	jalr	-1026(ra) # 80004308 <iunlockput>
    end_op();
    80006712:	ffffe097          	auipc	ra,0xffffe
    80006716:	6fc080e7          	jalr	1788(ra) # 80004e0e <end_op>
    return -1;
    8000671a:	54fd                	li	s1,-1
    8000671c:	b7b9                	j	8000666a <sys_open+0xe4>

000000008000671e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000671e:	7175                	addi	sp,sp,-144
    80006720:	e506                	sd	ra,136(sp)
    80006722:	e122                	sd	s0,128(sp)
    80006724:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006726:	ffffe097          	auipc	ra,0xffffe
    8000672a:	668080e7          	jalr	1640(ra) # 80004d8e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000672e:	08000613          	li	a2,128
    80006732:	f7040593          	addi	a1,s0,-144
    80006736:	4501                	li	a0,0
    80006738:	ffffd097          	auipc	ra,0xffffd
    8000673c:	e28080e7          	jalr	-472(ra) # 80003560 <argstr>
    80006740:	02054963          	bltz	a0,80006772 <sys_mkdir+0x54>
    80006744:	4681                	li	a3,0
    80006746:	4601                	li	a2,0
    80006748:	4585                	li	a1,1
    8000674a:	f7040513          	addi	a0,s0,-144
    8000674e:	00000097          	auipc	ra,0x0
    80006752:	cd2080e7          	jalr	-814(ra) # 80006420 <create>
    80006756:	cd11                	beqz	a0,80006772 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006758:	ffffe097          	auipc	ra,0xffffe
    8000675c:	bb0080e7          	jalr	-1104(ra) # 80004308 <iunlockput>
  end_op();
    80006760:	ffffe097          	auipc	ra,0xffffe
    80006764:	6ae080e7          	jalr	1710(ra) # 80004e0e <end_op>
  return 0;
    80006768:	4501                	li	a0,0
}
    8000676a:	60aa                	ld	ra,136(sp)
    8000676c:	640a                	ld	s0,128(sp)
    8000676e:	6149                	addi	sp,sp,144
    80006770:	8082                	ret
    end_op();
    80006772:	ffffe097          	auipc	ra,0xffffe
    80006776:	69c080e7          	jalr	1692(ra) # 80004e0e <end_op>
    return -1;
    8000677a:	557d                	li	a0,-1
    8000677c:	b7fd                	j	8000676a <sys_mkdir+0x4c>

000000008000677e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000677e:	7135                	addi	sp,sp,-160
    80006780:	ed06                	sd	ra,152(sp)
    80006782:	e922                	sd	s0,144(sp)
    80006784:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006786:	ffffe097          	auipc	ra,0xffffe
    8000678a:	608080e7          	jalr	1544(ra) # 80004d8e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000678e:	08000613          	li	a2,128
    80006792:	f7040593          	addi	a1,s0,-144
    80006796:	4501                	li	a0,0
    80006798:	ffffd097          	auipc	ra,0xffffd
    8000679c:	dc8080e7          	jalr	-568(ra) # 80003560 <argstr>
    800067a0:	04054a63          	bltz	a0,800067f4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800067a4:	f6c40593          	addi	a1,s0,-148
    800067a8:	4505                	li	a0,1
    800067aa:	ffffd097          	auipc	ra,0xffffd
    800067ae:	d72080e7          	jalr	-654(ra) # 8000351c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800067b2:	04054163          	bltz	a0,800067f4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800067b6:	f6840593          	addi	a1,s0,-152
    800067ba:	4509                	li	a0,2
    800067bc:	ffffd097          	auipc	ra,0xffffd
    800067c0:	d60080e7          	jalr	-672(ra) # 8000351c <argint>
     argint(1, &major) < 0 ||
    800067c4:	02054863          	bltz	a0,800067f4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800067c8:	f6841683          	lh	a3,-152(s0)
    800067cc:	f6c41603          	lh	a2,-148(s0)
    800067d0:	458d                	li	a1,3
    800067d2:	f7040513          	addi	a0,s0,-144
    800067d6:	00000097          	auipc	ra,0x0
    800067da:	c4a080e7          	jalr	-950(ra) # 80006420 <create>
     argint(2, &minor) < 0 ||
    800067de:	c919                	beqz	a0,800067f4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800067e0:	ffffe097          	auipc	ra,0xffffe
    800067e4:	b28080e7          	jalr	-1240(ra) # 80004308 <iunlockput>
  end_op();
    800067e8:	ffffe097          	auipc	ra,0xffffe
    800067ec:	626080e7          	jalr	1574(ra) # 80004e0e <end_op>
  return 0;
    800067f0:	4501                	li	a0,0
    800067f2:	a031                	j	800067fe <sys_mknod+0x80>
    end_op();
    800067f4:	ffffe097          	auipc	ra,0xffffe
    800067f8:	61a080e7          	jalr	1562(ra) # 80004e0e <end_op>
    return -1;
    800067fc:	557d                	li	a0,-1
}
    800067fe:	60ea                	ld	ra,152(sp)
    80006800:	644a                	ld	s0,144(sp)
    80006802:	610d                	addi	sp,sp,160
    80006804:	8082                	ret

0000000080006806 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006806:	7135                	addi	sp,sp,-160
    80006808:	ed06                	sd	ra,152(sp)
    8000680a:	e922                	sd	s0,144(sp)
    8000680c:	e526                	sd	s1,136(sp)
    8000680e:	e14a                	sd	s2,128(sp)
    80006810:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006812:	ffffb097          	auipc	ra,0xffffb
    80006816:	374080e7          	jalr	884(ra) # 80001b86 <myproc>
    8000681a:	892a                	mv	s2,a0
  
  begin_op();
    8000681c:	ffffe097          	auipc	ra,0xffffe
    80006820:	572080e7          	jalr	1394(ra) # 80004d8e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006824:	08000613          	li	a2,128
    80006828:	f6040593          	addi	a1,s0,-160
    8000682c:	4501                	li	a0,0
    8000682e:	ffffd097          	auipc	ra,0xffffd
    80006832:	d32080e7          	jalr	-718(ra) # 80003560 <argstr>
    80006836:	04054b63          	bltz	a0,8000688c <sys_chdir+0x86>
    8000683a:	f6040513          	addi	a0,s0,-160
    8000683e:	ffffe097          	auipc	ra,0xffffe
    80006842:	01e080e7          	jalr	30(ra) # 8000485c <namei>
    80006846:	84aa                	mv	s1,a0
    80006848:	c131                	beqz	a0,8000688c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000684a:	ffffe097          	auipc	ra,0xffffe
    8000684e:	85c080e7          	jalr	-1956(ra) # 800040a6 <ilock>
  if(ip->type != T_DIR){
    80006852:	04449703          	lh	a4,68(s1)
    80006856:	4785                	li	a5,1
    80006858:	04f71063          	bne	a4,a5,80006898 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000685c:	8526                	mv	a0,s1
    8000685e:	ffffe097          	auipc	ra,0xffffe
    80006862:	90a080e7          	jalr	-1782(ra) # 80004168 <iunlock>
  iput(p->cwd);
    80006866:	15093503          	ld	a0,336(s2)
    8000686a:	ffffe097          	auipc	ra,0xffffe
    8000686e:	9f6080e7          	jalr	-1546(ra) # 80004260 <iput>
  end_op();
    80006872:	ffffe097          	auipc	ra,0xffffe
    80006876:	59c080e7          	jalr	1436(ra) # 80004e0e <end_op>
  p->cwd = ip;
    8000687a:	14993823          	sd	s1,336(s2)
  return 0;
    8000687e:	4501                	li	a0,0
}
    80006880:	60ea                	ld	ra,152(sp)
    80006882:	644a                	ld	s0,144(sp)
    80006884:	64aa                	ld	s1,136(sp)
    80006886:	690a                	ld	s2,128(sp)
    80006888:	610d                	addi	sp,sp,160
    8000688a:	8082                	ret
    end_op();
    8000688c:	ffffe097          	auipc	ra,0xffffe
    80006890:	582080e7          	jalr	1410(ra) # 80004e0e <end_op>
    return -1;
    80006894:	557d                	li	a0,-1
    80006896:	b7ed                	j	80006880 <sys_chdir+0x7a>
    iunlockput(ip);
    80006898:	8526                	mv	a0,s1
    8000689a:	ffffe097          	auipc	ra,0xffffe
    8000689e:	a6e080e7          	jalr	-1426(ra) # 80004308 <iunlockput>
    end_op();
    800068a2:	ffffe097          	auipc	ra,0xffffe
    800068a6:	56c080e7          	jalr	1388(ra) # 80004e0e <end_op>
    return -1;
    800068aa:	557d                	li	a0,-1
    800068ac:	bfd1                	j	80006880 <sys_chdir+0x7a>

00000000800068ae <sys_exec>:

uint64
sys_exec(void)
{
    800068ae:	7145                	addi	sp,sp,-464
    800068b0:	e786                	sd	ra,456(sp)
    800068b2:	e3a2                	sd	s0,448(sp)
    800068b4:	ff26                	sd	s1,440(sp)
    800068b6:	fb4a                	sd	s2,432(sp)
    800068b8:	f74e                	sd	s3,424(sp)
    800068ba:	f352                	sd	s4,416(sp)
    800068bc:	ef56                	sd	s5,408(sp)
    800068be:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800068c0:	08000613          	li	a2,128
    800068c4:	f4040593          	addi	a1,s0,-192
    800068c8:	4501                	li	a0,0
    800068ca:	ffffd097          	auipc	ra,0xffffd
    800068ce:	c96080e7          	jalr	-874(ra) # 80003560 <argstr>
    return -1;
    800068d2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800068d4:	0c054a63          	bltz	a0,800069a8 <sys_exec+0xfa>
    800068d8:	e3840593          	addi	a1,s0,-456
    800068dc:	4505                	li	a0,1
    800068de:	ffffd097          	auipc	ra,0xffffd
    800068e2:	c60080e7          	jalr	-928(ra) # 8000353e <argaddr>
    800068e6:	0c054163          	bltz	a0,800069a8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800068ea:	10000613          	li	a2,256
    800068ee:	4581                	li	a1,0
    800068f0:	e4040513          	addi	a0,s0,-448
    800068f4:	ffffa097          	auipc	ra,0xffffa
    800068f8:	3ca080e7          	jalr	970(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800068fc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006900:	89a6                	mv	s3,s1
    80006902:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006904:	02000a13          	li	s4,32
    80006908:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000690c:	00391793          	slli	a5,s2,0x3
    80006910:	e3040593          	addi	a1,s0,-464
    80006914:	e3843503          	ld	a0,-456(s0)
    80006918:	953e                	add	a0,a0,a5
    8000691a:	ffffd097          	auipc	ra,0xffffd
    8000691e:	b68080e7          	jalr	-1176(ra) # 80003482 <fetchaddr>
    80006922:	02054a63          	bltz	a0,80006956 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006926:	e3043783          	ld	a5,-464(s0)
    8000692a:	c3b9                	beqz	a5,80006970 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000692c:	ffffa097          	auipc	ra,0xffffa
    80006930:	1a6080e7          	jalr	422(ra) # 80000ad2 <kalloc>
    80006934:	85aa                	mv	a1,a0
    80006936:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000693a:	cd11                	beqz	a0,80006956 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000693c:	6605                	lui	a2,0x1
    8000693e:	e3043503          	ld	a0,-464(s0)
    80006942:	ffffd097          	auipc	ra,0xffffd
    80006946:	b92080e7          	jalr	-1134(ra) # 800034d4 <fetchstr>
    8000694a:	00054663          	bltz	a0,80006956 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000694e:	0905                	addi	s2,s2,1
    80006950:	09a1                	addi	s3,s3,8
    80006952:	fb491be3          	bne	s2,s4,80006908 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006956:	10048913          	addi	s2,s1,256
    8000695a:	6088                	ld	a0,0(s1)
    8000695c:	c529                	beqz	a0,800069a6 <sys_exec+0xf8>
    kfree(argv[i]);
    8000695e:	ffffa097          	auipc	ra,0xffffa
    80006962:	078080e7          	jalr	120(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006966:	04a1                	addi	s1,s1,8
    80006968:	ff2499e3          	bne	s1,s2,8000695a <sys_exec+0xac>
  return -1;
    8000696c:	597d                	li	s2,-1
    8000696e:	a82d                	j	800069a8 <sys_exec+0xfa>
      argv[i] = 0;
    80006970:	0a8e                	slli	s5,s5,0x3
    80006972:	fc040793          	addi	a5,s0,-64
    80006976:	9abe                	add	s5,s5,a5
    80006978:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffb3e80>
  int ret = exec(path, argv);
    8000697c:	e4040593          	addi	a1,s0,-448
    80006980:	f4040513          	addi	a0,s0,-192
    80006984:	fffff097          	auipc	ra,0xfffff
    80006988:	11e080e7          	jalr	286(ra) # 80005aa2 <exec>
    8000698c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000698e:	10048993          	addi	s3,s1,256
    80006992:	6088                	ld	a0,0(s1)
    80006994:	c911                	beqz	a0,800069a8 <sys_exec+0xfa>
    kfree(argv[i]);
    80006996:	ffffa097          	auipc	ra,0xffffa
    8000699a:	040080e7          	jalr	64(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000699e:	04a1                	addi	s1,s1,8
    800069a0:	ff3499e3          	bne	s1,s3,80006992 <sys_exec+0xe4>
    800069a4:	a011                	j	800069a8 <sys_exec+0xfa>
  return -1;
    800069a6:	597d                	li	s2,-1
}
    800069a8:	854a                	mv	a0,s2
    800069aa:	60be                	ld	ra,456(sp)
    800069ac:	641e                	ld	s0,448(sp)
    800069ae:	74fa                	ld	s1,440(sp)
    800069b0:	795a                	ld	s2,432(sp)
    800069b2:	79ba                	ld	s3,424(sp)
    800069b4:	7a1a                	ld	s4,416(sp)
    800069b6:	6afa                	ld	s5,408(sp)
    800069b8:	6179                	addi	sp,sp,464
    800069ba:	8082                	ret

00000000800069bc <sys_pipe>:

uint64
sys_pipe(void)
{
    800069bc:	7139                	addi	sp,sp,-64
    800069be:	fc06                	sd	ra,56(sp)
    800069c0:	f822                	sd	s0,48(sp)
    800069c2:	f426                	sd	s1,40(sp)
    800069c4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800069c6:	ffffb097          	auipc	ra,0xffffb
    800069ca:	1c0080e7          	jalr	448(ra) # 80001b86 <myproc>
    800069ce:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800069d0:	fd840593          	addi	a1,s0,-40
    800069d4:	4501                	li	a0,0
    800069d6:	ffffd097          	auipc	ra,0xffffd
    800069da:	b68080e7          	jalr	-1176(ra) # 8000353e <argaddr>
    return -1;
    800069de:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800069e0:	0e054063          	bltz	a0,80006ac0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800069e4:	fc840593          	addi	a1,s0,-56
    800069e8:	fd040513          	addi	a0,s0,-48
    800069ec:	fffff097          	auipc	ra,0xfffff
    800069f0:	d94080e7          	jalr	-620(ra) # 80005780 <pipealloc>
    return -1;
    800069f4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800069f6:	0c054563          	bltz	a0,80006ac0 <sys_pipe+0x104>
  fd0 = -1;
    800069fa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800069fe:	fd043503          	ld	a0,-48(s0)
    80006a02:	fffff097          	auipc	ra,0xfffff
    80006a06:	4e8080e7          	jalr	1256(ra) # 80005eea <fdalloc>
    80006a0a:	fca42223          	sw	a0,-60(s0)
    80006a0e:	08054c63          	bltz	a0,80006aa6 <sys_pipe+0xea>
    80006a12:	fc843503          	ld	a0,-56(s0)
    80006a16:	fffff097          	auipc	ra,0xfffff
    80006a1a:	4d4080e7          	jalr	1236(ra) # 80005eea <fdalloc>
    80006a1e:	fca42023          	sw	a0,-64(s0)
    80006a22:	06054863          	bltz	a0,80006a92 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a26:	4691                	li	a3,4
    80006a28:	fc440613          	addi	a2,s0,-60
    80006a2c:	fd843583          	ld	a1,-40(s0)
    80006a30:	68a8                	ld	a0,80(s1)
    80006a32:	ffffb097          	auipc	ra,0xffffb
    80006a36:	e00080e7          	jalr	-512(ra) # 80001832 <copyout>
    80006a3a:	02054063          	bltz	a0,80006a5a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006a3e:	4691                	li	a3,4
    80006a40:	fc040613          	addi	a2,s0,-64
    80006a44:	fd843583          	ld	a1,-40(s0)
    80006a48:	0591                	addi	a1,a1,4
    80006a4a:	68a8                	ld	a0,80(s1)
    80006a4c:	ffffb097          	auipc	ra,0xffffb
    80006a50:	de6080e7          	jalr	-538(ra) # 80001832 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006a54:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006a56:	06055563          	bgez	a0,80006ac0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006a5a:	fc442783          	lw	a5,-60(s0)
    80006a5e:	07e9                	addi	a5,a5,26
    80006a60:	078e                	slli	a5,a5,0x3
    80006a62:	97a6                	add	a5,a5,s1
    80006a64:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006a68:	fc042503          	lw	a0,-64(s0)
    80006a6c:	0569                	addi	a0,a0,26
    80006a6e:	050e                	slli	a0,a0,0x3
    80006a70:	9526                	add	a0,a0,s1
    80006a72:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006a76:	fd043503          	ld	a0,-48(s0)
    80006a7a:	ffffe097          	auipc	ra,0xffffe
    80006a7e:	7e0080e7          	jalr	2016(ra) # 8000525a <fileclose>
    fileclose(wf);
    80006a82:	fc843503          	ld	a0,-56(s0)
    80006a86:	ffffe097          	auipc	ra,0xffffe
    80006a8a:	7d4080e7          	jalr	2004(ra) # 8000525a <fileclose>
    return -1;
    80006a8e:	57fd                	li	a5,-1
    80006a90:	a805                	j	80006ac0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006a92:	fc442783          	lw	a5,-60(s0)
    80006a96:	0007c863          	bltz	a5,80006aa6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006a9a:	01a78513          	addi	a0,a5,26
    80006a9e:	050e                	slli	a0,a0,0x3
    80006aa0:	9526                	add	a0,a0,s1
    80006aa2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006aa6:	fd043503          	ld	a0,-48(s0)
    80006aaa:	ffffe097          	auipc	ra,0xffffe
    80006aae:	7b0080e7          	jalr	1968(ra) # 8000525a <fileclose>
    fileclose(wf);
    80006ab2:	fc843503          	ld	a0,-56(s0)
    80006ab6:	ffffe097          	auipc	ra,0xffffe
    80006aba:	7a4080e7          	jalr	1956(ra) # 8000525a <fileclose>
    return -1;
    80006abe:	57fd                	li	a5,-1
}
    80006ac0:	853e                	mv	a0,a5
    80006ac2:	70e2                	ld	ra,56(sp)
    80006ac4:	7442                	ld	s0,48(sp)
    80006ac6:	74a2                	ld	s1,40(sp)
    80006ac8:	6121                	addi	sp,sp,64
    80006aca:	8082                	ret
    80006acc:	0000                	unimp
	...

0000000080006ad0 <kernelvec>:
    80006ad0:	7111                	addi	sp,sp,-256
    80006ad2:	e006                	sd	ra,0(sp)
    80006ad4:	e40a                	sd	sp,8(sp)
    80006ad6:	e80e                	sd	gp,16(sp)
    80006ad8:	ec12                	sd	tp,24(sp)
    80006ada:	f016                	sd	t0,32(sp)
    80006adc:	f41a                	sd	t1,40(sp)
    80006ade:	f81e                	sd	t2,48(sp)
    80006ae0:	fc22                	sd	s0,56(sp)
    80006ae2:	e0a6                	sd	s1,64(sp)
    80006ae4:	e4aa                	sd	a0,72(sp)
    80006ae6:	e8ae                	sd	a1,80(sp)
    80006ae8:	ecb2                	sd	a2,88(sp)
    80006aea:	f0b6                	sd	a3,96(sp)
    80006aec:	f4ba                	sd	a4,104(sp)
    80006aee:	f8be                	sd	a5,112(sp)
    80006af0:	fcc2                	sd	a6,120(sp)
    80006af2:	e146                	sd	a7,128(sp)
    80006af4:	e54a                	sd	s2,136(sp)
    80006af6:	e94e                	sd	s3,144(sp)
    80006af8:	ed52                	sd	s4,152(sp)
    80006afa:	f156                	sd	s5,160(sp)
    80006afc:	f55a                	sd	s6,168(sp)
    80006afe:	f95e                	sd	s7,176(sp)
    80006b00:	fd62                	sd	s8,184(sp)
    80006b02:	e1e6                	sd	s9,192(sp)
    80006b04:	e5ea                	sd	s10,200(sp)
    80006b06:	e9ee                	sd	s11,208(sp)
    80006b08:	edf2                	sd	t3,216(sp)
    80006b0a:	f1f6                	sd	t4,224(sp)
    80006b0c:	f5fa                	sd	t5,232(sp)
    80006b0e:	f9fe                	sd	t6,240(sp)
    80006b10:	83ffc0ef          	jal	ra,8000334e <kerneltrap>
    80006b14:	6082                	ld	ra,0(sp)
    80006b16:	6122                	ld	sp,8(sp)
    80006b18:	61c2                	ld	gp,16(sp)
    80006b1a:	7282                	ld	t0,32(sp)
    80006b1c:	7322                	ld	t1,40(sp)
    80006b1e:	73c2                	ld	t2,48(sp)
    80006b20:	7462                	ld	s0,56(sp)
    80006b22:	6486                	ld	s1,64(sp)
    80006b24:	6526                	ld	a0,72(sp)
    80006b26:	65c6                	ld	a1,80(sp)
    80006b28:	6666                	ld	a2,88(sp)
    80006b2a:	7686                	ld	a3,96(sp)
    80006b2c:	7726                	ld	a4,104(sp)
    80006b2e:	77c6                	ld	a5,112(sp)
    80006b30:	7866                	ld	a6,120(sp)
    80006b32:	688a                	ld	a7,128(sp)
    80006b34:	692a                	ld	s2,136(sp)
    80006b36:	69ca                	ld	s3,144(sp)
    80006b38:	6a6a                	ld	s4,152(sp)
    80006b3a:	7a8a                	ld	s5,160(sp)
    80006b3c:	7b2a                	ld	s6,168(sp)
    80006b3e:	7bca                	ld	s7,176(sp)
    80006b40:	7c6a                	ld	s8,184(sp)
    80006b42:	6c8e                	ld	s9,192(sp)
    80006b44:	6d2e                	ld	s10,200(sp)
    80006b46:	6dce                	ld	s11,208(sp)
    80006b48:	6e6e                	ld	t3,216(sp)
    80006b4a:	7e8e                	ld	t4,224(sp)
    80006b4c:	7f2e                	ld	t5,232(sp)
    80006b4e:	7fce                	ld	t6,240(sp)
    80006b50:	6111                	addi	sp,sp,256
    80006b52:	10200073          	sret
    80006b56:	00000013          	nop
    80006b5a:	00000013          	nop
    80006b5e:	0001                	nop

0000000080006b60 <timervec>:
    80006b60:	34051573          	csrrw	a0,mscratch,a0
    80006b64:	e10c                	sd	a1,0(a0)
    80006b66:	e510                	sd	a2,8(a0)
    80006b68:	e914                	sd	a3,16(a0)
    80006b6a:	6d0c                	ld	a1,24(a0)
    80006b6c:	7110                	ld	a2,32(a0)
    80006b6e:	6194                	ld	a3,0(a1)
    80006b70:	96b2                	add	a3,a3,a2
    80006b72:	e194                	sd	a3,0(a1)
    80006b74:	4589                	li	a1,2
    80006b76:	14459073          	csrw	sip,a1
    80006b7a:	6914                	ld	a3,16(a0)
    80006b7c:	6510                	ld	a2,8(a0)
    80006b7e:	610c                	ld	a1,0(a0)
    80006b80:	34051573          	csrrw	a0,mscratch,a0
    80006b84:	30200073          	mret
	...

0000000080006b8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006b8a:	1141                	addi	sp,sp,-16
    80006b8c:	e422                	sd	s0,8(sp)
    80006b8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006b90:	0c0007b7          	lui	a5,0xc000
    80006b94:	4705                	li	a4,1
    80006b96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006b98:	c3d8                	sw	a4,4(a5)
}
    80006b9a:	6422                	ld	s0,8(sp)
    80006b9c:	0141                	addi	sp,sp,16
    80006b9e:	8082                	ret

0000000080006ba0 <plicinithart>:

void
plicinithart(void)
{
    80006ba0:	1141                	addi	sp,sp,-16
    80006ba2:	e406                	sd	ra,8(sp)
    80006ba4:	e022                	sd	s0,0(sp)
    80006ba6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ba8:	ffffb097          	auipc	ra,0xffffb
    80006bac:	fb2080e7          	jalr	-78(ra) # 80001b5a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006bb0:	0085171b          	slliw	a4,a0,0x8
    80006bb4:	0c0027b7          	lui	a5,0xc002
    80006bb8:	97ba                	add	a5,a5,a4
    80006bba:	40200713          	li	a4,1026
    80006bbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006bc2:	00d5151b          	slliw	a0,a0,0xd
    80006bc6:	0c2017b7          	lui	a5,0xc201
    80006bca:	953e                	add	a0,a0,a5
    80006bcc:	00052023          	sw	zero,0(a0)
}
    80006bd0:	60a2                	ld	ra,8(sp)
    80006bd2:	6402                	ld	s0,0(sp)
    80006bd4:	0141                	addi	sp,sp,16
    80006bd6:	8082                	ret

0000000080006bd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006bd8:	1141                	addi	sp,sp,-16
    80006bda:	e406                	sd	ra,8(sp)
    80006bdc:	e022                	sd	s0,0(sp)
    80006bde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006be0:	ffffb097          	auipc	ra,0xffffb
    80006be4:	f7a080e7          	jalr	-134(ra) # 80001b5a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006be8:	00d5179b          	slliw	a5,a0,0xd
    80006bec:	0c201537          	lui	a0,0xc201
    80006bf0:	953e                	add	a0,a0,a5
  return irq;
}
    80006bf2:	4148                	lw	a0,4(a0)
    80006bf4:	60a2                	ld	ra,8(sp)
    80006bf6:	6402                	ld	s0,0(sp)
    80006bf8:	0141                	addi	sp,sp,16
    80006bfa:	8082                	ret

0000000080006bfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006bfc:	1101                	addi	sp,sp,-32
    80006bfe:	ec06                	sd	ra,24(sp)
    80006c00:	e822                	sd	s0,16(sp)
    80006c02:	e426                	sd	s1,8(sp)
    80006c04:	1000                	addi	s0,sp,32
    80006c06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006c08:	ffffb097          	auipc	ra,0xffffb
    80006c0c:	f52080e7          	jalr	-174(ra) # 80001b5a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006c10:	00d5151b          	slliw	a0,a0,0xd
    80006c14:	0c2017b7          	lui	a5,0xc201
    80006c18:	97aa                	add	a5,a5,a0
    80006c1a:	c3c4                	sw	s1,4(a5)
}
    80006c1c:	60e2                	ld	ra,24(sp)
    80006c1e:	6442                	ld	s0,16(sp)
    80006c20:	64a2                	ld	s1,8(sp)
    80006c22:	6105                	addi	sp,sp,32
    80006c24:	8082                	ret

0000000080006c26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006c26:	1141                	addi	sp,sp,-16
    80006c28:	e406                	sd	ra,8(sp)
    80006c2a:	e022                	sd	s0,0(sp)
    80006c2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006c2e:	479d                	li	a5,7
    80006c30:	06a7c963          	blt	a5,a0,80006ca2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006c34:	00041797          	auipc	a5,0x41
    80006c38:	3cc78793          	addi	a5,a5,972 # 80048000 <disk>
    80006c3c:	00a78733          	add	a4,a5,a0
    80006c40:	6789                	lui	a5,0x2
    80006c42:	97ba                	add	a5,a5,a4
    80006c44:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006c48:	e7ad                	bnez	a5,80006cb2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006c4a:	00451793          	slli	a5,a0,0x4
    80006c4e:	00043717          	auipc	a4,0x43
    80006c52:	3b270713          	addi	a4,a4,946 # 8004a000 <disk+0x2000>
    80006c56:	6314                	ld	a3,0(a4)
    80006c58:	96be                	add	a3,a3,a5
    80006c5a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006c5e:	6314                	ld	a3,0(a4)
    80006c60:	96be                	add	a3,a3,a5
    80006c62:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006c66:	6314                	ld	a3,0(a4)
    80006c68:	96be                	add	a3,a3,a5
    80006c6a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006c6e:	6318                	ld	a4,0(a4)
    80006c70:	97ba                	add	a5,a5,a4
    80006c72:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006c76:	00041797          	auipc	a5,0x41
    80006c7a:	38a78793          	addi	a5,a5,906 # 80048000 <disk>
    80006c7e:	97aa                	add	a5,a5,a0
    80006c80:	6509                	lui	a0,0x2
    80006c82:	953e                	add	a0,a0,a5
    80006c84:	4785                	li	a5,1
    80006c86:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006c8a:	00043517          	auipc	a0,0x43
    80006c8e:	38e50513          	addi	a0,a0,910 # 8004a018 <disk+0x2018>
    80006c92:	ffffb097          	auipc	ra,0xffffb
    80006c96:	336080e7          	jalr	822(ra) # 80001fc8 <wakeup>
}
    80006c9a:	60a2                	ld	ra,8(sp)
    80006c9c:	6402                	ld	s0,0(sp)
    80006c9e:	0141                	addi	sp,sp,16
    80006ca0:	8082                	ret
    panic("free_desc 1");
    80006ca2:	00003517          	auipc	a0,0x3
    80006ca6:	dce50513          	addi	a0,a0,-562 # 80009a70 <syscalls+0x360>
    80006caa:	ffffa097          	auipc	ra,0xffffa
    80006cae:	880080e7          	jalr	-1920(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006cb2:	00003517          	auipc	a0,0x3
    80006cb6:	dce50513          	addi	a0,a0,-562 # 80009a80 <syscalls+0x370>
    80006cba:	ffffa097          	auipc	ra,0xffffa
    80006cbe:	870080e7          	jalr	-1936(ra) # 8000052a <panic>

0000000080006cc2 <virtio_disk_init>:
{
    80006cc2:	1101                	addi	sp,sp,-32
    80006cc4:	ec06                	sd	ra,24(sp)
    80006cc6:	e822                	sd	s0,16(sp)
    80006cc8:	e426                	sd	s1,8(sp)
    80006cca:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006ccc:	00003597          	auipc	a1,0x3
    80006cd0:	dc458593          	addi	a1,a1,-572 # 80009a90 <syscalls+0x380>
    80006cd4:	00043517          	auipc	a0,0x43
    80006cd8:	45450513          	addi	a0,a0,1108 # 8004a128 <disk+0x2128>
    80006cdc:	ffffa097          	auipc	ra,0xffffa
    80006ce0:	e56080e7          	jalr	-426(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ce4:	100017b7          	lui	a5,0x10001
    80006ce8:	4398                	lw	a4,0(a5)
    80006cea:	2701                	sext.w	a4,a4
    80006cec:	747277b7          	lui	a5,0x74727
    80006cf0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006cf4:	0ef71163          	bne	a4,a5,80006dd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006cf8:	100017b7          	lui	a5,0x10001
    80006cfc:	43dc                	lw	a5,4(a5)
    80006cfe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006d00:	4705                	li	a4,1
    80006d02:	0ce79a63          	bne	a5,a4,80006dd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d06:	100017b7          	lui	a5,0x10001
    80006d0a:	479c                	lw	a5,8(a5)
    80006d0c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006d0e:	4709                	li	a4,2
    80006d10:	0ce79363          	bne	a5,a4,80006dd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006d14:	100017b7          	lui	a5,0x10001
    80006d18:	47d8                	lw	a4,12(a5)
    80006d1a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006d1c:	554d47b7          	lui	a5,0x554d4
    80006d20:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006d24:	0af71963          	bne	a4,a5,80006dd6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d28:	100017b7          	lui	a5,0x10001
    80006d2c:	4705                	li	a4,1
    80006d2e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d30:	470d                	li	a4,3
    80006d32:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006d34:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006d36:	c7ffe737          	lui	a4,0xc7ffe
    80006d3a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb375f>
    80006d3e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006d40:	2701                	sext.w	a4,a4
    80006d42:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d44:	472d                	li	a4,11
    80006d46:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006d48:	473d                	li	a4,15
    80006d4a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006d4c:	6705                	lui	a4,0x1
    80006d4e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006d50:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006d54:	5bdc                	lw	a5,52(a5)
    80006d56:	2781                	sext.w	a5,a5
  if(max == 0)
    80006d58:	c7d9                	beqz	a5,80006de6 <virtio_disk_init+0x124>
  if(max < NUM)
    80006d5a:	471d                	li	a4,7
    80006d5c:	08f77d63          	bgeu	a4,a5,80006df6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006d60:	100014b7          	lui	s1,0x10001
    80006d64:	47a1                	li	a5,8
    80006d66:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006d68:	6609                	lui	a2,0x2
    80006d6a:	4581                	li	a1,0
    80006d6c:	00041517          	auipc	a0,0x41
    80006d70:	29450513          	addi	a0,a0,660 # 80048000 <disk>
    80006d74:	ffffa097          	auipc	ra,0xffffa
    80006d78:	f4a080e7          	jalr	-182(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006d7c:	00041717          	auipc	a4,0x41
    80006d80:	28470713          	addi	a4,a4,644 # 80048000 <disk>
    80006d84:	00c75793          	srli	a5,a4,0xc
    80006d88:	2781                	sext.w	a5,a5
    80006d8a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006d8c:	00043797          	auipc	a5,0x43
    80006d90:	27478793          	addi	a5,a5,628 # 8004a000 <disk+0x2000>
    80006d94:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006d96:	00041717          	auipc	a4,0x41
    80006d9a:	2ea70713          	addi	a4,a4,746 # 80048080 <disk+0x80>
    80006d9e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006da0:	00042717          	auipc	a4,0x42
    80006da4:	26070713          	addi	a4,a4,608 # 80049000 <disk+0x1000>
    80006da8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006daa:	4705                	li	a4,1
    80006dac:	00e78c23          	sb	a4,24(a5)
    80006db0:	00e78ca3          	sb	a4,25(a5)
    80006db4:	00e78d23          	sb	a4,26(a5)
    80006db8:	00e78da3          	sb	a4,27(a5)
    80006dbc:	00e78e23          	sb	a4,28(a5)
    80006dc0:	00e78ea3          	sb	a4,29(a5)
    80006dc4:	00e78f23          	sb	a4,30(a5)
    80006dc8:	00e78fa3          	sb	a4,31(a5)
}
    80006dcc:	60e2                	ld	ra,24(sp)
    80006dce:	6442                	ld	s0,16(sp)
    80006dd0:	64a2                	ld	s1,8(sp)
    80006dd2:	6105                	addi	sp,sp,32
    80006dd4:	8082                	ret
    panic("could not find virtio disk");
    80006dd6:	00003517          	auipc	a0,0x3
    80006dda:	cca50513          	addi	a0,a0,-822 # 80009aa0 <syscalls+0x390>
    80006dde:	ffff9097          	auipc	ra,0xffff9
    80006de2:	74c080e7          	jalr	1868(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006de6:	00003517          	auipc	a0,0x3
    80006dea:	cda50513          	addi	a0,a0,-806 # 80009ac0 <syscalls+0x3b0>
    80006dee:	ffff9097          	auipc	ra,0xffff9
    80006df2:	73c080e7          	jalr	1852(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006df6:	00003517          	auipc	a0,0x3
    80006dfa:	cea50513          	addi	a0,a0,-790 # 80009ae0 <syscalls+0x3d0>
    80006dfe:	ffff9097          	auipc	ra,0xffff9
    80006e02:	72c080e7          	jalr	1836(ra) # 8000052a <panic>

0000000080006e06 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006e06:	7119                	addi	sp,sp,-128
    80006e08:	fc86                	sd	ra,120(sp)
    80006e0a:	f8a2                	sd	s0,112(sp)
    80006e0c:	f4a6                	sd	s1,104(sp)
    80006e0e:	f0ca                	sd	s2,96(sp)
    80006e10:	ecce                	sd	s3,88(sp)
    80006e12:	e8d2                	sd	s4,80(sp)
    80006e14:	e4d6                	sd	s5,72(sp)
    80006e16:	e0da                	sd	s6,64(sp)
    80006e18:	fc5e                	sd	s7,56(sp)
    80006e1a:	f862                	sd	s8,48(sp)
    80006e1c:	f466                	sd	s9,40(sp)
    80006e1e:	f06a                	sd	s10,32(sp)
    80006e20:	ec6e                	sd	s11,24(sp)
    80006e22:	0100                	addi	s0,sp,128
    80006e24:	8aaa                	mv	s5,a0
    80006e26:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006e28:	00c52c83          	lw	s9,12(a0)
    80006e2c:	001c9c9b          	slliw	s9,s9,0x1
    80006e30:	1c82                	slli	s9,s9,0x20
    80006e32:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006e36:	00043517          	auipc	a0,0x43
    80006e3a:	2f250513          	addi	a0,a0,754 # 8004a128 <disk+0x2128>
    80006e3e:	ffffa097          	auipc	ra,0xffffa
    80006e42:	d84080e7          	jalr	-636(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006e46:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006e48:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006e4a:	00041c17          	auipc	s8,0x41
    80006e4e:	1b6c0c13          	addi	s8,s8,438 # 80048000 <disk>
    80006e52:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006e54:	4b0d                	li	s6,3
    80006e56:	a0ad                	j	80006ec0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006e58:	00fc0733          	add	a4,s8,a5
    80006e5c:	975e                	add	a4,a4,s7
    80006e5e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006e62:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006e64:	0207c563          	bltz	a5,80006e8e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006e68:	2905                	addiw	s2,s2,1
    80006e6a:	0611                	addi	a2,a2,4
    80006e6c:	19690d63          	beq	s2,s6,80007006 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006e70:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006e72:	00043717          	auipc	a4,0x43
    80006e76:	1a670713          	addi	a4,a4,422 # 8004a018 <disk+0x2018>
    80006e7a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006e7c:	00074683          	lbu	a3,0(a4)
    80006e80:	fee1                	bnez	a3,80006e58 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006e82:	2785                	addiw	a5,a5,1
    80006e84:	0705                	addi	a4,a4,1
    80006e86:	fe979be3          	bne	a5,s1,80006e7c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006e8a:	57fd                	li	a5,-1
    80006e8c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006e8e:	01205d63          	blez	s2,80006ea8 <virtio_disk_rw+0xa2>
    80006e92:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006e94:	000a2503          	lw	a0,0(s4)
    80006e98:	00000097          	auipc	ra,0x0
    80006e9c:	d8e080e7          	jalr	-626(ra) # 80006c26 <free_desc>
      for(int j = 0; j < i; j++)
    80006ea0:	2d85                	addiw	s11,s11,1
    80006ea2:	0a11                	addi	s4,s4,4
    80006ea4:	ffb918e3          	bne	s2,s11,80006e94 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006ea8:	00043597          	auipc	a1,0x43
    80006eac:	28058593          	addi	a1,a1,640 # 8004a128 <disk+0x2128>
    80006eb0:	00043517          	auipc	a0,0x43
    80006eb4:	16850513          	addi	a0,a0,360 # 8004a018 <disk+0x2018>
    80006eb8:	ffffb097          	auipc	ra,0xffffb
    80006ebc:	0ac080e7          	jalr	172(ra) # 80001f64 <sleep>
  for(int i = 0; i < 3; i++){
    80006ec0:	f8040a13          	addi	s4,s0,-128
{
    80006ec4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006ec6:	894e                	mv	s2,s3
    80006ec8:	b765                	j	80006e70 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006eca:	00043697          	auipc	a3,0x43
    80006ece:	1366b683          	ld	a3,310(a3) # 8004a000 <disk+0x2000>
    80006ed2:	96ba                	add	a3,a3,a4
    80006ed4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006ed8:	00041817          	auipc	a6,0x41
    80006edc:	12880813          	addi	a6,a6,296 # 80048000 <disk>
    80006ee0:	00043697          	auipc	a3,0x43
    80006ee4:	12068693          	addi	a3,a3,288 # 8004a000 <disk+0x2000>
    80006ee8:	6290                	ld	a2,0(a3)
    80006eea:	963a                	add	a2,a2,a4
    80006eec:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006ef0:	0015e593          	ori	a1,a1,1
    80006ef4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006ef8:	f8842603          	lw	a2,-120(s0)
    80006efc:	628c                	ld	a1,0(a3)
    80006efe:	972e                	add	a4,a4,a1
    80006f00:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006f04:	20050593          	addi	a1,a0,512
    80006f08:	0592                	slli	a1,a1,0x4
    80006f0a:	95c2                	add	a1,a1,a6
    80006f0c:	577d                	li	a4,-1
    80006f0e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006f12:	00461713          	slli	a4,a2,0x4
    80006f16:	6290                	ld	a2,0(a3)
    80006f18:	963a                	add	a2,a2,a4
    80006f1a:	03078793          	addi	a5,a5,48
    80006f1e:	97c2                	add	a5,a5,a6
    80006f20:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006f22:	629c                	ld	a5,0(a3)
    80006f24:	97ba                	add	a5,a5,a4
    80006f26:	4605                	li	a2,1
    80006f28:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006f2a:	629c                	ld	a5,0(a3)
    80006f2c:	97ba                	add	a5,a5,a4
    80006f2e:	4809                	li	a6,2
    80006f30:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006f34:	629c                	ld	a5,0(a3)
    80006f36:	973e                	add	a4,a4,a5
    80006f38:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006f3c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006f40:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006f44:	6698                	ld	a4,8(a3)
    80006f46:	00275783          	lhu	a5,2(a4)
    80006f4a:	8b9d                	andi	a5,a5,7
    80006f4c:	0786                	slli	a5,a5,0x1
    80006f4e:	97ba                	add	a5,a5,a4
    80006f50:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006f54:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006f58:	6698                	ld	a4,8(a3)
    80006f5a:	00275783          	lhu	a5,2(a4)
    80006f5e:	2785                	addiw	a5,a5,1
    80006f60:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006f64:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006f68:	100017b7          	lui	a5,0x10001
    80006f6c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006f70:	004aa783          	lw	a5,4(s5)
    80006f74:	02c79163          	bne	a5,a2,80006f96 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006f78:	00043917          	auipc	s2,0x43
    80006f7c:	1b090913          	addi	s2,s2,432 # 8004a128 <disk+0x2128>
  while(b->disk == 1) {
    80006f80:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006f82:	85ca                	mv	a1,s2
    80006f84:	8556                	mv	a0,s5
    80006f86:	ffffb097          	auipc	ra,0xffffb
    80006f8a:	fde080e7          	jalr	-34(ra) # 80001f64 <sleep>
  while(b->disk == 1) {
    80006f8e:	004aa783          	lw	a5,4(s5)
    80006f92:	fe9788e3          	beq	a5,s1,80006f82 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006f96:	f8042903          	lw	s2,-128(s0)
    80006f9a:	20090793          	addi	a5,s2,512
    80006f9e:	00479713          	slli	a4,a5,0x4
    80006fa2:	00041797          	auipc	a5,0x41
    80006fa6:	05e78793          	addi	a5,a5,94 # 80048000 <disk>
    80006faa:	97ba                	add	a5,a5,a4
    80006fac:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006fb0:	00043997          	auipc	s3,0x43
    80006fb4:	05098993          	addi	s3,s3,80 # 8004a000 <disk+0x2000>
    80006fb8:	00491713          	slli	a4,s2,0x4
    80006fbc:	0009b783          	ld	a5,0(s3)
    80006fc0:	97ba                	add	a5,a5,a4
    80006fc2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006fc6:	854a                	mv	a0,s2
    80006fc8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006fcc:	00000097          	auipc	ra,0x0
    80006fd0:	c5a080e7          	jalr	-934(ra) # 80006c26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006fd4:	8885                	andi	s1,s1,1
    80006fd6:	f0ed                	bnez	s1,80006fb8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006fd8:	00043517          	auipc	a0,0x43
    80006fdc:	15050513          	addi	a0,a0,336 # 8004a128 <disk+0x2128>
    80006fe0:	ffffa097          	auipc	ra,0xffffa
    80006fe4:	c96080e7          	jalr	-874(ra) # 80000c76 <release>
}
    80006fe8:	70e6                	ld	ra,120(sp)
    80006fea:	7446                	ld	s0,112(sp)
    80006fec:	74a6                	ld	s1,104(sp)
    80006fee:	7906                	ld	s2,96(sp)
    80006ff0:	69e6                	ld	s3,88(sp)
    80006ff2:	6a46                	ld	s4,80(sp)
    80006ff4:	6aa6                	ld	s5,72(sp)
    80006ff6:	6b06                	ld	s6,64(sp)
    80006ff8:	7be2                	ld	s7,56(sp)
    80006ffa:	7c42                	ld	s8,48(sp)
    80006ffc:	7ca2                	ld	s9,40(sp)
    80006ffe:	7d02                	ld	s10,32(sp)
    80007000:	6de2                	ld	s11,24(sp)
    80007002:	6109                	addi	sp,sp,128
    80007004:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007006:	f8042503          	lw	a0,-128(s0)
    8000700a:	20050793          	addi	a5,a0,512
    8000700e:	0792                	slli	a5,a5,0x4
  if(write)
    80007010:	00041817          	auipc	a6,0x41
    80007014:	ff080813          	addi	a6,a6,-16 # 80048000 <disk>
    80007018:	00f80733          	add	a4,a6,a5
    8000701c:	01a036b3          	snez	a3,s10
    80007020:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007024:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007028:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000702c:	7679                	lui	a2,0xffffe
    8000702e:	963e                	add	a2,a2,a5
    80007030:	00043697          	auipc	a3,0x43
    80007034:	fd068693          	addi	a3,a3,-48 # 8004a000 <disk+0x2000>
    80007038:	6298                	ld	a4,0(a3)
    8000703a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000703c:	0a878593          	addi	a1,a5,168
    80007040:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007042:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007044:	6298                	ld	a4,0(a3)
    80007046:	9732                	add	a4,a4,a2
    80007048:	45c1                	li	a1,16
    8000704a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000704c:	6298                	ld	a4,0(a3)
    8000704e:	9732                	add	a4,a4,a2
    80007050:	4585                	li	a1,1
    80007052:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007056:	f8442703          	lw	a4,-124(s0)
    8000705a:	628c                	ld	a1,0(a3)
    8000705c:	962e                	add	a2,a2,a1
    8000705e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffb300e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007062:	0712                	slli	a4,a4,0x4
    80007064:	6290                	ld	a2,0(a3)
    80007066:	963a                	add	a2,a2,a4
    80007068:	058a8593          	addi	a1,s5,88
    8000706c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000706e:	6294                	ld	a3,0(a3)
    80007070:	96ba                	add	a3,a3,a4
    80007072:	40000613          	li	a2,1024
    80007076:	c690                	sw	a2,8(a3)
  if(write)
    80007078:	e40d19e3          	bnez	s10,80006eca <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000707c:	00043697          	auipc	a3,0x43
    80007080:	f846b683          	ld	a3,-124(a3) # 8004a000 <disk+0x2000>
    80007084:	96ba                	add	a3,a3,a4
    80007086:	4609                	li	a2,2
    80007088:	00c69623          	sh	a2,12(a3)
    8000708c:	b5b1                	j	80006ed8 <virtio_disk_rw+0xd2>

000000008000708e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000708e:	1101                	addi	sp,sp,-32
    80007090:	ec06                	sd	ra,24(sp)
    80007092:	e822                	sd	s0,16(sp)
    80007094:	e426                	sd	s1,8(sp)
    80007096:	e04a                	sd	s2,0(sp)
    80007098:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000709a:	00043517          	auipc	a0,0x43
    8000709e:	08e50513          	addi	a0,a0,142 # 8004a128 <disk+0x2128>
    800070a2:	ffffa097          	auipc	ra,0xffffa
    800070a6:	b20080e7          	jalr	-1248(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800070aa:	10001737          	lui	a4,0x10001
    800070ae:	533c                	lw	a5,96(a4)
    800070b0:	8b8d                	andi	a5,a5,3
    800070b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800070b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800070b8:	00043797          	auipc	a5,0x43
    800070bc:	f4878793          	addi	a5,a5,-184 # 8004a000 <disk+0x2000>
    800070c0:	6b94                	ld	a3,16(a5)
    800070c2:	0207d703          	lhu	a4,32(a5)
    800070c6:	0026d783          	lhu	a5,2(a3)
    800070ca:	06f70163          	beq	a4,a5,8000712c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800070ce:	00041917          	auipc	s2,0x41
    800070d2:	f3290913          	addi	s2,s2,-206 # 80048000 <disk>
    800070d6:	00043497          	auipc	s1,0x43
    800070da:	f2a48493          	addi	s1,s1,-214 # 8004a000 <disk+0x2000>
    __sync_synchronize();
    800070de:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800070e2:	6898                	ld	a4,16(s1)
    800070e4:	0204d783          	lhu	a5,32(s1)
    800070e8:	8b9d                	andi	a5,a5,7
    800070ea:	078e                	slli	a5,a5,0x3
    800070ec:	97ba                	add	a5,a5,a4
    800070ee:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800070f0:	20078713          	addi	a4,a5,512
    800070f4:	0712                	slli	a4,a4,0x4
    800070f6:	974a                	add	a4,a4,s2
    800070f8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800070fc:	e731                	bnez	a4,80007148 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800070fe:	20078793          	addi	a5,a5,512
    80007102:	0792                	slli	a5,a5,0x4
    80007104:	97ca                	add	a5,a5,s2
    80007106:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007108:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000710c:	ffffb097          	auipc	ra,0xffffb
    80007110:	ebc080e7          	jalr	-324(ra) # 80001fc8 <wakeup>

    disk.used_idx += 1;
    80007114:	0204d783          	lhu	a5,32(s1)
    80007118:	2785                	addiw	a5,a5,1
    8000711a:	17c2                	slli	a5,a5,0x30
    8000711c:	93c1                	srli	a5,a5,0x30
    8000711e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007122:	6898                	ld	a4,16(s1)
    80007124:	00275703          	lhu	a4,2(a4)
    80007128:	faf71be3          	bne	a4,a5,800070de <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000712c:	00043517          	auipc	a0,0x43
    80007130:	ffc50513          	addi	a0,a0,-4 # 8004a128 <disk+0x2128>
    80007134:	ffffa097          	auipc	ra,0xffffa
    80007138:	b42080e7          	jalr	-1214(ra) # 80000c76 <release>
}
    8000713c:	60e2                	ld	ra,24(sp)
    8000713e:	6442                	ld	s0,16(sp)
    80007140:	64a2                	ld	s1,8(sp)
    80007142:	6902                	ld	s2,0(sp)
    80007144:	6105                	addi	sp,sp,32
    80007146:	8082                	ret
      panic("virtio_disk_intr status");
    80007148:	00003517          	auipc	a0,0x3
    8000714c:	9b850513          	addi	a0,a0,-1608 # 80009b00 <syscalls+0x3f0>
    80007150:	ffff9097          	auipc	ra,0xffff9
    80007154:	3da080e7          	jalr	986(ra) # 8000052a <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
