
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
    80000068:	a1c78793          	addi	a5,a5,-1508 # 80006a80 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb97ff>
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
    80000122:	010080e7          	jalr	16(ra) # 8000212e <either_copyin>
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
    800001b6:	8da080e7          	jalr	-1830(ra) # 80001a8c <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	c6c080e7          	jalr	-916(ra) # 80001e2e <sleep>
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
    80000202:	eda080e7          	jalr	-294(ra) # 800020d8 <either_copyout>
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
    800002e2:	ea6080e7          	jalr	-346(ra) # 80002184 <procdump>
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
    80000436:	a60080e7          	jalr	-1440(ra) # 80001e92 <wakeup>
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
    80000464:	00040797          	auipc	a5,0x40
    80000468:	4b478793          	addi	a5,a5,1204 # 80040918 <devsw>
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
    8000055c:	f5850513          	addi	a0,a0,-168 # 800094b0 <digits+0x470>
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
    80000882:	614080e7          	jalr	1556(ra) # 80001e92 <wakeup>
    
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
    8000090e:	524080e7          	jalr	1316(ra) # 80001e2e <sleep>
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
    800009ea:	00044797          	auipc	a5,0x44
    800009ee:	61678793          	addi	a5,a5,1558 # 80045000 <end>
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
    80000aba:	00044517          	auipc	a0,0x44
    80000abe:	54650513          	addi	a0,a0,1350 # 80045000 <end>
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
    80000b60:	f14080e7          	jalr	-236(ra) # 80001a70 <mycpu>
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
    80000b92:	ee2080e7          	jalr	-286(ra) # 80001a70 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	ed6080e7          	jalr	-298(ra) # 80001a70 <mycpu>
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
    80000bb6:	ebe080e7          	jalr	-322(ra) # 80001a70 <mycpu>
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
    80000bf6:	e7e080e7          	jalr	-386(ra) # 80001a70 <mycpu>
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
    80000c22:	e52080e7          	jalr	-430(ra) # 80001a70 <mycpu>
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
    80000e78:	bec080e7          	jalr	-1044(ra) # 80001a60 <cpuid>
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
    80000e94:	bd0080e7          	jalr	-1072(ra) # 80001a60 <cpuid>
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
    80000eb6:	0f6080e7          	jalr	246(ra) # 80002fa8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	c06080e7          	jalr	-1018(ra) # 80006ac0 <plicinithart>
  }
  scheduler();
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	df0080e7          	jalr	-528(ra) # 80001cb2 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	5d650513          	addi	a0,a0,1494 # 800094b0 <digits+0x470>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	5b650513          	addi	a0,a0,1462 # 800094b0 <digits+0x470>
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
    80000f26:	a86080e7          	jalr	-1402(ra) # 800019a8 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	056080e7          	jalr	86(ra) # 80002f80 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	076080e7          	jalr	118(ra) # 80002fa8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	b70080e7          	jalr	-1168(ra) # 80006aaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	b7e080e7          	jalr	-1154(ra) # 80006ac0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	7e4080e7          	jalr	2020(ra) # 8000372e <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	e76080e7          	jalr	-394(ra) # 80003dc8 <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	136080e7          	jalr	310(ra) # 80005090 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	c80080e7          	jalr	-896(ra) # 80006be2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	642080e7          	jalr	1602(ra) # 800025ac <userinit>
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
    80001210:	6fa080e7          	jalr	1786(ra) # 80001906 <proc_mapstacks>
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
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	e062                	sd	s8,0(sp)
    80001258:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000125a:	03459793          	slli	a5,a1,0x34
    8000125e:	eb85                	bnez	a5,8000128e <uvmunmap+0x4c>
    80001260:	8b2a                	mv	s6,a0
    80001262:	84ae                	mv	s1,a1
    80001264:	8bb6                	mv	s7,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    80001266:	0632                	slli	a2,a2,0xc
    80001268:	00b60ab3          	add	s5,a2,a1
  {
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126c:	4985                	li	s3,1
      // printf("kfree from uvmunmap\n");
      kfree((void*)pa);
    }
    #ifndef NONE
    struct proc *p = myproc();
    if(p->pid > 2)
    8000126e:	4c09                	li	s8,2
    80001270:	6a05                	lui	s4,0x1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    80001272:	0755ea63          	bltu	a1,s5,800012e6 <uvmunmap+0xa4>
      }
    }
    #endif
    *pte = 0;
  }
}
    80001276:	60a6                	ld	ra,72(sp)
    80001278:	6406                	ld	s0,64(sp)
    8000127a:	74e2                	ld	s1,56(sp)
    8000127c:	7942                	ld	s2,48(sp)
    8000127e:	79a2                	ld	s3,40(sp)
    80001280:	7a02                	ld	s4,32(sp)
    80001282:	6ae2                	ld	s5,24(sp)
    80001284:	6b42                	ld	s6,16(sp)
    80001286:	6ba2                	ld	s7,8(sp)
    80001288:	6c02                	ld	s8,0(sp)
    8000128a:	6161                	addi	sp,sp,80
    8000128c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000128e:	00008517          	auipc	a0,0x8
    80001292:	e5a50513          	addi	a0,a0,-422 # 800090e8 <digits+0xa8>
    80001296:	fffff097          	auipc	ra,0xfffff
    8000129a:	294080e7          	jalr	660(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    8000129e:	00008517          	auipc	a0,0x8
    800012a2:	e6250513          	addi	a0,a0,-414 # 80009100 <digits+0xc0>
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	284080e7          	jalr	644(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012ae:	00008517          	auipc	a0,0x8
    800012b2:	e6250513          	addi	a0,a0,-414 # 80009110 <digits+0xd0>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	274080e7          	jalr	628(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012be:	00008517          	auipc	a0,0x8
    800012c2:	e6a50513          	addi	a0,a0,-406 # 80009128 <digits+0xe8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	264080e7          	jalr	612(ra) # 8000052a <panic>
    struct proc *p = myproc();
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	7be080e7          	jalr	1982(ra) # 80001a8c <myproc>
    if(p->pid > 2)
    800012d6:	591c                	lw	a5,48(a0)
    800012d8:	04fc4463          	blt	s8,a5,80001320 <uvmunmap+0xde>
    *pte = 0;
    800012dc:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    800012e0:	94d2                	add	s1,s1,s4
    800012e2:	f954fae3          	bgeu	s1,s5,80001276 <uvmunmap+0x34>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012e6:	4601                	li	a2,0
    800012e8:	85a6                	mv	a1,s1
    800012ea:	855a                	mv	a0,s6
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	cba080e7          	jalr	-838(ra) # 80000fa6 <walk>
    800012f4:	892a                	mv	s2,a0
    800012f6:	d545                	beqz	a0,8000129e <uvmunmap+0x5c>
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
    800012f8:	6108                	ld	a0,0(a0)
    800012fa:	20157793          	andi	a5,a0,513
    800012fe:	dbc5                	beqz	a5,800012ae <uvmunmap+0x6c>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001300:	3ff57793          	andi	a5,a0,1023
    80001304:	fb378de3          	beq	a5,s3,800012be <uvmunmap+0x7c>
    if(do_free && (*pte & PTE_PG) == 0)
    80001308:	fc0b83e3          	beqz	s7,800012ce <uvmunmap+0x8c>
    8000130c:	20057793          	andi	a5,a0,512
    80001310:	ffdd                	bnez	a5,800012ce <uvmunmap+0x8c>
      uint64 pa = PTE2PA(*pte);
    80001312:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001314:	0532                	slli	a0,a0,0xc
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	6c0080e7          	jalr	1728(ra) # 800009d6 <kfree>
    8000131e:	bf45                	j	800012ce <uvmunmap+0x8c>
    80001320:	014507b3          	add	a5,a0,s4
    80001324:	8f07a603          	lw	a2,-1808(a5)
    80001328:	8f47a683          	lw	a3,-1804(a5)
    8000132c:	fff6079b          	addiw	a5,a2,-1
    80001330:	68850713          	addi	a4,a0,1672
    80001334:	fef6059b          	addiw	a1,a2,-17
    80001338:	9e91                	subw	a3,a3,a2
    8000133a:	a811                	j	8000134e <uvmunmap+0x10c>
        p->num_of_pages--;
    8000133c:	0007881b          	sext.w	a6,a5
        p->num_of_pages_in_phys--;
    80001340:	00f6863b          	addw	a2,a3,a5
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    80001344:	37fd                	addiw	a5,a5,-1
    80001346:	02870713          	addi	a4,a4,40 # fffffffffffff028 <end+0xffffffff7ffba028>
    8000134a:	00b78a63          	beq	a5,a1,8000135e <uvmunmap+0x11c>
        if(p->files_in_physicalmem[i].va == a)
    8000134e:	6310                	ld	a2,0(a4)
    80001350:	fe9616e3          	bne	a2,s1,8000133c <uvmunmap+0xfa>
          p->files_in_physicalmem[i].va = 0;
    80001354:	00073023          	sd	zero,0(a4)
          p->files_in_physicalmem[i].isAvailable = 1;
    80001358:	ff372423          	sw	s3,-24(a4)
    8000135c:	b7c5                	j	8000133c <uvmunmap+0xfa>
    8000135e:	9552                	add	a0,a0,s4
    80001360:	8f052823          	sw	a6,-1808(a0)
    80001364:	8ec52a23          	sw	a2,-1804(a0)
    80001368:	bf95                	j	800012dc <uvmunmap+0x9a>

000000008000136a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000136a:	1101                	addi	sp,sp,-32
    8000136c:	ec06                	sd	ra,24(sp)
    8000136e:	e822                	sd	s0,16(sp)
    80001370:	e426                	sd	s1,8(sp)
    80001372:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001374:	fffff097          	auipc	ra,0xfffff
    80001378:	75e080e7          	jalr	1886(ra) # 80000ad2 <kalloc>
    8000137c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000137e:	c519                	beqz	a0,8000138c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	00000097          	auipc	ra,0x0
    80001388:	93a080e7          	jalr	-1734(ra) # 80000cbe <memset>
  return pagetable;
}
    8000138c:	8526                	mv	a0,s1
    8000138e:	60e2                	ld	ra,24(sp)
    80001390:	6442                	ld	s0,16(sp)
    80001392:	64a2                	ld	s1,8(sp)
    80001394:	6105                	addi	sp,sp,32
    80001396:	8082                	ret

0000000080001398 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001398:	7179                	addi	sp,sp,-48
    8000139a:	f406                	sd	ra,40(sp)
    8000139c:	f022                	sd	s0,32(sp)
    8000139e:	ec26                	sd	s1,24(sp)
    800013a0:	e84a                	sd	s2,16(sp)
    800013a2:	e44e                	sd	s3,8(sp)
    800013a4:	e052                	sd	s4,0(sp)
    800013a6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013a8:	6785                	lui	a5,0x1
    800013aa:	04f67863          	bgeu	a2,a5,800013fa <uvminit+0x62>
    800013ae:	8a2a                	mv	s4,a0
    800013b0:	89ae                	mv	s3,a1
    800013b2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013b4:	fffff097          	auipc	ra,0xfffff
    800013b8:	71e080e7          	jalr	1822(ra) # 80000ad2 <kalloc>
    800013bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013be:	6605                	lui	a2,0x1
    800013c0:	4581                	li	a1,0
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	8fc080e7          	jalr	-1796(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013ca:	4779                	li	a4,30
    800013cc:	86ca                	mv	a3,s2
    800013ce:	6605                	lui	a2,0x1
    800013d0:	4581                	li	a1,0
    800013d2:	8552                	mv	a0,s4
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	cba080e7          	jalr	-838(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    800013dc:	8626                	mv	a2,s1
    800013de:	85ce                	mv	a1,s3
    800013e0:	854a                	mv	a0,s2
    800013e2:	00000097          	auipc	ra,0x0
    800013e6:	938080e7          	jalr	-1736(ra) # 80000d1a <memmove>
}
    800013ea:	70a2                	ld	ra,40(sp)
    800013ec:	7402                	ld	s0,32(sp)
    800013ee:	64e2                	ld	s1,24(sp)
    800013f0:	6942                	ld	s2,16(sp)
    800013f2:	69a2                	ld	s3,8(sp)
    800013f4:	6a02                	ld	s4,0(sp)
    800013f6:	6145                	addi	sp,sp,48
    800013f8:	8082                	ret
    panic("inituvm: more than a page");
    800013fa:	00008517          	auipc	a0,0x8
    800013fe:	d4650513          	addi	a0,a0,-698 # 80009140 <digits+0x100>
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	128080e7          	jalr	296(ra) # 8000052a <panic>

000000008000140a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000140a:	1101                	addi	sp,sp,-32
    8000140c:	ec06                	sd	ra,24(sp)
    8000140e:	e822                	sd	s0,16(sp)
    80001410:	e426                	sd	s1,8(sp)
    80001412:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001414:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001416:	00b67d63          	bgeu	a2,a1,80001430 <uvmdealloc+0x26>
    8000141a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000141c:	6785                	lui	a5,0x1
    8000141e:	17fd                	addi	a5,a5,-1
    80001420:	00f60733          	add	a4,a2,a5
    80001424:	767d                	lui	a2,0xfffff
    80001426:	8f71                	and	a4,a4,a2
    80001428:	97ae                	add	a5,a5,a1
    8000142a:	8ff1                	and	a5,a5,a2
    8000142c:	00f76863          	bltu	a4,a5,8000143c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001430:	8526                	mv	a0,s1
    80001432:	60e2                	ld	ra,24(sp)
    80001434:	6442                	ld	s0,16(sp)
    80001436:	64a2                	ld	s1,8(sp)
    80001438:	6105                	addi	sp,sp,32
    8000143a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000143c:	8f99                	sub	a5,a5,a4
    8000143e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001440:	4685                	li	a3,1
    80001442:	0007861b          	sext.w	a2,a5
    80001446:	85ba                	mv	a1,a4
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	dfa080e7          	jalr	-518(ra) # 80001242 <uvmunmap>
    80001450:	b7c5                	j	80001430 <uvmdealloc+0x26>

0000000080001452 <uvmalloc>:
  if(newsz < oldsz)
    80001452:	12b66c63          	bltu	a2,a1,8000158a <uvmalloc+0x138>
{
    80001456:	7159                	addi	sp,sp,-112
    80001458:	f486                	sd	ra,104(sp)
    8000145a:	f0a2                	sd	s0,96(sp)
    8000145c:	eca6                	sd	s1,88(sp)
    8000145e:	e8ca                	sd	s2,80(sp)
    80001460:	e4ce                	sd	s3,72(sp)
    80001462:	e0d2                	sd	s4,64(sp)
    80001464:	fc56                	sd	s5,56(sp)
    80001466:	f85a                	sd	s6,48(sp)
    80001468:	f45e                	sd	s7,40(sp)
    8000146a:	f062                	sd	s8,32(sp)
    8000146c:	ec66                	sd	s9,24(sp)
    8000146e:	e86a                	sd	s10,16(sp)
    80001470:	e46e                	sd	s11,8(sp)
    80001472:	1880                	addi	s0,sp,112
    80001474:	8aaa                	mv	s5,a0
    80001476:	8bb2                	mv	s7,a2
  oldsz = PGROUNDUP(oldsz);
    80001478:	6b05                	lui	s6,0x1
    8000147a:	1b7d                	addi	s6,s6,-1
    8000147c:	95da                	add	a1,a1,s6
    8000147e:	7b7d                	lui	s6,0xfffff
    80001480:	0165fb33          	and	s6,a1,s6
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001484:	10cb7563          	bgeu	s6,a2,8000158e <uvmalloc+0x13c>
    80001488:	8a5a                	mv	s4,s6
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    8000148a:	6985                	lui	s3,0x1
    8000148c:	4c7d                	li	s8,31
    if (p->pid > 2) {
    8000148e:	4c89                	li	s9,2
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80001490:	4d3d                	li	s10,15
        printf("swapped ti swapfile\n");
    80001492:	00008d97          	auipc	s11,0x8
    80001496:	ce6d8d93          	addi	s11,s11,-794 # 80009178 <digits+0x138>
    8000149a:	a061                	j	80001522 <uvmalloc+0xd0>
      printf("not enough free pages\n");
    8000149c:	00008517          	auipc	a0,0x8
    800014a0:	cc450513          	addi	a0,a0,-828 # 80009160 <digits+0x120>
    800014a4:	fffff097          	auipc	ra,0xfffff
    800014a8:	0d0080e7          	jalr	208(ra) # 80000574 <printf>
      return 0;
    800014ac:	4501                	li	a0,0
}
    800014ae:	70a6                	ld	ra,104(sp)
    800014b0:	7406                	ld	s0,96(sp)
    800014b2:	64e6                	ld	s1,88(sp)
    800014b4:	6946                	ld	s2,80(sp)
    800014b6:	69a6                	ld	s3,72(sp)
    800014b8:	6a06                	ld	s4,64(sp)
    800014ba:	7ae2                	ld	s5,56(sp)
    800014bc:	7b42                	ld	s6,48(sp)
    800014be:	7ba2                	ld	s7,40(sp)
    800014c0:	7c02                	ld	s8,32(sp)
    800014c2:	6ce2                	ld	s9,24(sp)
    800014c4:	6d42                	ld	s10,16(sp)
    800014c6:	6da2                	ld	s11,8(sp)
    800014c8:	6165                	addi	sp,sp,112
    800014ca:	8082                	ret
      uvmdealloc(pagetable, a, oldsz);
    800014cc:	865a                	mv	a2,s6
    800014ce:	85d2                	mv	a1,s4
    800014d0:	8556                	mv	a0,s5
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	f38080e7          	jalr	-200(ra) # 8000140a <uvmdealloc>
      return 0;
    800014da:	4501                	li	a0,0
    800014dc:	bfc9                	j	800014ae <uvmalloc+0x5c>
      kfree(mem);
    800014de:	854a                	mv	a0,s2
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	4f6080e7          	jalr	1270(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014e8:	865a                	mv	a2,s6
    800014ea:	85d2                	mv	a1,s4
    800014ec:	8556                	mv	a0,s5
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	f1c080e7          	jalr	-228(ra) # 8000140a <uvmdealloc>
      return 0;
    800014f6:	4501                	li	a0,0
    800014f8:	bf5d                	j	800014ae <uvmalloc+0x5c>
        swap_to_swapFile(p);
    800014fa:	8526                	mv	a0,s1
    800014fc:	00001097          	auipc	ra,0x1
    80001500:	69e080e7          	jalr	1694(ra) # 80002b9a <swap_to_swapFile>
        printf("swapped ti swapfile\n");
    80001504:	856e                	mv	a0,s11
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	06e080e7          	jalr	110(ra) # 80000574 <printf>
        add_page_to_phys(p, pagetable, a);
    8000150e:	8652                	mv	a2,s4
    80001510:	85d6                	mv	a1,s5
    80001512:	8526                	mv	a0,s1
    80001514:	00001097          	auipc	ra,0x1
    80001518:	11a080e7          	jalr	282(ra) # 8000262e <add_page_to_phys>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000151c:	9a4e                	add	s4,s4,s3
    8000151e:	077a7463          	bgeu	s4,s7,80001586 <uvmalloc+0x134>
    struct proc* p = myproc();
    80001522:	00000097          	auipc	ra,0x0
    80001526:	56a080e7          	jalr	1386(ra) # 80001a8c <myproc>
    8000152a:	84aa                	mv	s1,a0
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    8000152c:	013507b3          	add	a5,a0,s3
    80001530:	8f07a783          	lw	a5,-1808(a5) # 8f0 <_entry-0x7ffff710>
    80001534:	f6fc44e3          	blt	s8,a5,8000149c <uvmalloc+0x4a>
    mem = kalloc();
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	59a080e7          	jalr	1434(ra) # 80000ad2 <kalloc>
    80001540:	892a                	mv	s2,a0
    if(mem == 0){
    80001542:	d549                	beqz	a0,800014cc <uvmalloc+0x7a>
    memset(mem, 0, PGSIZE);
    80001544:	864e                	mv	a2,s3
    80001546:	4581                	li	a1,0
    80001548:	fffff097          	auipc	ra,0xfffff
    8000154c:	776080e7          	jalr	1910(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001550:	4779                	li	a4,30
    80001552:	86ca                	mv	a3,s2
    80001554:	864e                	mv	a2,s3
    80001556:	85d2                	mv	a1,s4
    80001558:	8556                	mv	a0,s5
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	b34080e7          	jalr	-1228(ra) # 8000108e <mappages>
    80001562:	fd35                	bnez	a0,800014de <uvmalloc+0x8c>
    if (p->pid > 2) {
    80001564:	589c                	lw	a5,48(s1)
    80001566:	fafcdbe3          	bge	s9,a5,8000151c <uvmalloc+0xca>
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    8000156a:	013487b3          	add	a5,s1,s3
    8000156e:	8f47a783          	lw	a5,-1804(a5)
    80001572:	f8fd44e3          	blt	s10,a5,800014fa <uvmalloc+0xa8>
        add_page_to_phys(p, pagetable, a); //a= va
    80001576:	8652                	mv	a2,s4
    80001578:	85d6                	mv	a1,s5
    8000157a:	8526                	mv	a0,s1
    8000157c:	00001097          	auipc	ra,0x1
    80001580:	0b2080e7          	jalr	178(ra) # 8000262e <add_page_to_phys>
    80001584:	bf61                	j	8000151c <uvmalloc+0xca>
  return newsz;
    80001586:	855e                	mv	a0,s7
    80001588:	b71d                	j	800014ae <uvmalloc+0x5c>
    return oldsz;
    8000158a:	852e                	mv	a0,a1
}
    8000158c:	8082                	ret
  return newsz;
    8000158e:	8532                	mv	a0,a2
    80001590:	bf39                	j	800014ae <uvmalloc+0x5c>

0000000080001592 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001592:	7179                	addi	sp,sp,-48
    80001594:	f406                	sd	ra,40(sp)
    80001596:	f022                	sd	s0,32(sp)
    80001598:	ec26                	sd	s1,24(sp)
    8000159a:	e84a                	sd	s2,16(sp)
    8000159c:	e44e                	sd	s3,8(sp)
    8000159e:	e052                	sd	s4,0(sp)
    800015a0:	1800                	addi	s0,sp,48
    800015a2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015a4:	84aa                	mv	s1,a0
    800015a6:	6905                	lui	s2,0x1
    800015a8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015aa:	4985                	li	s3,1
    800015ac:	a821                	j	800015c4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015ae:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015b0:	0532                	slli	a0,a0,0xc
    800015b2:	00000097          	auipc	ra,0x0
    800015b6:	fe0080e7          	jalr	-32(ra) # 80001592 <freewalk>
      pagetable[i] = 0;
    800015ba:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015be:	04a1                	addi	s1,s1,8
    800015c0:	03248163          	beq	s1,s2,800015e2 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015c4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c6:	00f57793          	andi	a5,a0,15
    800015ca:	ff3782e3          	beq	a5,s3,800015ae <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015ce:	8905                	andi	a0,a0,1
    800015d0:	d57d                	beqz	a0,800015be <freewalk+0x2c>
      panic("freewalk: leaf");
    800015d2:	00008517          	auipc	a0,0x8
    800015d6:	bbe50513          	addi	a0,a0,-1090 # 80009190 <digits+0x150>
    800015da:	fffff097          	auipc	ra,0xfffff
    800015de:	f50080e7          	jalr	-176(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800015e2:	8552                	mv	a0,s4
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	3f2080e7          	jalr	1010(ra) # 800009d6 <kfree>
}
    800015ec:	70a2                	ld	ra,40(sp)
    800015ee:	7402                	ld	s0,32(sp)
    800015f0:	64e2                	ld	s1,24(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6a02                	ld	s4,0(sp)
    800015f8:	6145                	addi	sp,sp,48
    800015fa:	8082                	ret

00000000800015fc <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015fc:	1101                	addi	sp,sp,-32
    800015fe:	ec06                	sd	ra,24(sp)
    80001600:	e822                	sd	s0,16(sp)
    80001602:	e426                	sd	s1,8(sp)
    80001604:	1000                	addi	s0,sp,32
    80001606:	84aa                	mv	s1,a0
  if(sz > 0)
    80001608:	e999                	bnez	a1,8000161e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000160a:	8526                	mv	a0,s1
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	f86080e7          	jalr	-122(ra) # 80001592 <freewalk>
}
    80001614:	60e2                	ld	ra,24(sp)
    80001616:	6442                	ld	s0,16(sp)
    80001618:	64a2                	ld	s1,8(sp)
    8000161a:	6105                	addi	sp,sp,32
    8000161c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000161e:	6605                	lui	a2,0x1
    80001620:	167d                	addi	a2,a2,-1
    80001622:	962e                	add	a2,a2,a1
    80001624:	4685                	li	a3,1
    80001626:	8231                	srli	a2,a2,0xc
    80001628:	4581                	li	a1,0
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	c18080e7          	jalr	-1000(ra) # 80001242 <uvmunmap>
    80001632:	bfe1                	j	8000160a <uvmfree+0xe>

0000000080001634 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001634:	c679                	beqz	a2,80001702 <uvmcopy+0xce>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	0880                	addi	s0,sp,80
    8000164c:	8b2a                	mv	s6,a0
    8000164e:	8aae                	mv	s5,a1
    80001650:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001652:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001654:	4601                	li	a2,0
    80001656:	85ce                	mv	a1,s3
    80001658:	855a                	mv	a0,s6
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	94c080e7          	jalr	-1716(ra) # 80000fa6 <walk>
    80001662:	c531                	beqz	a0,800016ae <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001664:	6118                	ld	a4,0(a0)
    80001666:	00177793          	andi	a5,a4,1
    8000166a:	cbb1                	beqz	a5,800016be <uvmcopy+0x8a>
    //   *new_pte |= PTE_PG;
    //   *new_pte &= ~PTE_V;
    //   continue;
    // }

    pa = PTE2PA(*pte);
    8000166c:	00a75593          	srli	a1,a4,0xa
    80001670:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001674:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	45a080e7          	jalr	1114(ra) # 80000ad2 <kalloc>
    80001680:	892a                	mv	s2,a0
    80001682:	c939                	beqz	a0,800016d8 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001684:	6605                	lui	a2,0x1
    80001686:	85de                	mv	a1,s7
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	692080e7          	jalr	1682(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001690:	8726                	mv	a4,s1
    80001692:	86ca                	mv	a3,s2
    80001694:	6605                	lui	a2,0x1
    80001696:	85ce                	mv	a1,s3
    80001698:	8556                	mv	a0,s5
    8000169a:	00000097          	auipc	ra,0x0
    8000169e:	9f4080e7          	jalr	-1548(ra) # 8000108e <mappages>
    800016a2:	e515                	bnez	a0,800016ce <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a4:	6785                	lui	a5,0x1
    800016a6:	99be                	add	s3,s3,a5
    800016a8:	fb49e6e3          	bltu	s3,s4,80001654 <uvmcopy+0x20>
    800016ac:	a081                	j	800016ec <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016ae:	00008517          	auipc	a0,0x8
    800016b2:	af250513          	addi	a0,a0,-1294 # 800091a0 <digits+0x160>
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	e74080e7          	jalr	-396(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800016be:	00008517          	auipc	a0,0x8
    800016c2:	b0250513          	addi	a0,a0,-1278 # 800091c0 <digits+0x180>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	e64080e7          	jalr	-412(ra) # 8000052a <panic>
      kfree(mem);
    800016ce:	854a                	mv	a0,s2
    800016d0:	fffff097          	auipc	ra,0xfffff
    800016d4:	306080e7          	jalr	774(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d8:	4685                	li	a3,1
    800016da:	00c9d613          	srli	a2,s3,0xc
    800016de:	4581                	li	a1,0
    800016e0:	8556                	mv	a0,s5
    800016e2:	00000097          	auipc	ra,0x0
    800016e6:	b60080e7          	jalr	-1184(ra) # 80001242 <uvmunmap>
  return -1;
    800016ea:	557d                	li	a0,-1
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret
  return 0;
    80001702:	4501                	li	a0,0
}
    80001704:	8082                	ret

0000000080001706 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001706:	1141                	addi	sp,sp,-16
    80001708:	e406                	sd	ra,8(sp)
    8000170a:	e022                	sd	s0,0(sp)
    8000170c:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000170e:	4601                	li	a2,0
    80001710:	00000097          	auipc	ra,0x0
    80001714:	896080e7          	jalr	-1898(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001718:	c901                	beqz	a0,80001728 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000171a:	611c                	ld	a5,0(a0)
    8000171c:	9bbd                	andi	a5,a5,-17
    8000171e:	e11c                	sd	a5,0(a0)
}
    80001720:	60a2                	ld	ra,8(sp)
    80001722:	6402                	ld	s0,0(sp)
    80001724:	0141                	addi	sp,sp,16
    80001726:	8082                	ret
    panic("uvmclear");
    80001728:	00008517          	auipc	a0,0x8
    8000172c:	ab850513          	addi	a0,a0,-1352 # 800091e0 <digits+0x1a0>
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	dfa080e7          	jalr	-518(ra) # 8000052a <panic>

0000000080001738 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001738:	c6bd                	beqz	a3,800017a6 <copyout+0x6e>
{
    8000173a:	715d                	addi	sp,sp,-80
    8000173c:	e486                	sd	ra,72(sp)
    8000173e:	e0a2                	sd	s0,64(sp)
    80001740:	fc26                	sd	s1,56(sp)
    80001742:	f84a                	sd	s2,48(sp)
    80001744:	f44e                	sd	s3,40(sp)
    80001746:	f052                	sd	s4,32(sp)
    80001748:	ec56                	sd	s5,24(sp)
    8000174a:	e85a                	sd	s6,16(sp)
    8000174c:	e45e                	sd	s7,8(sp)
    8000174e:	e062                	sd	s8,0(sp)
    80001750:	0880                	addi	s0,sp,80
    80001752:	8b2a                	mv	s6,a0
    80001754:	8c2e                	mv	s8,a1
    80001756:	8a32                	mv	s4,a2
    80001758:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000175a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000175c:	6a85                	lui	s5,0x1
    8000175e:	a015                	j	80001782 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001760:	9562                	add	a0,a0,s8
    80001762:	0004861b          	sext.w	a2,s1
    80001766:	85d2                	mv	a1,s4
    80001768:	41250533          	sub	a0,a0,s2
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	5ae080e7          	jalr	1454(ra) # 80000d1a <memmove>

    len -= n;
    80001774:	409989b3          	sub	s3,s3,s1
    src += n;
    80001778:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000177a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177e:	02098263          	beqz	s3,800017a2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001782:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001786:	85ca                	mv	a1,s2
    80001788:	855a                	mv	a0,s6
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	8c2080e7          	jalr	-1854(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001792:	cd01                	beqz	a0,800017aa <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001794:	418904b3          	sub	s1,s2,s8
    80001798:	94d6                	add	s1,s1,s5
    if(n > len)
    8000179a:	fc99f3e3          	bgeu	s3,s1,80001760 <copyout+0x28>
    8000179e:	84ce                	mv	s1,s3
    800017a0:	b7c1                	j	80001760 <copyout+0x28>
  }
  return 0;
    800017a2:	4501                	li	a0,0
    800017a4:	a021                	j	800017ac <copyout+0x74>
    800017a6:	4501                	li	a0,0
}
    800017a8:	8082                	ret
      return -1;
    800017aa:	557d                	li	a0,-1
}
    800017ac:	60a6                	ld	ra,72(sp)
    800017ae:	6406                	ld	s0,64(sp)
    800017b0:	74e2                	ld	s1,56(sp)
    800017b2:	7942                	ld	s2,48(sp)
    800017b4:	79a2                	ld	s3,40(sp)
    800017b6:	7a02                	ld	s4,32(sp)
    800017b8:	6ae2                	ld	s5,24(sp)
    800017ba:	6b42                	ld	s6,16(sp)
    800017bc:	6ba2                	ld	s7,8(sp)
    800017be:	6c02                	ld	s8,0(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret

00000000800017c4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c4:	caa5                	beqz	a3,80001834 <copyin+0x70>
{
    800017c6:	715d                	addi	sp,sp,-80
    800017c8:	e486                	sd	ra,72(sp)
    800017ca:	e0a2                	sd	s0,64(sp)
    800017cc:	fc26                	sd	s1,56(sp)
    800017ce:	f84a                	sd	s2,48(sp)
    800017d0:	f44e                	sd	s3,40(sp)
    800017d2:	f052                	sd	s4,32(sp)
    800017d4:	ec56                	sd	s5,24(sp)
    800017d6:	e85a                	sd	s6,16(sp)
    800017d8:	e45e                	sd	s7,8(sp)
    800017da:	e062                	sd	s8,0(sp)
    800017dc:	0880                	addi	s0,sp,80
    800017de:	8b2a                	mv	s6,a0
    800017e0:	8a2e                	mv	s4,a1
    800017e2:	8c32                	mv	s8,a2
    800017e4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e8:	6a85                	lui	s5,0x1
    800017ea:	a01d                	j	80001810 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017ec:	018505b3          	add	a1,a0,s8
    800017f0:	0004861b          	sext.w	a2,s1
    800017f4:	412585b3          	sub	a1,a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	fffff097          	auipc	ra,0xfffff
    800017fe:	520080e7          	jalr	1312(ra) # 80000d1a <memmove>

    len -= n;
    80001802:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001806:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001808:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000180c:	02098263          	beqz	s3,80001830 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001810:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001814:	85ca                	mv	a1,s2
    80001816:	855a                	mv	a0,s6
    80001818:	00000097          	auipc	ra,0x0
    8000181c:	834080e7          	jalr	-1996(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001820:	cd01                	beqz	a0,80001838 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001822:	418904b3          	sub	s1,s2,s8
    80001826:	94d6                	add	s1,s1,s5
    if(n > len)
    80001828:	fc99f2e3          	bgeu	s3,s1,800017ec <copyin+0x28>
    8000182c:	84ce                	mv	s1,s3
    8000182e:	bf7d                	j	800017ec <copyin+0x28>
  }
  return 0;
    80001830:	4501                	li	a0,0
    80001832:	a021                	j	8000183a <copyin+0x76>
    80001834:	4501                	li	a0,0
}
    80001836:	8082                	ret
      return -1;
    80001838:	557d                	li	a0,-1
}
    8000183a:	60a6                	ld	ra,72(sp)
    8000183c:	6406                	ld	s0,64(sp)
    8000183e:	74e2                	ld	s1,56(sp)
    80001840:	7942                	ld	s2,48(sp)
    80001842:	79a2                	ld	s3,40(sp)
    80001844:	7a02                	ld	s4,32(sp)
    80001846:	6ae2                	ld	s5,24(sp)
    80001848:	6b42                	ld	s6,16(sp)
    8000184a:	6ba2                	ld	s7,8(sp)
    8000184c:	6c02                	ld	s8,0(sp)
    8000184e:	6161                	addi	sp,sp,80
    80001850:	8082                	ret

0000000080001852 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001852:	c6c5                	beqz	a3,800018fa <copyinstr+0xa8>
{
    80001854:	715d                	addi	sp,sp,-80
    80001856:	e486                	sd	ra,72(sp)
    80001858:	e0a2                	sd	s0,64(sp)
    8000185a:	fc26                	sd	s1,56(sp)
    8000185c:	f84a                	sd	s2,48(sp)
    8000185e:	f44e                	sd	s3,40(sp)
    80001860:	f052                	sd	s4,32(sp)
    80001862:	ec56                	sd	s5,24(sp)
    80001864:	e85a                	sd	s6,16(sp)
    80001866:	e45e                	sd	s7,8(sp)
    80001868:	0880                	addi	s0,sp,80
    8000186a:	8a2a                	mv	s4,a0
    8000186c:	8b2e                	mv	s6,a1
    8000186e:	8bb2                	mv	s7,a2
    80001870:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001872:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001874:	6985                	lui	s3,0x1
    80001876:	a035                	j	800018a2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001878:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000187c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187e:	0017b793          	seqz	a5,a5
    80001882:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001886:	60a6                	ld	ra,72(sp)
    80001888:	6406                	ld	s0,64(sp)
    8000188a:	74e2                	ld	s1,56(sp)
    8000188c:	7942                	ld	s2,48(sp)
    8000188e:	79a2                	ld	s3,40(sp)
    80001890:	7a02                	ld	s4,32(sp)
    80001892:	6ae2                	ld	s5,24(sp)
    80001894:	6b42                	ld	s6,16(sp)
    80001896:	6ba2                	ld	s7,8(sp)
    80001898:	6161                	addi	sp,sp,80
    8000189a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000189c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018a0:	c8a9                	beqz	s1,800018f2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018a2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a6:	85ca                	mv	a1,s2
    800018a8:	8552                	mv	a0,s4
    800018aa:	fffff097          	auipc	ra,0xfffff
    800018ae:	7a2080e7          	jalr	1954(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800018b2:	c131                	beqz	a0,800018f6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018b4:	41790833          	sub	a6,s2,s7
    800018b8:	984e                	add	a6,a6,s3
    if(n > max)
    800018ba:	0104f363          	bgeu	s1,a6,800018c0 <copyinstr+0x6e>
    800018be:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018c0:	955e                	add	a0,a0,s7
    800018c2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c6:	fc080be3          	beqz	a6,8000189c <copyinstr+0x4a>
    800018ca:	985a                	add	a6,a6,s6
    800018cc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ce:	41650633          	sub	a2,a0,s6
    800018d2:	14fd                	addi	s1,s1,-1
    800018d4:	9b26                	add	s6,s6,s1
    800018d6:	00f60733          	add	a4,a2,a5
    800018da:	00074703          	lbu	a4,0(a4)
    800018de:	df49                	beqz	a4,80001878 <copyinstr+0x26>
        *dst = *p;
    800018e0:	00e78023          	sb	a4,0(a5)
      --max;
    800018e4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018e8:	0785                	addi	a5,a5,1
    while(n > 0){
    800018ea:	ff0796e3          	bne	a5,a6,800018d6 <copyinstr+0x84>
      dst++;
    800018ee:	8b42                	mv	s6,a6
    800018f0:	b775                	j	8000189c <copyinstr+0x4a>
    800018f2:	4781                	li	a5,0
    800018f4:	b769                	j	8000187e <copyinstr+0x2c>
      return -1;
    800018f6:	557d                	li	a0,-1
    800018f8:	b779                	j	80001886 <copyinstr+0x34>
  int got_null = 0;
    800018fa:	4781                	li	a5,0
  if(got_null){
    800018fc:	0017b793          	seqz	a5,a5
    80001900:	40f00533          	neg	a0,a5
}
    80001904:	8082                	ret

0000000080001906 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001906:	715d                	addi	sp,sp,-80
    80001908:	e486                	sd	ra,72(sp)
    8000190a:	e0a2                	sd	s0,64(sp)
    8000190c:	fc26                	sd	s1,56(sp)
    8000190e:	f84a                	sd	s2,48(sp)
    80001910:	f44e                	sd	s3,40(sp)
    80001912:	f052                	sd	s4,32(sp)
    80001914:	ec56                	sd	s5,24(sp)
    80001916:	e85a                	sd	s6,16(sp)
    80001918:	e45e                	sd	s7,8(sp)
    8000191a:	e062                	sd	s8,0(sp)
    8000191c:	0880                	addi	s0,sp,80
    8000191e:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00011497          	auipc	s1,0x11
    80001924:	db048493          	addi	s1,s1,-592 # 800126d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001928:	8c26                	mv	s8,s1
    8000192a:	00007b97          	auipc	s7,0x7
    8000192e:	6d6b8b93          	addi	s7,s7,1750 # 80009000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000193a:	6a05                	lui	s4,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	900a0b13          	addi	s6,s4,-1792 # 900 <_entry-0x7ffff700>
    80001940:	00035a97          	auipc	s5,0x35
    80001944:	d90a8a93          	addi	s5,s5,-624 # 800366d0 <tickslock>
    char *pa = kalloc();
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	18a080e7          	jalr	394(ra) # 80000ad2 <kalloc>
    80001950:	862a                	mv	a2,a0
    if(pa == 0)
    80001952:	c139                	beqz	a0,80001998 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    80001954:	418485b3          	sub	a1,s1,s8
    80001958:	85a1                	srai	a1,a1,0x8
    8000195a:	000bb783          	ld	a5,0(s7)
    8000195e:	02f585b3          	mul	a1,a1,a5
    80001962:	2585                	addiw	a1,a1,1
    80001964:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001968:	4719                	li	a4,6
    8000196a:	86d2                	mv	a3,s4
    8000196c:	40b905b3          	sub	a1,s2,a1
    80001970:	854e                	mv	a0,s3
    80001972:	fffff097          	auipc	ra,0xfffff
    80001976:	7aa080e7          	jalr	1962(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197a:	94da                	add	s1,s1,s6
    8000197c:	fd5496e3          	bne	s1,s5,80001948 <proc_mapstacks+0x42>
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
    80001992:	6c02                	ld	s8,0(sp)
    80001994:	6161                	addi	sp,sp,80
    80001996:	8082                	ret
      panic("kalloc");
    80001998:	00008517          	auipc	a0,0x8
    8000199c:	85850513          	addi	a0,a0,-1960 # 800091f0 <digits+0x1b0>
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	b8a080e7          	jalr	-1142(ra) # 8000052a <panic>

00000000800019a8 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800019a8:	715d                	addi	sp,sp,-80
    800019aa:	e486                	sd	ra,72(sp)
    800019ac:	e0a2                	sd	s0,64(sp)
    800019ae:	fc26                	sd	s1,56(sp)
    800019b0:	f84a                	sd	s2,48(sp)
    800019b2:	f44e                	sd	s3,40(sp)
    800019b4:	f052                	sd	s4,32(sp)
    800019b6:	ec56                	sd	s5,24(sp)
    800019b8:	e85a                	sd	s6,16(sp)
    800019ba:	e45e                	sd	s7,8(sp)
    800019bc:	0880                	addi	s0,sp,80
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800019be:	00008597          	auipc	a1,0x8
    800019c2:	83a58593          	addi	a1,a1,-1990 # 800091f8 <digits+0x1b8>
    800019c6:	00011517          	auipc	a0,0x11
    800019ca:	8da50513          	addi	a0,a0,-1830 # 800122a0 <pid_lock>
    800019ce:	fffff097          	auipc	ra,0xfffff
    800019d2:	164080e7          	jalr	356(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019d6:	00008597          	auipc	a1,0x8
    800019da:	82a58593          	addi	a1,a1,-2006 # 80009200 <digits+0x1c0>
    800019de:	00011517          	auipc	a0,0x11
    800019e2:	8da50513          	addi	a0,a0,-1830 # 800122b8 <wait_lock>
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	14c080e7          	jalr	332(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ee:	00011497          	auipc	s1,0x11
    800019f2:	ce248493          	addi	s1,s1,-798 # 800126d0 <proc>
      initlock(&p->lock, "proc");
    800019f6:	00008b97          	auipc	s7,0x8
    800019fa:	81ab8b93          	addi	s7,s7,-2022 # 80009210 <digits+0x1d0>
      p->kstack = KSTACK((int) (p - proc));
    800019fe:	8b26                	mv	s6,s1
    80001a00:	00007a97          	auipc	s5,0x7
    80001a04:	600a8a93          	addi	s5,s5,1536 # 80009000 <etext>
    80001a08:	04000937          	lui	s2,0x4000
    80001a0c:	197d                	addi	s2,s2,-1
    80001a0e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a10:	6985                	lui	s3,0x1
    80001a12:	90098993          	addi	s3,s3,-1792 # 900 <_entry-0x7ffff700>
    80001a16:	00035a17          	auipc	s4,0x35
    80001a1a:	cbaa0a13          	addi	s4,s4,-838 # 800366d0 <tickslock>
      initlock(&p->lock, "proc");
    80001a1e:	85de                	mv	a1,s7
    80001a20:	8526                	mv	a0,s1
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	110080e7          	jalr	272(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001a2a:	416487b3          	sub	a5,s1,s6
    80001a2e:	87a1                	srai	a5,a5,0x8
    80001a30:	000ab703          	ld	a4,0(s5)
    80001a34:	02e787b3          	mul	a5,a5,a4
    80001a38:	2785                	addiw	a5,a5,1
    80001a3a:	00d7979b          	slliw	a5,a5,0xd
    80001a3e:	40f907b3          	sub	a5,s2,a5
    80001a42:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a44:	94ce                	add	s1,s1,s3
    80001a46:	fd449ce3          	bne	s1,s4,80001a1e <procinit+0x76>
  }
}
    80001a4a:	60a6                	ld	ra,72(sp)
    80001a4c:	6406                	ld	s0,64(sp)
    80001a4e:	74e2                	ld	s1,56(sp)
    80001a50:	7942                	ld	s2,48(sp)
    80001a52:	79a2                	ld	s3,40(sp)
    80001a54:	7a02                	ld	s4,32(sp)
    80001a56:	6ae2                	ld	s5,24(sp)
    80001a58:	6b42                	ld	s6,16(sp)
    80001a5a:	6ba2                	ld	s7,8(sp)
    80001a5c:	6161                	addi	sp,sp,80
    80001a5e:	8082                	ret

0000000080001a60 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a60:	1141                	addi	sp,sp,-16
    80001a62:	e422                	sd	s0,8(sp)
    80001a64:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a66:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a68:	2501                	sext.w	a0,a0
    80001a6a:	6422                	ld	s0,8(sp)
    80001a6c:	0141                	addi	sp,sp,16
    80001a6e:	8082                	ret

0000000080001a70 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a70:	1141                	addi	sp,sp,-16
    80001a72:	e422                	sd	s0,8(sp)
    80001a74:	0800                	addi	s0,sp,16
    80001a76:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a78:	2781                	sext.w	a5,a5
    80001a7a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a7c:	00011517          	auipc	a0,0x11
    80001a80:	85450513          	addi	a0,a0,-1964 # 800122d0 <cpus>
    80001a84:	953e                	add	a0,a0,a5
    80001a86:	6422                	ld	s0,8(sp)
    80001a88:	0141                	addi	sp,sp,16
    80001a8a:	8082                	ret

0000000080001a8c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a8c:	1101                	addi	sp,sp,-32
    80001a8e:	ec06                	sd	ra,24(sp)
    80001a90:	e822                	sd	s0,16(sp)
    80001a92:	e426                	sd	s1,8(sp)
    80001a94:	1000                	addi	s0,sp,32
  push_off();
    80001a96:	fffff097          	auipc	ra,0xfffff
    80001a9a:	0e0080e7          	jalr	224(ra) # 80000b76 <push_off>
    80001a9e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001aa0:	2781                	sext.w	a5,a5
    80001aa2:	079e                	slli	a5,a5,0x7
    80001aa4:	00010717          	auipc	a4,0x10
    80001aa8:	7fc70713          	addi	a4,a4,2044 # 800122a0 <pid_lock>
    80001aac:	97ba                	add	a5,a5,a4
    80001aae:	7b84                	ld	s1,48(a5)
  pop_off();
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	166080e7          	jalr	358(ra) # 80000c16 <pop_off>
  return p;
}
    80001ab8:	8526                	mv	a0,s1
    80001aba:	60e2                	ld	ra,24(sp)
    80001abc:	6442                	ld	s0,16(sp)
    80001abe:	64a2                	ld	s1,8(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret

0000000080001ac4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ac4:	1141                	addi	sp,sp,-16
    80001ac6:	e406                	sd	ra,8(sp)
    80001ac8:	e022                	sd	s0,0(sp)
    80001aca:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001acc:	00000097          	auipc	ra,0x0
    80001ad0:	fc0080e7          	jalr	-64(ra) # 80001a8c <myproc>
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	1a2080e7          	jalr	418(ra) # 80000c76 <release>

  if (first) {
    80001adc:	00008797          	auipc	a5,0x8
    80001ae0:	0c47a783          	lw	a5,196(a5) # 80009ba0 <first.1>
    80001ae4:	eb89                	bnez	a5,80001af6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ae6:	00001097          	auipc	ra,0x1
    80001aea:	4da080e7          	jalr	1242(ra) # 80002fc0 <usertrapret>
}
    80001aee:	60a2                	ld	ra,8(sp)
    80001af0:	6402                	ld	s0,0(sp)
    80001af2:	0141                	addi	sp,sp,16
    80001af4:	8082                	ret
    first = 0;
    80001af6:	00008797          	auipc	a5,0x8
    80001afa:	0a07a523          	sw	zero,170(a5) # 80009ba0 <first.1>
    fsinit(ROOTDEV);
    80001afe:	4505                	li	a0,1
    80001b00:	00002097          	auipc	ra,0x2
    80001b04:	248080e7          	jalr	584(ra) # 80003d48 <fsinit>
    80001b08:	bff9                	j	80001ae6 <forkret+0x22>

0000000080001b0a <allocpid>:
allocpid() {
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	e04a                	sd	s2,0(sp)
    80001b14:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b16:	00010917          	auipc	s2,0x10
    80001b1a:	78a90913          	addi	s2,s2,1930 # 800122a0 <pid_lock>
    80001b1e:	854a                	mv	a0,s2
    80001b20:	fffff097          	auipc	ra,0xfffff
    80001b24:	0a2080e7          	jalr	162(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001b28:	00008797          	auipc	a5,0x8
    80001b2c:	07c78793          	addi	a5,a5,124 # 80009ba4 <nextpid>
    80001b30:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b32:	0014871b          	addiw	a4,s1,1
    80001b36:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b38:	854a                	mv	a0,s2
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	13c080e7          	jalr	316(ra) # 80000c76 <release>
}
    80001b42:	8526                	mv	a0,s1
    80001b44:	60e2                	ld	ra,24(sp)
    80001b46:	6442                	ld	s0,16(sp)
    80001b48:	64a2                	ld	s1,8(sp)
    80001b4a:	6902                	ld	s2,0(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret

0000000080001b50 <proc_pagetable>:
{
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	e04a                	sd	s2,0(sp)
    80001b5a:	1000                	addi	s0,sp,32
    80001b5c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b5e:	00000097          	auipc	ra,0x0
    80001b62:	80c080e7          	jalr	-2036(ra) # 8000136a <uvmcreate>
    80001b66:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b68:	c121                	beqz	a0,80001ba8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b6a:	4729                	li	a4,10
    80001b6c:	00006697          	auipc	a3,0x6
    80001b70:	49468693          	addi	a3,a3,1172 # 80008000 <_trampoline>
    80001b74:	6605                	lui	a2,0x1
    80001b76:	040005b7          	lui	a1,0x4000
    80001b7a:	15fd                	addi	a1,a1,-1
    80001b7c:	05b2                	slli	a1,a1,0xc
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	510080e7          	jalr	1296(ra) # 8000108e <mappages>
    80001b86:	02054863          	bltz	a0,80001bb6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b8a:	4719                	li	a4,6
    80001b8c:	05893683          	ld	a3,88(s2)
    80001b90:	6605                	lui	a2,0x1
    80001b92:	020005b7          	lui	a1,0x2000
    80001b96:	15fd                	addi	a1,a1,-1
    80001b98:	05b6                	slli	a1,a1,0xd
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	fffff097          	auipc	ra,0xfffff
    80001ba0:	4f2080e7          	jalr	1266(ra) # 8000108e <mappages>
    80001ba4:	02054163          	bltz	a0,80001bc6 <proc_pagetable+0x76>
}
    80001ba8:	8526                	mv	a0,s1
    80001baa:	60e2                	ld	ra,24(sp)
    80001bac:	6442                	ld	s0,16(sp)
    80001bae:	64a2                	ld	s1,8(sp)
    80001bb0:	6902                	ld	s2,0(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret
    uvmfree(pagetable, 0);
    80001bb6:	4581                	li	a1,0
    80001bb8:	8526                	mv	a0,s1
    80001bba:	00000097          	auipc	ra,0x0
    80001bbe:	a42080e7          	jalr	-1470(ra) # 800015fc <uvmfree>
    return 0;
    80001bc2:	4481                	li	s1,0
    80001bc4:	b7d5                	j	80001ba8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bc6:	4681                	li	a3,0
    80001bc8:	4605                	li	a2,1
    80001bca:	040005b7          	lui	a1,0x4000
    80001bce:	15fd                	addi	a1,a1,-1
    80001bd0:	05b2                	slli	a1,a1,0xc
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	66e080e7          	jalr	1646(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bdc:	4581                	li	a1,0
    80001bde:	8526                	mv	a0,s1
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	a1c080e7          	jalr	-1508(ra) # 800015fc <uvmfree>
    return 0;
    80001be8:	4481                	li	s1,0
    80001bea:	bf7d                	j	80001ba8 <proc_pagetable+0x58>

0000000080001bec <proc_freepagetable>:
{
    80001bec:	1101                	addi	sp,sp,-32
    80001bee:	ec06                	sd	ra,24(sp)
    80001bf0:	e822                	sd	s0,16(sp)
    80001bf2:	e426                	sd	s1,8(sp)
    80001bf4:	e04a                	sd	s2,0(sp)
    80001bf6:	1000                	addi	s0,sp,32
    80001bf8:	84aa                	mv	s1,a0
    80001bfa:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bfc:	4681                	li	a3,0
    80001bfe:	4605                	li	a2,1
    80001c00:	040005b7          	lui	a1,0x4000
    80001c04:	15fd                	addi	a1,a1,-1
    80001c06:	05b2                	slli	a1,a1,0xc
    80001c08:	fffff097          	auipc	ra,0xfffff
    80001c0c:	63a080e7          	jalr	1594(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c10:	4681                	li	a3,0
    80001c12:	4605                	li	a2,1
    80001c14:	020005b7          	lui	a1,0x2000
    80001c18:	15fd                	addi	a1,a1,-1
    80001c1a:	05b6                	slli	a1,a1,0xd
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	624080e7          	jalr	1572(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c26:	85ca                	mv	a1,s2
    80001c28:	8526                	mv	a0,s1
    80001c2a:	00000097          	auipc	ra,0x0
    80001c2e:	9d2080e7          	jalr	-1582(ra) # 800015fc <uvmfree>
}
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6902                	ld	s2,0(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <growproc>:
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	e04a                	sd	s2,0(sp)
    80001c48:	1000                	addi	s0,sp,32
    80001c4a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	e40080e7          	jalr	-448(ra) # 80001a8c <myproc>
    80001c54:	892a                	mv	s2,a0
  sz = p->sz;
    80001c56:	652c                	ld	a1,72(a0)
    80001c58:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001c5c:	00904f63          	bgtz	s1,80001c7a <growproc+0x3c>
  } else if(n < 0){
    80001c60:	0204cc63          	bltz	s1,80001c98 <growproc+0x5a>
  p->sz = sz;
    80001c64:	1602                	slli	a2,a2,0x20
    80001c66:	9201                	srli	a2,a2,0x20
    80001c68:	04c93423          	sd	a2,72(s2)
  return 0;
    80001c6c:	4501                	li	a0,0
}
    80001c6e:	60e2                	ld	ra,24(sp)
    80001c70:	6442                	ld	s0,16(sp)
    80001c72:	64a2                	ld	s1,8(sp)
    80001c74:	6902                	ld	s2,0(sp)
    80001c76:	6105                	addi	sp,sp,32
    80001c78:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001c7a:	9e25                	addw	a2,a2,s1
    80001c7c:	1602                	slli	a2,a2,0x20
    80001c7e:	9201                	srli	a2,a2,0x20
    80001c80:	1582                	slli	a1,a1,0x20
    80001c82:	9181                	srli	a1,a1,0x20
    80001c84:	6928                	ld	a0,80(a0)
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	7cc080e7          	jalr	1996(ra) # 80001452 <uvmalloc>
    80001c8e:	0005061b          	sext.w	a2,a0
    80001c92:	fa69                	bnez	a2,80001c64 <growproc+0x26>
      return -1;
    80001c94:	557d                	li	a0,-1
    80001c96:	bfe1                	j	80001c6e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c98:	9e25                	addw	a2,a2,s1
    80001c9a:	1602                	slli	a2,a2,0x20
    80001c9c:	9201                	srli	a2,a2,0x20
    80001c9e:	1582                	slli	a1,a1,0x20
    80001ca0:	9181                	srli	a1,a1,0x20
    80001ca2:	6928                	ld	a0,80(a0)
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	766080e7          	jalr	1894(ra) # 8000140a <uvmdealloc>
    80001cac:	0005061b          	sext.w	a2,a0
    80001cb0:	bf55                	j	80001c64 <growproc+0x26>

0000000080001cb2 <scheduler>:
{
    80001cb2:	715d                	addi	sp,sp,-80
    80001cb4:	e486                	sd	ra,72(sp)
    80001cb6:	e0a2                	sd	s0,64(sp)
    80001cb8:	fc26                	sd	s1,56(sp)
    80001cba:	f84a                	sd	s2,48(sp)
    80001cbc:	f44e                	sd	s3,40(sp)
    80001cbe:	f052                	sd	s4,32(sp)
    80001cc0:	ec56                	sd	s5,24(sp)
    80001cc2:	e85a                	sd	s6,16(sp)
    80001cc4:	e45e                	sd	s7,8(sp)
    80001cc6:	0880                	addi	s0,sp,80
    80001cc8:	8792                	mv	a5,tp
  int id = r_tp();
    80001cca:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ccc:	00779b13          	slli	s6,a5,0x7
    80001cd0:	00010717          	auipc	a4,0x10
    80001cd4:	5d070713          	addi	a4,a4,1488 # 800122a0 <pid_lock>
    80001cd8:	975a                	add	a4,a4,s6
    80001cda:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001cde:	00010717          	auipc	a4,0x10
    80001ce2:	5fa70713          	addi	a4,a4,1530 # 800122d8 <cpus+0x8>
    80001ce6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ce8:	4b91                	li	s7,4
        c->proc = p;
    80001cea:	079e                	slli	a5,a5,0x7
    80001cec:	00010a97          	auipc	s5,0x10
    80001cf0:	5b4a8a93          	addi	s5,s5,1460 # 800122a0 <pid_lock>
    80001cf4:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cf6:	6985                	lui	s3,0x1
    80001cf8:	90098993          	addi	s3,s3,-1792 # 900 <_entry-0x7ffff700>
    80001cfc:	00035a17          	auipc	s4,0x35
    80001d00:	9d4a0a13          	addi	s4,s4,-1580 # 800366d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d08:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d0c:	10079073          	csrw	sstatus,a5
    80001d10:	00011497          	auipc	s1,0x11
    80001d14:	9c048493          	addi	s1,s1,-1600 # 800126d0 <proc>
      if(p->state == RUNNABLE) {
    80001d18:	490d                	li	s2,3
    80001d1a:	a809                	j	80001d2c <scheduler+0x7a>
      release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	f58080e7          	jalr	-168(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d26:	94ce                	add	s1,s1,s3
    80001d28:	fd448ee3          	beq	s1,s4,80001d04 <scheduler+0x52>
      acquire(&p->lock);
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	e94080e7          	jalr	-364(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001d36:	4c9c                	lw	a5,24(s1)
    80001d38:	ff2792e3          	bne	a5,s2,80001d1c <scheduler+0x6a>
        p->state = RUNNING;
    80001d3c:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001d40:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001d44:	06048593          	addi	a1,s1,96
    80001d48:	855a                	mv	a0,s6
    80001d4a:	00001097          	auipc	ra,0x1
    80001d4e:	1cc080e7          	jalr	460(ra) # 80002f16 <swtch>
        c->proc = 0;
    80001d52:	020ab823          	sd	zero,48(s5)
    80001d56:	b7d9                	j	80001d1c <scheduler+0x6a>

0000000080001d58 <sched>:
{
    80001d58:	7179                	addi	sp,sp,-48
    80001d5a:	f406                	sd	ra,40(sp)
    80001d5c:	f022                	sd	s0,32(sp)
    80001d5e:	ec26                	sd	s1,24(sp)
    80001d60:	e84a                	sd	s2,16(sp)
    80001d62:	e44e                	sd	s3,8(sp)
    80001d64:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	d26080e7          	jalr	-730(ra) # 80001a8c <myproc>
    80001d6e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	dd8080e7          	jalr	-552(ra) # 80000b48 <holding>
    80001d78:	c93d                	beqz	a0,80001dee <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d7a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d7c:	2781                	sext.w	a5,a5
    80001d7e:	079e                	slli	a5,a5,0x7
    80001d80:	00010717          	auipc	a4,0x10
    80001d84:	52070713          	addi	a4,a4,1312 # 800122a0 <pid_lock>
    80001d88:	97ba                	add	a5,a5,a4
    80001d8a:	0a87a703          	lw	a4,168(a5)
    80001d8e:	4785                	li	a5,1
    80001d90:	06f71763          	bne	a4,a5,80001dfe <sched+0xa6>
  if(p->state == RUNNING)
    80001d94:	4c98                	lw	a4,24(s1)
    80001d96:	4791                	li	a5,4
    80001d98:	06f70b63          	beq	a4,a5,80001e0e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001da0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001da2:	efb5                	bnez	a5,80001e1e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001da4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001da6:	00010917          	auipc	s2,0x10
    80001daa:	4fa90913          	addi	s2,s2,1274 # 800122a0 <pid_lock>
    80001dae:	2781                	sext.w	a5,a5
    80001db0:	079e                	slli	a5,a5,0x7
    80001db2:	97ca                	add	a5,a5,s2
    80001db4:	0ac7a983          	lw	s3,172(a5)
    80001db8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001dba:	2781                	sext.w	a5,a5
    80001dbc:	079e                	slli	a5,a5,0x7
    80001dbe:	00010597          	auipc	a1,0x10
    80001dc2:	51a58593          	addi	a1,a1,1306 # 800122d8 <cpus+0x8>
    80001dc6:	95be                	add	a1,a1,a5
    80001dc8:	06048513          	addi	a0,s1,96
    80001dcc:	00001097          	auipc	ra,0x1
    80001dd0:	14a080e7          	jalr	330(ra) # 80002f16 <swtch>
    80001dd4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001dd6:	2781                	sext.w	a5,a5
    80001dd8:	079e                	slli	a5,a5,0x7
    80001dda:	97ca                	add	a5,a5,s2
    80001ddc:	0b37a623          	sw	s3,172(a5)
}
    80001de0:	70a2                	ld	ra,40(sp)
    80001de2:	7402                	ld	s0,32(sp)
    80001de4:	64e2                	ld	s1,24(sp)
    80001de6:	6942                	ld	s2,16(sp)
    80001de8:	69a2                	ld	s3,8(sp)
    80001dea:	6145                	addi	sp,sp,48
    80001dec:	8082                	ret
    panic("sched p->lock");
    80001dee:	00007517          	auipc	a0,0x7
    80001df2:	42a50513          	addi	a0,a0,1066 # 80009218 <digits+0x1d8>
    80001df6:	ffffe097          	auipc	ra,0xffffe
    80001dfa:	734080e7          	jalr	1844(ra) # 8000052a <panic>
    panic("sched locks");
    80001dfe:	00007517          	auipc	a0,0x7
    80001e02:	42a50513          	addi	a0,a0,1066 # 80009228 <digits+0x1e8>
    80001e06:	ffffe097          	auipc	ra,0xffffe
    80001e0a:	724080e7          	jalr	1828(ra) # 8000052a <panic>
    panic("sched running");
    80001e0e:	00007517          	auipc	a0,0x7
    80001e12:	42a50513          	addi	a0,a0,1066 # 80009238 <digits+0x1f8>
    80001e16:	ffffe097          	auipc	ra,0xffffe
    80001e1a:	714080e7          	jalr	1812(ra) # 8000052a <panic>
    panic("sched interruptible");
    80001e1e:	00007517          	auipc	a0,0x7
    80001e22:	42a50513          	addi	a0,a0,1066 # 80009248 <digits+0x208>
    80001e26:	ffffe097          	auipc	ra,0xffffe
    80001e2a:	704080e7          	jalr	1796(ra) # 8000052a <panic>

0000000080001e2e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001e2e:	7179                	addi	sp,sp,-48
    80001e30:	f406                	sd	ra,40(sp)
    80001e32:	f022                	sd	s0,32(sp)
    80001e34:	ec26                	sd	s1,24(sp)
    80001e36:	e84a                	sd	s2,16(sp)
    80001e38:	e44e                	sd	s3,8(sp)
    80001e3a:	1800                	addi	s0,sp,48
    80001e3c:	89aa                	mv	s3,a0
    80001e3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e40:	00000097          	auipc	ra,0x0
    80001e44:	c4c080e7          	jalr	-948(ra) # 80001a8c <myproc>
    80001e48:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	d78080e7          	jalr	-648(ra) # 80000bc2 <acquire>
  release(lk);
    80001e52:	854a                	mv	a0,s2
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	e22080e7          	jalr	-478(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80001e5c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e60:	4789                	li	a5,2
    80001e62:	cc9c                	sw	a5,24(s1)

  sched();
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	ef4080e7          	jalr	-268(ra) # 80001d58 <sched>

  // Tidy up.
  p->chan = 0;
    80001e6c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	e04080e7          	jalr	-508(ra) # 80000c76 <release>
  acquire(lk);
    80001e7a:	854a                	mv	a0,s2
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	d46080e7          	jalr	-698(ra) # 80000bc2 <acquire>
}
    80001e84:	70a2                	ld	ra,40(sp)
    80001e86:	7402                	ld	s0,32(sp)
    80001e88:	64e2                	ld	s1,24(sp)
    80001e8a:	6942                	ld	s2,16(sp)
    80001e8c:	69a2                	ld	s3,8(sp)
    80001e8e:	6145                	addi	sp,sp,48
    80001e90:	8082                	ret

0000000080001e92 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001e92:	7139                	addi	sp,sp,-64
    80001e94:	fc06                	sd	ra,56(sp)
    80001e96:	f822                	sd	s0,48(sp)
    80001e98:	f426                	sd	s1,40(sp)
    80001e9a:	f04a                	sd	s2,32(sp)
    80001e9c:	ec4e                	sd	s3,24(sp)
    80001e9e:	e852                	sd	s4,16(sp)
    80001ea0:	e456                	sd	s5,8(sp)
    80001ea2:	e05a                	sd	s6,0(sp)
    80001ea4:	0080                	addi	s0,sp,64
    80001ea6:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea8:	00011497          	auipc	s1,0x11
    80001eac:	82848493          	addi	s1,s1,-2008 # 800126d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001eb0:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001eb2:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eb4:	6905                	lui	s2,0x1
    80001eb6:	90090913          	addi	s2,s2,-1792 # 900 <_entry-0x7ffff700>
    80001eba:	00035997          	auipc	s3,0x35
    80001ebe:	81698993          	addi	s3,s3,-2026 # 800366d0 <tickslock>
    80001ec2:	a809                	j	80001ed4 <wakeup+0x42>
      }
      release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	db0080e7          	jalr	-592(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ece:	94ca                	add	s1,s1,s2
    80001ed0:	03348663          	beq	s1,s3,80001efc <wakeup+0x6a>
    if(p != myproc()){
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	bb8080e7          	jalr	-1096(ra) # 80001a8c <myproc>
    80001edc:	fea489e3          	beq	s1,a0,80001ece <wakeup+0x3c>
      acquire(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	ce0080e7          	jalr	-800(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001eea:	4c9c                	lw	a5,24(s1)
    80001eec:	fd479ce3          	bne	a5,s4,80001ec4 <wakeup+0x32>
    80001ef0:	709c                	ld	a5,32(s1)
    80001ef2:	fd5799e3          	bne	a5,s5,80001ec4 <wakeup+0x32>
        p->state = RUNNABLE;
    80001ef6:	0164ac23          	sw	s6,24(s1)
    80001efa:	b7e9                	j	80001ec4 <wakeup+0x32>
    }
  }
}
    80001efc:	70e2                	ld	ra,56(sp)
    80001efe:	7442                	ld	s0,48(sp)
    80001f00:	74a2                	ld	s1,40(sp)
    80001f02:	7902                	ld	s2,32(sp)
    80001f04:	69e2                	ld	s3,24(sp)
    80001f06:	6a42                	ld	s4,16(sp)
    80001f08:	6aa2                	ld	s5,8(sp)
    80001f0a:	6b02                	ld	s6,0(sp)
    80001f0c:	6121                	addi	sp,sp,64
    80001f0e:	8082                	ret

0000000080001f10 <reparent>:
{
    80001f10:	7139                	addi	sp,sp,-64
    80001f12:	fc06                	sd	ra,56(sp)
    80001f14:	f822                	sd	s0,48(sp)
    80001f16:	f426                	sd	s1,40(sp)
    80001f18:	f04a                	sd	s2,32(sp)
    80001f1a:	ec4e                	sd	s3,24(sp)
    80001f1c:	e852                	sd	s4,16(sp)
    80001f1e:	e456                	sd	s5,8(sp)
    80001f20:	0080                	addi	s0,sp,64
    80001f22:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f24:	00010497          	auipc	s1,0x10
    80001f28:	7ac48493          	addi	s1,s1,1964 # 800126d0 <proc>
      pp->parent = initproc;
    80001f2c:	00008a97          	auipc	s5,0x8
    80001f30:	104a8a93          	addi	s5,s5,260 # 8000a030 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f34:	6905                	lui	s2,0x1
    80001f36:	90090913          	addi	s2,s2,-1792 # 900 <_entry-0x7ffff700>
    80001f3a:	00034a17          	auipc	s4,0x34
    80001f3e:	796a0a13          	addi	s4,s4,1942 # 800366d0 <tickslock>
    80001f42:	a021                	j	80001f4a <reparent+0x3a>
    80001f44:	94ca                	add	s1,s1,s2
    80001f46:	01448d63          	beq	s1,s4,80001f60 <reparent+0x50>
    if(pp->parent == p){
    80001f4a:	7c9c                	ld	a5,56(s1)
    80001f4c:	ff379ce3          	bne	a5,s3,80001f44 <reparent+0x34>
      pp->parent = initproc;
    80001f50:	000ab503          	ld	a0,0(s5)
    80001f54:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	f3c080e7          	jalr	-196(ra) # 80001e92 <wakeup>
    80001f5e:	b7dd                	j	80001f44 <reparent+0x34>
}
    80001f60:	70e2                	ld	ra,56(sp)
    80001f62:	7442                	ld	s0,48(sp)
    80001f64:	74a2                	ld	s1,40(sp)
    80001f66:	7902                	ld	s2,32(sp)
    80001f68:	69e2                	ld	s3,24(sp)
    80001f6a:	6a42                	ld	s4,16(sp)
    80001f6c:	6aa2                	ld	s5,8(sp)
    80001f6e:	6121                	addi	sp,sp,64
    80001f70:	8082                	ret

0000000080001f72 <exit>:
{
    80001f72:	7179                	addi	sp,sp,-48
    80001f74:	f406                	sd	ra,40(sp)
    80001f76:	f022                	sd	s0,32(sp)
    80001f78:	ec26                	sd	s1,24(sp)
    80001f7a:	e84a                	sd	s2,16(sp)
    80001f7c:	e44e                	sd	s3,8(sp)
    80001f7e:	e052                	sd	s4,0(sp)
    80001f80:	1800                	addi	s0,sp,48
    80001f82:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f84:	00000097          	auipc	ra,0x0
    80001f88:	b08080e7          	jalr	-1272(ra) # 80001a8c <myproc>
    80001f8c:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f8e:	00008797          	auipc	a5,0x8
    80001f92:	0a27b783          	ld	a5,162(a5) # 8000a030 <initproc>
    80001f96:	0d050493          	addi	s1,a0,208
    80001f9a:	15050913          	addi	s2,a0,336
    80001f9e:	02a79363          	bne	a5,a0,80001fc4 <exit+0x52>
    panic("init exiting");
    80001fa2:	00007517          	auipc	a0,0x7
    80001fa6:	2be50513          	addi	a0,a0,702 # 80009260 <digits+0x220>
    80001faa:	ffffe097          	auipc	ra,0xffffe
    80001fae:	580080e7          	jalr	1408(ra) # 8000052a <panic>
      fileclose(f);
    80001fb2:	00003097          	auipc	ra,0x3
    80001fb6:	1c2080e7          	jalr	450(ra) # 80005174 <fileclose>
      p->ofile[fd] = 0;
    80001fba:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001fbe:	04a1                	addi	s1,s1,8
    80001fc0:	01248563          	beq	s1,s2,80001fca <exit+0x58>
    if(p->ofile[fd]){
    80001fc4:	6088                	ld	a0,0(s1)
    80001fc6:	f575                	bnez	a0,80001fb2 <exit+0x40>
    80001fc8:	bfdd                	j	80001fbe <exit+0x4c>
  if (p->pid > 2) {
    80001fca:	0309a703          	lw	a4,48(s3)
    80001fce:	4789                	li	a5,2
    80001fd0:	08e7c163          	blt	a5,a4,80002052 <exit+0xe0>
  begin_op();
    80001fd4:	00003097          	auipc	ra,0x3
    80001fd8:	cd4080e7          	jalr	-812(ra) # 80004ca8 <begin_op>
  iput(p->cwd);
    80001fdc:	1509b503          	ld	a0,336(s3)
    80001fe0:	00002097          	auipc	ra,0x2
    80001fe4:	19a080e7          	jalr	410(ra) # 8000417a <iput>
  end_op();
    80001fe8:	00003097          	auipc	ra,0x3
    80001fec:	d40080e7          	jalr	-704(ra) # 80004d28 <end_op>
  p->cwd = 0;
    80001ff0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001ff4:	00010497          	auipc	s1,0x10
    80001ff8:	2c448493          	addi	s1,s1,708 # 800122b8 <wait_lock>
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	bc4080e7          	jalr	-1084(ra) # 80000bc2 <acquire>
  reparent(p);
    80002006:	854e                	mv	a0,s3
    80002008:	00000097          	auipc	ra,0x0
    8000200c:	f08080e7          	jalr	-248(ra) # 80001f10 <reparent>
  wakeup(p->parent);
    80002010:	0389b503          	ld	a0,56(s3)
    80002014:	00000097          	auipc	ra,0x0
    80002018:	e7e080e7          	jalr	-386(ra) # 80001e92 <wakeup>
  acquire(&p->lock);
    8000201c:	854e                	mv	a0,s3
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	ba4080e7          	jalr	-1116(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002026:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000202a:	4795                	li	a5,5
    8000202c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002030:	8526                	mv	a0,s1
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	c44080e7          	jalr	-956(ra) # 80000c76 <release>
  sched();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	d1e080e7          	jalr	-738(ra) # 80001d58 <sched>
  panic("zombie exit");
    80002042:	00007517          	auipc	a0,0x7
    80002046:	22e50513          	addi	a0,a0,558 # 80009270 <digits+0x230>
    8000204a:	ffffe097          	auipc	ra,0xffffe
    8000204e:	4e0080e7          	jalr	1248(ra) # 8000052a <panic>
	  removeSwapFile(p);
    80002052:	854e                	mv	a0,s3
    80002054:	00002097          	auipc	ra,0x2
    80002058:	7ce080e7          	jalr	1998(ra) # 80004822 <removeSwapFile>
    8000205c:	bfa5                	j	80001fd4 <exit+0x62>

000000008000205e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000205e:	7179                	addi	sp,sp,-48
    80002060:	f406                	sd	ra,40(sp)
    80002062:	f022                	sd	s0,32(sp)
    80002064:	ec26                	sd	s1,24(sp)
    80002066:	e84a                	sd	s2,16(sp)
    80002068:	e44e                	sd	s3,8(sp)
    8000206a:	e052                	sd	s4,0(sp)
    8000206c:	1800                	addi	s0,sp,48
    8000206e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002070:	00010497          	auipc	s1,0x10
    80002074:	66048493          	addi	s1,s1,1632 # 800126d0 <proc>
    80002078:	6985                	lui	s3,0x1
    8000207a:	90098993          	addi	s3,s3,-1792 # 900 <_entry-0x7ffff700>
    8000207e:	00034a17          	auipc	s4,0x34
    80002082:	652a0a13          	addi	s4,s4,1618 # 800366d0 <tickslock>
    acquire(&p->lock);
    80002086:	8526                	mv	a0,s1
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	b3a080e7          	jalr	-1222(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    80002090:	589c                	lw	a5,48(s1)
    80002092:	01278c63          	beq	a5,s2,800020aa <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bde080e7          	jalr	-1058(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020a0:	94ce                	add	s1,s1,s3
    800020a2:	ff4492e3          	bne	s1,s4,80002086 <kill+0x28>
  }
  return -1;
    800020a6:	557d                	li	a0,-1
    800020a8:	a829                	j	800020c2 <kill+0x64>
      p->killed = 1;
    800020aa:	4785                	li	a5,1
    800020ac:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020ae:	4c98                	lw	a4,24(s1)
    800020b0:	4789                	li	a5,2
    800020b2:	02f70063          	beq	a4,a5,800020d2 <kill+0x74>
      release(&p->lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	bbe080e7          	jalr	-1090(ra) # 80000c76 <release>
      return 0;
    800020c0:	4501                	li	a0,0
}
    800020c2:	70a2                	ld	ra,40(sp)
    800020c4:	7402                	ld	s0,32(sp)
    800020c6:	64e2                	ld	s1,24(sp)
    800020c8:	6942                	ld	s2,16(sp)
    800020ca:	69a2                	ld	s3,8(sp)
    800020cc:	6a02                	ld	s4,0(sp)
    800020ce:	6145                	addi	sp,sp,48
    800020d0:	8082                	ret
        p->state = RUNNABLE;
    800020d2:	478d                	li	a5,3
    800020d4:	cc9c                	sw	a5,24(s1)
    800020d6:	b7c5                	j	800020b6 <kill+0x58>

00000000800020d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800020d8:	7179                	addi	sp,sp,-48
    800020da:	f406                	sd	ra,40(sp)
    800020dc:	f022                	sd	s0,32(sp)
    800020de:	ec26                	sd	s1,24(sp)
    800020e0:	e84a                	sd	s2,16(sp)
    800020e2:	e44e                	sd	s3,8(sp)
    800020e4:	e052                	sd	s4,0(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	84aa                	mv	s1,a0
    800020ea:	892e                	mv	s2,a1
    800020ec:	89b2                	mv	s3,a2
    800020ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	99c080e7          	jalr	-1636(ra) # 80001a8c <myproc>
  if(user_dst){
    800020f8:	c08d                	beqz	s1,8000211a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800020fa:	86d2                	mv	a3,s4
    800020fc:	864e                	mv	a2,s3
    800020fe:	85ca                	mv	a1,s2
    80002100:	6928                	ld	a0,80(a0)
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	636080e7          	jalr	1590(ra) # 80001738 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000210a:	70a2                	ld	ra,40(sp)
    8000210c:	7402                	ld	s0,32(sp)
    8000210e:	64e2                	ld	s1,24(sp)
    80002110:	6942                	ld	s2,16(sp)
    80002112:	69a2                	ld	s3,8(sp)
    80002114:	6a02                	ld	s4,0(sp)
    80002116:	6145                	addi	sp,sp,48
    80002118:	8082                	ret
    memmove((char *)dst, src, len);
    8000211a:	000a061b          	sext.w	a2,s4
    8000211e:	85ce                	mv	a1,s3
    80002120:	854a                	mv	a0,s2
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	bf8080e7          	jalr	-1032(ra) # 80000d1a <memmove>
    return 0;
    8000212a:	8526                	mv	a0,s1
    8000212c:	bff9                	j	8000210a <either_copyout+0x32>

000000008000212e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	892a                	mv	s2,a0
    80002140:	84ae                	mv	s1,a1
    80002142:	89b2                	mv	s3,a2
    80002144:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	946080e7          	jalr	-1722(ra) # 80001a8c <myproc>
  if(user_src){
    8000214e:	c08d                	beqz	s1,80002170 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002150:	86d2                	mv	a3,s4
    80002152:	864e                	mv	a2,s3
    80002154:	85ca                	mv	a1,s2
    80002156:	6928                	ld	a0,80(a0)
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	66c080e7          	jalr	1644(ra) # 800017c4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002160:	70a2                	ld	ra,40(sp)
    80002162:	7402                	ld	s0,32(sp)
    80002164:	64e2                	ld	s1,24(sp)
    80002166:	6942                	ld	s2,16(sp)
    80002168:	69a2                	ld	s3,8(sp)
    8000216a:	6a02                	ld	s4,0(sp)
    8000216c:	6145                	addi	sp,sp,48
    8000216e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002170:	000a061b          	sext.w	a2,s4
    80002174:	85ce                	mv	a1,s3
    80002176:	854a                	mv	a0,s2
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	ba2080e7          	jalr	-1118(ra) # 80000d1a <memmove>
    return 0;
    80002180:	8526                	mv	a0,s1
    80002182:	bff9                	j	80002160 <either_copyin+0x32>

0000000080002184 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002184:	715d                	addi	sp,sp,-80
    80002186:	e486                	sd	ra,72(sp)
    80002188:	e0a2                	sd	s0,64(sp)
    8000218a:	fc26                	sd	s1,56(sp)
    8000218c:	f84a                	sd	s2,48(sp)
    8000218e:	f44e                	sd	s3,40(sp)
    80002190:	f052                	sd	s4,32(sp)
    80002192:	ec56                	sd	s5,24(sp)
    80002194:	e85a                	sd	s6,16(sp)
    80002196:	e45e                	sd	s7,8(sp)
    80002198:	e062                	sd	s8,0(sp)
    8000219a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000219c:	00007517          	auipc	a0,0x7
    800021a0:	31450513          	addi	a0,a0,788 # 800094b0 <digits+0x470>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	3d0080e7          	jalr	976(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800021ac:	00010497          	auipc	s1,0x10
    800021b0:	67c48493          	addi	s1,s1,1660 # 80012828 <proc+0x158>
    800021b4:	00034997          	auipc	s3,0x34
    800021b8:	67498993          	addi	s3,s3,1652 # 80036828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800021bc:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    800021be:	00007a17          	auipc	s4,0x7
    800021c2:	0c2a0a13          	addi	s4,s4,194 # 80009280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800021c6:	00007b17          	auipc	s6,0x7
    800021ca:	0c2b0b13          	addi	s6,s6,194 # 80009288 <digits+0x248>
    printf("\n");
    800021ce:	00007a97          	auipc	s5,0x7
    800021d2:	2e2a8a93          	addi	s5,s5,738 # 800094b0 <digits+0x470>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800021d6:	00007c17          	auipc	s8,0x7
    800021da:	432c0c13          	addi	s8,s8,1074 # 80009608 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800021de:	6905                	lui	s2,0x1
    800021e0:	90090913          	addi	s2,s2,-1792 # 900 <_entry-0x7ffff700>
    800021e4:	a005                	j	80002204 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800021e6:	ed86a583          	lw	a1,-296(a3)
    800021ea:	855a                	mv	a0,s6
    800021ec:	ffffe097          	auipc	ra,0xffffe
    800021f0:	388080e7          	jalr	904(ra) # 80000574 <printf>
    printf("\n");
    800021f4:	8556                	mv	a0,s5
    800021f6:	ffffe097          	auipc	ra,0xffffe
    800021fa:	37e080e7          	jalr	894(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800021fe:	94ca                	add	s1,s1,s2
    80002200:	03348263          	beq	s1,s3,80002224 <procdump+0xa0>
    if(p->state == UNUSED)
    80002204:	86a6                	mv	a3,s1
    80002206:	ec04a783          	lw	a5,-320(s1)
    8000220a:	dbf5                	beqz	a5,800021fe <procdump+0x7a>
      state = "???";
    8000220c:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000220e:	fcfbece3          	bltu	s7,a5,800021e6 <procdump+0x62>
    80002212:	02079713          	slli	a4,a5,0x20
    80002216:	01d75793          	srli	a5,a4,0x1d
    8000221a:	97e2                	add	a5,a5,s8
    8000221c:	6390                	ld	a2,0(a5)
    8000221e:	f661                	bnez	a2,800021e6 <procdump+0x62>
      state = "???";
    80002220:	8652                	mv	a2,s4
    80002222:	b7d1                	j	800021e6 <procdump+0x62>
  }
}
    80002224:	60a6                	ld	ra,72(sp)
    80002226:	6406                	ld	s0,64(sp)
    80002228:	74e2                	ld	s1,56(sp)
    8000222a:	7942                	ld	s2,48(sp)
    8000222c:	79a2                	ld	s3,40(sp)
    8000222e:	7a02                	ld	s4,32(sp)
    80002230:	6ae2                	ld	s5,24(sp)
    80002232:	6b42                	ld	s6,16(sp)
    80002234:	6ba2                	ld	s7,8(sp)
    80002236:	6c02                	ld	s8,0(sp)
    80002238:	6161                	addi	sp,sp,80
    8000223a:	8082                	ret

000000008000223c <find_free_index>:
 ///////////////////////// - swap functions - /////////////////////////
// #ifndef NONE


  //returns a free index in physical memory
 int find_free_index(struct page_struct* pagearr) {
    8000223c:	1141                	addi	sp,sp,-16
    8000223e:	e422                	sd	s0,8(sp)
    80002240:	0800                	addi	s0,sp,16
    80002242:	87aa                	mv	a5,a0
  struct page_struct *arr;
  int i = 0;
    80002244:	4501                	li	a0,0
  for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    80002246:	46c1                	li	a3,16
    // printf("pid: %d, i: %d, pagearr[i].isAvailable: %d\n",myproc()->pid, i, pagearr[i].isAvailable);
    if(arr->isAvailable){
    80002248:	4398                	lw	a4,0(a5)
    8000224a:	e719                	bnez	a4,80002258 <find_free_index+0x1c>
      return i;
    }
    i++;
    8000224c:	2505                	addiw	a0,a0,1
  for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    8000224e:	02878793          	addi	a5,a5,40
    80002252:	fed51be3          	bne	a0,a3,80002248 <find_free_index+0xc>
  }
  return -1; //in case there no space
    80002256:	557d                	li	a0,-1
 }
    80002258:	6422                	ld	s0,8(sp)
    8000225a:	0141                	addi	sp,sp,16
    8000225c:	8082                	ret

000000008000225e <init_meta_data>:

 void init_meta_data(struct proc* p) {
    8000225e:	1101                	addi	sp,sp,-32
    80002260:	ec06                	sd	ra,24(sp)
    80002262:	e822                	sd	s0,16(sp)
    80002264:	e426                	sd	s1,8(sp)
    80002266:	e04a                	sd	s2,0(sp)
    80002268:	1000                	addi	s0,sp,32
    8000226a:	892a                	mv	s2,a0
  p->num_of_pages = 0;
    8000226c:	6785                	lui	a5,0x1
    8000226e:	97aa                	add	a5,a5,a0
    80002270:	8e07a823          	sw	zero,-1808(a5) # 8f0 <_entry-0x7ffff710>
  p->num_of_pages_in_phys = 0;
    80002274:	8e07aa23          	sw	zero,-1804(a5)
  struct page_struct *pa_swap;
  // printf("allocproc, p->pid: %d, p->files_in_swap: %d\n", p->pid, p->files_in_swap);
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_PSYC_PAGES] ; pa_swap++) {
    80002278:	17050793          	addi	a5,a0,368
    8000227c:	3f050593          	addi	a1,a0,1008
    pa_swap->pagetable = p->pagetable;
    pa_swap->isAvailable = 1;
    80002280:	4605                	li	a2,1
    pa_swap->va = -1;
    80002282:	577d                	li	a4,-1
    pa_swap->pagetable = p->pagetable;
    80002284:	05093683          	ld	a3,80(s2)
    80002288:	e794                	sd	a3,8(a5)
    pa_swap->isAvailable = 1;
    8000228a:	c390                	sw	a2,0(a5)
    pa_swap->va = -1;
    8000228c:	ef98                	sd	a4,24(a5)
    pa_swap->offset = -1;
    8000228e:	d398                	sw	a4,32(a5)
    #ifdef NFUA
     pa_swap->counter_NFUA = 0;
    80002290:	0207a223          	sw	zero,36(a5)
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_PSYC_PAGES] ; pa_swap++) {
    80002294:	02878793          	addi	a5,a5,40
    80002298:	feb796e3          	bne	a5,a1,80002284 <init_meta_data+0x26>
      pa_swap->index_of_next_p = -1;
    #endif
  }

  struct page_struct *pa_psyc;
  printf("allocproc, p->pid: %d, p->files_in_physicalmem: %d\n", p->pid, p->files_in_physicalmem);
    8000229c:	67090493          	addi	s1,s2,1648
    800022a0:	8626                	mv	a2,s1
    800022a2:	03092583          	lw	a1,48(s2)
    800022a6:	00007517          	auipc	a0,0x7
    800022aa:	ff250513          	addi	a0,a0,-14 # 80009298 <digits+0x258>
    800022ae:	ffffe097          	auipc	ra,0xffffe
    800022b2:	2c6080e7          	jalr	710(ra) # 80000574 <printf>

  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    800022b6:	69890713          	addi	a4,s2,1688
    800022ba:	6785                	lui	a5,0x1
    800022bc:	8f078793          	addi	a5,a5,-1808 # 8f0 <_entry-0x7ffff710>
    800022c0:	97ca                	add	a5,a5,s2
    800022c2:	4641                	li	a2,16
    800022c4:	00e7f363          	bgeu	a5,a4,800022ca <init_meta_data+0x6c>
    800022c8:	4605                	li	a2,1
    800022ca:	00261693          	slli	a3,a2,0x2
    800022ce:	96b2                	add	a3,a3,a2
    800022d0:	068e                	slli	a3,a3,0x3
    800022d2:	67068693          	addi	a3,a3,1648
    800022d6:	96ca                	add	a3,a3,s2
    pa_psyc->pagetable = p->pagetable;
    pa_psyc->isAvailable = 1;
    800022d8:	4605                	li	a2,1
    pa_psyc->va = -1;
    800022da:	57fd                	li	a5,-1
    pa_psyc->pagetable = p->pagetable;
    800022dc:	05093703          	ld	a4,80(s2)
    800022e0:	e498                	sd	a4,8(s1)
    pa_psyc->isAvailable = 1;
    800022e2:	c090                	sw	a2,0(s1)
    pa_psyc->va = -1;
    800022e4:	ec9c                	sd	a5,24(s1)
    pa_psyc->offset = -1;
    800022e6:	d09c                	sw	a5,32(s1)
  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    800022e8:	02848493          	addi	s1,s1,40
    800022ec:	fed498e3          	bne	s1,a3,800022dc <init_meta_data+0x7e>
  }

  #ifdef SCFIFO
    p->index_of_head_p = -1;  //no pages in ram so no head
  #endif
}
    800022f0:	60e2                	ld	ra,24(sp)
    800022f2:	6442                	ld	s0,16(sp)
    800022f4:	64a2                	ld	s1,8(sp)
    800022f6:	6902                	ld	s2,0(sp)
    800022f8:	6105                	addi	sp,sp,32
    800022fa:	8082                	ret

00000000800022fc <freeproc>:
{
    800022fc:	1101                	addi	sp,sp,-32
    800022fe:	ec06                	sd	ra,24(sp)
    80002300:	e822                	sd	s0,16(sp)
    80002302:	e426                	sd	s1,8(sp)
    80002304:	1000                	addi	s0,sp,32
    80002306:	84aa                	mv	s1,a0
  if(p->trapframe)
    80002308:	6d28                	ld	a0,88(a0)
    8000230a:	c509                	beqz	a0,80002314 <freeproc+0x18>
    kfree((void*)p->trapframe);
    8000230c:	ffffe097          	auipc	ra,0xffffe
    80002310:	6ca080e7          	jalr	1738(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80002314:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80002318:	68a8                	ld	a0,80(s1)
    8000231a:	c511                	beqz	a0,80002326 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    8000231c:	64ac                	ld	a1,72(s1)
    8000231e:	00000097          	auipc	ra,0x0
    80002322:	8ce080e7          	jalr	-1842(ra) # 80001bec <proc_freepagetable>
  p->pagetable = 0;
    80002326:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    8000232a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000232e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002332:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002336:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    8000233a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000233e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002342:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002346:	0004ac23          	sw	zero,24(s1)
  init_meta_data(p); //TODO not sure
    8000234a:	8526                	mv	a0,s1
    8000234c:	00000097          	auipc	ra,0x0
    80002350:	f12080e7          	jalr	-238(ra) # 8000225e <init_meta_data>
  printf("end freeproc\n");
    80002354:	00007517          	auipc	a0,0x7
    80002358:	f7c50513          	addi	a0,a0,-132 # 800092d0 <digits+0x290>
    8000235c:	ffffe097          	auipc	ra,0xffffe
    80002360:	218080e7          	jalr	536(ra) # 80000574 <printf>
}
    80002364:	60e2                	ld	ra,24(sp)
    80002366:	6442                	ld	s0,16(sp)
    80002368:	64a2                	ld	s1,8(sp)
    8000236a:	6105                	addi	sp,sp,32
    8000236c:	8082                	ret

000000008000236e <wait>:
{
    8000236e:	715d                	addi	sp,sp,-80
    80002370:	e486                	sd	ra,72(sp)
    80002372:	e0a2                	sd	s0,64(sp)
    80002374:	fc26                	sd	s1,56(sp)
    80002376:	f84a                	sd	s2,48(sp)
    80002378:	f44e                	sd	s3,40(sp)
    8000237a:	f052                	sd	s4,32(sp)
    8000237c:	ec56                	sd	s5,24(sp)
    8000237e:	e85a                	sd	s6,16(sp)
    80002380:	e45e                	sd	s7,8(sp)
    80002382:	0880                	addi	s0,sp,80
    80002384:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	706080e7          	jalr	1798(ra) # 80001a8c <myproc>
    8000238e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002390:	00010517          	auipc	a0,0x10
    80002394:	f2850513          	addi	a0,a0,-216 # 800122b8 <wait_lock>
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	82a080e7          	jalr	-2006(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800023a0:	4a95                	li	s5,5
        havekids = 1;
    800023a2:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    800023a4:	6985                	lui	s3,0x1
    800023a6:	90098993          	addi	s3,s3,-1792 # 900 <_entry-0x7ffff700>
    800023aa:	00034a17          	auipc	s4,0x34
    800023ae:	326a0a13          	addi	s4,s4,806 # 800366d0 <tickslock>
    havekids = 0;
    800023b2:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    800023b4:	00010497          	auipc	s1,0x10
    800023b8:	31c48493          	addi	s1,s1,796 # 800126d0 <proc>
    800023bc:	a0b5                	j	80002428 <wait+0xba>
          pid = np->pid;
    800023be:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023c2:	000b8e63          	beqz	s7,800023de <wait+0x70>
    800023c6:	4691                	li	a3,4
    800023c8:	02c48613          	addi	a2,s1,44
    800023cc:	85de                	mv	a1,s7
    800023ce:	05093503          	ld	a0,80(s2)
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	366080e7          	jalr	870(ra) # 80001738 <copyout>
    800023da:	02054563          	bltz	a0,80002404 <wait+0x96>
          freeproc(np);
    800023de:	8526                	mv	a0,s1
    800023e0:	00000097          	auipc	ra,0x0
    800023e4:	f1c080e7          	jalr	-228(ra) # 800022fc <freeproc>
          release(&np->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	88c080e7          	jalr	-1908(ra) # 80000c76 <release>
          release(&wait_lock);
    800023f2:	00010517          	auipc	a0,0x10
    800023f6:	ec650513          	addi	a0,a0,-314 # 800122b8 <wait_lock>
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	87c080e7          	jalr	-1924(ra) # 80000c76 <release>
          return pid;
    80002402:	a095                	j	80002466 <wait+0xf8>
            release(&np->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	870080e7          	jalr	-1936(ra) # 80000c76 <release>
            release(&wait_lock);
    8000240e:	00010517          	auipc	a0,0x10
    80002412:	eaa50513          	addi	a0,a0,-342 # 800122b8 <wait_lock>
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	860080e7          	jalr	-1952(ra) # 80000c76 <release>
            return -1;
    8000241e:	59fd                	li	s3,-1
    80002420:	a099                	j	80002466 <wait+0xf8>
    for(np = proc; np < &proc[NPROC]; np++){
    80002422:	94ce                	add	s1,s1,s3
    80002424:	03448463          	beq	s1,s4,8000244c <wait+0xde>
      if(np->parent == p){
    80002428:	7c9c                	ld	a5,56(s1)
    8000242a:	ff279ce3          	bne	a5,s2,80002422 <wait+0xb4>
        acquire(&np->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	ffffe097          	auipc	ra,0xffffe
    80002434:	792080e7          	jalr	1938(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002438:	4c9c                	lw	a5,24(s1)
    8000243a:	f95782e3          	beq	a5,s5,800023be <wait+0x50>
        release(&np->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	836080e7          	jalr	-1994(ra) # 80000c76 <release>
        havekids = 1;
    80002448:	875a                	mv	a4,s6
    8000244a:	bfe1                	j	80002422 <wait+0xb4>
    if(!havekids || p->killed){
    8000244c:	c701                	beqz	a4,80002454 <wait+0xe6>
    8000244e:	02892783          	lw	a5,40(s2)
    80002452:	c795                	beqz	a5,8000247e <wait+0x110>
      release(&wait_lock);
    80002454:	00010517          	auipc	a0,0x10
    80002458:	e6450513          	addi	a0,a0,-412 # 800122b8 <wait_lock>
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	81a080e7          	jalr	-2022(ra) # 80000c76 <release>
      return -1;
    80002464:	59fd                	li	s3,-1
}
    80002466:	854e                	mv	a0,s3
    80002468:	60a6                	ld	ra,72(sp)
    8000246a:	6406                	ld	s0,64(sp)
    8000246c:	74e2                	ld	s1,56(sp)
    8000246e:	7942                	ld	s2,48(sp)
    80002470:	79a2                	ld	s3,40(sp)
    80002472:	7a02                	ld	s4,32(sp)
    80002474:	6ae2                	ld	s5,24(sp)
    80002476:	6b42                	ld	s6,16(sp)
    80002478:	6ba2                	ld	s7,8(sp)
    8000247a:	6161                	addi	sp,sp,80
    8000247c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000247e:	00010597          	auipc	a1,0x10
    80002482:	e3a58593          	addi	a1,a1,-454 # 800122b8 <wait_lock>
    80002486:	854a                	mv	a0,s2
    80002488:	00000097          	auipc	ra,0x0
    8000248c:	9a6080e7          	jalr	-1626(ra) # 80001e2e <sleep>
    havekids = 0;
    80002490:	b70d                	j	800023b2 <wait+0x44>

0000000080002492 <allocproc>:
{
    80002492:	7179                	addi	sp,sp,-48
    80002494:	f406                	sd	ra,40(sp)
    80002496:	f022                	sd	s0,32(sp)
    80002498:	ec26                	sd	s1,24(sp)
    8000249a:	e84a                	sd	s2,16(sp)
    8000249c:	e44e                	sd	s3,8(sp)
    8000249e:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800024a0:	00010497          	auipc	s1,0x10
    800024a4:	23048493          	addi	s1,s1,560 # 800126d0 <proc>
    800024a8:	6905                	lui	s2,0x1
    800024aa:	90090913          	addi	s2,s2,-1792 # 900 <_entry-0x7ffff700>
    800024ae:	00034997          	auipc	s3,0x34
    800024b2:	22298993          	addi	s3,s3,546 # 800366d0 <tickslock>
    acquire(&p->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	70a080e7          	jalr	1802(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    800024c0:	4c9c                	lw	a5,24(s1)
    800024c2:	cb99                	beqz	a5,800024d8 <allocproc+0x46>
      release(&p->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	7b0080e7          	jalr	1968(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ce:	94ca                	add	s1,s1,s2
    800024d0:	ff3493e3          	bne	s1,s3,800024b6 <allocproc+0x24>
  return 0;
    800024d4:	4481                	li	s1,0
    800024d6:	a059                	j	8000255c <allocproc+0xca>
  p->pid = allocpid();
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	632080e7          	jalr	1586(ra) # 80001b0a <allocpid>
    800024e0:	d888                	sw	a0,48(s1)
  p->state = USED;
    800024e2:	4785                	li	a5,1
    800024e4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800024e6:	ffffe097          	auipc	ra,0xffffe
    800024ea:	5ec080e7          	jalr	1516(ra) # 80000ad2 <kalloc>
    800024ee:	892a                	mv	s2,a0
    800024f0:	eca8                	sd	a0,88(s1)
    800024f2:	cd2d                	beqz	a0,8000256c <allocproc+0xda>
  p->pagetable = proc_pagetable(p);
    800024f4:	8526                	mv	a0,s1
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	65a080e7          	jalr	1626(ra) # 80001b50 <proc_pagetable>
    800024fe:	892a                	mv	s2,a0
    80002500:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002502:	c149                	beqz	a0,80002584 <allocproc+0xf2>
  memset(&p->context, 0, sizeof(p->context));
    80002504:	07000613          	li	a2,112
    80002508:	4581                	li	a1,0
    8000250a:	06048513          	addi	a0,s1,96
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	7b0080e7          	jalr	1968(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80002516:	fffff797          	auipc	a5,0xfffff
    8000251a:	5ae78793          	addi	a5,a5,1454 # 80001ac4 <forkret>
    8000251e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002520:	60bc                	ld	a5,64(s1)
    80002522:	6705                	lui	a4,0x1
    80002524:	97ba                	add	a5,a5,a4
    80002526:	f4bc                	sd	a5,104(s1)
  if (p->pid > 2){
    80002528:	5898                	lw	a4,48(s1)
    8000252a:	4789                	li	a5,2
    8000252c:	02e7d363          	bge	a5,a4,80002552 <allocproc+0xc0>
    release(&p->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	744080e7          	jalr	1860(ra) # 80000c76 <release>
    if(createSwapFile(p) < 0)
    8000253a:	8526                	mv	a0,s1
    8000253c:	00002097          	auipc	ra,0x2
    80002540:	48e080e7          	jalr	1166(ra) # 800049ca <createSwapFile>
    80002544:	04054c63          	bltz	a0,8000259c <allocproc+0x10a>
    acquire(&p->lock);
    80002548:	8526                	mv	a0,s1
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	678080e7          	jalr	1656(ra) # 80000bc2 <acquire>
  init_meta_data(p);
    80002552:	8526                	mv	a0,s1
    80002554:	00000097          	auipc	ra,0x0
    80002558:	d0a080e7          	jalr	-758(ra) # 8000225e <init_meta_data>
}
    8000255c:	8526                	mv	a0,s1
    8000255e:	70a2                	ld	ra,40(sp)
    80002560:	7402                	ld	s0,32(sp)
    80002562:	64e2                	ld	s1,24(sp)
    80002564:	6942                	ld	s2,16(sp)
    80002566:	69a2                	ld	s3,8(sp)
    80002568:	6145                	addi	sp,sp,48
    8000256a:	8082                	ret
    freeproc(p);
    8000256c:	8526                	mv	a0,s1
    8000256e:	00000097          	auipc	ra,0x0
    80002572:	d8e080e7          	jalr	-626(ra) # 800022fc <freeproc>
    release(&p->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	6fe080e7          	jalr	1790(ra) # 80000c76 <release>
    return 0;
    80002580:	84ca                	mv	s1,s2
    80002582:	bfe9                	j	8000255c <allocproc+0xca>
    freeproc(p);
    80002584:	8526                	mv	a0,s1
    80002586:	00000097          	auipc	ra,0x0
    8000258a:	d76080e7          	jalr	-650(ra) # 800022fc <freeproc>
    release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	6e6080e7          	jalr	1766(ra) # 80000c76 <release>
    return 0;
    80002598:	84ca                	mv	s1,s2
    8000259a:	b7c9                	j	8000255c <allocproc+0xca>
      panic("allocproc swapfile creation failed\n");
    8000259c:	00007517          	auipc	a0,0x7
    800025a0:	d4450513          	addi	a0,a0,-700 # 800092e0 <digits+0x2a0>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	f86080e7          	jalr	-122(ra) # 8000052a <panic>

00000000800025ac <userinit>:
{
    800025ac:	1101                	addi	sp,sp,-32
    800025ae:	ec06                	sd	ra,24(sp)
    800025b0:	e822                	sd	s0,16(sp)
    800025b2:	e426                	sd	s1,8(sp)
    800025b4:	1000                	addi	s0,sp,32
  p = allocproc();
    800025b6:	00000097          	auipc	ra,0x0
    800025ba:	edc080e7          	jalr	-292(ra) # 80002492 <allocproc>
    800025be:	84aa                	mv	s1,a0
  initproc = p;
    800025c0:	00008797          	auipc	a5,0x8
    800025c4:	a6a7b823          	sd	a0,-1424(a5) # 8000a030 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800025c8:	03400613          	li	a2,52
    800025cc:	00007597          	auipc	a1,0x7
    800025d0:	5e458593          	addi	a1,a1,1508 # 80009bb0 <initcode>
    800025d4:	6928                	ld	a0,80(a0)
    800025d6:	fffff097          	auipc	ra,0xfffff
    800025da:	dc2080e7          	jalr	-574(ra) # 80001398 <uvminit>
  p->sz = PGSIZE;
    800025de:	6785                	lui	a5,0x1
    800025e0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800025e2:	6cb8                	ld	a4,88(s1)
    800025e4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800025e8:	6cb8                	ld	a4,88(s1)
    800025ea:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800025ec:	4641                	li	a2,16
    800025ee:	00007597          	auipc	a1,0x7
    800025f2:	d1a58593          	addi	a1,a1,-742 # 80009308 <digits+0x2c8>
    800025f6:	15848513          	addi	a0,s1,344
    800025fa:	fffff097          	auipc	ra,0xfffff
    800025fe:	816080e7          	jalr	-2026(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002602:	00007517          	auipc	a0,0x7
    80002606:	d1650513          	addi	a0,a0,-746 # 80009318 <digits+0x2d8>
    8000260a:	00002097          	auipc	ra,0x2
    8000260e:	16c080e7          	jalr	364(ra) # 80004776 <namei>
    80002612:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002616:	478d                	li	a5,3
    80002618:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000261a:	8526                	mv	a0,s1
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	65a080e7          	jalr	1626(ra) # 80000c76 <release>
}
    80002624:	60e2                	ld	ra,24(sp)
    80002626:	6442                	ld	s0,16(sp)
    80002628:	64a2                	ld	s1,8(sp)
    8000262a:	6105                	addi	sp,sp,32
    8000262c:	8082                	ret

000000008000262e <add_page_to_phys>:

 /*
  Adds a page_struct (for the given va) to ram array
 */
int add_page_to_phys(struct proc* p, pagetable_t pagetable, uint64 va) {
    8000262e:	7139                	addi	sp,sp,-64
    80002630:	fc06                	sd	ra,56(sp)
    80002632:	f822                	sd	s0,48(sp)
    80002634:	f426                	sd	s1,40(sp)
    80002636:	f04a                	sd	s2,32(sp)
    80002638:	ec4e                	sd	s3,24(sp)
    8000263a:	e852                	sd	s4,16(sp)
    8000263c:	e456                	sd	s5,8(sp)
    8000263e:	e05a                	sd	s6,0(sp)
    80002640:	0080                	addi	s0,sp,64
    80002642:	84aa                	mv	s1,a0
    80002644:	8b2e                	mv	s6,a1
    80002646:	8ab2                	mv	s5,a2

  int index = find_free_index(p->files_in_physicalmem);
    80002648:	67050513          	addi	a0,a0,1648
    8000264c:	00000097          	auipc	ra,0x0
    80002650:	bf0080e7          	jalr	-1040(ra) # 8000223c <find_free_index>
  // printf(" add_page_to_phys. index: %d\n", index);

  if (index == -1){
    80002654:	57fd                	li	a5,-1
    80002656:	06f50363          	beq	a0,a5,800026bc <add_page_to_phys+0x8e>
    panic("no free index in ram\n");
  }

  p->files_in_physicalmem[index].isAvailable = 0;
    8000265a:	00251993          	slli	s3,a0,0x2
    8000265e:	00a98933          	add	s2,s3,a0
    80002662:	090e                	slli	s2,s2,0x3
    80002664:	9926                	add	s2,s2,s1
    80002666:	66092823          	sw	zero,1648(s2)
  p->files_in_physicalmem[index].pagetable = pagetable;
    8000266a:	67693c23          	sd	s6,1656(s2)
  p->files_in_physicalmem[index].page = walk(pagetable, va, 0);
    8000266e:	4601                	li	a2,0
    80002670:	85d6                	mv	a1,s5
    80002672:	855a                	mv	a0,s6
    80002674:	fffff097          	auipc	ra,0xfffff
    80002678:	932080e7          	jalr	-1742(ra) # 80000fa6 <walk>
    8000267c:	68a93023          	sd	a0,1664(s2)
  p->files_in_physicalmem[index].va = va;
    80002680:	69593423          	sd	s5,1672(s2)
  p->files_in_physicalmem[index].offset = -1;   //offset is a field for files in swap_file only
    80002684:	57fd                	li	a5,-1
    80002686:	68f92823          	sw	a5,1680(s2)

  #ifdef NFUA
    p->files_in_physicalmem[index].counter_NFUA = 0;
    8000268a:	68092a23          	sw	zero,1684(s2)
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[index].index_of_prev_p].index_of_next_p = index;
    }
  #endif

  p->num_of_pages++;
    8000268e:	6505                	lui	a0,0x1
    80002690:	94aa                	add	s1,s1,a0
    80002692:	8f04a783          	lw	a5,-1808(s1)
    80002696:	2785                	addiw	a5,a5,1
    80002698:	8ef4a823          	sw	a5,-1808(s1)
  p->num_of_pages_in_phys++;
    8000269c:	8f44a783          	lw	a5,-1804(s1)
    800026a0:	2785                	addiw	a5,a5,1
    800026a2:	8ef4aa23          	sw	a5,-1804(s1)
  return 0;
}
    800026a6:	4501                	li	a0,0
    800026a8:	70e2                	ld	ra,56(sp)
    800026aa:	7442                	ld	s0,48(sp)
    800026ac:	74a2                	ld	s1,40(sp)
    800026ae:	7902                	ld	s2,32(sp)
    800026b0:	69e2                	ld	s3,24(sp)
    800026b2:	6a42                	ld	s4,16(sp)
    800026b4:	6aa2                	ld	s5,8(sp)
    800026b6:	6b02                	ld	s6,0(sp)
    800026b8:	6121                	addi	sp,sp,64
    800026ba:	8082                	ret
    panic("no free index in ram\n");
    800026bc:	00007517          	auipc	a0,0x7
    800026c0:	c6450513          	addi	a0,a0,-924 # 80009320 <digits+0x2e0>
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	e66080e7          	jalr	-410(ra) # 8000052a <panic>

00000000800026cc <find_index_file_arr>:


int find_index_file_arr(struct proc* p, uint64 address) {
    800026cc:	1101                	addi	sp,sp,-32
    800026ce:	ec06                	sd	ra,24(sp)
    800026d0:	e822                	sd	s0,16(sp)
    800026d2:	e426                	sd	s1,8(sp)
    800026d4:	1000                	addi	s0,sp,32
  // uint64 va = PGROUNDDOWN(address);
  for (int i=0; i<MAX_PSYC_PAGES; i++) {
    800026d6:	18850513          	addi	a0,a0,392
    800026da:	4481                	li	s1,0
    800026dc:	4741                	li	a4,16
    if (p->files_in_swap[i].va == address) {
    800026de:	611c                	ld	a5,0(a0)
    800026e0:	00b78e63          	beq	a5,a1,800026fc <find_index_file_arr+0x30>
  for (int i=0; i<MAX_PSYC_PAGES; i++) {
    800026e4:	2485                	addiw	s1,s1,1
    800026e6:	02850513          	addi	a0,a0,40
    800026ea:	fee49ae3          	bne	s1,a4,800026de <find_index_file_arr+0x12>
      printf("DEBUG found index in swapfilearr: %d\n", i);
      return i;
    }
  }
  return -1;
    800026ee:	54fd                	li	s1,-1
}
    800026f0:	8526                	mv	a0,s1
    800026f2:	60e2                	ld	ra,24(sp)
    800026f4:	6442                	ld	s0,16(sp)
    800026f6:	64a2                	ld	s1,8(sp)
    800026f8:	6105                	addi	sp,sp,32
    800026fa:	8082                	ret
      printf("DEBUG found index in swapfilearr: %d\n", i);
    800026fc:	85a6                	mv	a1,s1
    800026fe:	00007517          	auipc	a0,0x7
    80002702:	c3a50513          	addi	a0,a0,-966 # 80009338 <digits+0x2f8>
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	e6e080e7          	jalr	-402(ra) # 80000574 <printf>
      return i;
    8000270e:	b7cd                	j	800026f0 <find_index_file_arr+0x24>

0000000080002710 <copy_file>:

  return 0;
}


int copy_file(struct proc* dest, struct proc* source) {
    80002710:	715d                	addi	sp,sp,-80
    80002712:	e486                	sd	ra,72(sp)
    80002714:	e0a2                	sd	s0,64(sp)
    80002716:	fc26                	sd	s1,56(sp)
    80002718:	f84a                	sd	s2,48(sp)
    8000271a:	f44e                	sd	s3,40(sp)
    8000271c:	f052                	sd	s4,32(sp)
    8000271e:	ec56                	sd	s5,24(sp)
    80002720:	e85a                	sd	s6,16(sp)
    80002722:	e45e                	sd	s7,8(sp)
    80002724:	0880                	addi	s0,sp,80
    80002726:	8aaa                	mv	s5,a0
    80002728:	8a2e                	mv	s4,a1
  //TODO maybe need to add file size
  char* buf = kalloc();
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	3a8080e7          	jalr	936(ra) # 80000ad2 <kalloc>
    80002732:	89aa                	mv	s3,a0
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    80002734:	4481                	li	s1,0
    80002736:	6b85                	lui	s7,0x1
    80002738:	6b41                	lui	s6,0x10
    readFromSwapFile(source, buf, i, PGSIZE);
    8000273a:	0004891b          	sext.w	s2,s1
    8000273e:	6685                	lui	a3,0x1
    80002740:	864a                	mv	a2,s2
    80002742:	85ce                	mv	a1,s3
    80002744:	8552                	mv	a0,s4
    80002746:	00002097          	auipc	ra,0x2
    8000274a:	358080e7          	jalr	856(ra) # 80004a9e <readFromSwapFile>
    writeToSwapFile(dest, buf, i, PGSIZE);
    8000274e:	6685                	lui	a3,0x1
    80002750:	864a                	mv	a2,s2
    80002752:	85ce                	mv	a1,s3
    80002754:	8556                	mv	a0,s5
    80002756:	00002097          	auipc	ra,0x2
    8000275a:	324080e7          	jalr	804(ra) # 80004a7a <writeToSwapFile>
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    8000275e:	009b84bb          	addw	s1,s7,s1
    80002762:	fd649ce3          	bne	s1,s6,8000273a <copy_file+0x2a>
  }
  kfree(buf);
    80002766:	854e                	mv	a0,s3
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	26e080e7          	jalr	622(ra) # 800009d6 <kfree>
  return 0;
}
    80002770:	4501                	li	a0,0
    80002772:	60a6                	ld	ra,72(sp)
    80002774:	6406                	ld	s0,64(sp)
    80002776:	74e2                	ld	s1,56(sp)
    80002778:	7942                	ld	s2,48(sp)
    8000277a:	79a2                	ld	s3,40(sp)
    8000277c:	7a02                	ld	s4,32(sp)
    8000277e:	6ae2                	ld	s5,24(sp)
    80002780:	6b42                	ld	s6,16(sp)
    80002782:	6ba2                	ld	s7,8(sp)
    80002784:	6161                	addi	sp,sp,80
    80002786:	8082                	ret

0000000080002788 <fork>:
{
    80002788:	7139                	addi	sp,sp,-64
    8000278a:	fc06                	sd	ra,56(sp)
    8000278c:	f822                	sd	s0,48(sp)
    8000278e:	f426                	sd	s1,40(sp)
    80002790:	f04a                	sd	s2,32(sp)
    80002792:	ec4e                	sd	s3,24(sp)
    80002794:	e852                	sd	s4,16(sp)
    80002796:	e456                	sd	s5,8(sp)
    80002798:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000279a:	fffff097          	auipc	ra,0xfffff
    8000279e:	2f2080e7          	jalr	754(ra) # 80001a8c <myproc>
    800027a2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800027a4:	00000097          	auipc	ra,0x0
    800027a8:	cee080e7          	jalr	-786(ra) # 80002492 <allocproc>
    800027ac:	c13d                	beqz	a0,80002812 <fork+0x8a>
    800027ae:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800027b0:	048ab603          	ld	a2,72(s5)
    800027b4:	692c                	ld	a1,80(a0)
    800027b6:	050ab503          	ld	a0,80(s5)
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	e7a080e7          	jalr	-390(ra) # 80001634 <uvmcopy>
    800027c2:	06054263          	bltz	a0,80002826 <fork+0x9e>
  np->sz = p->sz;
    800027c6:	048ab783          	ld	a5,72(s5)
    800027ca:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800027ce:	058ab683          	ld	a3,88(s5)
    800027d2:	87b6                	mv	a5,a3
    800027d4:	0589b703          	ld	a4,88(s3)
    800027d8:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    800027dc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800027e0:	6788                	ld	a0,8(a5)
    800027e2:	6b8c                	ld	a1,16(a5)
    800027e4:	6f90                	ld	a2,24(a5)
    800027e6:	01073023          	sd	a6,0(a4)
    800027ea:	e708                	sd	a0,8(a4)
    800027ec:	eb0c                	sd	a1,16(a4)
    800027ee:	ef10                	sd	a2,24(a4)
    800027f0:	02078793          	addi	a5,a5,32
    800027f4:	02070713          	addi	a4,a4,32
    800027f8:	fed792e3          	bne	a5,a3,800027dc <fork+0x54>
  np->trapframe->a0 = 0;
    800027fc:	0589b783          	ld	a5,88(s3)
    80002800:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002804:	0d0a8493          	addi	s1,s5,208
    80002808:	0d098913          	addi	s2,s3,208
    8000280c:	150a8a13          	addi	s4,s5,336
    80002810:	a089                	j	80002852 <fork+0xca>
    printf("fork allocproc failed\n");
    80002812:	00007517          	auipc	a0,0x7
    80002816:	b4e50513          	addi	a0,a0,-1202 # 80009360 <digits+0x320>
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	d5a080e7          	jalr	-678(ra) # 80000574 <printf>
    return -1;
    80002822:	54fd                	li	s1,-1
    80002824:	a219                	j	8000292a <fork+0x1a2>
    freeproc(np);
    80002826:	854e                	mv	a0,s3
    80002828:	00000097          	auipc	ra,0x0
    8000282c:	ad4080e7          	jalr	-1324(ra) # 800022fc <freeproc>
    release(&np->lock);
    80002830:	854e                	mv	a0,s3
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	444080e7          	jalr	1092(ra) # 80000c76 <release>
    return -1;
    8000283a:	54fd                	li	s1,-1
    8000283c:	a0fd                	j	8000292a <fork+0x1a2>
      np->ofile[i] = filedup(p->ofile[i]);
    8000283e:	00003097          	auipc	ra,0x3
    80002842:	8e4080e7          	jalr	-1820(ra) # 80005122 <filedup>
    80002846:	00a93023          	sd	a0,0(s2)
  for(i = 0; i < NOFILE; i++)
    8000284a:	04a1                	addi	s1,s1,8
    8000284c:	0921                	addi	s2,s2,8
    8000284e:	01448563          	beq	s1,s4,80002858 <fork+0xd0>
    if(p->ofile[i])
    80002852:	6088                	ld	a0,0(s1)
    80002854:	f56d                	bnez	a0,8000283e <fork+0xb6>
    80002856:	bfd5                	j	8000284a <fork+0xc2>
  np->cwd = idup(p->cwd);
    80002858:	150ab503          	ld	a0,336(s5)
    8000285c:	00001097          	auipc	ra,0x1
    80002860:	726080e7          	jalr	1830(ra) # 80003f82 <idup>
    80002864:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002868:	4641                	li	a2,16
    8000286a:	158a8593          	addi	a1,s5,344
    8000286e:	15898513          	addi	a0,s3,344
    80002872:	ffffe097          	auipc	ra,0xffffe
    80002876:	59e080e7          	jalr	1438(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    8000287a:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    8000287e:	854e                	mv	a0,s3
    80002880:	ffffe097          	auipc	ra,0xffffe
    80002884:	3f6080e7          	jalr	1014(ra) # 80000c76 <release>
  if(np->pid > 2){
    80002888:	0309a703          	lw	a4,48(s3)
    8000288c:	4789                	li	a5,2
    8000288e:	06e7d163          	bge	a5,a4,800028f0 <fork+0x168>
    np->num_of_pages = p->num_of_pages;
    80002892:	6885                	lui	a7,0x1
    80002894:	011a8733          	add	a4,s5,a7
    80002898:	8f072683          	lw	a3,-1808(a4)
    8000289c:	011987b3          	add	a5,s3,a7
    800028a0:	8ed7a823          	sw	a3,-1808(a5)
    np->num_of_pages_in_phys = p->num_of_pages_in_phys;
    800028a4:	8f472703          	lw	a4,-1804(a4)
    800028a8:	8ee7aa23          	sw	a4,-1804(a5)
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    800028ac:	670a8793          	addi	a5,s5,1648
    800028b0:	67098713          	addi	a4,s3,1648
    800028b4:	8f088893          	addi	a7,a7,-1808 # 8f0 <_entry-0x7ffff710>
    800028b8:	98d6                	add	a7,a7,s5
      np->files_in_physicalmem[i] = p->files_in_physicalmem[i];
    800028ba:	0007b803          	ld	a6,0(a5)
    800028be:	6788                	ld	a0,8(a5)
    800028c0:	6b8c                	ld	a1,16(a5)
    800028c2:	6f90                	ld	a2,24(a5)
    800028c4:	7394                	ld	a3,32(a5)
    800028c6:	01073023          	sd	a6,0(a4)
    800028ca:	e708                	sd	a0,8(a4)
    800028cc:	eb0c                	sd	a1,16(a4)
    800028ce:	ef10                	sd	a2,24(a4)
    800028d0:	f314                	sd	a3,32(a4)
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    800028d2:	02878793          	addi	a5,a5,40
    800028d6:	02870713          	addi	a4,a4,40
    800028da:	ff1790e3          	bne	a5,a7,800028ba <fork+0x132>
    if(p->swapFile){
    800028de:	168ab783          	ld	a5,360(s5)
    800028e2:	c799                	beqz	a5,800028f0 <fork+0x168>
      copy_file(np, p);
    800028e4:	85d6                	mv	a1,s5
    800028e6:	854e                	mv	a0,s3
    800028e8:	00000097          	auipc	ra,0x0
    800028ec:	e28080e7          	jalr	-472(ra) # 80002710 <copy_file>
  acquire(&wait_lock);
    800028f0:	00010917          	auipc	s2,0x10
    800028f4:	9c890913          	addi	s2,s2,-1592 # 800122b8 <wait_lock>
    800028f8:	854a                	mv	a0,s2
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	2c8080e7          	jalr	712(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002902:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002906:	854a                	mv	a0,s2
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	36e080e7          	jalr	878(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002910:	854e                	mv	a0,s3
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	2b0080e7          	jalr	688(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    8000291a:	478d                	li	a5,3
    8000291c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002920:	854e                	mv	a0,s3
    80002922:	ffffe097          	auipc	ra,0xffffe
    80002926:	354080e7          	jalr	852(ra) # 80000c76 <release>
}
    8000292a:	8526                	mv	a0,s1
    8000292c:	70e2                	ld	ra,56(sp)
    8000292e:	7442                	ld	s0,48(sp)
    80002930:	74a2                	ld	s1,40(sp)
    80002932:	7902                	ld	s2,32(sp)
    80002934:	69e2                	ld	s3,24(sp)
    80002936:	6a42                	ld	s4,16(sp)
    80002938:	6aa2                	ld	s5,8(sp)
    8000293a:	6121                	addi	sp,sp,64
    8000293c:	8082                	ret

000000008000293e <insert_from_swap_to_ram>:


int insert_from_swap_to_ram(struct proc* p, char* buff ,uint64 va) {
    8000293e:	7179                	addi	sp,sp,-48
    80002940:	f406                	sd	ra,40(sp)
    80002942:	f022                	sd	s0,32(sp)
    80002944:	ec26                	sd	s1,24(sp)
    80002946:	e84a                	sd	s2,16(sp)
    80002948:	e44e                	sd	s3,8(sp)
    8000294a:	1800                	addi	s0,sp,48
    8000294c:	84aa                	mv	s1,a0
    8000294e:	89ae                	mv	s3,a1
    80002950:	8932                	mv	s2,a2
    pte_t* pte = walk(p->pagetable, va, 0); //we want to update the corresponding pte according to our changes
    80002952:	4601                	li	a2,0
    80002954:	85ca                	mv	a1,s2
    80002956:	6928                	ld	a0,80(a0)
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	64e080e7          	jalr	1614(ra) # 80000fa6 <walk>
    *pte |= PTE_V | PTE_W | PTE_U; //mark that page is in ram, is writable, and is a user page
    *pte &= ~PTE_PG;              //page was moved from swapfile
    80002960:	611c                	ld	a5,0(a0)
    80002962:	dff7f793          	andi	a5,a5,-513
    80002966:	0157e793          	ori	a5,a5,21
    8000296a:	e11c                	sd	a5,0(a0)
    *pte |= *buff;                //TODO not sure
    8000296c:	0009c703          	lbu	a4,0(s3)
    80002970:	8fd9                	or	a5,a5,a4
    80002972:	e11c                	sd	a5,0(a0)

    int swap_ind = find_index_file_arr(p, va);
    80002974:	85ca                	mv	a1,s2
    80002976:	8526                	mv	a0,s1
    80002978:	00000097          	auipc	ra,0x0
    8000297c:	d54080e7          	jalr	-684(ra) # 800026cc <find_index_file_arr>
    //if index is -1, according to swap_file_array the file isn't in swapfile
    if (swap_ind == -1) {
    80002980:	57fd                	li	a5,-1
    80002982:	0af50363          	beq	a0,a5,80002a28 <insert_from_swap_to_ram+0xea>
    80002986:	892a                	mv	s2,a0
      panic("index in file is -1");
    }
    int offset = p->files_in_swap[swap_ind].offset;
    80002988:	00251793          	slli	a5,a0,0x2
    8000298c:	97aa                	add	a5,a5,a0
    8000298e:	078e                	slli	a5,a5,0x3
    80002990:	97a6                	add	a5,a5,s1
    80002992:	1907a603          	lw	a2,400(a5)
    if (offset == -1) {
    80002996:	57fd                	li	a5,-1
    80002998:	0af60063          	beq	a2,a5,80002a38 <insert_from_swap_to_ram+0xfa>
      panic("offset is -1");
    }
    readFromSwapFile(p, buff, offset, PGSIZE);
    8000299c:	6685                	lui	a3,0x1
    8000299e:	85ce                	mv	a1,s3
    800029a0:	8526                	mv	a0,s1
    800029a2:	00002097          	auipc	ra,0x2
    800029a6:	0fc080e7          	jalr	252(ra) # 80004a9e <readFromSwapFile>

    //copy swap_arr[index] to mem_arr[index] and change swap_arr[index] to available
    int mem_ind = find_free_index(p->files_in_physicalmem);
    800029aa:	67048513          	addi	a0,s1,1648
    800029ae:	00000097          	auipc	ra,0x0
    800029b2:	88e080e7          	jalr	-1906(ra) # 8000223c <find_free_index>
    p->files_in_physicalmem[mem_ind].pagetable = p->files_in_swap[swap_ind].pagetable;
    800029b6:	00251613          	slli	a2,a0,0x2
    800029ba:	00a607b3          	add	a5,a2,a0
    800029be:	078e                	slli	a5,a5,0x3
    800029c0:	97a6                	add	a5,a5,s1
    800029c2:	00291713          	slli	a4,s2,0x2
    800029c6:	012706b3          	add	a3,a4,s2
    800029ca:	068e                	slli	a3,a3,0x3
    800029cc:	96a6                	add	a3,a3,s1
    800029ce:	1786b583          	ld	a1,376(a3) # 1178 <_entry-0x7fffee88>
    800029d2:	66b7bc23          	sd	a1,1656(a5)
    p->files_in_physicalmem[mem_ind].page = p->files_in_swap[swap_ind].page;
    800029d6:	1806b583          	ld	a1,384(a3)
    800029da:	68b7b023          	sd	a1,1664(a5)
    p->files_in_physicalmem[mem_ind].va = p->files_in_swap[swap_ind].va;
    800029de:	1886b683          	ld	a3,392(a3)
    800029e2:	68d7b423          	sd	a3,1672(a5)
    p->files_in_physicalmem[mem_ind].offset = -1;
    800029e6:	56fd                	li	a3,-1
    800029e8:	68d7a823          	sw	a3,1680(a5)
    p->files_in_physicalmem[mem_ind].isAvailable = 0;
    800029ec:	6607a823          	sw	zero,1648(a5)
    p->num_of_pages_in_phys++;
    800029f0:	6785                	lui	a5,0x1
    800029f2:	97a6                	add	a5,a5,s1
    800029f4:	8f47a683          	lw	a3,-1804(a5) # 8f4 <_entry-0x7ffff70c>
    800029f8:	2685                	addiw	a3,a3,1
    800029fa:	8ed7aa23          	sw	a3,-1804(a5)

    p->files_in_swap[swap_ind].isAvailable = 1;
    800029fe:	974a                	add	a4,a4,s2
    80002a00:	070e                	slli	a4,a4,0x3
    80002a02:	9726                	add	a4,a4,s1
    80002a04:	4785                	li	a5,1
    80002a06:	16f72823          	sw	a5,368(a4)

    //need to maintain counter fiels value
    #ifdef NFUA
      p->files_in_physicalmem[mem_ind].counter_NFUA = 1<<31;
    80002a0a:	962a                	add	a2,a2,a0
    80002a0c:	060e                	slli	a2,a2,0x3
    80002a0e:	94b2                	add	s1,s1,a2
    80002a10:	800007b7          	lui	a5,0x80000
    80002a14:	68f4aa23          	sw	a5,1684(s1)
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = mem_ind;
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = mem_ind;
    #endif
    return 0;
  }
    80002a18:	4501                	li	a0,0
    80002a1a:	70a2                	ld	ra,40(sp)
    80002a1c:	7402                	ld	s0,32(sp)
    80002a1e:	64e2                	ld	s1,24(sp)
    80002a20:	6942                	ld	s2,16(sp)
    80002a22:	69a2                	ld	s3,8(sp)
    80002a24:	6145                	addi	sp,sp,48
    80002a26:	8082                	ret
      panic("index in file is -1");
    80002a28:	00007517          	auipc	a0,0x7
    80002a2c:	95050513          	addi	a0,a0,-1712 # 80009378 <digits+0x338>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	afa080e7          	jalr	-1286(ra) # 8000052a <panic>
      panic("offset is -1");
    80002a38:	00007517          	auipc	a0,0x7
    80002a3c:	95850513          	addi	a0,a0,-1704 # 80009390 <digits+0x350>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	aea080e7          	jalr	-1302(ra) # 8000052a <panic>

0000000080002a48 <print_page_array>:
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }
}

void print_page_array(struct proc* p ,struct page_struct* pagearr) {
    80002a48:	7139                	addi	sp,sp,-64
    80002a4a:	fc06                	sd	ra,56(sp)
    80002a4c:	f822                	sd	s0,48(sp)
    80002a4e:	f426                	sd	s1,40(sp)
    80002a50:	f04a                	sd	s2,32(sp)
    80002a52:	ec4e                	sd	s3,24(sp)
    80002a54:	e852                	sd	s4,16(sp)
    80002a56:	e456                	sd	s5,8(sp)
    80002a58:	0080                	addi	s0,sp,64
    80002a5a:	89aa                	mv	s3,a0
    80002a5c:	84ae                	mv	s1,a1
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002a5e:	4901                	li	s2,0
    struct page_struct curr = pagearr[i];
    printf("pid: %d, index: %d, page: %d, isAvailable: %d, va: %d, offset: %d\n",
    80002a60:	00007a97          	auipc	s5,0x7
    80002a64:	940a8a93          	addi	s5,s5,-1728 # 800093a0 <digits+0x360>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002a68:	4a41                	li	s4,16
    printf("pid: %d, index: %d, page: %d, isAvailable: %d, va: %d, offset: %d\n",
    80002a6a:	0204a803          	lw	a6,32(s1)
    80002a6e:	6c9c                	ld	a5,24(s1)
    80002a70:	4098                	lw	a4,0(s1)
    80002a72:	6894                	ld	a3,16(s1)
    80002a74:	864a                	mv	a2,s2
    80002a76:	0309a583          	lw	a1,48(s3)
    80002a7a:	8556                	mv	a0,s5
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	af8080e7          	jalr	-1288(ra) # 80000574 <printf>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002a84:	2905                	addiw	s2,s2,1
    80002a86:	02848493          	addi	s1,s1,40
    80002a8a:	ff4910e3          	bne	s2,s4,80002a6a <print_page_array+0x22>
    p->pid, i, curr.page, curr.isAvailable, curr.va, curr.offset);
  }
}
    80002a8e:	70e2                	ld	ra,56(sp)
    80002a90:	7442                	ld	s0,48(sp)
    80002a92:	74a2                	ld	s1,40(sp)
    80002a94:	7902                	ld	s2,32(sp)
    80002a96:	69e2                	ld	s3,24(sp)
    80002a98:	6a42                	ld	s4,16(sp)
    80002a9a:	6aa2                	ld	s5,8(sp)
    80002a9c:	6121                	addi	sp,sp,64
    80002a9e:	8082                	ret

0000000080002aa0 <calc_ndx_NFUA>:
  #endif

  return ndx;
}
#ifdef NFUA
int calc_ndx_NFUA(struct proc *p){
    80002aa0:	715d                	addi	sp,sp,-80
    80002aa2:	e486                	sd	ra,72(sp)
    80002aa4:	e0a2                	sd	s0,64(sp)
    80002aa6:	fc26                	sd	s1,56(sp)
    80002aa8:	f84a                	sd	s2,48(sp)
    80002aaa:	f44e                	sd	s3,40(sp)
    80002aac:	f052                	sd	s4,32(sp)
    80002aae:	ec56                	sd	s5,24(sp)
    80002ab0:	e85a                	sd	s6,16(sp)
    80002ab2:	e45e                	sd	s7,8(sp)
    80002ab4:	e062                	sd	s8,0(sp)
    80002ab6:	0880                	addi	s0,sp,80
    80002ab8:	84aa                	mv	s1,a0
printf("begin calc_ndx_NFUA\n");
    80002aba:	00007517          	auipc	a0,0x7
    80002abe:	92e50513          	addi	a0,a0,-1746 # 800093e8 <digits+0x3a8>
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	ab2080e7          	jalr	-1358(ra) # 80000574 <printf>
  int selected = -1;
  int curr_index = -1;
  int lowest = -1;
  printf("11\n");
    80002aca:	00007517          	auipc	a0,0x7
    80002ace:	93650513          	addi	a0,a0,-1738 # 80009400 <digits+0x3c0>
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	aa2080e7          	jalr	-1374(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    80002ada:	67048493          	addi	s1,s1,1648
    80002ade:	4901                	li	s2,0
  int lowest = -1;
    80002ae0:	5afd                	li	s5,-1
  int selected = -1;
    80002ae2:	5c7d                	li	s8,-1
    struct page_struct curr_page = p->files_in_physicalmem[i];
    if (curr_page.isAvailable == 0) {
      printf("hahayyyyy\n");
    80002ae4:	00007b97          	auipc	s7,0x7
    80002ae8:	924b8b93          	addi	s7,s7,-1756 # 80009408 <digits+0x3c8>
      curr_index = curr_page.counter_NFUA;
      printf("curr_index dec %d, hex %x\n", curr_index, curr_index);
    80002aec:	00007b17          	auipc	s6,0x7
    80002af0:	92cb0b13          	addi	s6,s6,-1748 # 80009418 <digits+0x3d8>
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    80002af4:	4a41                	li	s4,16
    80002af6:	a031                	j	80002b02 <calc_ndx_NFUA+0x62>
    80002af8:	2905                	addiw	s2,s2,1
    80002afa:	02848493          	addi	s1,s1,40
    80002afe:	03490863          	beq	s2,s4,80002b2e <calc_ndx_NFUA+0x8e>
    if (curr_page.isAvailable == 0) {
    80002b02:	409c                	lw	a5,0(s1)
    80002b04:	fbf5                	bnez	a5,80002af8 <calc_ndx_NFUA+0x58>
    struct page_struct curr_page = p->files_in_physicalmem[i];
    80002b06:	0244a983          	lw	s3,36(s1)
      printf("hahayyyyy\n");
    80002b0a:	855e                	mv	a0,s7
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	a68080e7          	jalr	-1432(ra) # 80000574 <printf>
      curr_index = curr_page.counter_NFUA;
    80002b14:	2981                	sext.w	s3,s3
      printf("curr_index dec %d, hex %x\n", curr_index, curr_index);
    80002b16:	864e                	mv	a2,s3
    80002b18:	85ce                	mv	a1,s3
    80002b1a:	855a                	mv	a0,s6
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a58080e7          	jalr	-1448(ra) # 80000574 <printf>
      if (curr_index < lowest) {
    80002b24:	fd59dae3          	bge	s3,s5,80002af8 <calc_ndx_NFUA+0x58>
        lowest = curr_index;
    80002b28:	8ace                	mv	s5,s3
      if (curr_index < lowest) {
    80002b2a:	8c4a                	mv	s8,s2
    80002b2c:	b7f1                	j	80002af8 <calc_ndx_NFUA+0x58>
        selected = i;
      }
    }
    // printf("hahahi\n");
  }
  printf("selected: %d\n", selected);
    80002b2e:	85e2                	mv	a1,s8
    80002b30:	00007517          	auipc	a0,0x7
    80002b34:	90850513          	addi	a0,a0,-1784 # 80009438 <digits+0x3f8>
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	a3c080e7          	jalr	-1476(ra) # 80000574 <printf>
  printf("end calc_ndx_NFUA\n");
    80002b40:	00007517          	auipc	a0,0x7
    80002b44:	90850513          	addi	a0,a0,-1784 # 80009448 <digits+0x408>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a2c080e7          	jalr	-1492(ra) # 80000574 <printf>

  return selected;
}
    80002b50:	8562                	mv	a0,s8
    80002b52:	60a6                	ld	ra,72(sp)
    80002b54:	6406                	ld	s0,64(sp)
    80002b56:	74e2                	ld	s1,56(sp)
    80002b58:	7942                	ld	s2,48(sp)
    80002b5a:	79a2                	ld	s3,40(sp)
    80002b5c:	7a02                	ld	s4,32(sp)
    80002b5e:	6ae2                	ld	s5,24(sp)
    80002b60:	6b42                	ld	s6,16(sp)
    80002b62:	6ba2                	ld	s7,8(sp)
    80002b64:	6c02                	ld	s8,0(sp)
    80002b66:	6161                	addi	sp,sp,80
    80002b68:	8082                	ret

0000000080002b6a <calc_ndx_for_ramarr_removal>:
int calc_ndx_for_ramarr_removal(struct proc *p){
    80002b6a:	1101                	addi	sp,sp,-32
    80002b6c:	ec06                	sd	ra,24(sp)
    80002b6e:	e822                	sd	s0,16(sp)
    80002b70:	e426                	sd	s1,8(sp)
    80002b72:	1000                	addi	s0,sp,32
    80002b74:	84aa                	mv	s1,a0
  printf("hello calculation\n");
    80002b76:	00007517          	auipc	a0,0x7
    80002b7a:	8ea50513          	addi	a0,a0,-1814 # 80009460 <digits+0x420>
    80002b7e:	ffffe097          	auipc	ra,0xffffe
    80002b82:	9f6080e7          	jalr	-1546(ra) # 80000574 <printf>
    ndx = calc_ndx_NFUA(p);
    80002b86:	8526                	mv	a0,s1
    80002b88:	00000097          	auipc	ra,0x0
    80002b8c:	f18080e7          	jalr	-232(ra) # 80002aa0 <calc_ndx_NFUA>
}
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6105                	addi	sp,sp,32
    80002b98:	8082                	ret

0000000080002b9a <swap_to_swapFile>:
int swap_to_swapFile(struct proc* p) {
    80002b9a:	715d                	addi	sp,sp,-80
    80002b9c:	e486                	sd	ra,72(sp)
    80002b9e:	e0a2                	sd	s0,64(sp)
    80002ba0:	fc26                	sd	s1,56(sp)
    80002ba2:	f84a                	sd	s2,48(sp)
    80002ba4:	f44e                	sd	s3,40(sp)
    80002ba6:	f052                	sd	s4,32(sp)
    80002ba8:	ec56                	sd	s5,24(sp)
    80002baa:	e85a                	sd	s6,16(sp)
    80002bac:	e45e                	sd	s7,8(sp)
    80002bae:	e062                	sd	s8,0(sp)
    80002bb0:	0880                	addi	s0,sp,80
    80002bb2:	84aa                	mv	s1,a0
  printf("swap to swapfile\n");
    80002bb4:	00007517          	auipc	a0,0x7
    80002bb8:	8c450513          	addi	a0,a0,-1852 # 80009478 <digits+0x438>
    80002bbc:	ffffe097          	auipc	ra,0xffffe
    80002bc0:	9b8080e7          	jalr	-1608(ra) # 80000574 <printf>
  int mem_ind = calc_ndx_for_ramarr_removal(p);  //index of page to remove from ram array
    80002bc4:	8526                	mv	a0,s1
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	fa4080e7          	jalr	-92(ra) # 80002b6a <calc_ndx_for_ramarr_removal>
    80002bce:	8aaa                	mv	s5,a0
  int swap_ind = find_free_index(p->files_in_swap);
    80002bd0:	17048513          	addi	a0,s1,368
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	668080e7          	jalr	1640(ra) # 8000223c <find_free_index>
    80002bdc:	8a2a                	mv	s4,a0
  pagetable_t pagetable_to_swap_file = p->files_in_physicalmem[mem_ind].pagetable;
    80002bde:	002a9913          	slli	s2,s5,0x2
    80002be2:	015909b3          	add	s3,s2,s5
    80002be6:	098e                	slli	s3,s3,0x3
    80002be8:	99a6                	add	s3,s3,s1
    80002bea:	6789bc03          	ld	s8,1656(s3)
  uint64 va_to_swap_file = p->files_in_physicalmem[mem_ind].va;
    80002bee:	6889bb83          	ld	s7,1672(s3)
  uint64 pa = walkaddr(pagetable_to_swap_file, va_to_swap_file);
    80002bf2:	85de                	mv	a1,s7
    80002bf4:	8562                	mv	a0,s8
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	456080e7          	jalr	1110(ra) # 8000104c <walkaddr>
    80002bfe:	85aa                	mv	a1,a0
  int offset = swap_ind*PGSIZE; //fine offset we want to insert to
    80002c00:	00ca1b1b          	slliw	s6,s4,0xc
  writeToSwapFile(p, (char *)pa, offset, PGSIZE);
    80002c04:	6685                	lui	a3,0x1
    80002c06:	000b061b          	sext.w	a2,s6
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	00002097          	auipc	ra,0x2
    80002c10:	e6e080e7          	jalr	-402(ra) # 80004a7a <writeToSwapFile>
  p->files_in_swap[swap_ind].pagetable = pagetable_to_swap_file;
    80002c14:	002a1793          	slli	a5,s4,0x2
    80002c18:	01478733          	add	a4,a5,s4
    80002c1c:	070e                	slli	a4,a4,0x3
    80002c1e:	9726                	add	a4,a4,s1
    80002c20:	17873c23          	sd	s8,376(a4)
  p->files_in_swap[swap_ind].va = va_to_swap_file;
    80002c24:	19773423          	sd	s7,392(a4)
  p->files_in_swap[swap_ind].isAvailable = 0;
    80002c28:	16072823          	sw	zero,368(a4)
  p->files_in_swap[swap_ind].offset = offset;
    80002c2c:	19672823          	sw	s6,400(a4)
  p->files_in_swap[swap_ind].page = p->files_in_physicalmem[mem_ind].page;
    80002c30:	6809bb03          	ld	s6,1664(s3)
    80002c34:	19673023          	sd	s6,384(a4)
  char *pa_tofree = (char *)PTE2PA(*pte);
    80002c38:	000b3503          	ld	a0,0(s6)
    80002c3c:	8129                	srli	a0,a0,0xa
  kfree(pa_tofree);
    80002c3e:	0532                	slli	a0,a0,0xc
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	d96080e7          	jalr	-618(ra) # 800009d6 <kfree>
  (*pte) &= ~PTE_V;
    80002c48:	000b3783          	ld	a5,0(s6)
    80002c4c:	9bf9                	andi	a5,a5,-2
  (*pte) |= PTE_PG;
    80002c4e:	2007e793          	ori	a5,a5,512
    80002c52:	00fb3023          	sd	a5,0(s6)
  asm volatile("sfence.vma zero, zero");
    80002c56:	12000073          	sfence.vma
  p->files_in_physicalmem[mem_ind].isAvailable = 1;
    80002c5a:	4785                	li	a5,1
    80002c5c:	66f9a823          	sw	a5,1648(s3)
  p->files_in_physicalmem[mem_ind].counter_NFUA = 0;
    80002c60:	6809aa23          	sw	zero,1684(s3)
  p->num_of_pages_in_phys--;
    80002c64:	6505                	lui	a0,0x1
    80002c66:	94aa                	add	s1,s1,a0
    80002c68:	8f44a783          	lw	a5,-1804(s1)
    80002c6c:	37fd                	addiw	a5,a5,-1
    80002c6e:	8ef4aa23          	sw	a5,-1804(s1)
}
    80002c72:	4501                	li	a0,0
    80002c74:	60a6                	ld	ra,72(sp)
    80002c76:	6406                	ld	s0,64(sp)
    80002c78:	74e2                	ld	s1,56(sp)
    80002c7a:	7942                	ld	s2,48(sp)
    80002c7c:	79a2                	ld	s3,40(sp)
    80002c7e:	7a02                	ld	s4,32(sp)
    80002c80:	6ae2                	ld	s5,24(sp)
    80002c82:	6b42                	ld	s6,16(sp)
    80002c84:	6ba2                	ld	s7,8(sp)
    80002c86:	6c02                	ld	s8,0(sp)
    80002c88:	6161                	addi	sp,sp,80
    80002c8a:	8082                	ret

0000000080002c8c <swap_to_memory>:
  int swap_to_memory(struct proc* p, uint64 address) {
    80002c8c:	7179                	addi	sp,sp,-48
    80002c8e:	f406                	sd	ra,40(sp)
    80002c90:	f022                	sd	s0,32(sp)
    80002c92:	ec26                	sd	s1,24(sp)
    80002c94:	e84a                	sd	s2,16(sp)
    80002c96:	e44e                	sd	s3,8(sp)
    80002c98:	1800                	addi	s0,sp,48
    80002c9a:	892a                	mv	s2,a0
  uint64 va = PGROUNDDOWN(address);
    80002c9c:	79fd                	lui	s3,0xfffff
    80002c9e:	0135f9b3          	and	s3,a1,s3
  if ((buff = kalloc()) == 0) {
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	e30080e7          	jalr	-464(ra) # 80000ad2 <kalloc>
    80002caa:	cd1d                	beqz	a0,80002ce8 <swap_to_memory+0x5c>
    80002cac:	84aa                	mv	s1,a0
  if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80002cae:	6785                	lui	a5,0x1
    80002cb0:	97ca                	add	a5,a5,s2
    80002cb2:	8f47a703          	lw	a4,-1804(a5) # 8f4 <_entry-0x7ffff70c>
    80002cb6:	47bd                	li	a5,15
    80002cb8:	04e7c063          	blt	a5,a4,80002cf8 <swap_to_memory+0x6c>
    insert_from_swap_to_ram(p, buff, va);
    80002cbc:	864e                	mv	a2,s3
    80002cbe:	85aa                	mv	a1,a0
    80002cc0:	854a                	mv	a0,s2
    80002cc2:	00000097          	auipc	ra,0x0
    80002cc6:	c7c080e7          	jalr	-900(ra) # 8000293e <insert_from_swap_to_ram>
    memmove((void*)va, buff, PGSIZE); //copy page to va TODO check im not sure
    80002cca:	6605                	lui	a2,0x1
    80002ccc:	85a6                	mv	a1,s1
    80002cce:	854e                	mv	a0,s3
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	04a080e7          	jalr	74(ra) # 80000d1a <memmove>
}
    80002cd8:	4501                	li	a0,0
    80002cda:	70a2                	ld	ra,40(sp)
    80002cdc:	7402                	ld	s0,32(sp)
    80002cde:	64e2                	ld	s1,24(sp)
    80002ce0:	6942                	ld	s2,16(sp)
    80002ce2:	69a2                	ld	s3,8(sp)
    80002ce4:	6145                	addi	sp,sp,48
    80002ce6:	8082                	ret
    panic("kalloc failed");
    80002ce8:	00006517          	auipc	a0,0x6
    80002cec:	7a850513          	addi	a0,a0,1960 # 80009490 <digits+0x450>
    80002cf0:	ffffe097          	auipc	ra,0xffffe
    80002cf4:	83a080e7          	jalr	-1990(ra) # 8000052a <panic>
    swap_to_swapFile(p);      //if there's no available place in ram, make some
    80002cf8:	854a                	mv	a0,s2
    80002cfa:	00000097          	auipc	ra,0x0
    80002cfe:	ea0080e7          	jalr	-352(ra) # 80002b9a <swap_to_swapFile>
    insert_from_swap_to_ram(p, buff, va); //move from swapfile the page we wanted to insert to ram
    80002d02:	864e                	mv	a2,s3
    80002d04:	85a6                	mv	a1,s1
    80002d06:	854a                	mv	a0,s2
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	c36080e7          	jalr	-970(ra) # 8000293e <insert_from_swap_to_ram>
    memmove((void*)va, buff, PGSIZE); //copy page to va TODO check im not sure
    80002d10:	6605                	lui	a2,0x1
    80002d12:	85a6                	mv	a1,s1
    80002d14:	854e                	mv	a0,s3
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	004080e7          	jalr	4(ra) # 80000d1a <memmove>
    80002d1e:	bf6d                	j	80002cd8 <swap_to_memory+0x4c>

0000000080002d20 <hanle_page_fault>:
void hanle_page_fault(struct proc* p) {
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	e04a                	sd	s2,0(sp)
    80002d2a:	1000                	addi	s0,sp,32
    80002d2c:	84aa                	mv	s1,a0
  printf("files in memory:\n");
    80002d2e:	00006517          	auipc	a0,0x6
    80002d32:	77250513          	addi	a0,a0,1906 # 800094a0 <digits+0x460>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	83e080e7          	jalr	-1986(ra) # 80000574 <printf>
  print_page_array(p, p->files_in_physicalmem);
    80002d3e:	67048593          	addi	a1,s1,1648
    80002d42:	8526                	mv	a0,s1
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	d04080e7          	jalr	-764(ra) # 80002a48 <print_page_array>
  printf("files in swap:\n");
    80002d4c:	00006517          	auipc	a0,0x6
    80002d50:	76c50513          	addi	a0,a0,1900 # 800094b8 <digits+0x478>
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	820080e7          	jalr	-2016(ra) # 80000574 <printf>
  print_page_array(p, p->files_in_swap);
    80002d5c:	17048593          	addi	a1,s1,368
    80002d60:	8526                	mv	a0,s1
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	ce6080e7          	jalr	-794(ra) # 80002a48 <print_page_array>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d6a:	14302973          	csrr	s2,stval
  printf("fault address: %d\n", va);
    80002d6e:	85ca                	mv	a1,s2
    80002d70:	00006517          	auipc	a0,0x6
    80002d74:	75850513          	addi	a0,a0,1880 # 800094c8 <digits+0x488>
    80002d78:	ffffd097          	auipc	ra,0xffffd
    80002d7c:	7fc080e7          	jalr	2044(ra) # 80000574 <printf>
  pte_t* pte = walk(p->pagetable, va, 0); //identify the page
    80002d80:	4601                	li	a2,0
    80002d82:	85ca                	mv	a1,s2
    80002d84:	68a8                	ld	a0,80(s1)
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	220080e7          	jalr	544(ra) # 80000fa6 <walk>
  if (*pte & PTE_PG) {
    80002d8e:	611c                	ld	a5,0(a0)
    80002d90:	2007f793          	andi	a5,a5,512
    80002d94:	cf89                	beqz	a5,80002dae <hanle_page_fault+0x8e>
    swap_to_memory(p, va);
    80002d96:	85ca                	mv	a1,s2
    80002d98:	8526                	mv	a0,s1
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	ef2080e7          	jalr	-270(ra) # 80002c8c <swap_to_memory>
}
    80002da2:	60e2                	ld	ra,24(sp)
    80002da4:	6442                	ld	s0,16(sp)
    80002da6:	64a2                	ld	s1,8(sp)
    80002da8:	6902                	ld	s2,0(sp)
    80002daa:	6105                	addi	sp,sp,32
    80002dac:	8082                	ret
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dae:	142025f3          	csrr	a1,scause
    printf("usertrap1(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002db2:	5890                	lw	a2,48(s1)
    80002db4:	00006517          	auipc	a0,0x6
    80002db8:	72c50513          	addi	a0,a0,1836 # 800094e0 <digits+0x4a0>
    80002dbc:	ffffd097          	auipc	ra,0xffffd
    80002dc0:	7b8080e7          	jalr	1976(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dc4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dc8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dcc:	00006517          	auipc	a0,0x6
    80002dd0:	74450513          	addi	a0,a0,1860 # 80009510 <digits+0x4d0>
    80002dd4:	ffffd097          	auipc	ra,0xffffd
    80002dd8:	7a0080e7          	jalr	1952(ra) # 80000574 <printf>
    p->killed = 1;
    80002ddc:	4785                	li	a5,1
    80002dde:	d49c                	sw	a5,40(s1)
}
    80002de0:	b7c9                	j	80002da2 <hanle_page_fault+0x82>

0000000080002de2 <update_counter_NFUA>:
  return toReturn;
}
#endif

#ifdef NFUA
void update_counter_NFUA(struct proc* p) {
    80002de2:	715d                	addi	sp,sp,-80
    80002de4:	e486                	sd	ra,72(sp)
    80002de6:	e0a2                	sd	s0,64(sp)
    80002de8:	fc26                	sd	s1,56(sp)
    80002dea:	f84a                	sd	s2,48(sp)
    80002dec:	f44e                	sd	s3,40(sp)
    80002dee:	f052                	sd	s4,32(sp)
    80002df0:	ec56                	sd	s5,24(sp)
    80002df2:	e85a                	sd	s6,16(sp)
    80002df4:	e45e                	sd	s7,8(sp)
    80002df6:	0880                	addi	s0,sp,80
    80002df8:	8aaa                	mv	s5,a0
  printf("-----------------------------------------------------------begin update_counter_NFUA\n");
    80002dfa:	00006517          	auipc	a0,0x6
    80002dfe:	73650513          	addi	a0,a0,1846 # 80009530 <digits+0x4f0>
    80002e02:	ffffd097          	auipc	ra,0xffffd
    80002e06:	772080e7          	jalr	1906(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    80002e0a:	670a8493          	addi	s1,s5,1648
    80002e0e:	6a05                	lui	s4,0x1
    80002e10:	8f0a0a13          	addi	s4,s4,-1808 # 8f0 <_entry-0x7ffff710>
    80002e14:	9a56                	add	s4,s4,s5
    // pte_t* pte = curr_page.page;
    if (curr_page.isAvailable == 0) {

      curr_page.counter_NFUA >>=1;
      if(*pte & PTE_A) {
        curr_page.counter_NFUA |= 0x80000000;
    80002e16:	80000bb7          	lui	s7,0x80000
        *pte &= ~PTE_A;
      }
    }
    printf("curr_page.counter_NFUA %h, %d\n", curr_page.counter_NFUA , curr_page.counter_NFUA );
    80002e1a:	00006b17          	auipc	s6,0x6
    80002e1e:	76eb0b13          	addi	s6,s6,1902 # 80009588 <digits+0x548>
    80002e22:	a821                	j	80002e3a <update_counter_NFUA+0x58>
    80002e24:	864a                	mv	a2,s2
    80002e26:	85ca                	mv	a1,s2
    80002e28:	855a                	mv	a0,s6
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	74a080e7          	jalr	1866(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    80002e32:	02848493          	addi	s1,s1,40
    80002e36:	05448063          	beq	s1,s4,80002e76 <update_counter_NFUA+0x94>
    struct page_struct curr_page = p->files_in_physicalmem[i];
    80002e3a:	0004a983          	lw	s3,0(s1)
    80002e3e:	0244a903          	lw	s2,36(s1)
    pte_t* pte = walk(p->pagetable, curr_page.va, 0);
    80002e42:	4601                	li	a2,0
    80002e44:	6c8c                	ld	a1,24(s1)
    80002e46:	050ab503          	ld	a0,80(s5)
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	15c080e7          	jalr	348(ra) # 80000fa6 <walk>
    if (curr_page.isAvailable == 0) {
    80002e52:	fc0999e3          	bnez	s3,80002e24 <update_counter_NFUA+0x42>
      curr_page.counter_NFUA >>=1;
    80002e56:	0019571b          	srliw	a4,s2,0x1
    80002e5a:	0007091b          	sext.w	s2,a4
      if(*pte & PTE_A) {
    80002e5e:	611c                	ld	a5,0(a0)
    80002e60:	0407f693          	andi	a3,a5,64
    80002e64:	d2e1                	beqz	a3,80002e24 <update_counter_NFUA+0x42>
        curr_page.counter_NFUA |= 0x80000000;
    80002e66:	01776733          	or	a4,a4,s7
    80002e6a:	0007091b          	sext.w	s2,a4
        *pte &= ~PTE_A;
    80002e6e:	fbf7f793          	andi	a5,a5,-65
    80002e72:	e11c                	sd	a5,0(a0)
    80002e74:	bf45                	j	80002e24 <update_counter_NFUA+0x42>
  }
  printf("end update_counter_NFUA\n");
    80002e76:	00006517          	auipc	a0,0x6
    80002e7a:	73250513          	addi	a0,a0,1842 # 800095a8 <digits+0x568>
    80002e7e:	ffffd097          	auipc	ra,0xffffd
    80002e82:	6f6080e7          	jalr	1782(ra) # 80000574 <printf>
}
    80002e86:	60a6                	ld	ra,72(sp)
    80002e88:	6406                	ld	s0,64(sp)
    80002e8a:	74e2                	ld	s1,56(sp)
    80002e8c:	7942                	ld	s2,48(sp)
    80002e8e:	79a2                	ld	s3,40(sp)
    80002e90:	7a02                	ld	s4,32(sp)
    80002e92:	6ae2                	ld	s5,24(sp)
    80002e94:	6b42                	ld	s6,16(sp)
    80002e96:	6ba2                	ld	s7,8(sp)
    80002e98:	6161                	addi	sp,sp,80
    80002e9a:	8082                	ret

0000000080002e9c <yield>:
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	e426                	sd	s1,8(sp)
    80002ea4:	1000                	addi	s0,sp,32
  printf("yield\n");
    80002ea6:	00006517          	auipc	a0,0x6
    80002eaa:	72250513          	addi	a0,a0,1826 # 800095c8 <digits+0x588>
    80002eae:	ffffd097          	auipc	ra,0xffffd
    80002eb2:	6c6080e7          	jalr	1734(ra) # 80000574 <printf>
  struct proc *p = myproc();
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	bd6080e7          	jalr	-1066(ra) # 80001a8c <myproc>
    80002ebe:	84aa                	mv	s1,a0
  if (myproc()->pid > 2) {
    80002ec0:	fffff097          	auipc	ra,0xfffff
    80002ec4:	bcc080e7          	jalr	-1076(ra) # 80001a8c <myproc>
    80002ec8:	5918                	lw	a4,48(a0)
    80002eca:	4789                	li	a5,2
    80002ecc:	02e7c763          	blt	a5,a4,80002efa <yield+0x5e>
  acquire(&p->lock);
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	cf0080e7          	jalr	-784(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002eda:	478d                	li	a5,3
    80002edc:	cc9c                	sw	a5,24(s1)
  sched();
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	e7a080e7          	jalr	-390(ra) # 80001d58 <sched>
  release(&p->lock);
    80002ee6:	8526                	mv	a0,s1
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	d8e080e7          	jalr	-626(ra) # 80000c76 <release>
}
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	64a2                	ld	s1,8(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret
    printf("hellohelloe\n");
    80002efa:	00006517          	auipc	a0,0x6
    80002efe:	6d650513          	addi	a0,a0,1750 # 800095d0 <digits+0x590>
    80002f02:	ffffd097          	auipc	ra,0xffffd
    80002f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    update_counter_NFUA(p);
    80002f0a:	8526                	mv	a0,s1
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	ed6080e7          	jalr	-298(ra) # 80002de2 <update_counter_NFUA>
    80002f14:	bf75                	j	80002ed0 <yield+0x34>

0000000080002f16 <swtch>:
    80002f16:	00153023          	sd	ra,0(a0)
    80002f1a:	00253423          	sd	sp,8(a0)
    80002f1e:	e900                	sd	s0,16(a0)
    80002f20:	ed04                	sd	s1,24(a0)
    80002f22:	03253023          	sd	s2,32(a0)
    80002f26:	03353423          	sd	s3,40(a0)
    80002f2a:	03453823          	sd	s4,48(a0)
    80002f2e:	03553c23          	sd	s5,56(a0)
    80002f32:	05653023          	sd	s6,64(a0)
    80002f36:	05753423          	sd	s7,72(a0)
    80002f3a:	05853823          	sd	s8,80(a0)
    80002f3e:	05953c23          	sd	s9,88(a0)
    80002f42:	07a53023          	sd	s10,96(a0)
    80002f46:	07b53423          	sd	s11,104(a0)
    80002f4a:	0005b083          	ld	ra,0(a1)
    80002f4e:	0085b103          	ld	sp,8(a1)
    80002f52:	6980                	ld	s0,16(a1)
    80002f54:	6d84                	ld	s1,24(a1)
    80002f56:	0205b903          	ld	s2,32(a1)
    80002f5a:	0285b983          	ld	s3,40(a1)
    80002f5e:	0305ba03          	ld	s4,48(a1)
    80002f62:	0385ba83          	ld	s5,56(a1)
    80002f66:	0405bb03          	ld	s6,64(a1)
    80002f6a:	0485bb83          	ld	s7,72(a1)
    80002f6e:	0505bc03          	ld	s8,80(a1)
    80002f72:	0585bc83          	ld	s9,88(a1)
    80002f76:	0605bd03          	ld	s10,96(a1)
    80002f7a:	0685bd83          	ld	s11,104(a1)
    80002f7e:	8082                	ret

0000000080002f80 <trapinit>:
extern int devintr();
extern void hanle_page_fault(struct proc* p);

void
trapinit(void)
{
    80002f80:	1141                	addi	sp,sp,-16
    80002f82:	e406                	sd	ra,8(sp)
    80002f84:	e022                	sd	s0,0(sp)
    80002f86:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f88:	00006597          	auipc	a1,0x6
    80002f8c:	6b058593          	addi	a1,a1,1712 # 80009638 <states.0+0x30>
    80002f90:	00033517          	auipc	a0,0x33
    80002f94:	74050513          	addi	a0,a0,1856 # 800366d0 <tickslock>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	b9a080e7          	jalr	-1126(ra) # 80000b32 <initlock>
}
    80002fa0:	60a2                	ld	ra,8(sp)
    80002fa2:	6402                	ld	s0,0(sp)
    80002fa4:	0141                	addi	sp,sp,16
    80002fa6:	8082                	ret

0000000080002fa8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002fa8:	1141                	addi	sp,sp,-16
    80002faa:	e422                	sd	s0,8(sp)
    80002fac:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fae:	00004797          	auipc	a5,0x4
    80002fb2:	a4278793          	addi	a5,a5,-1470 # 800069f0 <kernelvec>
    80002fb6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002fba:	6422                	ld	s0,8(sp)
    80002fbc:	0141                	addi	sp,sp,16
    80002fbe:	8082                	ret

0000000080002fc0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002fc0:	1141                	addi	sp,sp,-16
    80002fc2:	e406                	sd	ra,8(sp)
    80002fc4:	e022                	sd	s0,0(sp)
    80002fc6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	ac4080e7          	jalr	-1340(ra) # 80001a8c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002fd4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fd6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002fda:	00005617          	auipc	a2,0x5
    80002fde:	02660613          	addi	a2,a2,38 # 80008000 <_trampoline>
    80002fe2:	00005697          	auipc	a3,0x5
    80002fe6:	01e68693          	addi	a3,a3,30 # 80008000 <_trampoline>
    80002fea:	8e91                	sub	a3,a3,a2
    80002fec:	040007b7          	lui	a5,0x4000
    80002ff0:	17fd                	addi	a5,a5,-1
    80002ff2:	07b2                	slli	a5,a5,0xc
    80002ff4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ff6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ffa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ffc:	180026f3          	csrr	a3,satp
    80003000:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003002:	6d38                	ld	a4,88(a0)
    80003004:	6134                	ld	a3,64(a0)
    80003006:	6585                	lui	a1,0x1
    80003008:	96ae                	add	a3,a3,a1
    8000300a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000300c:	6d38                	ld	a4,88(a0)
    8000300e:	00000697          	auipc	a3,0x0
    80003012:	13868693          	addi	a3,a3,312 # 80003146 <usertrap>
    80003016:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003018:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000301a:	8692                	mv	a3,tp
    8000301c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000301e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003022:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003026:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000302a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000302e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003030:	6f18                	ld	a4,24(a4)
    80003032:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003036:	692c                	ld	a1,80(a0)
    80003038:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000303a:	00005717          	auipc	a4,0x5
    8000303e:	05670713          	addi	a4,a4,86 # 80008090 <userret>
    80003042:	8f11                	sub	a4,a4,a2
    80003044:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003046:	577d                	li	a4,-1
    80003048:	177e                	slli	a4,a4,0x3f
    8000304a:	8dd9                	or	a1,a1,a4
    8000304c:	02000537          	lui	a0,0x2000
    80003050:	157d                	addi	a0,a0,-1
    80003052:	0536                	slli	a0,a0,0xd
    80003054:	9782                	jalr	a5
}
    80003056:	60a2                	ld	ra,8(sp)
    80003058:	6402                	ld	s0,0(sp)
    8000305a:	0141                	addi	sp,sp,16
    8000305c:	8082                	ret

000000008000305e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003068:	00033497          	auipc	s1,0x33
    8000306c:	66848493          	addi	s1,s1,1640 # 800366d0 <tickslock>
    80003070:	8526                	mv	a0,s1
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	b50080e7          	jalr	-1200(ra) # 80000bc2 <acquire>
  ticks++;
    8000307a:	00007517          	auipc	a0,0x7
    8000307e:	fbe50513          	addi	a0,a0,-66 # 8000a038 <ticks>
    80003082:	411c                	lw	a5,0(a0)
    80003084:	2785                	addiw	a5,a5,1
    80003086:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	e0a080e7          	jalr	-502(ra) # 80001e92 <wakeup>
  release(&tickslock);
    80003090:	8526                	mv	a0,s1
    80003092:	ffffe097          	auipc	ra,0xffffe
    80003096:	be4080e7          	jalr	-1052(ra) # 80000c76 <release>
}
    8000309a:	60e2                	ld	ra,24(sp)
    8000309c:	6442                	ld	s0,16(sp)
    8000309e:	64a2                	ld	s1,8(sp)
    800030a0:	6105                	addi	sp,sp,32
    800030a2:	8082                	ret

00000000800030a4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800030a4:	1101                	addi	sp,sp,-32
    800030a6:	ec06                	sd	ra,24(sp)
    800030a8:	e822                	sd	s0,16(sp)
    800030aa:	e426                	sd	s1,8(sp)
    800030ac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030ae:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800030b2:	00074d63          	bltz	a4,800030cc <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800030b6:	57fd                	li	a5,-1
    800030b8:	17fe                	slli	a5,a5,0x3f
    800030ba:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800030bc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800030be:	06f70363          	beq	a4,a5,80003124 <devintr+0x80>
  }
}
    800030c2:	60e2                	ld	ra,24(sp)
    800030c4:	6442                	ld	s0,16(sp)
    800030c6:	64a2                	ld	s1,8(sp)
    800030c8:	6105                	addi	sp,sp,32
    800030ca:	8082                	ret
     (scause & 0xff) == 9){
    800030cc:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800030d0:	46a5                	li	a3,9
    800030d2:	fed792e3          	bne	a5,a3,800030b6 <devintr+0x12>
    int irq = plic_claim();
    800030d6:	00004097          	auipc	ra,0x4
    800030da:	a22080e7          	jalr	-1502(ra) # 80006af8 <plic_claim>
    800030de:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800030e0:	47a9                	li	a5,10
    800030e2:	02f50763          	beq	a0,a5,80003110 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800030e6:	4785                	li	a5,1
    800030e8:	02f50963          	beq	a0,a5,8000311a <devintr+0x76>
    return 1;
    800030ec:	4505                	li	a0,1
    } else if(irq){
    800030ee:	d8f1                	beqz	s1,800030c2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800030f0:	85a6                	mv	a1,s1
    800030f2:	00006517          	auipc	a0,0x6
    800030f6:	54e50513          	addi	a0,a0,1358 # 80009640 <states.0+0x38>
    800030fa:	ffffd097          	auipc	ra,0xffffd
    800030fe:	47a080e7          	jalr	1146(ra) # 80000574 <printf>
      plic_complete(irq);
    80003102:	8526                	mv	a0,s1
    80003104:	00004097          	auipc	ra,0x4
    80003108:	a18080e7          	jalr	-1512(ra) # 80006b1c <plic_complete>
    return 1;
    8000310c:	4505                	li	a0,1
    8000310e:	bf55                	j	800030c2 <devintr+0x1e>
      uartintr();
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	876080e7          	jalr	-1930(ra) # 80000986 <uartintr>
    80003118:	b7ed                	j	80003102 <devintr+0x5e>
      virtio_disk_intr();
    8000311a:	00004097          	auipc	ra,0x4
    8000311e:	e94080e7          	jalr	-364(ra) # 80006fae <virtio_disk_intr>
    80003122:	b7c5                	j	80003102 <devintr+0x5e>
    if(cpuid() == 0){
    80003124:	fffff097          	auipc	ra,0xfffff
    80003128:	93c080e7          	jalr	-1732(ra) # 80001a60 <cpuid>
    8000312c:	c901                	beqz	a0,8000313c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000312e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003132:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003134:	14479073          	csrw	sip,a5
    return 2;
    80003138:	4509                	li	a0,2
    8000313a:	b761                	j	800030c2 <devintr+0x1e>
      clockintr();
    8000313c:	00000097          	auipc	ra,0x0
    80003140:	f22080e7          	jalr	-222(ra) # 8000305e <clockintr>
    80003144:	b7ed                	j	8000312e <devintr+0x8a>

0000000080003146 <usertrap>:
{
    80003146:	1101                	addi	sp,sp,-32
    80003148:	ec06                	sd	ra,24(sp)
    8000314a:	e822                	sd	s0,16(sp)
    8000314c:	e426                	sd	s1,8(sp)
    8000314e:	e04a                	sd	s2,0(sp)
    80003150:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003152:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003156:	1007f793          	andi	a5,a5,256
    8000315a:	e3ad                	bnez	a5,800031bc <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000315c:	00004797          	auipc	a5,0x4
    80003160:	89478793          	addi	a5,a5,-1900 # 800069f0 <kernelvec>
    80003164:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003168:	fffff097          	auipc	ra,0xfffff
    8000316c:	924080e7          	jalr	-1756(ra) # 80001a8c <myproc>
    80003170:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003172:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003174:	14102773          	csrr	a4,sepc
    80003178:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000317a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000317e:	47a1                	li	a5,8
    80003180:	04f70663          	beq	a4,a5,800031cc <usertrap+0x86>
  } else if(p->pid > 2 && (r_scause() == 12 || r_scause() == 13 || r_scause() == 15)) {
    80003184:	5918                	lw	a4,48(a0)
    80003186:	4789                	li	a5,2
    80003188:	02e7d163          	bge	a5,a4,800031aa <usertrap+0x64>
    8000318c:	14202773          	csrr	a4,scause
    80003190:	47b1                	li	a5,12
    80003192:	06f70f63          	beq	a4,a5,80003210 <usertrap+0xca>
    80003196:	14202773          	csrr	a4,scause
    8000319a:	47b5                	li	a5,13
    8000319c:	06f70a63          	beq	a4,a5,80003210 <usertrap+0xca>
    800031a0:	14202773          	csrr	a4,scause
    800031a4:	47bd                	li	a5,15
    800031a6:	06f70563          	beq	a4,a5,80003210 <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    800031aa:	00000097          	auipc	ra,0x0
    800031ae:	efa080e7          	jalr	-262(ra) # 800030a4 <devintr>
    800031b2:	892a                	mv	s2,a0
    800031b4:	cd35                	beqz	a0,80003230 <usertrap+0xea>
  if(p->killed)
    800031b6:	549c                	lw	a5,40(s1)
    800031b8:	cfc5                	beqz	a5,80003270 <usertrap+0x12a>
    800031ba:	a075                	j	80003266 <usertrap+0x120>
    panic("usertrap: not from user mode");
    800031bc:	00006517          	auipc	a0,0x6
    800031c0:	4a450513          	addi	a0,a0,1188 # 80009660 <states.0+0x58>
    800031c4:	ffffd097          	auipc	ra,0xffffd
    800031c8:	366080e7          	jalr	870(ra) # 8000052a <panic>
    if(p->killed)
    800031cc:	551c                	lw	a5,40(a0)
    800031ce:	eb9d                	bnez	a5,80003204 <usertrap+0xbe>
    p->trapframe->epc += 4;
    800031d0:	6cb8                	ld	a4,88(s1)
    800031d2:	6f1c                	ld	a5,24(a4)
    800031d4:	0791                	addi	a5,a5,4
    800031d6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800031dc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800031e0:	10079073          	csrw	sstatus,a5
    syscall();
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	2de080e7          	jalr	734(ra) # 800034c2 <syscall>
  if(p->killed)
    800031ec:	549c                	lw	a5,40(s1)
    800031ee:	ebbd                	bnez	a5,80003264 <usertrap+0x11e>
  usertrapret();
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	dd0080e7          	jalr	-560(ra) # 80002fc0 <usertrapret>
}
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	64a2                	ld	s1,8(sp)
    800031fe:	6902                	ld	s2,0(sp)
    80003200:	6105                	addi	sp,sp,32
    80003202:	8082                	ret
      exit(-1);
    80003204:	557d                	li	a0,-1
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	d6c080e7          	jalr	-660(ra) # 80001f72 <exit>
    8000320e:	b7c9                	j	800031d0 <usertrap+0x8a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003210:	142025f3          	csrr	a1,scause
    printf("before handke page fault, r_scause: %d\n", r_scause());
    80003214:	00006517          	auipc	a0,0x6
    80003218:	46c50513          	addi	a0,a0,1132 # 80009680 <states.0+0x78>
    8000321c:	ffffd097          	auipc	ra,0xffffd
    80003220:	358080e7          	jalr	856(ra) # 80000574 <printf>
    hanle_page_fault(p);
    80003224:	8526                	mv	a0,s1
    80003226:	00000097          	auipc	ra,0x0
    8000322a:	afa080e7          	jalr	-1286(ra) # 80002d20 <hanle_page_fault>
    8000322e:	bf7d                	j	800031ec <usertrap+0xa6>
    80003230:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003234:	5890                	lw	a2,48(s1)
    80003236:	00006517          	auipc	a0,0x6
    8000323a:	47250513          	addi	a0,a0,1138 # 800096a8 <states.0+0xa0>
    8000323e:	ffffd097          	auipc	ra,0xffffd
    80003242:	336080e7          	jalr	822(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003246:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000324a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000324e:	00006517          	auipc	a0,0x6
    80003252:	2c250513          	addi	a0,a0,706 # 80009510 <digits+0x4d0>
    80003256:	ffffd097          	auipc	ra,0xffffd
    8000325a:	31e080e7          	jalr	798(ra) # 80000574 <printf>
    p->killed = 1;
    8000325e:	4785                	li	a5,1
    80003260:	d49c                	sw	a5,40(s1)
  if(p->killed)
    80003262:	a011                	j	80003266 <usertrap+0x120>
    80003264:	4901                	li	s2,0
    exit(-1);
    80003266:	557d                	li	a0,-1
    80003268:	fffff097          	auipc	ra,0xfffff
    8000326c:	d0a080e7          	jalr	-758(ra) # 80001f72 <exit>
  if(which_dev == 2)
    80003270:	4789                	li	a5,2
    80003272:	f6f91fe3          	bne	s2,a5,800031f0 <usertrap+0xaa>
    yield();
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	c26080e7          	jalr	-986(ra) # 80002e9c <yield>
    8000327e:	bf8d                	j	800031f0 <usertrap+0xaa>

0000000080003280 <kerneltrap>:
{
    80003280:	7179                	addi	sp,sp,-48
    80003282:	f406                	sd	ra,40(sp)
    80003284:	f022                	sd	s0,32(sp)
    80003286:	ec26                	sd	s1,24(sp)
    80003288:	e84a                	sd	s2,16(sp)
    8000328a:	e44e                	sd	s3,8(sp)
    8000328c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000328e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003292:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003296:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000329a:	1004f793          	andi	a5,s1,256
    8000329e:	cb85                	beqz	a5,800032ce <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032a0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800032a4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800032a6:	ef85                	bnez	a5,800032de <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800032a8:	00000097          	auipc	ra,0x0
    800032ac:	dfc080e7          	jalr	-516(ra) # 800030a4 <devintr>
    800032b0:	cd1d                	beqz	a0,800032ee <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032b2:	4789                	li	a5,2
    800032b4:	06f50a63          	beq	a0,a5,80003328 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800032b8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800032bc:	10049073          	csrw	sstatus,s1
}
    800032c0:	70a2                	ld	ra,40(sp)
    800032c2:	7402                	ld	s0,32(sp)
    800032c4:	64e2                	ld	s1,24(sp)
    800032c6:	6942                	ld	s2,16(sp)
    800032c8:	69a2                	ld	s3,8(sp)
    800032ca:	6145                	addi	sp,sp,48
    800032cc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800032ce:	00006517          	auipc	a0,0x6
    800032d2:	40a50513          	addi	a0,a0,1034 # 800096d8 <states.0+0xd0>
    800032d6:	ffffd097          	auipc	ra,0xffffd
    800032da:	254080e7          	jalr	596(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800032de:	00006517          	auipc	a0,0x6
    800032e2:	42250513          	addi	a0,a0,1058 # 80009700 <states.0+0xf8>
    800032e6:	ffffd097          	auipc	ra,0xffffd
    800032ea:	244080e7          	jalr	580(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    800032ee:	85ce                	mv	a1,s3
    800032f0:	00006517          	auipc	a0,0x6
    800032f4:	43050513          	addi	a0,a0,1072 # 80009720 <states.0+0x118>
    800032f8:	ffffd097          	auipc	ra,0xffffd
    800032fc:	27c080e7          	jalr	636(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003300:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003304:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003308:	00006517          	auipc	a0,0x6
    8000330c:	42850513          	addi	a0,a0,1064 # 80009730 <states.0+0x128>
    80003310:	ffffd097          	auipc	ra,0xffffd
    80003314:	264080e7          	jalr	612(ra) # 80000574 <printf>
    panic("kerneltrap");
    80003318:	00006517          	auipc	a0,0x6
    8000331c:	43050513          	addi	a0,a0,1072 # 80009748 <states.0+0x140>
    80003320:	ffffd097          	auipc	ra,0xffffd
    80003324:	20a080e7          	jalr	522(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003328:	ffffe097          	auipc	ra,0xffffe
    8000332c:	764080e7          	jalr	1892(ra) # 80001a8c <myproc>
    80003330:	d541                	beqz	a0,800032b8 <kerneltrap+0x38>
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	75a080e7          	jalr	1882(ra) # 80001a8c <myproc>
    8000333a:	4d18                	lw	a4,24(a0)
    8000333c:	4791                	li	a5,4
    8000333e:	f6f71de3          	bne	a4,a5,800032b8 <kerneltrap+0x38>
    yield();
    80003342:	00000097          	auipc	ra,0x0
    80003346:	b5a080e7          	jalr	-1190(ra) # 80002e9c <yield>
    8000334a:	b7bd                	j	800032b8 <kerneltrap+0x38>

000000008000334c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000334c:	1101                	addi	sp,sp,-32
    8000334e:	ec06                	sd	ra,24(sp)
    80003350:	e822                	sd	s0,16(sp)
    80003352:	e426                	sd	s1,8(sp)
    80003354:	1000                	addi	s0,sp,32
    80003356:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	734080e7          	jalr	1844(ra) # 80001a8c <myproc>
  switch (n) {
    80003360:	4795                	li	a5,5
    80003362:	0497e163          	bltu	a5,s1,800033a4 <argraw+0x58>
    80003366:	048a                	slli	s1,s1,0x2
    80003368:	00006717          	auipc	a4,0x6
    8000336c:	41870713          	addi	a4,a4,1048 # 80009780 <states.0+0x178>
    80003370:	94ba                	add	s1,s1,a4
    80003372:	409c                	lw	a5,0(s1)
    80003374:	97ba                	add	a5,a5,a4
    80003376:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003378:	6d3c                	ld	a5,88(a0)
    8000337a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000337c:	60e2                	ld	ra,24(sp)
    8000337e:	6442                	ld	s0,16(sp)
    80003380:	64a2                	ld	s1,8(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret
    return p->trapframe->a1;
    80003386:	6d3c                	ld	a5,88(a0)
    80003388:	7fa8                	ld	a0,120(a5)
    8000338a:	bfcd                	j	8000337c <argraw+0x30>
    return p->trapframe->a2;
    8000338c:	6d3c                	ld	a5,88(a0)
    8000338e:	63c8                	ld	a0,128(a5)
    80003390:	b7f5                	j	8000337c <argraw+0x30>
    return p->trapframe->a3;
    80003392:	6d3c                	ld	a5,88(a0)
    80003394:	67c8                	ld	a0,136(a5)
    80003396:	b7dd                	j	8000337c <argraw+0x30>
    return p->trapframe->a4;
    80003398:	6d3c                	ld	a5,88(a0)
    8000339a:	6bc8                	ld	a0,144(a5)
    8000339c:	b7c5                	j	8000337c <argraw+0x30>
    return p->trapframe->a5;
    8000339e:	6d3c                	ld	a5,88(a0)
    800033a0:	6fc8                	ld	a0,152(a5)
    800033a2:	bfe9                	j	8000337c <argraw+0x30>
  panic("argraw");
    800033a4:	00006517          	auipc	a0,0x6
    800033a8:	3b450513          	addi	a0,a0,948 # 80009758 <states.0+0x150>
    800033ac:	ffffd097          	auipc	ra,0xffffd
    800033b0:	17e080e7          	jalr	382(ra) # 8000052a <panic>

00000000800033b4 <fetchaddr>:
{
    800033b4:	1101                	addi	sp,sp,-32
    800033b6:	ec06                	sd	ra,24(sp)
    800033b8:	e822                	sd	s0,16(sp)
    800033ba:	e426                	sd	s1,8(sp)
    800033bc:	e04a                	sd	s2,0(sp)
    800033be:	1000                	addi	s0,sp,32
    800033c0:	84aa                	mv	s1,a0
    800033c2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	6c8080e7          	jalr	1736(ra) # 80001a8c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800033cc:	653c                	ld	a5,72(a0)
    800033ce:	02f4f863          	bgeu	s1,a5,800033fe <fetchaddr+0x4a>
    800033d2:	00848713          	addi	a4,s1,8
    800033d6:	02e7e663          	bltu	a5,a4,80003402 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800033da:	46a1                	li	a3,8
    800033dc:	8626                	mv	a2,s1
    800033de:	85ca                	mv	a1,s2
    800033e0:	6928                	ld	a0,80(a0)
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	3e2080e7          	jalr	994(ra) # 800017c4 <copyin>
    800033ea:	00a03533          	snez	a0,a0
    800033ee:	40a00533          	neg	a0,a0
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6902                	ld	s2,0(sp)
    800033fa:	6105                	addi	sp,sp,32
    800033fc:	8082                	ret
    return -1;
    800033fe:	557d                	li	a0,-1
    80003400:	bfcd                	j	800033f2 <fetchaddr+0x3e>
    80003402:	557d                	li	a0,-1
    80003404:	b7fd                	j	800033f2 <fetchaddr+0x3e>

0000000080003406 <fetchstr>:
{
    80003406:	7179                	addi	sp,sp,-48
    80003408:	f406                	sd	ra,40(sp)
    8000340a:	f022                	sd	s0,32(sp)
    8000340c:	ec26                	sd	s1,24(sp)
    8000340e:	e84a                	sd	s2,16(sp)
    80003410:	e44e                	sd	s3,8(sp)
    80003412:	1800                	addi	s0,sp,48
    80003414:	892a                	mv	s2,a0
    80003416:	84ae                	mv	s1,a1
    80003418:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	672080e7          	jalr	1650(ra) # 80001a8c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003422:	86ce                	mv	a3,s3
    80003424:	864a                	mv	a2,s2
    80003426:	85a6                	mv	a1,s1
    80003428:	6928                	ld	a0,80(a0)
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	428080e7          	jalr	1064(ra) # 80001852 <copyinstr>
  if(err < 0)
    80003432:	00054763          	bltz	a0,80003440 <fetchstr+0x3a>
  return strlen(buf);
    80003436:	8526                	mv	a0,s1
    80003438:	ffffe097          	auipc	ra,0xffffe
    8000343c:	a0a080e7          	jalr	-1526(ra) # 80000e42 <strlen>
}
    80003440:	70a2                	ld	ra,40(sp)
    80003442:	7402                	ld	s0,32(sp)
    80003444:	64e2                	ld	s1,24(sp)
    80003446:	6942                	ld	s2,16(sp)
    80003448:	69a2                	ld	s3,8(sp)
    8000344a:	6145                	addi	sp,sp,48
    8000344c:	8082                	ret

000000008000344e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	e426                	sd	s1,8(sp)
    80003456:	1000                	addi	s0,sp,32
    80003458:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	ef2080e7          	jalr	-270(ra) # 8000334c <argraw>
    80003462:	c088                	sw	a0,0(s1)
  return 0;
}
    80003464:	4501                	li	a0,0
    80003466:	60e2                	ld	ra,24(sp)
    80003468:	6442                	ld	s0,16(sp)
    8000346a:	64a2                	ld	s1,8(sp)
    8000346c:	6105                	addi	sp,sp,32
    8000346e:	8082                	ret

0000000080003470 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003470:	1101                	addi	sp,sp,-32
    80003472:	ec06                	sd	ra,24(sp)
    80003474:	e822                	sd	s0,16(sp)
    80003476:	e426                	sd	s1,8(sp)
    80003478:	1000                	addi	s0,sp,32
    8000347a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000347c:	00000097          	auipc	ra,0x0
    80003480:	ed0080e7          	jalr	-304(ra) # 8000334c <argraw>
    80003484:	e088                	sd	a0,0(s1)
  return 0;
}
    80003486:	4501                	li	a0,0
    80003488:	60e2                	ld	ra,24(sp)
    8000348a:	6442                	ld	s0,16(sp)
    8000348c:	64a2                	ld	s1,8(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret

0000000080003492 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	e04a                	sd	s2,0(sp)
    8000349c:	1000                	addi	s0,sp,32
    8000349e:	84ae                	mv	s1,a1
    800034a0:	8932                	mv	s2,a2
  *ip = argraw(n);
    800034a2:	00000097          	auipc	ra,0x0
    800034a6:	eaa080e7          	jalr	-342(ra) # 8000334c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800034aa:	864a                	mv	a2,s2
    800034ac:	85a6                	mv	a1,s1
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	f58080e7          	jalr	-168(ra) # 80003406 <fetchstr>
}
    800034b6:	60e2                	ld	ra,24(sp)
    800034b8:	6442                	ld	s0,16(sp)
    800034ba:	64a2                	ld	s1,8(sp)
    800034bc:	6902                	ld	s2,0(sp)
    800034be:	6105                	addi	sp,sp,32
    800034c0:	8082                	ret

00000000800034c2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800034c2:	1101                	addi	sp,sp,-32
    800034c4:	ec06                	sd	ra,24(sp)
    800034c6:	e822                	sd	s0,16(sp)
    800034c8:	e426                	sd	s1,8(sp)
    800034ca:	e04a                	sd	s2,0(sp)
    800034cc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800034ce:	ffffe097          	auipc	ra,0xffffe
    800034d2:	5be080e7          	jalr	1470(ra) # 80001a8c <myproc>
    800034d6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800034d8:	05853903          	ld	s2,88(a0)
    800034dc:	0a893783          	ld	a5,168(s2)
    800034e0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800034e4:	37fd                	addiw	a5,a5,-1
    800034e6:	4751                	li	a4,20
    800034e8:	00f76f63          	bltu	a4,a5,80003506 <syscall+0x44>
    800034ec:	00369713          	slli	a4,a3,0x3
    800034f0:	00006797          	auipc	a5,0x6
    800034f4:	2a878793          	addi	a5,a5,680 # 80009798 <syscalls>
    800034f8:	97ba                	add	a5,a5,a4
    800034fa:	639c                	ld	a5,0(a5)
    800034fc:	c789                	beqz	a5,80003506 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800034fe:	9782                	jalr	a5
    80003500:	06a93823          	sd	a0,112(s2)
    80003504:	a839                	j	80003522 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003506:	15848613          	addi	a2,s1,344
    8000350a:	588c                	lw	a1,48(s1)
    8000350c:	00006517          	auipc	a0,0x6
    80003510:	25450513          	addi	a0,a0,596 # 80009760 <states.0+0x158>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	060080e7          	jalr	96(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000351c:	6cbc                	ld	a5,88(s1)
    8000351e:	577d                	li	a4,-1
    80003520:	fbb8                	sd	a4,112(a5)
  }
}
    80003522:	60e2                	ld	ra,24(sp)
    80003524:	6442                	ld	s0,16(sp)
    80003526:	64a2                	ld	s1,8(sp)
    80003528:	6902                	ld	s2,0(sp)
    8000352a:	6105                	addi	sp,sp,32
    8000352c:	8082                	ret

000000008000352e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000352e:	1101                	addi	sp,sp,-32
    80003530:	ec06                	sd	ra,24(sp)
    80003532:	e822                	sd	s0,16(sp)
    80003534:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003536:	fec40593          	addi	a1,s0,-20
    8000353a:	4501                	li	a0,0
    8000353c:	00000097          	auipc	ra,0x0
    80003540:	f12080e7          	jalr	-238(ra) # 8000344e <argint>
    return -1;
    80003544:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003546:	00054963          	bltz	a0,80003558 <sys_exit+0x2a>
  exit(n);
    8000354a:	fec42503          	lw	a0,-20(s0)
    8000354e:	fffff097          	auipc	ra,0xfffff
    80003552:	a24080e7          	jalr	-1500(ra) # 80001f72 <exit>
  return 0;  // not reached
    80003556:	4781                	li	a5,0
}
    80003558:	853e                	mv	a0,a5
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	6105                	addi	sp,sp,32
    80003560:	8082                	ret

0000000080003562 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003562:	1141                	addi	sp,sp,-16
    80003564:	e406                	sd	ra,8(sp)
    80003566:	e022                	sd	s0,0(sp)
    80003568:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000356a:	ffffe097          	auipc	ra,0xffffe
    8000356e:	522080e7          	jalr	1314(ra) # 80001a8c <myproc>
}
    80003572:	5908                	lw	a0,48(a0)
    80003574:	60a2                	ld	ra,8(sp)
    80003576:	6402                	ld	s0,0(sp)
    80003578:	0141                	addi	sp,sp,16
    8000357a:	8082                	ret

000000008000357c <sys_fork>:

uint64
sys_fork(void)
{
    8000357c:	1141                	addi	sp,sp,-16
    8000357e:	e406                	sd	ra,8(sp)
    80003580:	e022                	sd	s0,0(sp)
    80003582:	0800                	addi	s0,sp,16
  return fork();
    80003584:	fffff097          	auipc	ra,0xfffff
    80003588:	204080e7          	jalr	516(ra) # 80002788 <fork>
}
    8000358c:	60a2                	ld	ra,8(sp)
    8000358e:	6402                	ld	s0,0(sp)
    80003590:	0141                	addi	sp,sp,16
    80003592:	8082                	ret

0000000080003594 <sys_wait>:

uint64
sys_wait(void)
{
    80003594:	1101                	addi	sp,sp,-32
    80003596:	ec06                	sd	ra,24(sp)
    80003598:	e822                	sd	s0,16(sp)
    8000359a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000359c:	fe840593          	addi	a1,s0,-24
    800035a0:	4501                	li	a0,0
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	ece080e7          	jalr	-306(ra) # 80003470 <argaddr>
    800035aa:	87aa                	mv	a5,a0
    return -1;
    800035ac:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800035ae:	0007c863          	bltz	a5,800035be <sys_wait+0x2a>
  return wait(p);
    800035b2:	fe843503          	ld	a0,-24(s0)
    800035b6:	fffff097          	auipc	ra,0xfffff
    800035ba:	db8080e7          	jalr	-584(ra) # 8000236e <wait>
}
    800035be:	60e2                	ld	ra,24(sp)
    800035c0:	6442                	ld	s0,16(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret

00000000800035c6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800035c6:	7179                	addi	sp,sp,-48
    800035c8:	f406                	sd	ra,40(sp)
    800035ca:	f022                	sd	s0,32(sp)
    800035cc:	ec26                	sd	s1,24(sp)
    800035ce:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800035d0:	fdc40593          	addi	a1,s0,-36
    800035d4:	4501                	li	a0,0
    800035d6:	00000097          	auipc	ra,0x0
    800035da:	e78080e7          	jalr	-392(ra) # 8000344e <argint>
    return -1;
    800035de:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800035e0:	00054f63          	bltz	a0,800035fe <sys_sbrk+0x38>
  addr = myproc()->sz;
    800035e4:	ffffe097          	auipc	ra,0xffffe
    800035e8:	4a8080e7          	jalr	1192(ra) # 80001a8c <myproc>
    800035ec:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800035ee:	fdc42503          	lw	a0,-36(s0)
    800035f2:	ffffe097          	auipc	ra,0xffffe
    800035f6:	64c080e7          	jalr	1612(ra) # 80001c3e <growproc>
    800035fa:	00054863          	bltz	a0,8000360a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800035fe:	8526                	mv	a0,s1
    80003600:	70a2                	ld	ra,40(sp)
    80003602:	7402                	ld	s0,32(sp)
    80003604:	64e2                	ld	s1,24(sp)
    80003606:	6145                	addi	sp,sp,48
    80003608:	8082                	ret
    return -1;
    8000360a:	54fd                	li	s1,-1
    8000360c:	bfcd                	j	800035fe <sys_sbrk+0x38>

000000008000360e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000360e:	7139                	addi	sp,sp,-64
    80003610:	fc06                	sd	ra,56(sp)
    80003612:	f822                	sd	s0,48(sp)
    80003614:	f426                	sd	s1,40(sp)
    80003616:	f04a                	sd	s2,32(sp)
    80003618:	ec4e                	sd	s3,24(sp)
    8000361a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000361c:	fcc40593          	addi	a1,s0,-52
    80003620:	4501                	li	a0,0
    80003622:	00000097          	auipc	ra,0x0
    80003626:	e2c080e7          	jalr	-468(ra) # 8000344e <argint>
    return -1;
    8000362a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000362c:	06054563          	bltz	a0,80003696 <sys_sleep+0x88>
  acquire(&tickslock);
    80003630:	00033517          	auipc	a0,0x33
    80003634:	0a050513          	addi	a0,a0,160 # 800366d0 <tickslock>
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	58a080e7          	jalr	1418(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003640:	00007917          	auipc	s2,0x7
    80003644:	9f892903          	lw	s2,-1544(s2) # 8000a038 <ticks>
  while(ticks - ticks0 < n){
    80003648:	fcc42783          	lw	a5,-52(s0)
    8000364c:	cf85                	beqz	a5,80003684 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000364e:	00033997          	auipc	s3,0x33
    80003652:	08298993          	addi	s3,s3,130 # 800366d0 <tickslock>
    80003656:	00007497          	auipc	s1,0x7
    8000365a:	9e248493          	addi	s1,s1,-1566 # 8000a038 <ticks>
    if(myproc()->killed){
    8000365e:	ffffe097          	auipc	ra,0xffffe
    80003662:	42e080e7          	jalr	1070(ra) # 80001a8c <myproc>
    80003666:	551c                	lw	a5,40(a0)
    80003668:	ef9d                	bnez	a5,800036a6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000366a:	85ce                	mv	a1,s3
    8000366c:	8526                	mv	a0,s1
    8000366e:	ffffe097          	auipc	ra,0xffffe
    80003672:	7c0080e7          	jalr	1984(ra) # 80001e2e <sleep>
  while(ticks - ticks0 < n){
    80003676:	409c                	lw	a5,0(s1)
    80003678:	412787bb          	subw	a5,a5,s2
    8000367c:	fcc42703          	lw	a4,-52(s0)
    80003680:	fce7efe3          	bltu	a5,a4,8000365e <sys_sleep+0x50>
  }
  release(&tickslock);
    80003684:	00033517          	auipc	a0,0x33
    80003688:	04c50513          	addi	a0,a0,76 # 800366d0 <tickslock>
    8000368c:	ffffd097          	auipc	ra,0xffffd
    80003690:	5ea080e7          	jalr	1514(ra) # 80000c76 <release>
  return 0;
    80003694:	4781                	li	a5,0
}
    80003696:	853e                	mv	a0,a5
    80003698:	70e2                	ld	ra,56(sp)
    8000369a:	7442                	ld	s0,48(sp)
    8000369c:	74a2                	ld	s1,40(sp)
    8000369e:	7902                	ld	s2,32(sp)
    800036a0:	69e2                	ld	s3,24(sp)
    800036a2:	6121                	addi	sp,sp,64
    800036a4:	8082                	ret
      release(&tickslock);
    800036a6:	00033517          	auipc	a0,0x33
    800036aa:	02a50513          	addi	a0,a0,42 # 800366d0 <tickslock>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	5c8080e7          	jalr	1480(ra) # 80000c76 <release>
      return -1;
    800036b6:	57fd                	li	a5,-1
    800036b8:	bff9                	j	80003696 <sys_sleep+0x88>

00000000800036ba <sys_kill>:

uint64
sys_kill(void)
{
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800036c2:	fec40593          	addi	a1,s0,-20
    800036c6:	4501                	li	a0,0
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	d86080e7          	jalr	-634(ra) # 8000344e <argint>
    800036d0:	87aa                	mv	a5,a0
    return -1;
    800036d2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800036d4:	0007c863          	bltz	a5,800036e4 <sys_kill+0x2a>
  return kill(pid);
    800036d8:	fec42503          	lw	a0,-20(s0)
    800036dc:	fffff097          	auipc	ra,0xfffff
    800036e0:	982080e7          	jalr	-1662(ra) # 8000205e <kill>
}
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	e426                	sd	s1,8(sp)
    800036f4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800036f6:	00033517          	auipc	a0,0x33
    800036fa:	fda50513          	addi	a0,a0,-38 # 800366d0 <tickslock>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	4c4080e7          	jalr	1220(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003706:	00007497          	auipc	s1,0x7
    8000370a:	9324a483          	lw	s1,-1742(s1) # 8000a038 <ticks>
  release(&tickslock);
    8000370e:	00033517          	auipc	a0,0x33
    80003712:	fc250513          	addi	a0,a0,-62 # 800366d0 <tickslock>
    80003716:	ffffd097          	auipc	ra,0xffffd
    8000371a:	560080e7          	jalr	1376(ra) # 80000c76 <release>
  return xticks;
}
    8000371e:	02049513          	slli	a0,s1,0x20
    80003722:	9101                	srli	a0,a0,0x20
    80003724:	60e2                	ld	ra,24(sp)
    80003726:	6442                	ld	s0,16(sp)
    80003728:	64a2                	ld	s1,8(sp)
    8000372a:	6105                	addi	sp,sp,32
    8000372c:	8082                	ret

000000008000372e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000372e:	7179                	addi	sp,sp,-48
    80003730:	f406                	sd	ra,40(sp)
    80003732:	f022                	sd	s0,32(sp)
    80003734:	ec26                	sd	s1,24(sp)
    80003736:	e84a                	sd	s2,16(sp)
    80003738:	e44e                	sd	s3,8(sp)
    8000373a:	e052                	sd	s4,0(sp)
    8000373c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000373e:	00006597          	auipc	a1,0x6
    80003742:	10a58593          	addi	a1,a1,266 # 80009848 <syscalls+0xb0>
    80003746:	00033517          	auipc	a0,0x33
    8000374a:	fa250513          	addi	a0,a0,-94 # 800366e8 <bcache>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	3e4080e7          	jalr	996(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003756:	0003b797          	auipc	a5,0x3b
    8000375a:	f9278793          	addi	a5,a5,-110 # 8003e6e8 <bcache+0x8000>
    8000375e:	0003b717          	auipc	a4,0x3b
    80003762:	1f270713          	addi	a4,a4,498 # 8003e950 <bcache+0x8268>
    80003766:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000376a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000376e:	00033497          	auipc	s1,0x33
    80003772:	f9248493          	addi	s1,s1,-110 # 80036700 <bcache+0x18>
    b->next = bcache.head.next;
    80003776:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003778:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000377a:	00006a17          	auipc	s4,0x6
    8000377e:	0d6a0a13          	addi	s4,s4,214 # 80009850 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003782:	2b893783          	ld	a5,696(s2)
    80003786:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003788:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000378c:	85d2                	mv	a1,s4
    8000378e:	01048513          	addi	a0,s1,16
    80003792:	00001097          	auipc	ra,0x1
    80003796:	7d4080e7          	jalr	2004(ra) # 80004f66 <initsleeplock>
    bcache.head.next->prev = b;
    8000379a:	2b893783          	ld	a5,696(s2)
    8000379e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800037a0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037a4:	45848493          	addi	s1,s1,1112
    800037a8:	fd349de3          	bne	s1,s3,80003782 <binit+0x54>
  }
}
    800037ac:	70a2                	ld	ra,40(sp)
    800037ae:	7402                	ld	s0,32(sp)
    800037b0:	64e2                	ld	s1,24(sp)
    800037b2:	6942                	ld	s2,16(sp)
    800037b4:	69a2                	ld	s3,8(sp)
    800037b6:	6a02                	ld	s4,0(sp)
    800037b8:	6145                	addi	sp,sp,48
    800037ba:	8082                	ret

00000000800037bc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037bc:	7179                	addi	sp,sp,-48
    800037be:	f406                	sd	ra,40(sp)
    800037c0:	f022                	sd	s0,32(sp)
    800037c2:	ec26                	sd	s1,24(sp)
    800037c4:	e84a                	sd	s2,16(sp)
    800037c6:	e44e                	sd	s3,8(sp)
    800037c8:	1800                	addi	s0,sp,48
    800037ca:	892a                	mv	s2,a0
    800037cc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800037ce:	00033517          	auipc	a0,0x33
    800037d2:	f1a50513          	addi	a0,a0,-230 # 800366e8 <bcache>
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	3ec080e7          	jalr	1004(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800037de:	0003b497          	auipc	s1,0x3b
    800037e2:	1c24b483          	ld	s1,450(s1) # 8003e9a0 <bcache+0x82b8>
    800037e6:	0003b797          	auipc	a5,0x3b
    800037ea:	16a78793          	addi	a5,a5,362 # 8003e950 <bcache+0x8268>
    800037ee:	02f48f63          	beq	s1,a5,8000382c <bread+0x70>
    800037f2:	873e                	mv	a4,a5
    800037f4:	a021                	j	800037fc <bread+0x40>
    800037f6:	68a4                	ld	s1,80(s1)
    800037f8:	02e48a63          	beq	s1,a4,8000382c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800037fc:	449c                	lw	a5,8(s1)
    800037fe:	ff279ce3          	bne	a5,s2,800037f6 <bread+0x3a>
    80003802:	44dc                	lw	a5,12(s1)
    80003804:	ff3799e3          	bne	a5,s3,800037f6 <bread+0x3a>
      b->refcnt++;
    80003808:	40bc                	lw	a5,64(s1)
    8000380a:	2785                	addiw	a5,a5,1
    8000380c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000380e:	00033517          	auipc	a0,0x33
    80003812:	eda50513          	addi	a0,a0,-294 # 800366e8 <bcache>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	460080e7          	jalr	1120(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000381e:	01048513          	addi	a0,s1,16
    80003822:	00001097          	auipc	ra,0x1
    80003826:	77e080e7          	jalr	1918(ra) # 80004fa0 <acquiresleep>
      return b;
    8000382a:	a8b9                	j	80003888 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000382c:	0003b497          	auipc	s1,0x3b
    80003830:	16c4b483          	ld	s1,364(s1) # 8003e998 <bcache+0x82b0>
    80003834:	0003b797          	auipc	a5,0x3b
    80003838:	11c78793          	addi	a5,a5,284 # 8003e950 <bcache+0x8268>
    8000383c:	00f48863          	beq	s1,a5,8000384c <bread+0x90>
    80003840:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003842:	40bc                	lw	a5,64(s1)
    80003844:	cf81                	beqz	a5,8000385c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003846:	64a4                	ld	s1,72(s1)
    80003848:	fee49de3          	bne	s1,a4,80003842 <bread+0x86>
  panic("bget: no buffers");
    8000384c:	00006517          	auipc	a0,0x6
    80003850:	00c50513          	addi	a0,a0,12 # 80009858 <syscalls+0xc0>
    80003854:	ffffd097          	auipc	ra,0xffffd
    80003858:	cd6080e7          	jalr	-810(ra) # 8000052a <panic>
      b->dev = dev;
    8000385c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003860:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003864:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003868:	4785                	li	a5,1
    8000386a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000386c:	00033517          	auipc	a0,0x33
    80003870:	e7c50513          	addi	a0,a0,-388 # 800366e8 <bcache>
    80003874:	ffffd097          	auipc	ra,0xffffd
    80003878:	402080e7          	jalr	1026(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000387c:	01048513          	addi	a0,s1,16
    80003880:	00001097          	auipc	ra,0x1
    80003884:	720080e7          	jalr	1824(ra) # 80004fa0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003888:	409c                	lw	a5,0(s1)
    8000388a:	cb89                	beqz	a5,8000389c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000388c:	8526                	mv	a0,s1
    8000388e:	70a2                	ld	ra,40(sp)
    80003890:	7402                	ld	s0,32(sp)
    80003892:	64e2                	ld	s1,24(sp)
    80003894:	6942                	ld	s2,16(sp)
    80003896:	69a2                	ld	s3,8(sp)
    80003898:	6145                	addi	sp,sp,48
    8000389a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000389c:	4581                	li	a1,0
    8000389e:	8526                	mv	a0,s1
    800038a0:	00003097          	auipc	ra,0x3
    800038a4:	486080e7          	jalr	1158(ra) # 80006d26 <virtio_disk_rw>
    b->valid = 1;
    800038a8:	4785                	li	a5,1
    800038aa:	c09c                	sw	a5,0(s1)
  return b;
    800038ac:	b7c5                	j	8000388c <bread+0xd0>

00000000800038ae <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038ae:	1101                	addi	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	1000                	addi	s0,sp,32
    800038b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038ba:	0541                	addi	a0,a0,16
    800038bc:	00001097          	auipc	ra,0x1
    800038c0:	77e080e7          	jalr	1918(ra) # 8000503a <holdingsleep>
    800038c4:	cd01                	beqz	a0,800038dc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038c6:	4585                	li	a1,1
    800038c8:	8526                	mv	a0,s1
    800038ca:	00003097          	auipc	ra,0x3
    800038ce:	45c080e7          	jalr	1116(ra) # 80006d26 <virtio_disk_rw>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret
    panic("bwrite");
    800038dc:	00006517          	auipc	a0,0x6
    800038e0:	f9450513          	addi	a0,a0,-108 # 80009870 <syscalls+0xd8>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	c46080e7          	jalr	-954(ra) # 8000052a <panic>

00000000800038ec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038ec:	1101                	addi	sp,sp,-32
    800038ee:	ec06                	sd	ra,24(sp)
    800038f0:	e822                	sd	s0,16(sp)
    800038f2:	e426                	sd	s1,8(sp)
    800038f4:	e04a                	sd	s2,0(sp)
    800038f6:	1000                	addi	s0,sp,32
    800038f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038fa:	01050913          	addi	s2,a0,16
    800038fe:	854a                	mv	a0,s2
    80003900:	00001097          	auipc	ra,0x1
    80003904:	73a080e7          	jalr	1850(ra) # 8000503a <holdingsleep>
    80003908:	c92d                	beqz	a0,8000397a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000390a:	854a                	mv	a0,s2
    8000390c:	00001097          	auipc	ra,0x1
    80003910:	6ea080e7          	jalr	1770(ra) # 80004ff6 <releasesleep>

  acquire(&bcache.lock);
    80003914:	00033517          	auipc	a0,0x33
    80003918:	dd450513          	addi	a0,a0,-556 # 800366e8 <bcache>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	2a6080e7          	jalr	678(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003924:	40bc                	lw	a5,64(s1)
    80003926:	37fd                	addiw	a5,a5,-1
    80003928:	0007871b          	sext.w	a4,a5
    8000392c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000392e:	eb05                	bnez	a4,8000395e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003930:	68bc                	ld	a5,80(s1)
    80003932:	64b8                	ld	a4,72(s1)
    80003934:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003936:	64bc                	ld	a5,72(s1)
    80003938:	68b8                	ld	a4,80(s1)
    8000393a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000393c:	0003b797          	auipc	a5,0x3b
    80003940:	dac78793          	addi	a5,a5,-596 # 8003e6e8 <bcache+0x8000>
    80003944:	2b87b703          	ld	a4,696(a5)
    80003948:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000394a:	0003b717          	auipc	a4,0x3b
    8000394e:	00670713          	addi	a4,a4,6 # 8003e950 <bcache+0x8268>
    80003952:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003954:	2b87b703          	ld	a4,696(a5)
    80003958:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000395a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000395e:	00033517          	auipc	a0,0x33
    80003962:	d8a50513          	addi	a0,a0,-630 # 800366e8 <bcache>
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	310080e7          	jalr	784(ra) # 80000c76 <release>
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6902                	ld	s2,0(sp)
    80003976:	6105                	addi	sp,sp,32
    80003978:	8082                	ret
    panic("brelse");
    8000397a:	00006517          	auipc	a0,0x6
    8000397e:	efe50513          	addi	a0,a0,-258 # 80009878 <syscalls+0xe0>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	ba8080e7          	jalr	-1112(ra) # 8000052a <panic>

000000008000398a <bpin>:

void
bpin(struct buf *b) {
    8000398a:	1101                	addi	sp,sp,-32
    8000398c:	ec06                	sd	ra,24(sp)
    8000398e:	e822                	sd	s0,16(sp)
    80003990:	e426                	sd	s1,8(sp)
    80003992:	1000                	addi	s0,sp,32
    80003994:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003996:	00033517          	auipc	a0,0x33
    8000399a:	d5250513          	addi	a0,a0,-686 # 800366e8 <bcache>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	224080e7          	jalr	548(ra) # 80000bc2 <acquire>
  b->refcnt++;
    800039a6:	40bc                	lw	a5,64(s1)
    800039a8:	2785                	addiw	a5,a5,1
    800039aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039ac:	00033517          	auipc	a0,0x33
    800039b0:	d3c50513          	addi	a0,a0,-708 # 800366e8 <bcache>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	2c2080e7          	jalr	706(ra) # 80000c76 <release>
}
    800039bc:	60e2                	ld	ra,24(sp)
    800039be:	6442                	ld	s0,16(sp)
    800039c0:	64a2                	ld	s1,8(sp)
    800039c2:	6105                	addi	sp,sp,32
    800039c4:	8082                	ret

00000000800039c6 <bunpin>:

void
bunpin(struct buf *b) {
    800039c6:	1101                	addi	sp,sp,-32
    800039c8:	ec06                	sd	ra,24(sp)
    800039ca:	e822                	sd	s0,16(sp)
    800039cc:	e426                	sd	s1,8(sp)
    800039ce:	1000                	addi	s0,sp,32
    800039d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039d2:	00033517          	auipc	a0,0x33
    800039d6:	d1650513          	addi	a0,a0,-746 # 800366e8 <bcache>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	1e8080e7          	jalr	488(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800039e2:	40bc                	lw	a5,64(s1)
    800039e4:	37fd                	addiw	a5,a5,-1
    800039e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039e8:	00033517          	auipc	a0,0x33
    800039ec:	d0050513          	addi	a0,a0,-768 # 800366e8 <bcache>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	286080e7          	jalr	646(ra) # 80000c76 <release>
}
    800039f8:	60e2                	ld	ra,24(sp)
    800039fa:	6442                	ld	s0,16(sp)
    800039fc:	64a2                	ld	s1,8(sp)
    800039fe:	6105                	addi	sp,sp,32
    80003a00:	8082                	ret

0000000080003a02 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a02:	1101                	addi	sp,sp,-32
    80003a04:	ec06                	sd	ra,24(sp)
    80003a06:	e822                	sd	s0,16(sp)
    80003a08:	e426                	sd	s1,8(sp)
    80003a0a:	e04a                	sd	s2,0(sp)
    80003a0c:	1000                	addi	s0,sp,32
    80003a0e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a10:	00d5d59b          	srliw	a1,a1,0xd
    80003a14:	0003b797          	auipc	a5,0x3b
    80003a18:	3b07a783          	lw	a5,944(a5) # 8003edc4 <sb+0x1c>
    80003a1c:	9dbd                	addw	a1,a1,a5
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	d9e080e7          	jalr	-610(ra) # 800037bc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a26:	0074f713          	andi	a4,s1,7
    80003a2a:	4785                	li	a5,1
    80003a2c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a30:	14ce                	slli	s1,s1,0x33
    80003a32:	90d9                	srli	s1,s1,0x36
    80003a34:	00950733          	add	a4,a0,s1
    80003a38:	05874703          	lbu	a4,88(a4)
    80003a3c:	00e7f6b3          	and	a3,a5,a4
    80003a40:	c69d                	beqz	a3,80003a6e <bfree+0x6c>
    80003a42:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a44:	94aa                	add	s1,s1,a0
    80003a46:	fff7c793          	not	a5,a5
    80003a4a:	8ff9                	and	a5,a5,a4
    80003a4c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003a50:	00001097          	auipc	ra,0x1
    80003a54:	430080e7          	jalr	1072(ra) # 80004e80 <log_write>
  brelse(bp);
    80003a58:	854a                	mv	a0,s2
    80003a5a:	00000097          	auipc	ra,0x0
    80003a5e:	e92080e7          	jalr	-366(ra) # 800038ec <brelse>
}
    80003a62:	60e2                	ld	ra,24(sp)
    80003a64:	6442                	ld	s0,16(sp)
    80003a66:	64a2                	ld	s1,8(sp)
    80003a68:	6902                	ld	s2,0(sp)
    80003a6a:	6105                	addi	sp,sp,32
    80003a6c:	8082                	ret
    panic("freeing free block");
    80003a6e:	00006517          	auipc	a0,0x6
    80003a72:	e1250513          	addi	a0,a0,-494 # 80009880 <syscalls+0xe8>
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	ab4080e7          	jalr	-1356(ra) # 8000052a <panic>

0000000080003a7e <balloc>:
{
    80003a7e:	711d                	addi	sp,sp,-96
    80003a80:	ec86                	sd	ra,88(sp)
    80003a82:	e8a2                	sd	s0,80(sp)
    80003a84:	e4a6                	sd	s1,72(sp)
    80003a86:	e0ca                	sd	s2,64(sp)
    80003a88:	fc4e                	sd	s3,56(sp)
    80003a8a:	f852                	sd	s4,48(sp)
    80003a8c:	f456                	sd	s5,40(sp)
    80003a8e:	f05a                	sd	s6,32(sp)
    80003a90:	ec5e                	sd	s7,24(sp)
    80003a92:	e862                	sd	s8,16(sp)
    80003a94:	e466                	sd	s9,8(sp)
    80003a96:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a98:	0003b797          	auipc	a5,0x3b
    80003a9c:	3147a783          	lw	a5,788(a5) # 8003edac <sb+0x4>
    80003aa0:	cbd1                	beqz	a5,80003b34 <balloc+0xb6>
    80003aa2:	8baa                	mv	s7,a0
    80003aa4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003aa6:	0003bb17          	auipc	s6,0x3b
    80003aaa:	302b0b13          	addi	s6,s6,770 # 8003eda8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003ab0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ab2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003ab4:	6c89                	lui	s9,0x2
    80003ab6:	a831                	j	80003ad2 <balloc+0x54>
    brelse(bp);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	e32080e7          	jalr	-462(ra) # 800038ec <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ac2:	015c87bb          	addw	a5,s9,s5
    80003ac6:	00078a9b          	sext.w	s5,a5
    80003aca:	004b2703          	lw	a4,4(s6)
    80003ace:	06eaf363          	bgeu	s5,a4,80003b34 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003ad2:	41fad79b          	sraiw	a5,s5,0x1f
    80003ad6:	0137d79b          	srliw	a5,a5,0x13
    80003ada:	015787bb          	addw	a5,a5,s5
    80003ade:	40d7d79b          	sraiw	a5,a5,0xd
    80003ae2:	01cb2583          	lw	a1,28(s6)
    80003ae6:	9dbd                	addw	a1,a1,a5
    80003ae8:	855e                	mv	a0,s7
    80003aea:	00000097          	auipc	ra,0x0
    80003aee:	cd2080e7          	jalr	-814(ra) # 800037bc <bread>
    80003af2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003af4:	004b2503          	lw	a0,4(s6)
    80003af8:	000a849b          	sext.w	s1,s5
    80003afc:	8662                	mv	a2,s8
    80003afe:	faa4fde3          	bgeu	s1,a0,80003ab8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003b02:	41f6579b          	sraiw	a5,a2,0x1f
    80003b06:	01d7d69b          	srliw	a3,a5,0x1d
    80003b0a:	00c6873b          	addw	a4,a3,a2
    80003b0e:	00777793          	andi	a5,a4,7
    80003b12:	9f95                	subw	a5,a5,a3
    80003b14:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b18:	4037571b          	sraiw	a4,a4,0x3
    80003b1c:	00e906b3          	add	a3,s2,a4
    80003b20:	0586c683          	lbu	a3,88(a3)
    80003b24:	00d7f5b3          	and	a1,a5,a3
    80003b28:	cd91                	beqz	a1,80003b44 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b2a:	2605                	addiw	a2,a2,1
    80003b2c:	2485                	addiw	s1,s1,1
    80003b2e:	fd4618e3          	bne	a2,s4,80003afe <balloc+0x80>
    80003b32:	b759                	j	80003ab8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003b34:	00006517          	auipc	a0,0x6
    80003b38:	d6450513          	addi	a0,a0,-668 # 80009898 <syscalls+0x100>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	9ee080e7          	jalr	-1554(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b44:	974a                	add	a4,a4,s2
    80003b46:	8fd5                	or	a5,a5,a3
    80003b48:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003b4c:	854a                	mv	a0,s2
    80003b4e:	00001097          	auipc	ra,0x1
    80003b52:	332080e7          	jalr	818(ra) # 80004e80 <log_write>
        brelse(bp);
    80003b56:	854a                	mv	a0,s2
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	d94080e7          	jalr	-620(ra) # 800038ec <brelse>
  bp = bread(dev, bno);
    80003b60:	85a6                	mv	a1,s1
    80003b62:	855e                	mv	a0,s7
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	c58080e7          	jalr	-936(ra) # 800037bc <bread>
    80003b6c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003b6e:	40000613          	li	a2,1024
    80003b72:	4581                	li	a1,0
    80003b74:	05850513          	addi	a0,a0,88
    80003b78:	ffffd097          	auipc	ra,0xffffd
    80003b7c:	146080e7          	jalr	326(ra) # 80000cbe <memset>
  log_write(bp);
    80003b80:	854a                	mv	a0,s2
    80003b82:	00001097          	auipc	ra,0x1
    80003b86:	2fe080e7          	jalr	766(ra) # 80004e80 <log_write>
  brelse(bp);
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	d60080e7          	jalr	-672(ra) # 800038ec <brelse>
}
    80003b94:	8526                	mv	a0,s1
    80003b96:	60e6                	ld	ra,88(sp)
    80003b98:	6446                	ld	s0,80(sp)
    80003b9a:	64a6                	ld	s1,72(sp)
    80003b9c:	6906                	ld	s2,64(sp)
    80003b9e:	79e2                	ld	s3,56(sp)
    80003ba0:	7a42                	ld	s4,48(sp)
    80003ba2:	7aa2                	ld	s5,40(sp)
    80003ba4:	7b02                	ld	s6,32(sp)
    80003ba6:	6be2                	ld	s7,24(sp)
    80003ba8:	6c42                	ld	s8,16(sp)
    80003baa:	6ca2                	ld	s9,8(sp)
    80003bac:	6125                	addi	sp,sp,96
    80003bae:	8082                	ret

0000000080003bb0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003bb0:	7179                	addi	sp,sp,-48
    80003bb2:	f406                	sd	ra,40(sp)
    80003bb4:	f022                	sd	s0,32(sp)
    80003bb6:	ec26                	sd	s1,24(sp)
    80003bb8:	e84a                	sd	s2,16(sp)
    80003bba:	e44e                	sd	s3,8(sp)
    80003bbc:	e052                	sd	s4,0(sp)
    80003bbe:	1800                	addi	s0,sp,48
    80003bc0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003bc2:	47ad                	li	a5,11
    80003bc4:	04b7fe63          	bgeu	a5,a1,80003c20 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003bc8:	ff45849b          	addiw	s1,a1,-12
    80003bcc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bd0:	0ff00793          	li	a5,255
    80003bd4:	0ae7e463          	bltu	a5,a4,80003c7c <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003bd8:	08052583          	lw	a1,128(a0)
    80003bdc:	c5b5                	beqz	a1,80003c48 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003bde:	00092503          	lw	a0,0(s2)
    80003be2:	00000097          	auipc	ra,0x0
    80003be6:	bda080e7          	jalr	-1062(ra) # 800037bc <bread>
    80003bea:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bec:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bf0:	02049713          	slli	a4,s1,0x20
    80003bf4:	01e75593          	srli	a1,a4,0x1e
    80003bf8:	00b784b3          	add	s1,a5,a1
    80003bfc:	0004a983          	lw	s3,0(s1)
    80003c00:	04098e63          	beqz	s3,80003c5c <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003c04:	8552                	mv	a0,s4
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	ce6080e7          	jalr	-794(ra) # 800038ec <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c0e:	854e                	mv	a0,s3
    80003c10:	70a2                	ld	ra,40(sp)
    80003c12:	7402                	ld	s0,32(sp)
    80003c14:	64e2                	ld	s1,24(sp)
    80003c16:	6942                	ld	s2,16(sp)
    80003c18:	69a2                	ld	s3,8(sp)
    80003c1a:	6a02                	ld	s4,0(sp)
    80003c1c:	6145                	addi	sp,sp,48
    80003c1e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003c20:	02059793          	slli	a5,a1,0x20
    80003c24:	01e7d593          	srli	a1,a5,0x1e
    80003c28:	00b504b3          	add	s1,a0,a1
    80003c2c:	0504a983          	lw	s3,80(s1)
    80003c30:	fc099fe3          	bnez	s3,80003c0e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003c34:	4108                	lw	a0,0(a0)
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	e48080e7          	jalr	-440(ra) # 80003a7e <balloc>
    80003c3e:	0005099b          	sext.w	s3,a0
    80003c42:	0534a823          	sw	s3,80(s1)
    80003c46:	b7e1                	j	80003c0e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003c48:	4108                	lw	a0,0(a0)
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	e34080e7          	jalr	-460(ra) # 80003a7e <balloc>
    80003c52:	0005059b          	sext.w	a1,a0
    80003c56:	08b92023          	sw	a1,128(s2)
    80003c5a:	b751                	j	80003bde <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003c5c:	00092503          	lw	a0,0(s2)
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	e1e080e7          	jalr	-482(ra) # 80003a7e <balloc>
    80003c68:	0005099b          	sext.w	s3,a0
    80003c6c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003c70:	8552                	mv	a0,s4
    80003c72:	00001097          	auipc	ra,0x1
    80003c76:	20e080e7          	jalr	526(ra) # 80004e80 <log_write>
    80003c7a:	b769                	j	80003c04 <bmap+0x54>
  panic("bmap: out of range");
    80003c7c:	00006517          	auipc	a0,0x6
    80003c80:	c3450513          	addi	a0,a0,-972 # 800098b0 <syscalls+0x118>
    80003c84:	ffffd097          	auipc	ra,0xffffd
    80003c88:	8a6080e7          	jalr	-1882(ra) # 8000052a <panic>

0000000080003c8c <iget>:
{
    80003c8c:	7179                	addi	sp,sp,-48
    80003c8e:	f406                	sd	ra,40(sp)
    80003c90:	f022                	sd	s0,32(sp)
    80003c92:	ec26                	sd	s1,24(sp)
    80003c94:	e84a                	sd	s2,16(sp)
    80003c96:	e44e                	sd	s3,8(sp)
    80003c98:	e052                	sd	s4,0(sp)
    80003c9a:	1800                	addi	s0,sp,48
    80003c9c:	89aa                	mv	s3,a0
    80003c9e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003ca0:	0003b517          	auipc	a0,0x3b
    80003ca4:	12850513          	addi	a0,a0,296 # 8003edc8 <itable>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	f1a080e7          	jalr	-230(ra) # 80000bc2 <acquire>
  empty = 0;
    80003cb0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003cb2:	0003b497          	auipc	s1,0x3b
    80003cb6:	12e48493          	addi	s1,s1,302 # 8003ede0 <itable+0x18>
    80003cba:	0003d697          	auipc	a3,0x3d
    80003cbe:	bb668693          	addi	a3,a3,-1098 # 80040870 <log>
    80003cc2:	a039                	j	80003cd0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cc4:	02090b63          	beqz	s2,80003cfa <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003cc8:	08848493          	addi	s1,s1,136
    80003ccc:	02d48a63          	beq	s1,a3,80003d00 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003cd0:	449c                	lw	a5,8(s1)
    80003cd2:	fef059e3          	blez	a5,80003cc4 <iget+0x38>
    80003cd6:	4098                	lw	a4,0(s1)
    80003cd8:	ff3716e3          	bne	a4,s3,80003cc4 <iget+0x38>
    80003cdc:	40d8                	lw	a4,4(s1)
    80003cde:	ff4713e3          	bne	a4,s4,80003cc4 <iget+0x38>
      ip->ref++;
    80003ce2:	2785                	addiw	a5,a5,1
    80003ce4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ce6:	0003b517          	auipc	a0,0x3b
    80003cea:	0e250513          	addi	a0,a0,226 # 8003edc8 <itable>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	f88080e7          	jalr	-120(ra) # 80000c76 <release>
      return ip;
    80003cf6:	8926                	mv	s2,s1
    80003cf8:	a03d                	j	80003d26 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cfa:	f7f9                	bnez	a5,80003cc8 <iget+0x3c>
    80003cfc:	8926                	mv	s2,s1
    80003cfe:	b7e9                	j	80003cc8 <iget+0x3c>
  if(empty == 0)
    80003d00:	02090c63          	beqz	s2,80003d38 <iget+0xac>
  ip->dev = dev;
    80003d04:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d08:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d0c:	4785                	li	a5,1
    80003d0e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d12:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d16:	0003b517          	auipc	a0,0x3b
    80003d1a:	0b250513          	addi	a0,a0,178 # 8003edc8 <itable>
    80003d1e:	ffffd097          	auipc	ra,0xffffd
    80003d22:	f58080e7          	jalr	-168(ra) # 80000c76 <release>
}
    80003d26:	854a                	mv	a0,s2
    80003d28:	70a2                	ld	ra,40(sp)
    80003d2a:	7402                	ld	s0,32(sp)
    80003d2c:	64e2                	ld	s1,24(sp)
    80003d2e:	6942                	ld	s2,16(sp)
    80003d30:	69a2                	ld	s3,8(sp)
    80003d32:	6a02                	ld	s4,0(sp)
    80003d34:	6145                	addi	sp,sp,48
    80003d36:	8082                	ret
    panic("iget: no inodes");
    80003d38:	00006517          	auipc	a0,0x6
    80003d3c:	b9050513          	addi	a0,a0,-1136 # 800098c8 <syscalls+0x130>
    80003d40:	ffffc097          	auipc	ra,0xffffc
    80003d44:	7ea080e7          	jalr	2026(ra) # 8000052a <panic>

0000000080003d48 <fsinit>:
fsinit(int dev) {
    80003d48:	7179                	addi	sp,sp,-48
    80003d4a:	f406                	sd	ra,40(sp)
    80003d4c:	f022                	sd	s0,32(sp)
    80003d4e:	ec26                	sd	s1,24(sp)
    80003d50:	e84a                	sd	s2,16(sp)
    80003d52:	e44e                	sd	s3,8(sp)
    80003d54:	1800                	addi	s0,sp,48
    80003d56:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d58:	4585                	li	a1,1
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	a62080e7          	jalr	-1438(ra) # 800037bc <bread>
    80003d62:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d64:	0003b997          	auipc	s3,0x3b
    80003d68:	04498993          	addi	s3,s3,68 # 8003eda8 <sb>
    80003d6c:	02000613          	li	a2,32
    80003d70:	05850593          	addi	a1,a0,88
    80003d74:	854e                	mv	a0,s3
    80003d76:	ffffd097          	auipc	ra,0xffffd
    80003d7a:	fa4080e7          	jalr	-92(ra) # 80000d1a <memmove>
  brelse(bp);
    80003d7e:	8526                	mv	a0,s1
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	b6c080e7          	jalr	-1172(ra) # 800038ec <brelse>
  if(sb.magic != FSMAGIC)
    80003d88:	0009a703          	lw	a4,0(s3)
    80003d8c:	102037b7          	lui	a5,0x10203
    80003d90:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d94:	02f71263          	bne	a4,a5,80003db8 <fsinit+0x70>
  initlog(dev, &sb);
    80003d98:	0003b597          	auipc	a1,0x3b
    80003d9c:	01058593          	addi	a1,a1,16 # 8003eda8 <sb>
    80003da0:	854a                	mv	a0,s2
    80003da2:	00001097          	auipc	ra,0x1
    80003da6:	e60080e7          	jalr	-416(ra) # 80004c02 <initlog>
}
    80003daa:	70a2                	ld	ra,40(sp)
    80003dac:	7402                	ld	s0,32(sp)
    80003dae:	64e2                	ld	s1,24(sp)
    80003db0:	6942                	ld	s2,16(sp)
    80003db2:	69a2                	ld	s3,8(sp)
    80003db4:	6145                	addi	sp,sp,48
    80003db6:	8082                	ret
    panic("invalid file system");
    80003db8:	00006517          	auipc	a0,0x6
    80003dbc:	b2050513          	addi	a0,a0,-1248 # 800098d8 <syscalls+0x140>
    80003dc0:	ffffc097          	auipc	ra,0xffffc
    80003dc4:	76a080e7          	jalr	1898(ra) # 8000052a <panic>

0000000080003dc8 <iinit>:
{
    80003dc8:	7179                	addi	sp,sp,-48
    80003dca:	f406                	sd	ra,40(sp)
    80003dcc:	f022                	sd	s0,32(sp)
    80003dce:	ec26                	sd	s1,24(sp)
    80003dd0:	e84a                	sd	s2,16(sp)
    80003dd2:	e44e                	sd	s3,8(sp)
    80003dd4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003dd6:	00006597          	auipc	a1,0x6
    80003dda:	b1a58593          	addi	a1,a1,-1254 # 800098f0 <syscalls+0x158>
    80003dde:	0003b517          	auipc	a0,0x3b
    80003de2:	fea50513          	addi	a0,a0,-22 # 8003edc8 <itable>
    80003de6:	ffffd097          	auipc	ra,0xffffd
    80003dea:	d4c080e7          	jalr	-692(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003dee:	0003b497          	auipc	s1,0x3b
    80003df2:	00248493          	addi	s1,s1,2 # 8003edf0 <itable+0x28>
    80003df6:	0003d997          	auipc	s3,0x3d
    80003dfa:	a8a98993          	addi	s3,s3,-1398 # 80040880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003dfe:	00006917          	auipc	s2,0x6
    80003e02:	afa90913          	addi	s2,s2,-1286 # 800098f8 <syscalls+0x160>
    80003e06:	85ca                	mv	a1,s2
    80003e08:	8526                	mv	a0,s1
    80003e0a:	00001097          	auipc	ra,0x1
    80003e0e:	15c080e7          	jalr	348(ra) # 80004f66 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003e12:	08848493          	addi	s1,s1,136
    80003e16:	ff3498e3          	bne	s1,s3,80003e06 <iinit+0x3e>
}
    80003e1a:	70a2                	ld	ra,40(sp)
    80003e1c:	7402                	ld	s0,32(sp)
    80003e1e:	64e2                	ld	s1,24(sp)
    80003e20:	6942                	ld	s2,16(sp)
    80003e22:	69a2                	ld	s3,8(sp)
    80003e24:	6145                	addi	sp,sp,48
    80003e26:	8082                	ret

0000000080003e28 <ialloc>:
{
    80003e28:	715d                	addi	sp,sp,-80
    80003e2a:	e486                	sd	ra,72(sp)
    80003e2c:	e0a2                	sd	s0,64(sp)
    80003e2e:	fc26                	sd	s1,56(sp)
    80003e30:	f84a                	sd	s2,48(sp)
    80003e32:	f44e                	sd	s3,40(sp)
    80003e34:	f052                	sd	s4,32(sp)
    80003e36:	ec56                	sd	s5,24(sp)
    80003e38:	e85a                	sd	s6,16(sp)
    80003e3a:	e45e                	sd	s7,8(sp)
    80003e3c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e3e:	0003b717          	auipc	a4,0x3b
    80003e42:	f7672703          	lw	a4,-138(a4) # 8003edb4 <sb+0xc>
    80003e46:	4785                	li	a5,1
    80003e48:	04e7fa63          	bgeu	a5,a4,80003e9c <ialloc+0x74>
    80003e4c:	8aaa                	mv	s5,a0
    80003e4e:	8bae                	mv	s7,a1
    80003e50:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e52:	0003ba17          	auipc	s4,0x3b
    80003e56:	f56a0a13          	addi	s4,s4,-170 # 8003eda8 <sb>
    80003e5a:	00048b1b          	sext.w	s6,s1
    80003e5e:	0044d793          	srli	a5,s1,0x4
    80003e62:	018a2583          	lw	a1,24(s4)
    80003e66:	9dbd                	addw	a1,a1,a5
    80003e68:	8556                	mv	a0,s5
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	952080e7          	jalr	-1710(ra) # 800037bc <bread>
    80003e72:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e74:	05850993          	addi	s3,a0,88
    80003e78:	00f4f793          	andi	a5,s1,15
    80003e7c:	079a                	slli	a5,a5,0x6
    80003e7e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e80:	00099783          	lh	a5,0(s3)
    80003e84:	c785                	beqz	a5,80003eac <ialloc+0x84>
    brelse(bp);
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	a66080e7          	jalr	-1434(ra) # 800038ec <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e8e:	0485                	addi	s1,s1,1
    80003e90:	00ca2703          	lw	a4,12(s4)
    80003e94:	0004879b          	sext.w	a5,s1
    80003e98:	fce7e1e3          	bltu	a5,a4,80003e5a <ialloc+0x32>
  panic("ialloc: no inodes");
    80003e9c:	00006517          	auipc	a0,0x6
    80003ea0:	a6450513          	addi	a0,a0,-1436 # 80009900 <syscalls+0x168>
    80003ea4:	ffffc097          	auipc	ra,0xffffc
    80003ea8:	686080e7          	jalr	1670(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003eac:	04000613          	li	a2,64
    80003eb0:	4581                	li	a1,0
    80003eb2:	854e                	mv	a0,s3
    80003eb4:	ffffd097          	auipc	ra,0xffffd
    80003eb8:	e0a080e7          	jalr	-502(ra) # 80000cbe <memset>
      dip->type = type;
    80003ebc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ec0:	854a                	mv	a0,s2
    80003ec2:	00001097          	auipc	ra,0x1
    80003ec6:	fbe080e7          	jalr	-66(ra) # 80004e80 <log_write>
      brelse(bp);
    80003eca:	854a                	mv	a0,s2
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	a20080e7          	jalr	-1504(ra) # 800038ec <brelse>
      return iget(dev, inum);
    80003ed4:	85da                	mv	a1,s6
    80003ed6:	8556                	mv	a0,s5
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	db4080e7          	jalr	-588(ra) # 80003c8c <iget>
}
    80003ee0:	60a6                	ld	ra,72(sp)
    80003ee2:	6406                	ld	s0,64(sp)
    80003ee4:	74e2                	ld	s1,56(sp)
    80003ee6:	7942                	ld	s2,48(sp)
    80003ee8:	79a2                	ld	s3,40(sp)
    80003eea:	7a02                	ld	s4,32(sp)
    80003eec:	6ae2                	ld	s5,24(sp)
    80003eee:	6b42                	ld	s6,16(sp)
    80003ef0:	6ba2                	ld	s7,8(sp)
    80003ef2:	6161                	addi	sp,sp,80
    80003ef4:	8082                	ret

0000000080003ef6 <iupdate>:
{
    80003ef6:	1101                	addi	sp,sp,-32
    80003ef8:	ec06                	sd	ra,24(sp)
    80003efa:	e822                	sd	s0,16(sp)
    80003efc:	e426                	sd	s1,8(sp)
    80003efe:	e04a                	sd	s2,0(sp)
    80003f00:	1000                	addi	s0,sp,32
    80003f02:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f04:	415c                	lw	a5,4(a0)
    80003f06:	0047d79b          	srliw	a5,a5,0x4
    80003f0a:	0003b597          	auipc	a1,0x3b
    80003f0e:	eb65a583          	lw	a1,-330(a1) # 8003edc0 <sb+0x18>
    80003f12:	9dbd                	addw	a1,a1,a5
    80003f14:	4108                	lw	a0,0(a0)
    80003f16:	00000097          	auipc	ra,0x0
    80003f1a:	8a6080e7          	jalr	-1882(ra) # 800037bc <bread>
    80003f1e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f20:	05850793          	addi	a5,a0,88
    80003f24:	40c8                	lw	a0,4(s1)
    80003f26:	893d                	andi	a0,a0,15
    80003f28:	051a                	slli	a0,a0,0x6
    80003f2a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003f2c:	04449703          	lh	a4,68(s1)
    80003f30:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003f34:	04649703          	lh	a4,70(s1)
    80003f38:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003f3c:	04849703          	lh	a4,72(s1)
    80003f40:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003f44:	04a49703          	lh	a4,74(s1)
    80003f48:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003f4c:	44f8                	lw	a4,76(s1)
    80003f4e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f50:	03400613          	li	a2,52
    80003f54:	05048593          	addi	a1,s1,80
    80003f58:	0531                	addi	a0,a0,12
    80003f5a:	ffffd097          	auipc	ra,0xffffd
    80003f5e:	dc0080e7          	jalr	-576(ra) # 80000d1a <memmove>
  log_write(bp);
    80003f62:	854a                	mv	a0,s2
    80003f64:	00001097          	auipc	ra,0x1
    80003f68:	f1c080e7          	jalr	-228(ra) # 80004e80 <log_write>
  brelse(bp);
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	97e080e7          	jalr	-1666(ra) # 800038ec <brelse>
}
    80003f76:	60e2                	ld	ra,24(sp)
    80003f78:	6442                	ld	s0,16(sp)
    80003f7a:	64a2                	ld	s1,8(sp)
    80003f7c:	6902                	ld	s2,0(sp)
    80003f7e:	6105                	addi	sp,sp,32
    80003f80:	8082                	ret

0000000080003f82 <idup>:
{
    80003f82:	1101                	addi	sp,sp,-32
    80003f84:	ec06                	sd	ra,24(sp)
    80003f86:	e822                	sd	s0,16(sp)
    80003f88:	e426                	sd	s1,8(sp)
    80003f8a:	1000                	addi	s0,sp,32
    80003f8c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f8e:	0003b517          	auipc	a0,0x3b
    80003f92:	e3a50513          	addi	a0,a0,-454 # 8003edc8 <itable>
    80003f96:	ffffd097          	auipc	ra,0xffffd
    80003f9a:	c2c080e7          	jalr	-980(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003f9e:	449c                	lw	a5,8(s1)
    80003fa0:	2785                	addiw	a5,a5,1
    80003fa2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fa4:	0003b517          	auipc	a0,0x3b
    80003fa8:	e2450513          	addi	a0,a0,-476 # 8003edc8 <itable>
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	cca080e7          	jalr	-822(ra) # 80000c76 <release>
}
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	60e2                	ld	ra,24(sp)
    80003fb8:	6442                	ld	s0,16(sp)
    80003fba:	64a2                	ld	s1,8(sp)
    80003fbc:	6105                	addi	sp,sp,32
    80003fbe:	8082                	ret

0000000080003fc0 <ilock>:
{
    80003fc0:	1101                	addi	sp,sp,-32
    80003fc2:	ec06                	sd	ra,24(sp)
    80003fc4:	e822                	sd	s0,16(sp)
    80003fc6:	e426                	sd	s1,8(sp)
    80003fc8:	e04a                	sd	s2,0(sp)
    80003fca:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003fcc:	c115                	beqz	a0,80003ff0 <ilock+0x30>
    80003fce:	84aa                	mv	s1,a0
    80003fd0:	451c                	lw	a5,8(a0)
    80003fd2:	00f05f63          	blez	a5,80003ff0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003fd6:	0541                	addi	a0,a0,16
    80003fd8:	00001097          	auipc	ra,0x1
    80003fdc:	fc8080e7          	jalr	-56(ra) # 80004fa0 <acquiresleep>
  if(ip->valid == 0){
    80003fe0:	40bc                	lw	a5,64(s1)
    80003fe2:	cf99                	beqz	a5,80004000 <ilock+0x40>
}
    80003fe4:	60e2                	ld	ra,24(sp)
    80003fe6:	6442                	ld	s0,16(sp)
    80003fe8:	64a2                	ld	s1,8(sp)
    80003fea:	6902                	ld	s2,0(sp)
    80003fec:	6105                	addi	sp,sp,32
    80003fee:	8082                	ret
    panic("ilock");
    80003ff0:	00006517          	auipc	a0,0x6
    80003ff4:	92850513          	addi	a0,a0,-1752 # 80009918 <syscalls+0x180>
    80003ff8:	ffffc097          	auipc	ra,0xffffc
    80003ffc:	532080e7          	jalr	1330(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004000:	40dc                	lw	a5,4(s1)
    80004002:	0047d79b          	srliw	a5,a5,0x4
    80004006:	0003b597          	auipc	a1,0x3b
    8000400a:	dba5a583          	lw	a1,-582(a1) # 8003edc0 <sb+0x18>
    8000400e:	9dbd                	addw	a1,a1,a5
    80004010:	4088                	lw	a0,0(s1)
    80004012:	fffff097          	auipc	ra,0xfffff
    80004016:	7aa080e7          	jalr	1962(ra) # 800037bc <bread>
    8000401a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000401c:	05850593          	addi	a1,a0,88
    80004020:	40dc                	lw	a5,4(s1)
    80004022:	8bbd                	andi	a5,a5,15
    80004024:	079a                	slli	a5,a5,0x6
    80004026:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004028:	00059783          	lh	a5,0(a1)
    8000402c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004030:	00259783          	lh	a5,2(a1)
    80004034:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004038:	00459783          	lh	a5,4(a1)
    8000403c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004040:	00659783          	lh	a5,6(a1)
    80004044:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004048:	459c                	lw	a5,8(a1)
    8000404a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000404c:	03400613          	li	a2,52
    80004050:	05b1                	addi	a1,a1,12
    80004052:	05048513          	addi	a0,s1,80
    80004056:	ffffd097          	auipc	ra,0xffffd
    8000405a:	cc4080e7          	jalr	-828(ra) # 80000d1a <memmove>
    brelse(bp);
    8000405e:	854a                	mv	a0,s2
    80004060:	00000097          	auipc	ra,0x0
    80004064:	88c080e7          	jalr	-1908(ra) # 800038ec <brelse>
    ip->valid = 1;
    80004068:	4785                	li	a5,1
    8000406a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000406c:	04449783          	lh	a5,68(s1)
    80004070:	fbb5                	bnez	a5,80003fe4 <ilock+0x24>
      panic("ilock: no type");
    80004072:	00006517          	auipc	a0,0x6
    80004076:	8ae50513          	addi	a0,a0,-1874 # 80009920 <syscalls+0x188>
    8000407a:	ffffc097          	auipc	ra,0xffffc
    8000407e:	4b0080e7          	jalr	1200(ra) # 8000052a <panic>

0000000080004082 <iunlock>:
{
    80004082:	1101                	addi	sp,sp,-32
    80004084:	ec06                	sd	ra,24(sp)
    80004086:	e822                	sd	s0,16(sp)
    80004088:	e426                	sd	s1,8(sp)
    8000408a:	e04a                	sd	s2,0(sp)
    8000408c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000408e:	c905                	beqz	a0,800040be <iunlock+0x3c>
    80004090:	84aa                	mv	s1,a0
    80004092:	01050913          	addi	s2,a0,16
    80004096:	854a                	mv	a0,s2
    80004098:	00001097          	auipc	ra,0x1
    8000409c:	fa2080e7          	jalr	-94(ra) # 8000503a <holdingsleep>
    800040a0:	cd19                	beqz	a0,800040be <iunlock+0x3c>
    800040a2:	449c                	lw	a5,8(s1)
    800040a4:	00f05d63          	blez	a5,800040be <iunlock+0x3c>
  releasesleep(&ip->lock);
    800040a8:	854a                	mv	a0,s2
    800040aa:	00001097          	auipc	ra,0x1
    800040ae:	f4c080e7          	jalr	-180(ra) # 80004ff6 <releasesleep>
}
    800040b2:	60e2                	ld	ra,24(sp)
    800040b4:	6442                	ld	s0,16(sp)
    800040b6:	64a2                	ld	s1,8(sp)
    800040b8:	6902                	ld	s2,0(sp)
    800040ba:	6105                	addi	sp,sp,32
    800040bc:	8082                	ret
    panic("iunlock");
    800040be:	00006517          	auipc	a0,0x6
    800040c2:	87250513          	addi	a0,a0,-1934 # 80009930 <syscalls+0x198>
    800040c6:	ffffc097          	auipc	ra,0xffffc
    800040ca:	464080e7          	jalr	1124(ra) # 8000052a <panic>

00000000800040ce <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800040ce:	7179                	addi	sp,sp,-48
    800040d0:	f406                	sd	ra,40(sp)
    800040d2:	f022                	sd	s0,32(sp)
    800040d4:	ec26                	sd	s1,24(sp)
    800040d6:	e84a                	sd	s2,16(sp)
    800040d8:	e44e                	sd	s3,8(sp)
    800040da:	e052                	sd	s4,0(sp)
    800040dc:	1800                	addi	s0,sp,48
    800040de:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040e0:	05050493          	addi	s1,a0,80
    800040e4:	08050913          	addi	s2,a0,128
    800040e8:	a021                	j	800040f0 <itrunc+0x22>
    800040ea:	0491                	addi	s1,s1,4
    800040ec:	01248d63          	beq	s1,s2,80004106 <itrunc+0x38>
    if(ip->addrs[i]){
    800040f0:	408c                	lw	a1,0(s1)
    800040f2:	dde5                	beqz	a1,800040ea <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800040f4:	0009a503          	lw	a0,0(s3)
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	90a080e7          	jalr	-1782(ra) # 80003a02 <bfree>
      ip->addrs[i] = 0;
    80004100:	0004a023          	sw	zero,0(s1)
    80004104:	b7dd                	j	800040ea <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004106:	0809a583          	lw	a1,128(s3)
    8000410a:	e185                	bnez	a1,8000412a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000410c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004110:	854e                	mv	a0,s3
    80004112:	00000097          	auipc	ra,0x0
    80004116:	de4080e7          	jalr	-540(ra) # 80003ef6 <iupdate>
}
    8000411a:	70a2                	ld	ra,40(sp)
    8000411c:	7402                	ld	s0,32(sp)
    8000411e:	64e2                	ld	s1,24(sp)
    80004120:	6942                	ld	s2,16(sp)
    80004122:	69a2                	ld	s3,8(sp)
    80004124:	6a02                	ld	s4,0(sp)
    80004126:	6145                	addi	sp,sp,48
    80004128:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000412a:	0009a503          	lw	a0,0(s3)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	68e080e7          	jalr	1678(ra) # 800037bc <bread>
    80004136:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004138:	05850493          	addi	s1,a0,88
    8000413c:	45850913          	addi	s2,a0,1112
    80004140:	a021                	j	80004148 <itrunc+0x7a>
    80004142:	0491                	addi	s1,s1,4
    80004144:	01248b63          	beq	s1,s2,8000415a <itrunc+0x8c>
      if(a[j])
    80004148:	408c                	lw	a1,0(s1)
    8000414a:	dde5                	beqz	a1,80004142 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000414c:	0009a503          	lw	a0,0(s3)
    80004150:	00000097          	auipc	ra,0x0
    80004154:	8b2080e7          	jalr	-1870(ra) # 80003a02 <bfree>
    80004158:	b7ed                	j	80004142 <itrunc+0x74>
    brelse(bp);
    8000415a:	8552                	mv	a0,s4
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	790080e7          	jalr	1936(ra) # 800038ec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004164:	0809a583          	lw	a1,128(s3)
    80004168:	0009a503          	lw	a0,0(s3)
    8000416c:	00000097          	auipc	ra,0x0
    80004170:	896080e7          	jalr	-1898(ra) # 80003a02 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004174:	0809a023          	sw	zero,128(s3)
    80004178:	bf51                	j	8000410c <itrunc+0x3e>

000000008000417a <iput>:
{
    8000417a:	1101                	addi	sp,sp,-32
    8000417c:	ec06                	sd	ra,24(sp)
    8000417e:	e822                	sd	s0,16(sp)
    80004180:	e426                	sd	s1,8(sp)
    80004182:	e04a                	sd	s2,0(sp)
    80004184:	1000                	addi	s0,sp,32
    80004186:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004188:	0003b517          	auipc	a0,0x3b
    8000418c:	c4050513          	addi	a0,a0,-960 # 8003edc8 <itable>
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	a32080e7          	jalr	-1486(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004198:	4498                	lw	a4,8(s1)
    8000419a:	4785                	li	a5,1
    8000419c:	02f70363          	beq	a4,a5,800041c2 <iput+0x48>
  ip->ref--;
    800041a0:	449c                	lw	a5,8(s1)
    800041a2:	37fd                	addiw	a5,a5,-1
    800041a4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800041a6:	0003b517          	auipc	a0,0x3b
    800041aa:	c2250513          	addi	a0,a0,-990 # 8003edc8 <itable>
    800041ae:	ffffd097          	auipc	ra,0xffffd
    800041b2:	ac8080e7          	jalr	-1336(ra) # 80000c76 <release>
}
    800041b6:	60e2                	ld	ra,24(sp)
    800041b8:	6442                	ld	s0,16(sp)
    800041ba:	64a2                	ld	s1,8(sp)
    800041bc:	6902                	ld	s2,0(sp)
    800041be:	6105                	addi	sp,sp,32
    800041c0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041c2:	40bc                	lw	a5,64(s1)
    800041c4:	dff1                	beqz	a5,800041a0 <iput+0x26>
    800041c6:	04a49783          	lh	a5,74(s1)
    800041ca:	fbf9                	bnez	a5,800041a0 <iput+0x26>
    acquiresleep(&ip->lock);
    800041cc:	01048913          	addi	s2,s1,16
    800041d0:	854a                	mv	a0,s2
    800041d2:	00001097          	auipc	ra,0x1
    800041d6:	dce080e7          	jalr	-562(ra) # 80004fa0 <acquiresleep>
    release(&itable.lock);
    800041da:	0003b517          	auipc	a0,0x3b
    800041de:	bee50513          	addi	a0,a0,-1042 # 8003edc8 <itable>
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	a94080e7          	jalr	-1388(ra) # 80000c76 <release>
    itrunc(ip);
    800041ea:	8526                	mv	a0,s1
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	ee2080e7          	jalr	-286(ra) # 800040ce <itrunc>
    ip->type = 0;
    800041f4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041f8:	8526                	mv	a0,s1
    800041fa:	00000097          	auipc	ra,0x0
    800041fe:	cfc080e7          	jalr	-772(ra) # 80003ef6 <iupdate>
    ip->valid = 0;
    80004202:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004206:	854a                	mv	a0,s2
    80004208:	00001097          	auipc	ra,0x1
    8000420c:	dee080e7          	jalr	-530(ra) # 80004ff6 <releasesleep>
    acquire(&itable.lock);
    80004210:	0003b517          	auipc	a0,0x3b
    80004214:	bb850513          	addi	a0,a0,-1096 # 8003edc8 <itable>
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	9aa080e7          	jalr	-1622(ra) # 80000bc2 <acquire>
    80004220:	b741                	j	800041a0 <iput+0x26>

0000000080004222 <iunlockput>:
{
    80004222:	1101                	addi	sp,sp,-32
    80004224:	ec06                	sd	ra,24(sp)
    80004226:	e822                	sd	s0,16(sp)
    80004228:	e426                	sd	s1,8(sp)
    8000422a:	1000                	addi	s0,sp,32
    8000422c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	e54080e7          	jalr	-428(ra) # 80004082 <iunlock>
  iput(ip);
    80004236:	8526                	mv	a0,s1
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	f42080e7          	jalr	-190(ra) # 8000417a <iput>
}
    80004240:	60e2                	ld	ra,24(sp)
    80004242:	6442                	ld	s0,16(sp)
    80004244:	64a2                	ld	s1,8(sp)
    80004246:	6105                	addi	sp,sp,32
    80004248:	8082                	ret

000000008000424a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000424a:	1141                	addi	sp,sp,-16
    8000424c:	e422                	sd	s0,8(sp)
    8000424e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004250:	411c                	lw	a5,0(a0)
    80004252:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004254:	415c                	lw	a5,4(a0)
    80004256:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004258:	04451783          	lh	a5,68(a0)
    8000425c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004260:	04a51783          	lh	a5,74(a0)
    80004264:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004268:	04c56783          	lwu	a5,76(a0)
    8000426c:	e99c                	sd	a5,16(a1)
}
    8000426e:	6422                	ld	s0,8(sp)
    80004270:	0141                	addi	sp,sp,16
    80004272:	8082                	ret

0000000080004274 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004274:	457c                	lw	a5,76(a0)
    80004276:	0ed7e963          	bltu	a5,a3,80004368 <readi+0xf4>
{
    8000427a:	7159                	addi	sp,sp,-112
    8000427c:	f486                	sd	ra,104(sp)
    8000427e:	f0a2                	sd	s0,96(sp)
    80004280:	eca6                	sd	s1,88(sp)
    80004282:	e8ca                	sd	s2,80(sp)
    80004284:	e4ce                	sd	s3,72(sp)
    80004286:	e0d2                	sd	s4,64(sp)
    80004288:	fc56                	sd	s5,56(sp)
    8000428a:	f85a                	sd	s6,48(sp)
    8000428c:	f45e                	sd	s7,40(sp)
    8000428e:	f062                	sd	s8,32(sp)
    80004290:	ec66                	sd	s9,24(sp)
    80004292:	e86a                	sd	s10,16(sp)
    80004294:	e46e                	sd	s11,8(sp)
    80004296:	1880                	addi	s0,sp,112
    80004298:	8baa                	mv	s7,a0
    8000429a:	8c2e                	mv	s8,a1
    8000429c:	8ab2                	mv	s5,a2
    8000429e:	84b6                	mv	s1,a3
    800042a0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800042a2:	9f35                	addw	a4,a4,a3
    return 0;
    800042a4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800042a6:	0ad76063          	bltu	a4,a3,80004346 <readi+0xd2>
  if(off + n > ip->size)
    800042aa:	00e7f463          	bgeu	a5,a4,800042b2 <readi+0x3e>
    n = ip->size - off;
    800042ae:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042b2:	0a0b0963          	beqz	s6,80004364 <readi+0xf0>
    800042b6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800042b8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800042bc:	5cfd                	li	s9,-1
    800042be:	a82d                	j	800042f8 <readi+0x84>
    800042c0:	020a1d93          	slli	s11,s4,0x20
    800042c4:	020ddd93          	srli	s11,s11,0x20
    800042c8:	05890793          	addi	a5,s2,88
    800042cc:	86ee                	mv	a3,s11
    800042ce:	963e                	add	a2,a2,a5
    800042d0:	85d6                	mv	a1,s5
    800042d2:	8562                	mv	a0,s8
    800042d4:	ffffe097          	auipc	ra,0xffffe
    800042d8:	e04080e7          	jalr	-508(ra) # 800020d8 <either_copyout>
    800042dc:	05950d63          	beq	a0,s9,80004336 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042e0:	854a                	mv	a0,s2
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	60a080e7          	jalr	1546(ra) # 800038ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042ea:	013a09bb          	addw	s3,s4,s3
    800042ee:	009a04bb          	addw	s1,s4,s1
    800042f2:	9aee                	add	s5,s5,s11
    800042f4:	0569f763          	bgeu	s3,s6,80004342 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800042f8:	000ba903          	lw	s2,0(s7) # ffffffff80000000 <end+0xfffffffefffbb000>
    800042fc:	00a4d59b          	srliw	a1,s1,0xa
    80004300:	855e                	mv	a0,s7
    80004302:	00000097          	auipc	ra,0x0
    80004306:	8ae080e7          	jalr	-1874(ra) # 80003bb0 <bmap>
    8000430a:	0005059b          	sext.w	a1,a0
    8000430e:	854a                	mv	a0,s2
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	4ac080e7          	jalr	1196(ra) # 800037bc <bread>
    80004318:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000431a:	3ff4f613          	andi	a2,s1,1023
    8000431e:	40cd07bb          	subw	a5,s10,a2
    80004322:	413b073b          	subw	a4,s6,s3
    80004326:	8a3e                	mv	s4,a5
    80004328:	2781                	sext.w	a5,a5
    8000432a:	0007069b          	sext.w	a3,a4
    8000432e:	f8f6f9e3          	bgeu	a3,a5,800042c0 <readi+0x4c>
    80004332:	8a3a                	mv	s4,a4
    80004334:	b771                	j	800042c0 <readi+0x4c>
      brelse(bp);
    80004336:	854a                	mv	a0,s2
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	5b4080e7          	jalr	1460(ra) # 800038ec <brelse>
      tot = -1;
    80004340:	59fd                	li	s3,-1
  }
  return tot;
    80004342:	0009851b          	sext.w	a0,s3
}
    80004346:	70a6                	ld	ra,104(sp)
    80004348:	7406                	ld	s0,96(sp)
    8000434a:	64e6                	ld	s1,88(sp)
    8000434c:	6946                	ld	s2,80(sp)
    8000434e:	69a6                	ld	s3,72(sp)
    80004350:	6a06                	ld	s4,64(sp)
    80004352:	7ae2                	ld	s5,56(sp)
    80004354:	7b42                	ld	s6,48(sp)
    80004356:	7ba2                	ld	s7,40(sp)
    80004358:	7c02                	ld	s8,32(sp)
    8000435a:	6ce2                	ld	s9,24(sp)
    8000435c:	6d42                	ld	s10,16(sp)
    8000435e:	6da2                	ld	s11,8(sp)
    80004360:	6165                	addi	sp,sp,112
    80004362:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004364:	89da                	mv	s3,s6
    80004366:	bff1                	j	80004342 <readi+0xce>
    return 0;
    80004368:	4501                	li	a0,0
}
    8000436a:	8082                	ret

000000008000436c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000436c:	457c                	lw	a5,76(a0)
    8000436e:	10d7e863          	bltu	a5,a3,8000447e <writei+0x112>
{
    80004372:	7159                	addi	sp,sp,-112
    80004374:	f486                	sd	ra,104(sp)
    80004376:	f0a2                	sd	s0,96(sp)
    80004378:	eca6                	sd	s1,88(sp)
    8000437a:	e8ca                	sd	s2,80(sp)
    8000437c:	e4ce                	sd	s3,72(sp)
    8000437e:	e0d2                	sd	s4,64(sp)
    80004380:	fc56                	sd	s5,56(sp)
    80004382:	f85a                	sd	s6,48(sp)
    80004384:	f45e                	sd	s7,40(sp)
    80004386:	f062                	sd	s8,32(sp)
    80004388:	ec66                	sd	s9,24(sp)
    8000438a:	e86a                	sd	s10,16(sp)
    8000438c:	e46e                	sd	s11,8(sp)
    8000438e:	1880                	addi	s0,sp,112
    80004390:	8b2a                	mv	s6,a0
    80004392:	8c2e                	mv	s8,a1
    80004394:	8ab2                	mv	s5,a2
    80004396:	8936                	mv	s2,a3
    80004398:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000439a:	00e687bb          	addw	a5,a3,a4
    8000439e:	0ed7e263          	bltu	a5,a3,80004482 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800043a2:	00043737          	lui	a4,0x43
    800043a6:	0ef76063          	bltu	a4,a5,80004486 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043aa:	0c0b8863          	beqz	s7,8000447a <writei+0x10e>
    800043ae:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800043b0:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800043b4:	5cfd                	li	s9,-1
    800043b6:	a091                	j	800043fa <writei+0x8e>
    800043b8:	02099d93          	slli	s11,s3,0x20
    800043bc:	020ddd93          	srli	s11,s11,0x20
    800043c0:	05848793          	addi	a5,s1,88
    800043c4:	86ee                	mv	a3,s11
    800043c6:	8656                	mv	a2,s5
    800043c8:	85e2                	mv	a1,s8
    800043ca:	953e                	add	a0,a0,a5
    800043cc:	ffffe097          	auipc	ra,0xffffe
    800043d0:	d62080e7          	jalr	-670(ra) # 8000212e <either_copyin>
    800043d4:	07950263          	beq	a0,s9,80004438 <writei+0xcc>

      brelse(bp);
      break;
    }
    log_write(bp);
    800043d8:	8526                	mv	a0,s1
    800043da:	00001097          	auipc	ra,0x1
    800043de:	aa6080e7          	jalr	-1370(ra) # 80004e80 <log_write>
    brelse(bp);
    800043e2:	8526                	mv	a0,s1
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	508080e7          	jalr	1288(ra) # 800038ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043ec:	01498a3b          	addw	s4,s3,s4
    800043f0:	0129893b          	addw	s2,s3,s2
    800043f4:	9aee                	add	s5,s5,s11
    800043f6:	057a7663          	bgeu	s4,s7,80004442 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800043fa:	000b2483          	lw	s1,0(s6)
    800043fe:	00a9559b          	srliw	a1,s2,0xa
    80004402:	855a                	mv	a0,s6
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	7ac080e7          	jalr	1964(ra) # 80003bb0 <bmap>
    8000440c:	0005059b          	sext.w	a1,a0
    80004410:	8526                	mv	a0,s1
    80004412:	fffff097          	auipc	ra,0xfffff
    80004416:	3aa080e7          	jalr	938(ra) # 800037bc <bread>
    8000441a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000441c:	3ff97513          	andi	a0,s2,1023
    80004420:	40ad07bb          	subw	a5,s10,a0
    80004424:	414b873b          	subw	a4,s7,s4
    80004428:	89be                	mv	s3,a5
    8000442a:	2781                	sext.w	a5,a5
    8000442c:	0007069b          	sext.w	a3,a4
    80004430:	f8f6f4e3          	bgeu	a3,a5,800043b8 <writei+0x4c>
    80004434:	89ba                	mv	s3,a4
    80004436:	b749                	j	800043b8 <writei+0x4c>
      brelse(bp);
    80004438:	8526                	mv	a0,s1
    8000443a:	fffff097          	auipc	ra,0xfffff
    8000443e:	4b2080e7          	jalr	1202(ra) # 800038ec <brelse>
  }

  if(off > ip->size)
    80004442:	04cb2783          	lw	a5,76(s6)
    80004446:	0127f463          	bgeu	a5,s2,8000444e <writei+0xe2>
    ip->size = off;
    8000444a:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000444e:	855a                	mv	a0,s6
    80004450:	00000097          	auipc	ra,0x0
    80004454:	aa6080e7          	jalr	-1370(ra) # 80003ef6 <iupdate>

  return tot;
    80004458:	000a051b          	sext.w	a0,s4
}
    8000445c:	70a6                	ld	ra,104(sp)
    8000445e:	7406                	ld	s0,96(sp)
    80004460:	64e6                	ld	s1,88(sp)
    80004462:	6946                	ld	s2,80(sp)
    80004464:	69a6                	ld	s3,72(sp)
    80004466:	6a06                	ld	s4,64(sp)
    80004468:	7ae2                	ld	s5,56(sp)
    8000446a:	7b42                	ld	s6,48(sp)
    8000446c:	7ba2                	ld	s7,40(sp)
    8000446e:	7c02                	ld	s8,32(sp)
    80004470:	6ce2                	ld	s9,24(sp)
    80004472:	6d42                	ld	s10,16(sp)
    80004474:	6da2                	ld	s11,8(sp)
    80004476:	6165                	addi	sp,sp,112
    80004478:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000447a:	8a5e                	mv	s4,s7
    8000447c:	bfc9                	j	8000444e <writei+0xe2>
    return -1;
    8000447e:	557d                	li	a0,-1
}
    80004480:	8082                	ret
    return -1;
    80004482:	557d                	li	a0,-1
    80004484:	bfe1                	j	8000445c <writei+0xf0>
    return -1;
    80004486:	557d                	li	a0,-1
    80004488:	bfd1                	j	8000445c <writei+0xf0>

000000008000448a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000448a:	1141                	addi	sp,sp,-16
    8000448c:	e406                	sd	ra,8(sp)
    8000448e:	e022                	sd	s0,0(sp)
    80004490:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004492:	4639                	li	a2,14
    80004494:	ffffd097          	auipc	ra,0xffffd
    80004498:	902080e7          	jalr	-1790(ra) # 80000d96 <strncmp>
}
    8000449c:	60a2                	ld	ra,8(sp)
    8000449e:	6402                	ld	s0,0(sp)
    800044a0:	0141                	addi	sp,sp,16
    800044a2:	8082                	ret

00000000800044a4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800044a4:	7139                	addi	sp,sp,-64
    800044a6:	fc06                	sd	ra,56(sp)
    800044a8:	f822                	sd	s0,48(sp)
    800044aa:	f426                	sd	s1,40(sp)
    800044ac:	f04a                	sd	s2,32(sp)
    800044ae:	ec4e                	sd	s3,24(sp)
    800044b0:	e852                	sd	s4,16(sp)
    800044b2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044b4:	04451703          	lh	a4,68(a0)
    800044b8:	4785                	li	a5,1
    800044ba:	00f71a63          	bne	a4,a5,800044ce <dirlookup+0x2a>
    800044be:	892a                	mv	s2,a0
    800044c0:	89ae                	mv	s3,a1
    800044c2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044c4:	457c                	lw	a5,76(a0)
    800044c6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800044c8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ca:	e79d                	bnez	a5,800044f8 <dirlookup+0x54>
    800044cc:	a8a5                	j	80004544 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044ce:	00005517          	auipc	a0,0x5
    800044d2:	46a50513          	addi	a0,a0,1130 # 80009938 <syscalls+0x1a0>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	054080e7          	jalr	84(ra) # 8000052a <panic>
      panic("dirlookup read");
    800044de:	00005517          	auipc	a0,0x5
    800044e2:	47250513          	addi	a0,a0,1138 # 80009950 <syscalls+0x1b8>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	044080e7          	jalr	68(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ee:	24c1                	addiw	s1,s1,16
    800044f0:	04c92783          	lw	a5,76(s2)
    800044f4:	04f4f763          	bgeu	s1,a5,80004542 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044f8:	4741                	li	a4,16
    800044fa:	86a6                	mv	a3,s1
    800044fc:	fc040613          	addi	a2,s0,-64
    80004500:	4581                	li	a1,0
    80004502:	854a                	mv	a0,s2
    80004504:	00000097          	auipc	ra,0x0
    80004508:	d70080e7          	jalr	-656(ra) # 80004274 <readi>
    8000450c:	47c1                	li	a5,16
    8000450e:	fcf518e3          	bne	a0,a5,800044de <dirlookup+0x3a>
    if(de.inum == 0)
    80004512:	fc045783          	lhu	a5,-64(s0)
    80004516:	dfe1                	beqz	a5,800044ee <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004518:	fc240593          	addi	a1,s0,-62
    8000451c:	854e                	mv	a0,s3
    8000451e:	00000097          	auipc	ra,0x0
    80004522:	f6c080e7          	jalr	-148(ra) # 8000448a <namecmp>
    80004526:	f561                	bnez	a0,800044ee <dirlookup+0x4a>
      if(poff)
    80004528:	000a0463          	beqz	s4,80004530 <dirlookup+0x8c>
        *poff = off;
    8000452c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004530:	fc045583          	lhu	a1,-64(s0)
    80004534:	00092503          	lw	a0,0(s2)
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	754080e7          	jalr	1876(ra) # 80003c8c <iget>
    80004540:	a011                	j	80004544 <dirlookup+0xa0>
  return 0;
    80004542:	4501                	li	a0,0
}
    80004544:	70e2                	ld	ra,56(sp)
    80004546:	7442                	ld	s0,48(sp)
    80004548:	74a2                	ld	s1,40(sp)
    8000454a:	7902                	ld	s2,32(sp)
    8000454c:	69e2                	ld	s3,24(sp)
    8000454e:	6a42                	ld	s4,16(sp)
    80004550:	6121                	addi	sp,sp,64
    80004552:	8082                	ret

0000000080004554 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004554:	711d                	addi	sp,sp,-96
    80004556:	ec86                	sd	ra,88(sp)
    80004558:	e8a2                	sd	s0,80(sp)
    8000455a:	e4a6                	sd	s1,72(sp)
    8000455c:	e0ca                	sd	s2,64(sp)
    8000455e:	fc4e                	sd	s3,56(sp)
    80004560:	f852                	sd	s4,48(sp)
    80004562:	f456                	sd	s5,40(sp)
    80004564:	f05a                	sd	s6,32(sp)
    80004566:	ec5e                	sd	s7,24(sp)
    80004568:	e862                	sd	s8,16(sp)
    8000456a:	e466                	sd	s9,8(sp)
    8000456c:	1080                	addi	s0,sp,96
    8000456e:	84aa                	mv	s1,a0
    80004570:	8aae                	mv	s5,a1
    80004572:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004574:	00054703          	lbu	a4,0(a0)
    80004578:	02f00793          	li	a5,47
    8000457c:	02f70363          	beq	a4,a5,800045a2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004580:	ffffd097          	auipc	ra,0xffffd
    80004584:	50c080e7          	jalr	1292(ra) # 80001a8c <myproc>
    80004588:	15053503          	ld	a0,336(a0)
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	9f6080e7          	jalr	-1546(ra) # 80003f82 <idup>
    80004594:	89aa                	mv	s3,a0
  while(*path == '/')
    80004596:	02f00913          	li	s2,47
  len = path - s;
    8000459a:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000459c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000459e:	4b85                	li	s7,1
    800045a0:	a865                	j	80004658 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800045a2:	4585                	li	a1,1
    800045a4:	4505                	li	a0,1
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	6e6080e7          	jalr	1766(ra) # 80003c8c <iget>
    800045ae:	89aa                	mv	s3,a0
    800045b0:	b7dd                	j	80004596 <namex+0x42>
      iunlockput(ip);
    800045b2:	854e                	mv	a0,s3
    800045b4:	00000097          	auipc	ra,0x0
    800045b8:	c6e080e7          	jalr	-914(ra) # 80004222 <iunlockput>
      return 0;
    800045bc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045be:	854e                	mv	a0,s3
    800045c0:	60e6                	ld	ra,88(sp)
    800045c2:	6446                	ld	s0,80(sp)
    800045c4:	64a6                	ld	s1,72(sp)
    800045c6:	6906                	ld	s2,64(sp)
    800045c8:	79e2                	ld	s3,56(sp)
    800045ca:	7a42                	ld	s4,48(sp)
    800045cc:	7aa2                	ld	s5,40(sp)
    800045ce:	7b02                	ld	s6,32(sp)
    800045d0:	6be2                	ld	s7,24(sp)
    800045d2:	6c42                	ld	s8,16(sp)
    800045d4:	6ca2                	ld	s9,8(sp)
    800045d6:	6125                	addi	sp,sp,96
    800045d8:	8082                	ret
      iunlock(ip);
    800045da:	854e                	mv	a0,s3
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	aa6080e7          	jalr	-1370(ra) # 80004082 <iunlock>
      return ip;
    800045e4:	bfe9                	j	800045be <namex+0x6a>
      iunlockput(ip);
    800045e6:	854e                	mv	a0,s3
    800045e8:	00000097          	auipc	ra,0x0
    800045ec:	c3a080e7          	jalr	-966(ra) # 80004222 <iunlockput>
      return 0;
    800045f0:	89e6                	mv	s3,s9
    800045f2:	b7f1                	j	800045be <namex+0x6a>
  len = path - s;
    800045f4:	40b48633          	sub	a2,s1,a1
    800045f8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800045fc:	099c5463          	bge	s8,s9,80004684 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004600:	4639                	li	a2,14
    80004602:	8552                	mv	a0,s4
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	716080e7          	jalr	1814(ra) # 80000d1a <memmove>
  while(*path == '/')
    8000460c:	0004c783          	lbu	a5,0(s1)
    80004610:	01279763          	bne	a5,s2,8000461e <namex+0xca>
    path++;
    80004614:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004616:	0004c783          	lbu	a5,0(s1)
    8000461a:	ff278de3          	beq	a5,s2,80004614 <namex+0xc0>
    ilock(ip);
    8000461e:	854e                	mv	a0,s3
    80004620:	00000097          	auipc	ra,0x0
    80004624:	9a0080e7          	jalr	-1632(ra) # 80003fc0 <ilock>
    if(ip->type != T_DIR){
    80004628:	04499783          	lh	a5,68(s3)
    8000462c:	f97793e3          	bne	a5,s7,800045b2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004630:	000a8563          	beqz	s5,8000463a <namex+0xe6>
    80004634:	0004c783          	lbu	a5,0(s1)
    80004638:	d3cd                	beqz	a5,800045da <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000463a:	865a                	mv	a2,s6
    8000463c:	85d2                	mv	a1,s4
    8000463e:	854e                	mv	a0,s3
    80004640:	00000097          	auipc	ra,0x0
    80004644:	e64080e7          	jalr	-412(ra) # 800044a4 <dirlookup>
    80004648:	8caa                	mv	s9,a0
    8000464a:	dd51                	beqz	a0,800045e6 <namex+0x92>
    iunlockput(ip);
    8000464c:	854e                	mv	a0,s3
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	bd4080e7          	jalr	-1068(ra) # 80004222 <iunlockput>
    ip = next;
    80004656:	89e6                	mv	s3,s9
  while(*path == '/')
    80004658:	0004c783          	lbu	a5,0(s1)
    8000465c:	05279763          	bne	a5,s2,800046aa <namex+0x156>
    path++;
    80004660:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004662:	0004c783          	lbu	a5,0(s1)
    80004666:	ff278de3          	beq	a5,s2,80004660 <namex+0x10c>
  if(*path == 0)
    8000466a:	c79d                	beqz	a5,80004698 <namex+0x144>
    path++;
    8000466c:	85a6                	mv	a1,s1
  len = path - s;
    8000466e:	8cda                	mv	s9,s6
    80004670:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004672:	01278963          	beq	a5,s2,80004684 <namex+0x130>
    80004676:	dfbd                	beqz	a5,800045f4 <namex+0xa0>
    path++;
    80004678:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000467a:	0004c783          	lbu	a5,0(s1)
    8000467e:	ff279ce3          	bne	a5,s2,80004676 <namex+0x122>
    80004682:	bf8d                	j	800045f4 <namex+0xa0>
    memmove(name, s, len);
    80004684:	2601                	sext.w	a2,a2
    80004686:	8552                	mv	a0,s4
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	692080e7          	jalr	1682(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004690:	9cd2                	add	s9,s9,s4
    80004692:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004696:	bf9d                	j	8000460c <namex+0xb8>
  if(nameiparent){
    80004698:	f20a83e3          	beqz	s5,800045be <namex+0x6a>
    iput(ip);
    8000469c:	854e                	mv	a0,s3
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	adc080e7          	jalr	-1316(ra) # 8000417a <iput>
    return 0;
    800046a6:	4981                	li	s3,0
    800046a8:	bf19                	j	800045be <namex+0x6a>
  if(*path == 0)
    800046aa:	d7fd                	beqz	a5,80004698 <namex+0x144>
  while(*path != '/' && *path != 0)
    800046ac:	0004c783          	lbu	a5,0(s1)
    800046b0:	85a6                	mv	a1,s1
    800046b2:	b7d1                	j	80004676 <namex+0x122>

00000000800046b4 <dirlink>:
{
    800046b4:	7139                	addi	sp,sp,-64
    800046b6:	fc06                	sd	ra,56(sp)
    800046b8:	f822                	sd	s0,48(sp)
    800046ba:	f426                	sd	s1,40(sp)
    800046bc:	f04a                	sd	s2,32(sp)
    800046be:	ec4e                	sd	s3,24(sp)
    800046c0:	e852                	sd	s4,16(sp)
    800046c2:	0080                	addi	s0,sp,64
    800046c4:	892a                	mv	s2,a0
    800046c6:	8a2e                	mv	s4,a1
    800046c8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046ca:	4601                	li	a2,0
    800046cc:	00000097          	auipc	ra,0x0
    800046d0:	dd8080e7          	jalr	-552(ra) # 800044a4 <dirlookup>
    800046d4:	e93d                	bnez	a0,8000474a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046d6:	04c92483          	lw	s1,76(s2)
    800046da:	c49d                	beqz	s1,80004708 <dirlink+0x54>
    800046dc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046de:	4741                	li	a4,16
    800046e0:	86a6                	mv	a3,s1
    800046e2:	fc040613          	addi	a2,s0,-64
    800046e6:	4581                	li	a1,0
    800046e8:	854a                	mv	a0,s2
    800046ea:	00000097          	auipc	ra,0x0
    800046ee:	b8a080e7          	jalr	-1142(ra) # 80004274 <readi>
    800046f2:	47c1                	li	a5,16
    800046f4:	06f51163          	bne	a0,a5,80004756 <dirlink+0xa2>
    if(de.inum == 0)
    800046f8:	fc045783          	lhu	a5,-64(s0)
    800046fc:	c791                	beqz	a5,80004708 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046fe:	24c1                	addiw	s1,s1,16
    80004700:	04c92783          	lw	a5,76(s2)
    80004704:	fcf4ede3          	bltu	s1,a5,800046de <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004708:	4639                	li	a2,14
    8000470a:	85d2                	mv	a1,s4
    8000470c:	fc240513          	addi	a0,s0,-62
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	6c2080e7          	jalr	1730(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    80004718:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000471c:	4741                	li	a4,16
    8000471e:	86a6                	mv	a3,s1
    80004720:	fc040613          	addi	a2,s0,-64
    80004724:	4581                	li	a1,0
    80004726:	854a                	mv	a0,s2
    80004728:	00000097          	auipc	ra,0x0
    8000472c:	c44080e7          	jalr	-956(ra) # 8000436c <writei>
    80004730:	872a                	mv	a4,a0
    80004732:	47c1                	li	a5,16
  return 0;
    80004734:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004736:	02f71863          	bne	a4,a5,80004766 <dirlink+0xb2>
}
    8000473a:	70e2                	ld	ra,56(sp)
    8000473c:	7442                	ld	s0,48(sp)
    8000473e:	74a2                	ld	s1,40(sp)
    80004740:	7902                	ld	s2,32(sp)
    80004742:	69e2                	ld	s3,24(sp)
    80004744:	6a42                	ld	s4,16(sp)
    80004746:	6121                	addi	sp,sp,64
    80004748:	8082                	ret
    iput(ip);
    8000474a:	00000097          	auipc	ra,0x0
    8000474e:	a30080e7          	jalr	-1488(ra) # 8000417a <iput>
    return -1;
    80004752:	557d                	li	a0,-1
    80004754:	b7dd                	j	8000473a <dirlink+0x86>
      panic("dirlink read");
    80004756:	00005517          	auipc	a0,0x5
    8000475a:	20a50513          	addi	a0,a0,522 # 80009960 <syscalls+0x1c8>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	dcc080e7          	jalr	-564(ra) # 8000052a <panic>
    panic("dirlink");
    80004766:	00005517          	auipc	a0,0x5
    8000476a:	38250513          	addi	a0,a0,898 # 80009ae8 <syscalls+0x350>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	dbc080e7          	jalr	-580(ra) # 8000052a <panic>

0000000080004776 <namei>:

struct inode*
namei(char *path)
{
    80004776:	1101                	addi	sp,sp,-32
    80004778:	ec06                	sd	ra,24(sp)
    8000477a:	e822                	sd	s0,16(sp)
    8000477c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000477e:	fe040613          	addi	a2,s0,-32
    80004782:	4581                	li	a1,0
    80004784:	00000097          	auipc	ra,0x0
    80004788:	dd0080e7          	jalr	-560(ra) # 80004554 <namex>
}
    8000478c:	60e2                	ld	ra,24(sp)
    8000478e:	6442                	ld	s0,16(sp)
    80004790:	6105                	addi	sp,sp,32
    80004792:	8082                	ret

0000000080004794 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004794:	1141                	addi	sp,sp,-16
    80004796:	e406                	sd	ra,8(sp)
    80004798:	e022                	sd	s0,0(sp)
    8000479a:	0800                	addi	s0,sp,16
    8000479c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000479e:	4585                	li	a1,1
    800047a0:	00000097          	auipc	ra,0x0
    800047a4:	db4080e7          	jalr	-588(ra) # 80004554 <namex>
}
    800047a8:	60a2                	ld	ra,8(sp)
    800047aa:	6402                	ld	s0,0(sp)
    800047ac:	0141                	addi	sp,sp,16
    800047ae:	8082                	ret

00000000800047b0 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    800047b0:	1101                	addi	sp,sp,-32
    800047b2:	ec22                	sd	s0,24(sp)
    800047b4:	1000                	addi	s0,sp,32
    800047b6:	872a                	mv	a4,a0
    800047b8:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    800047ba:	00005797          	auipc	a5,0x5
    800047be:	1b678793          	addi	a5,a5,438 # 80009970 <syscalls+0x1d8>
    800047c2:	6394                	ld	a3,0(a5)
    800047c4:	fed43023          	sd	a3,-32(s0)
    800047c8:	0087d683          	lhu	a3,8(a5)
    800047cc:	fed41423          	sh	a3,-24(s0)
    800047d0:	00a7c783          	lbu	a5,10(a5)
    800047d4:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    800047d8:	87ae                	mv	a5,a1
    if(i<0){
    800047da:	02074b63          	bltz	a4,80004810 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800047de:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800047e0:	4629                	li	a2,10
        ++p;
    800047e2:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800047e4:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800047e8:	feed                	bnez	a3,800047e2 <itoa+0x32>
    *p = '\0';
    800047ea:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800047ee:	4629                	li	a2,10
    800047f0:	17fd                	addi	a5,a5,-1
    800047f2:	02c766bb          	remw	a3,a4,a2
    800047f6:	ff040593          	addi	a1,s0,-16
    800047fa:	96ae                	add	a3,a3,a1
    800047fc:	ff06c683          	lbu	a3,-16(a3)
    80004800:	00d78023          	sb	a3,0(a5)
        i = i/10;
    80004804:	02c7473b          	divw	a4,a4,a2
    }while(i);
    80004808:	f765                	bnez	a4,800047f0 <itoa+0x40>
    return b;
}
    8000480a:	6462                	ld	s0,24(sp)
    8000480c:	6105                	addi	sp,sp,32
    8000480e:	8082                	ret
        *p++ = '-';
    80004810:	00158793          	addi	a5,a1,1
    80004814:	02d00693          	li	a3,45
    80004818:	00d58023          	sb	a3,0(a1)
        i *= -1;
    8000481c:	40e0073b          	negw	a4,a4
    80004820:	bf7d                	j	800047de <itoa+0x2e>

0000000080004822 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004822:	711d                	addi	sp,sp,-96
    80004824:	ec86                	sd	ra,88(sp)
    80004826:	e8a2                	sd	s0,80(sp)
    80004828:	e4a6                	sd	s1,72(sp)
    8000482a:	e0ca                	sd	s2,64(sp)
    8000482c:	1080                	addi	s0,sp,96
    8000482e:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004830:	4619                	li	a2,6
    80004832:	00005597          	auipc	a1,0x5
    80004836:	14e58593          	addi	a1,a1,334 # 80009980 <syscalls+0x1e8>
    8000483a:	fd040513          	addi	a0,s0,-48
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	4dc080e7          	jalr	1244(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004846:	fd640593          	addi	a1,s0,-42
    8000484a:	5888                	lw	a0,48(s1)
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	f64080e7          	jalr	-156(ra) # 800047b0 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004854:	1684b503          	ld	a0,360(s1)
    80004858:	16050763          	beqz	a0,800049c6 <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    8000485c:	00001097          	auipc	ra,0x1
    80004860:	918080e7          	jalr	-1768(ra) # 80005174 <fileclose>

  begin_op();
    80004864:	00000097          	auipc	ra,0x0
    80004868:	444080e7          	jalr	1092(ra) # 80004ca8 <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    8000486c:	fb040593          	addi	a1,s0,-80
    80004870:	fd040513          	addi	a0,s0,-48
    80004874:	00000097          	auipc	ra,0x0
    80004878:	f20080e7          	jalr	-224(ra) # 80004794 <nameiparent>
    8000487c:	892a                	mv	s2,a0
    8000487e:	cd69                	beqz	a0,80004958 <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004880:	fffff097          	auipc	ra,0xfffff
    80004884:	740080e7          	jalr	1856(ra) # 80003fc0 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004888:	00005597          	auipc	a1,0x5
    8000488c:	10058593          	addi	a1,a1,256 # 80009988 <syscalls+0x1f0>
    80004890:	fb040513          	addi	a0,s0,-80
    80004894:	00000097          	auipc	ra,0x0
    80004898:	bf6080e7          	jalr	-1034(ra) # 8000448a <namecmp>
    8000489c:	c57d                	beqz	a0,8000498a <removeSwapFile+0x168>
    8000489e:	00005597          	auipc	a1,0x5
    800048a2:	0f258593          	addi	a1,a1,242 # 80009990 <syscalls+0x1f8>
    800048a6:	fb040513          	addi	a0,s0,-80
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	be0080e7          	jalr	-1056(ra) # 8000448a <namecmp>
    800048b2:	cd61                	beqz	a0,8000498a <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800048b4:	fac40613          	addi	a2,s0,-84
    800048b8:	fb040593          	addi	a1,s0,-80
    800048bc:	854a                	mv	a0,s2
    800048be:	00000097          	auipc	ra,0x0
    800048c2:	be6080e7          	jalr	-1050(ra) # 800044a4 <dirlookup>
    800048c6:	84aa                	mv	s1,a0
    800048c8:	c169                	beqz	a0,8000498a <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	6f6080e7          	jalr	1782(ra) # 80003fc0 <ilock>

  if(ip->nlink < 1)
    800048d2:	04a49783          	lh	a5,74(s1)
    800048d6:	08f05763          	blez	a5,80004964 <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800048da:	04449703          	lh	a4,68(s1)
    800048de:	4785                	li	a5,1
    800048e0:	08f70a63          	beq	a4,a5,80004974 <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800048e4:	4641                	li	a2,16
    800048e6:	4581                	li	a1,0
    800048e8:	fc040513          	addi	a0,s0,-64
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	3d2080e7          	jalr	978(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048f4:	4741                	li	a4,16
    800048f6:	fac42683          	lw	a3,-84(s0)
    800048fa:	fc040613          	addi	a2,s0,-64
    800048fe:	4581                	li	a1,0
    80004900:	854a                	mv	a0,s2
    80004902:	00000097          	auipc	ra,0x0
    80004906:	a6a080e7          	jalr	-1430(ra) # 8000436c <writei>
    8000490a:	47c1                	li	a5,16
    8000490c:	08f51a63          	bne	a0,a5,800049a0 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004910:	04449703          	lh	a4,68(s1)
    80004914:	4785                	li	a5,1
    80004916:	08f70d63          	beq	a4,a5,800049b0 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000491a:	854a                	mv	a0,s2
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	906080e7          	jalr	-1786(ra) # 80004222 <iunlockput>

  ip->nlink--;
    80004924:	04a4d783          	lhu	a5,74(s1)
    80004928:	37fd                	addiw	a5,a5,-1
    8000492a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000492e:	8526                	mv	a0,s1
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	5c6080e7          	jalr	1478(ra) # 80003ef6 <iupdate>
  iunlockput(ip);
    80004938:	8526                	mv	a0,s1
    8000493a:	00000097          	auipc	ra,0x0
    8000493e:	8e8080e7          	jalr	-1816(ra) # 80004222 <iunlockput>

  end_op();
    80004942:	00000097          	auipc	ra,0x0
    80004946:	3e6080e7          	jalr	998(ra) # 80004d28 <end_op>

  return 0;
    8000494a:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    8000494c:	60e6                	ld	ra,88(sp)
    8000494e:	6446                	ld	s0,80(sp)
    80004950:	64a6                	ld	s1,72(sp)
    80004952:	6906                	ld	s2,64(sp)
    80004954:	6125                	addi	sp,sp,96
    80004956:	8082                	ret
    end_op();
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	3d0080e7          	jalr	976(ra) # 80004d28 <end_op>
    return -1;
    80004960:	557d                	li	a0,-1
    80004962:	b7ed                	j	8000494c <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    80004964:	00005517          	auipc	a0,0x5
    80004968:	03450513          	addi	a0,a0,52 # 80009998 <syscalls+0x200>
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	bbe080e7          	jalr	-1090(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004974:	8526                	mv	a0,s1
    80004976:	00001097          	auipc	ra,0x1
    8000497a:	7d0080e7          	jalr	2000(ra) # 80006146 <isdirempty>
    8000497e:	f13d                	bnez	a0,800048e4 <removeSwapFile+0xc2>
    iunlockput(ip);
    80004980:	8526                	mv	a0,s1
    80004982:	00000097          	auipc	ra,0x0
    80004986:	8a0080e7          	jalr	-1888(ra) # 80004222 <iunlockput>
    iunlockput(dp);
    8000498a:	854a                	mv	a0,s2
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	896080e7          	jalr	-1898(ra) # 80004222 <iunlockput>
    end_op();
    80004994:	00000097          	auipc	ra,0x0
    80004998:	394080e7          	jalr	916(ra) # 80004d28 <end_op>
    return -1;
    8000499c:	557d                	li	a0,-1
    8000499e:	b77d                	j	8000494c <removeSwapFile+0x12a>
    panic("unlink: writei");
    800049a0:	00005517          	auipc	a0,0x5
    800049a4:	01050513          	addi	a0,a0,16 # 800099b0 <syscalls+0x218>
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	b82080e7          	jalr	-1150(ra) # 8000052a <panic>
    dp->nlink--;
    800049b0:	04a95783          	lhu	a5,74(s2)
    800049b4:	37fd                	addiw	a5,a5,-1
    800049b6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800049ba:	854a                	mv	a0,s2
    800049bc:	fffff097          	auipc	ra,0xfffff
    800049c0:	53a080e7          	jalr	1338(ra) # 80003ef6 <iupdate>
    800049c4:	bf99                	j	8000491a <removeSwapFile+0xf8>
    return -1;
    800049c6:	557d                	li	a0,-1
    800049c8:	b751                	j	8000494c <removeSwapFile+0x12a>

00000000800049ca <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    800049ca:	7179                	addi	sp,sp,-48
    800049cc:	f406                	sd	ra,40(sp)
    800049ce:	f022                	sd	s0,32(sp)
    800049d0:	ec26                	sd	s1,24(sp)
    800049d2:	e84a                	sd	s2,16(sp)
    800049d4:	1800                	addi	s0,sp,48
    800049d6:	84aa                	mv	s1,a0

  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800049d8:	4619                	li	a2,6
    800049da:	00005597          	auipc	a1,0x5
    800049de:	fa658593          	addi	a1,a1,-90 # 80009980 <syscalls+0x1e8>
    800049e2:	fd040513          	addi	a0,s0,-48
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	334080e7          	jalr	820(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800049ee:	fd640593          	addi	a1,s0,-42
    800049f2:	5888                	lw	a0,48(s1)
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	dbc080e7          	jalr	-580(ra) # 800047b0 <itoa>

  begin_op();
    800049fc:	00000097          	auipc	ra,0x0
    80004a00:	2ac080e7          	jalr	684(ra) # 80004ca8 <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004a04:	4681                	li	a3,0
    80004a06:	4601                	li	a2,0
    80004a08:	4589                	li	a1,2
    80004a0a:	fd040513          	addi	a0,s0,-48
    80004a0e:	00002097          	auipc	ra,0x2
    80004a12:	92c080e7          	jalr	-1748(ra) # 8000633a <create>
    80004a16:	892a                	mv	s2,a0
  iunlock(in);
    80004a18:	fffff097          	auipc	ra,0xfffff
    80004a1c:	66a080e7          	jalr	1642(ra) # 80004082 <iunlock>
  p->swapFile = filealloc();
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	698080e7          	jalr	1688(ra) # 800050b8 <filealloc>
    80004a28:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    80004a2c:	cd1d                	beqz	a0,80004a6a <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004a2e:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004a32:	1684b703          	ld	a4,360(s1)
    80004a36:	4789                	li	a5,2
    80004a38:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004a3a:	1684b703          	ld	a4,360(s1)
    80004a3e:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004a42:	1684b703          	ld	a4,360(s1)
    80004a46:	4685                	li	a3,1
    80004a48:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004a4c:	1684b703          	ld	a4,360(s1)
    80004a50:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	2d4080e7          	jalr	724(ra) # 80004d28 <end_op>

    return 0;
}
    80004a5c:	4501                	li	a0,0
    80004a5e:	70a2                	ld	ra,40(sp)
    80004a60:	7402                	ld	s0,32(sp)
    80004a62:	64e2                	ld	s1,24(sp)
    80004a64:	6942                	ld	s2,16(sp)
    80004a66:	6145                	addi	sp,sp,48
    80004a68:	8082                	ret
    panic("no slot for files on /store");
    80004a6a:	00005517          	auipc	a0,0x5
    80004a6e:	f5650513          	addi	a0,a0,-170 # 800099c0 <syscalls+0x228>
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	ab8080e7          	jalr	-1352(ra) # 8000052a <panic>

0000000080004a7a <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004a7a:	1141                	addi	sp,sp,-16
    80004a7c:	e406                	sd	ra,8(sp)
    80004a7e:	e022                	sd	s0,0(sp)
    80004a80:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004a82:	16853783          	ld	a5,360(a0)
    80004a86:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004a88:	8636                	mv	a2,a3
    80004a8a:	16853503          	ld	a0,360(a0)
    80004a8e:	00001097          	auipc	ra,0x1
    80004a92:	ad8080e7          	jalr	-1320(ra) # 80005566 <kfilewrite>
}
    80004a96:	60a2                	ld	ra,8(sp)
    80004a98:	6402                	ld	s0,0(sp)
    80004a9a:	0141                	addi	sp,sp,16
    80004a9c:	8082                	ret

0000000080004a9e <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004a9e:	1141                	addi	sp,sp,-16
    80004aa0:	e406                	sd	ra,8(sp)
    80004aa2:	e022                	sd	s0,0(sp)
    80004aa4:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004aa6:	16853783          	ld	a5,360(a0)
    80004aaa:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004aac:	8636                	mv	a2,a3
    80004aae:	16853503          	ld	a0,360(a0)
    80004ab2:	00001097          	auipc	ra,0x1
    80004ab6:	9f2080e7          	jalr	-1550(ra) # 800054a4 <kfileread>
    80004aba:	60a2                	ld	ra,8(sp)
    80004abc:	6402                	ld	s0,0(sp)
    80004abe:	0141                	addi	sp,sp,16
    80004ac0:	8082                	ret

0000000080004ac2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004ac2:	1101                	addi	sp,sp,-32
    80004ac4:	ec06                	sd	ra,24(sp)
    80004ac6:	e822                	sd	s0,16(sp)
    80004ac8:	e426                	sd	s1,8(sp)
    80004aca:	e04a                	sd	s2,0(sp)
    80004acc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ace:	0003c917          	auipc	s2,0x3c
    80004ad2:	da290913          	addi	s2,s2,-606 # 80040870 <log>
    80004ad6:	01892583          	lw	a1,24(s2)
    80004ada:	02892503          	lw	a0,40(s2)
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	cde080e7          	jalr	-802(ra) # 800037bc <bread>
    80004ae6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004ae8:	02c92683          	lw	a3,44(s2)
    80004aec:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004aee:	02d05863          	blez	a3,80004b1e <write_head+0x5c>
    80004af2:	0003c797          	auipc	a5,0x3c
    80004af6:	dae78793          	addi	a5,a5,-594 # 800408a0 <log+0x30>
    80004afa:	05c50713          	addi	a4,a0,92
    80004afe:	36fd                	addiw	a3,a3,-1
    80004b00:	02069613          	slli	a2,a3,0x20
    80004b04:	01e65693          	srli	a3,a2,0x1e
    80004b08:	0003c617          	auipc	a2,0x3c
    80004b0c:	d9c60613          	addi	a2,a2,-612 # 800408a4 <log+0x34>
    80004b10:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004b12:	4390                	lw	a2,0(a5)
    80004b14:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b16:	0791                	addi	a5,a5,4
    80004b18:	0711                	addi	a4,a4,4
    80004b1a:	fed79ce3          	bne	a5,a3,80004b12 <write_head+0x50>
  }
  bwrite(buf);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	fffff097          	auipc	ra,0xfffff
    80004b24:	d8e080e7          	jalr	-626(ra) # 800038ae <bwrite>
  brelse(buf);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	fffff097          	auipc	ra,0xfffff
    80004b2e:	dc2080e7          	jalr	-574(ra) # 800038ec <brelse>
}
    80004b32:	60e2                	ld	ra,24(sp)
    80004b34:	6442                	ld	s0,16(sp)
    80004b36:	64a2                	ld	s1,8(sp)
    80004b38:	6902                	ld	s2,0(sp)
    80004b3a:	6105                	addi	sp,sp,32
    80004b3c:	8082                	ret

0000000080004b3e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b3e:	0003c797          	auipc	a5,0x3c
    80004b42:	d5e7a783          	lw	a5,-674(a5) # 8004089c <log+0x2c>
    80004b46:	0af05d63          	blez	a5,80004c00 <install_trans+0xc2>
{
    80004b4a:	7139                	addi	sp,sp,-64
    80004b4c:	fc06                	sd	ra,56(sp)
    80004b4e:	f822                	sd	s0,48(sp)
    80004b50:	f426                	sd	s1,40(sp)
    80004b52:	f04a                	sd	s2,32(sp)
    80004b54:	ec4e                	sd	s3,24(sp)
    80004b56:	e852                	sd	s4,16(sp)
    80004b58:	e456                	sd	s5,8(sp)
    80004b5a:	e05a                	sd	s6,0(sp)
    80004b5c:	0080                	addi	s0,sp,64
    80004b5e:	8b2a                	mv	s6,a0
    80004b60:	0003ca97          	auipc	s5,0x3c
    80004b64:	d40a8a93          	addi	s5,s5,-704 # 800408a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b68:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b6a:	0003c997          	auipc	s3,0x3c
    80004b6e:	d0698993          	addi	s3,s3,-762 # 80040870 <log>
    80004b72:	a00d                	j	80004b94 <install_trans+0x56>
    brelse(lbuf);
    80004b74:	854a                	mv	a0,s2
    80004b76:	fffff097          	auipc	ra,0xfffff
    80004b7a:	d76080e7          	jalr	-650(ra) # 800038ec <brelse>
    brelse(dbuf);
    80004b7e:	8526                	mv	a0,s1
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	d6c080e7          	jalr	-660(ra) # 800038ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b88:	2a05                	addiw	s4,s4,1
    80004b8a:	0a91                	addi	s5,s5,4
    80004b8c:	02c9a783          	lw	a5,44(s3)
    80004b90:	04fa5e63          	bge	s4,a5,80004bec <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b94:	0189a583          	lw	a1,24(s3)
    80004b98:	014585bb          	addw	a1,a1,s4
    80004b9c:	2585                	addiw	a1,a1,1
    80004b9e:	0289a503          	lw	a0,40(s3)
    80004ba2:	fffff097          	auipc	ra,0xfffff
    80004ba6:	c1a080e7          	jalr	-998(ra) # 800037bc <bread>
    80004baa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004bac:	000aa583          	lw	a1,0(s5)
    80004bb0:	0289a503          	lw	a0,40(s3)
    80004bb4:	fffff097          	auipc	ra,0xfffff
    80004bb8:	c08080e7          	jalr	-1016(ra) # 800037bc <bread>
    80004bbc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004bbe:	40000613          	li	a2,1024
    80004bc2:	05890593          	addi	a1,s2,88
    80004bc6:	05850513          	addi	a0,a0,88
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	150080e7          	jalr	336(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	fffff097          	auipc	ra,0xfffff
    80004bd8:	cda080e7          	jalr	-806(ra) # 800038ae <bwrite>
    if(recovering == 0)
    80004bdc:	f80b1ce3          	bnez	s6,80004b74 <install_trans+0x36>
      bunpin(dbuf);
    80004be0:	8526                	mv	a0,s1
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	de4080e7          	jalr	-540(ra) # 800039c6 <bunpin>
    80004bea:	b769                	j	80004b74 <install_trans+0x36>
}
    80004bec:	70e2                	ld	ra,56(sp)
    80004bee:	7442                	ld	s0,48(sp)
    80004bf0:	74a2                	ld	s1,40(sp)
    80004bf2:	7902                	ld	s2,32(sp)
    80004bf4:	69e2                	ld	s3,24(sp)
    80004bf6:	6a42                	ld	s4,16(sp)
    80004bf8:	6aa2                	ld	s5,8(sp)
    80004bfa:	6b02                	ld	s6,0(sp)
    80004bfc:	6121                	addi	sp,sp,64
    80004bfe:	8082                	ret
    80004c00:	8082                	ret

0000000080004c02 <initlog>:
{
    80004c02:	7179                	addi	sp,sp,-48
    80004c04:	f406                	sd	ra,40(sp)
    80004c06:	f022                	sd	s0,32(sp)
    80004c08:	ec26                	sd	s1,24(sp)
    80004c0a:	e84a                	sd	s2,16(sp)
    80004c0c:	e44e                	sd	s3,8(sp)
    80004c0e:	1800                	addi	s0,sp,48
    80004c10:	892a                	mv	s2,a0
    80004c12:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c14:	0003c497          	auipc	s1,0x3c
    80004c18:	c5c48493          	addi	s1,s1,-932 # 80040870 <log>
    80004c1c:	00005597          	auipc	a1,0x5
    80004c20:	dc458593          	addi	a1,a1,-572 # 800099e0 <syscalls+0x248>
    80004c24:	8526                	mv	a0,s1
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	f0c080e7          	jalr	-244(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004c2e:	0149a583          	lw	a1,20(s3)
    80004c32:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004c34:	0109a783          	lw	a5,16(s3)
    80004c38:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004c3a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004c3e:	854a                	mv	a0,s2
    80004c40:	fffff097          	auipc	ra,0xfffff
    80004c44:	b7c080e7          	jalr	-1156(ra) # 800037bc <bread>
  log.lh.n = lh->n;
    80004c48:	4d34                	lw	a3,88(a0)
    80004c4a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004c4c:	02d05663          	blez	a3,80004c78 <initlog+0x76>
    80004c50:	05c50793          	addi	a5,a0,92
    80004c54:	0003c717          	auipc	a4,0x3c
    80004c58:	c4c70713          	addi	a4,a4,-948 # 800408a0 <log+0x30>
    80004c5c:	36fd                	addiw	a3,a3,-1
    80004c5e:	02069613          	slli	a2,a3,0x20
    80004c62:	01e65693          	srli	a3,a2,0x1e
    80004c66:	06050613          	addi	a2,a0,96
    80004c6a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004c6c:	4390                	lw	a2,0(a5)
    80004c6e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004c70:	0791                	addi	a5,a5,4
    80004c72:	0711                	addi	a4,a4,4
    80004c74:	fed79ce3          	bne	a5,a3,80004c6c <initlog+0x6a>
  brelse(buf);
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	c74080e7          	jalr	-908(ra) # 800038ec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004c80:	4505                	li	a0,1
    80004c82:	00000097          	auipc	ra,0x0
    80004c86:	ebc080e7          	jalr	-324(ra) # 80004b3e <install_trans>
  log.lh.n = 0;
    80004c8a:	0003c797          	auipc	a5,0x3c
    80004c8e:	c007a923          	sw	zero,-1006(a5) # 8004089c <log+0x2c>
  write_head(); // clear the log
    80004c92:	00000097          	auipc	ra,0x0
    80004c96:	e30080e7          	jalr	-464(ra) # 80004ac2 <write_head>
}
    80004c9a:	70a2                	ld	ra,40(sp)
    80004c9c:	7402                	ld	s0,32(sp)
    80004c9e:	64e2                	ld	s1,24(sp)
    80004ca0:	6942                	ld	s2,16(sp)
    80004ca2:	69a2                	ld	s3,8(sp)
    80004ca4:	6145                	addi	sp,sp,48
    80004ca6:	8082                	ret

0000000080004ca8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004ca8:	1101                	addi	sp,sp,-32
    80004caa:	ec06                	sd	ra,24(sp)
    80004cac:	e822                	sd	s0,16(sp)
    80004cae:	e426                	sd	s1,8(sp)
    80004cb0:	e04a                	sd	s2,0(sp)
    80004cb2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004cb4:	0003c517          	auipc	a0,0x3c
    80004cb8:	bbc50513          	addi	a0,a0,-1092 # 80040870 <log>
    80004cbc:	ffffc097          	auipc	ra,0xffffc
    80004cc0:	f06080e7          	jalr	-250(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004cc4:	0003c497          	auipc	s1,0x3c
    80004cc8:	bac48493          	addi	s1,s1,-1108 # 80040870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004ccc:	4979                	li	s2,30
    80004cce:	a039                	j	80004cdc <begin_op+0x34>
      sleep(&log, &log.lock);
    80004cd0:	85a6                	mv	a1,s1
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	15a080e7          	jalr	346(ra) # 80001e2e <sleep>
    if(log.committing){
    80004cdc:	50dc                	lw	a5,36(s1)
    80004cde:	fbed                	bnez	a5,80004cd0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004ce0:	509c                	lw	a5,32(s1)
    80004ce2:	0017871b          	addiw	a4,a5,1
    80004ce6:	0007069b          	sext.w	a3,a4
    80004cea:	0027179b          	slliw	a5,a4,0x2
    80004cee:	9fb9                	addw	a5,a5,a4
    80004cf0:	0017979b          	slliw	a5,a5,0x1
    80004cf4:	54d8                	lw	a4,44(s1)
    80004cf6:	9fb9                	addw	a5,a5,a4
    80004cf8:	00f95963          	bge	s2,a5,80004d0a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004cfc:	85a6                	mv	a1,s1
    80004cfe:	8526                	mv	a0,s1
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	12e080e7          	jalr	302(ra) # 80001e2e <sleep>
    80004d08:	bfd1                	j	80004cdc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004d0a:	0003c517          	auipc	a0,0x3c
    80004d0e:	b6650513          	addi	a0,a0,-1178 # 80040870 <log>
    80004d12:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	f62080e7          	jalr	-158(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004d1c:	60e2                	ld	ra,24(sp)
    80004d1e:	6442                	ld	s0,16(sp)
    80004d20:	64a2                	ld	s1,8(sp)
    80004d22:	6902                	ld	s2,0(sp)
    80004d24:	6105                	addi	sp,sp,32
    80004d26:	8082                	ret

0000000080004d28 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d28:	7139                	addi	sp,sp,-64
    80004d2a:	fc06                	sd	ra,56(sp)
    80004d2c:	f822                	sd	s0,48(sp)
    80004d2e:	f426                	sd	s1,40(sp)
    80004d30:	f04a                	sd	s2,32(sp)
    80004d32:	ec4e                	sd	s3,24(sp)
    80004d34:	e852                	sd	s4,16(sp)
    80004d36:	e456                	sd	s5,8(sp)
    80004d38:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d3a:	0003c497          	auipc	s1,0x3c
    80004d3e:	b3648493          	addi	s1,s1,-1226 # 80040870 <log>
    80004d42:	8526                	mv	a0,s1
    80004d44:	ffffc097          	auipc	ra,0xffffc
    80004d48:	e7e080e7          	jalr	-386(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004d4c:	509c                	lw	a5,32(s1)
    80004d4e:	37fd                	addiw	a5,a5,-1
    80004d50:	0007891b          	sext.w	s2,a5
    80004d54:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004d56:	50dc                	lw	a5,36(s1)
    80004d58:	e7b9                	bnez	a5,80004da6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004d5a:	04091e63          	bnez	s2,80004db6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004d5e:	0003c497          	auipc	s1,0x3c
    80004d62:	b1248493          	addi	s1,s1,-1262 # 80040870 <log>
    80004d66:	4785                	li	a5,1
    80004d68:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	f0a080e7          	jalr	-246(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004d74:	54dc                	lw	a5,44(s1)
    80004d76:	06f04763          	bgtz	a5,80004de4 <end_op+0xbc>
    acquire(&log.lock);
    80004d7a:	0003c497          	auipc	s1,0x3c
    80004d7e:	af648493          	addi	s1,s1,-1290 # 80040870 <log>
    80004d82:	8526                	mv	a0,s1
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	e3e080e7          	jalr	-450(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004d8c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004d90:	8526                	mv	a0,s1
    80004d92:	ffffd097          	auipc	ra,0xffffd
    80004d96:	100080e7          	jalr	256(ra) # 80001e92 <wakeup>
    release(&log.lock);
    80004d9a:	8526                	mv	a0,s1
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	eda080e7          	jalr	-294(ra) # 80000c76 <release>
}
    80004da4:	a03d                	j	80004dd2 <end_op+0xaa>
    panic("log.committing");
    80004da6:	00005517          	auipc	a0,0x5
    80004daa:	c4250513          	addi	a0,a0,-958 # 800099e8 <syscalls+0x250>
    80004dae:	ffffb097          	auipc	ra,0xffffb
    80004db2:	77c080e7          	jalr	1916(ra) # 8000052a <panic>
    wakeup(&log);
    80004db6:	0003c497          	auipc	s1,0x3c
    80004dba:	aba48493          	addi	s1,s1,-1350 # 80040870 <log>
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	ffffd097          	auipc	ra,0xffffd
    80004dc4:	0d2080e7          	jalr	210(ra) # 80001e92 <wakeup>
  release(&log.lock);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	ffffc097          	auipc	ra,0xffffc
    80004dce:	eac080e7          	jalr	-340(ra) # 80000c76 <release>
}
    80004dd2:	70e2                	ld	ra,56(sp)
    80004dd4:	7442                	ld	s0,48(sp)
    80004dd6:	74a2                	ld	s1,40(sp)
    80004dd8:	7902                	ld	s2,32(sp)
    80004dda:	69e2                	ld	s3,24(sp)
    80004ddc:	6a42                	ld	s4,16(sp)
    80004dde:	6aa2                	ld	s5,8(sp)
    80004de0:	6121                	addi	sp,sp,64
    80004de2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004de4:	0003ca97          	auipc	s5,0x3c
    80004de8:	abca8a93          	addi	s5,s5,-1348 # 800408a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004dec:	0003ca17          	auipc	s4,0x3c
    80004df0:	a84a0a13          	addi	s4,s4,-1404 # 80040870 <log>
    80004df4:	018a2583          	lw	a1,24(s4)
    80004df8:	012585bb          	addw	a1,a1,s2
    80004dfc:	2585                	addiw	a1,a1,1
    80004dfe:	028a2503          	lw	a0,40(s4)
    80004e02:	fffff097          	auipc	ra,0xfffff
    80004e06:	9ba080e7          	jalr	-1606(ra) # 800037bc <bread>
    80004e0a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004e0c:	000aa583          	lw	a1,0(s5)
    80004e10:	028a2503          	lw	a0,40(s4)
    80004e14:	fffff097          	auipc	ra,0xfffff
    80004e18:	9a8080e7          	jalr	-1624(ra) # 800037bc <bread>
    80004e1c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004e1e:	40000613          	li	a2,1024
    80004e22:	05850593          	addi	a1,a0,88
    80004e26:	05848513          	addi	a0,s1,88
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	ef0080e7          	jalr	-272(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004e32:	8526                	mv	a0,s1
    80004e34:	fffff097          	auipc	ra,0xfffff
    80004e38:	a7a080e7          	jalr	-1414(ra) # 800038ae <bwrite>
    brelse(from);
    80004e3c:	854e                	mv	a0,s3
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	aae080e7          	jalr	-1362(ra) # 800038ec <brelse>
    brelse(to);
    80004e46:	8526                	mv	a0,s1
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	aa4080e7          	jalr	-1372(ra) # 800038ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e50:	2905                	addiw	s2,s2,1
    80004e52:	0a91                	addi	s5,s5,4
    80004e54:	02ca2783          	lw	a5,44(s4)
    80004e58:	f8f94ee3          	blt	s2,a5,80004df4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004e5c:	00000097          	auipc	ra,0x0
    80004e60:	c66080e7          	jalr	-922(ra) # 80004ac2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004e64:	4501                	li	a0,0
    80004e66:	00000097          	auipc	ra,0x0
    80004e6a:	cd8080e7          	jalr	-808(ra) # 80004b3e <install_trans>
    log.lh.n = 0;
    80004e6e:	0003c797          	auipc	a5,0x3c
    80004e72:	a207a723          	sw	zero,-1490(a5) # 8004089c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004e76:	00000097          	auipc	ra,0x0
    80004e7a:	c4c080e7          	jalr	-948(ra) # 80004ac2 <write_head>
    80004e7e:	bdf5                	j	80004d7a <end_op+0x52>

0000000080004e80 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004e80:	1101                	addi	sp,sp,-32
    80004e82:	ec06                	sd	ra,24(sp)
    80004e84:	e822                	sd	s0,16(sp)
    80004e86:	e426                	sd	s1,8(sp)
    80004e88:	e04a                	sd	s2,0(sp)
    80004e8a:	1000                	addi	s0,sp,32
    80004e8c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004e8e:	0003c917          	auipc	s2,0x3c
    80004e92:	9e290913          	addi	s2,s2,-1566 # 80040870 <log>
    80004e96:	854a                	mv	a0,s2
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	d2a080e7          	jalr	-726(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004ea0:	02c92603          	lw	a2,44(s2)
    80004ea4:	47f5                	li	a5,29
    80004ea6:	06c7c563          	blt	a5,a2,80004f10 <log_write+0x90>
    80004eaa:	0003c797          	auipc	a5,0x3c
    80004eae:	9e27a783          	lw	a5,-1566(a5) # 8004088c <log+0x1c>
    80004eb2:	37fd                	addiw	a5,a5,-1
    80004eb4:	04f65e63          	bge	a2,a5,80004f10 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004eb8:	0003c797          	auipc	a5,0x3c
    80004ebc:	9d87a783          	lw	a5,-1576(a5) # 80040890 <log+0x20>
    80004ec0:	06f05063          	blez	a5,80004f20 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004ec4:	4781                	li	a5,0
    80004ec6:	06c05563          	blez	a2,80004f30 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004eca:	44cc                	lw	a1,12(s1)
    80004ecc:	0003c717          	auipc	a4,0x3c
    80004ed0:	9d470713          	addi	a4,a4,-1580 # 800408a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ed4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004ed6:	4314                	lw	a3,0(a4)
    80004ed8:	04b68c63          	beq	a3,a1,80004f30 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004edc:	2785                	addiw	a5,a5,1
    80004ede:	0711                	addi	a4,a4,4
    80004ee0:	fef61be3          	bne	a2,a5,80004ed6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ee4:	0621                	addi	a2,a2,8
    80004ee6:	060a                	slli	a2,a2,0x2
    80004ee8:	0003c797          	auipc	a5,0x3c
    80004eec:	98878793          	addi	a5,a5,-1656 # 80040870 <log>
    80004ef0:	963e                	add	a2,a2,a5
    80004ef2:	44dc                	lw	a5,12(s1)
    80004ef4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	a92080e7          	jalr	-1390(ra) # 8000398a <bpin>
    log.lh.n++;
    80004f00:	0003c717          	auipc	a4,0x3c
    80004f04:	97070713          	addi	a4,a4,-1680 # 80040870 <log>
    80004f08:	575c                	lw	a5,44(a4)
    80004f0a:	2785                	addiw	a5,a5,1
    80004f0c:	d75c                	sw	a5,44(a4)
    80004f0e:	a835                	j	80004f4a <log_write+0xca>
    panic("too big a transaction");
    80004f10:	00005517          	auipc	a0,0x5
    80004f14:	ae850513          	addi	a0,a0,-1304 # 800099f8 <syscalls+0x260>
    80004f18:	ffffb097          	auipc	ra,0xffffb
    80004f1c:	612080e7          	jalr	1554(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004f20:	00005517          	auipc	a0,0x5
    80004f24:	af050513          	addi	a0,a0,-1296 # 80009a10 <syscalls+0x278>
    80004f28:	ffffb097          	auipc	ra,0xffffb
    80004f2c:	602080e7          	jalr	1538(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004f30:	00878713          	addi	a4,a5,8
    80004f34:	00271693          	slli	a3,a4,0x2
    80004f38:	0003c717          	auipc	a4,0x3c
    80004f3c:	93870713          	addi	a4,a4,-1736 # 80040870 <log>
    80004f40:	9736                	add	a4,a4,a3
    80004f42:	44d4                	lw	a3,12(s1)
    80004f44:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004f46:	faf608e3          	beq	a2,a5,80004ef6 <log_write+0x76>
  }
  release(&log.lock);
    80004f4a:	0003c517          	auipc	a0,0x3c
    80004f4e:	92650513          	addi	a0,a0,-1754 # 80040870 <log>
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	d24080e7          	jalr	-732(ra) # 80000c76 <release>
}
    80004f5a:	60e2                	ld	ra,24(sp)
    80004f5c:	6442                	ld	s0,16(sp)
    80004f5e:	64a2                	ld	s1,8(sp)
    80004f60:	6902                	ld	s2,0(sp)
    80004f62:	6105                	addi	sp,sp,32
    80004f64:	8082                	ret

0000000080004f66 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004f66:	1101                	addi	sp,sp,-32
    80004f68:	ec06                	sd	ra,24(sp)
    80004f6a:	e822                	sd	s0,16(sp)
    80004f6c:	e426                	sd	s1,8(sp)
    80004f6e:	e04a                	sd	s2,0(sp)
    80004f70:	1000                	addi	s0,sp,32
    80004f72:	84aa                	mv	s1,a0
    80004f74:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004f76:	00005597          	auipc	a1,0x5
    80004f7a:	aba58593          	addi	a1,a1,-1350 # 80009a30 <syscalls+0x298>
    80004f7e:	0521                	addi	a0,a0,8
    80004f80:	ffffc097          	auipc	ra,0xffffc
    80004f84:	bb2080e7          	jalr	-1102(ra) # 80000b32 <initlock>
  lk->name = name;
    80004f88:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004f8c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f90:	0204a423          	sw	zero,40(s1)
}
    80004f94:	60e2                	ld	ra,24(sp)
    80004f96:	6442                	ld	s0,16(sp)
    80004f98:	64a2                	ld	s1,8(sp)
    80004f9a:	6902                	ld	s2,0(sp)
    80004f9c:	6105                	addi	sp,sp,32
    80004f9e:	8082                	ret

0000000080004fa0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004fa0:	1101                	addi	sp,sp,-32
    80004fa2:	ec06                	sd	ra,24(sp)
    80004fa4:	e822                	sd	s0,16(sp)
    80004fa6:	e426                	sd	s1,8(sp)
    80004fa8:	e04a                	sd	s2,0(sp)
    80004faa:	1000                	addi	s0,sp,32
    80004fac:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004fae:	00850913          	addi	s2,a0,8
    80004fb2:	854a                	mv	a0,s2
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	c0e080e7          	jalr	-1010(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004fbc:	409c                	lw	a5,0(s1)
    80004fbe:	cb89                	beqz	a5,80004fd0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004fc0:	85ca                	mv	a1,s2
    80004fc2:	8526                	mv	a0,s1
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	e6a080e7          	jalr	-406(ra) # 80001e2e <sleep>
  while (lk->locked) {
    80004fcc:	409c                	lw	a5,0(s1)
    80004fce:	fbed                	bnez	a5,80004fc0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004fd0:	4785                	li	a5,1
    80004fd2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004fd4:	ffffd097          	auipc	ra,0xffffd
    80004fd8:	ab8080e7          	jalr	-1352(ra) # 80001a8c <myproc>
    80004fdc:	591c                	lw	a5,48(a0)
    80004fde:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004fe0:	854a                	mv	a0,s2
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	c94080e7          	jalr	-876(ra) # 80000c76 <release>
}
    80004fea:	60e2                	ld	ra,24(sp)
    80004fec:	6442                	ld	s0,16(sp)
    80004fee:	64a2                	ld	s1,8(sp)
    80004ff0:	6902                	ld	s2,0(sp)
    80004ff2:	6105                	addi	sp,sp,32
    80004ff4:	8082                	ret

0000000080004ff6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ff6:	1101                	addi	sp,sp,-32
    80004ff8:	ec06                	sd	ra,24(sp)
    80004ffa:	e822                	sd	s0,16(sp)
    80004ffc:	e426                	sd	s1,8(sp)
    80004ffe:	e04a                	sd	s2,0(sp)
    80005000:	1000                	addi	s0,sp,32
    80005002:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005004:	00850913          	addi	s2,a0,8
    80005008:	854a                	mv	a0,s2
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	bb8080e7          	jalr	-1096(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005012:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005016:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000501a:	8526                	mv	a0,s1
    8000501c:	ffffd097          	auipc	ra,0xffffd
    80005020:	e76080e7          	jalr	-394(ra) # 80001e92 <wakeup>
  release(&lk->lk);
    80005024:	854a                	mv	a0,s2
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	c50080e7          	jalr	-944(ra) # 80000c76 <release>
}
    8000502e:	60e2                	ld	ra,24(sp)
    80005030:	6442                	ld	s0,16(sp)
    80005032:	64a2                	ld	s1,8(sp)
    80005034:	6902                	ld	s2,0(sp)
    80005036:	6105                	addi	sp,sp,32
    80005038:	8082                	ret

000000008000503a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000503a:	7179                	addi	sp,sp,-48
    8000503c:	f406                	sd	ra,40(sp)
    8000503e:	f022                	sd	s0,32(sp)
    80005040:	ec26                	sd	s1,24(sp)
    80005042:	e84a                	sd	s2,16(sp)
    80005044:	e44e                	sd	s3,8(sp)
    80005046:	1800                	addi	s0,sp,48
    80005048:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000504a:	00850913          	addi	s2,a0,8
    8000504e:	854a                	mv	a0,s2
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	b72080e7          	jalr	-1166(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005058:	409c                	lw	a5,0(s1)
    8000505a:	ef99                	bnez	a5,80005078 <holdingsleep+0x3e>
    8000505c:	4481                	li	s1,0
  release(&lk->lk);
    8000505e:	854a                	mv	a0,s2
    80005060:	ffffc097          	auipc	ra,0xffffc
    80005064:	c16080e7          	jalr	-1002(ra) # 80000c76 <release>
  return r;
}
    80005068:	8526                	mv	a0,s1
    8000506a:	70a2                	ld	ra,40(sp)
    8000506c:	7402                	ld	s0,32(sp)
    8000506e:	64e2                	ld	s1,24(sp)
    80005070:	6942                	ld	s2,16(sp)
    80005072:	69a2                	ld	s3,8(sp)
    80005074:	6145                	addi	sp,sp,48
    80005076:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005078:	0284a983          	lw	s3,40(s1)
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	a10080e7          	jalr	-1520(ra) # 80001a8c <myproc>
    80005084:	5904                	lw	s1,48(a0)
    80005086:	413484b3          	sub	s1,s1,s3
    8000508a:	0014b493          	seqz	s1,s1
    8000508e:	bfc1                	j	8000505e <holdingsleep+0x24>

0000000080005090 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005090:	1141                	addi	sp,sp,-16
    80005092:	e406                	sd	ra,8(sp)
    80005094:	e022                	sd	s0,0(sp)
    80005096:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005098:	00005597          	auipc	a1,0x5
    8000509c:	9a858593          	addi	a1,a1,-1624 # 80009a40 <syscalls+0x2a8>
    800050a0:	0003c517          	auipc	a0,0x3c
    800050a4:	91850513          	addi	a0,a0,-1768 # 800409b8 <ftable>
    800050a8:	ffffc097          	auipc	ra,0xffffc
    800050ac:	a8a080e7          	jalr	-1398(ra) # 80000b32 <initlock>
}
    800050b0:	60a2                	ld	ra,8(sp)
    800050b2:	6402                	ld	s0,0(sp)
    800050b4:	0141                	addi	sp,sp,16
    800050b6:	8082                	ret

00000000800050b8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800050b8:	1101                	addi	sp,sp,-32
    800050ba:	ec06                	sd	ra,24(sp)
    800050bc:	e822                	sd	s0,16(sp)
    800050be:	e426                	sd	s1,8(sp)
    800050c0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800050c2:	0003c517          	auipc	a0,0x3c
    800050c6:	8f650513          	addi	a0,a0,-1802 # 800409b8 <ftable>
    800050ca:	ffffc097          	auipc	ra,0xffffc
    800050ce:	af8080e7          	jalr	-1288(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800050d2:	0003c497          	auipc	s1,0x3c
    800050d6:	8fe48493          	addi	s1,s1,-1794 # 800409d0 <ftable+0x18>
    800050da:	0003d717          	auipc	a4,0x3d
    800050de:	89670713          	addi	a4,a4,-1898 # 80041970 <ftable+0xfb8>
    if(f->ref == 0){
    800050e2:	40dc                	lw	a5,4(s1)
    800050e4:	cf99                	beqz	a5,80005102 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800050e6:	02848493          	addi	s1,s1,40
    800050ea:	fee49ce3          	bne	s1,a4,800050e2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800050ee:	0003c517          	auipc	a0,0x3c
    800050f2:	8ca50513          	addi	a0,a0,-1846 # 800409b8 <ftable>
    800050f6:	ffffc097          	auipc	ra,0xffffc
    800050fa:	b80080e7          	jalr	-1152(ra) # 80000c76 <release>
  return 0;
    800050fe:	4481                	li	s1,0
    80005100:	a819                	j	80005116 <filealloc+0x5e>
      f->ref = 1;
    80005102:	4785                	li	a5,1
    80005104:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005106:	0003c517          	auipc	a0,0x3c
    8000510a:	8b250513          	addi	a0,a0,-1870 # 800409b8 <ftable>
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	b68080e7          	jalr	-1176(ra) # 80000c76 <release>
}
    80005116:	8526                	mv	a0,s1
    80005118:	60e2                	ld	ra,24(sp)
    8000511a:	6442                	ld	s0,16(sp)
    8000511c:	64a2                	ld	s1,8(sp)
    8000511e:	6105                	addi	sp,sp,32
    80005120:	8082                	ret

0000000080005122 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005122:	1101                	addi	sp,sp,-32
    80005124:	ec06                	sd	ra,24(sp)
    80005126:	e822                	sd	s0,16(sp)
    80005128:	e426                	sd	s1,8(sp)
    8000512a:	1000                	addi	s0,sp,32
    8000512c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000512e:	0003c517          	auipc	a0,0x3c
    80005132:	88a50513          	addi	a0,a0,-1910 # 800409b8 <ftable>
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	a8c080e7          	jalr	-1396(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000513e:	40dc                	lw	a5,4(s1)
    80005140:	02f05263          	blez	a5,80005164 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005144:	2785                	addiw	a5,a5,1
    80005146:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005148:	0003c517          	auipc	a0,0x3c
    8000514c:	87050513          	addi	a0,a0,-1936 # 800409b8 <ftable>
    80005150:	ffffc097          	auipc	ra,0xffffc
    80005154:	b26080e7          	jalr	-1242(ra) # 80000c76 <release>
  return f;
}
    80005158:	8526                	mv	a0,s1
    8000515a:	60e2                	ld	ra,24(sp)
    8000515c:	6442                	ld	s0,16(sp)
    8000515e:	64a2                	ld	s1,8(sp)
    80005160:	6105                	addi	sp,sp,32
    80005162:	8082                	ret
    panic("filedup");
    80005164:	00005517          	auipc	a0,0x5
    80005168:	8e450513          	addi	a0,a0,-1820 # 80009a48 <syscalls+0x2b0>
    8000516c:	ffffb097          	auipc	ra,0xffffb
    80005170:	3be080e7          	jalr	958(ra) # 8000052a <panic>

0000000080005174 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005174:	7139                	addi	sp,sp,-64
    80005176:	fc06                	sd	ra,56(sp)
    80005178:	f822                	sd	s0,48(sp)
    8000517a:	f426                	sd	s1,40(sp)
    8000517c:	f04a                	sd	s2,32(sp)
    8000517e:	ec4e                	sd	s3,24(sp)
    80005180:	e852                	sd	s4,16(sp)
    80005182:	e456                	sd	s5,8(sp)
    80005184:	0080                	addi	s0,sp,64
    80005186:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005188:	0003c517          	auipc	a0,0x3c
    8000518c:	83050513          	addi	a0,a0,-2000 # 800409b8 <ftable>
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	a32080e7          	jalr	-1486(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005198:	40dc                	lw	a5,4(s1)
    8000519a:	06f05163          	blez	a5,800051fc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000519e:	37fd                	addiw	a5,a5,-1
    800051a0:	0007871b          	sext.w	a4,a5
    800051a4:	c0dc                	sw	a5,4(s1)
    800051a6:	06e04363          	bgtz	a4,8000520c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800051aa:	0004a903          	lw	s2,0(s1)
    800051ae:	0094ca83          	lbu	s5,9(s1)
    800051b2:	0104ba03          	ld	s4,16(s1)
    800051b6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800051ba:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800051be:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800051c2:	0003b517          	auipc	a0,0x3b
    800051c6:	7f650513          	addi	a0,a0,2038 # 800409b8 <ftable>
    800051ca:	ffffc097          	auipc	ra,0xffffc
    800051ce:	aac080e7          	jalr	-1364(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800051d2:	4785                	li	a5,1
    800051d4:	04f90d63          	beq	s2,a5,8000522e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800051d8:	3979                	addiw	s2,s2,-2
    800051da:	4785                	li	a5,1
    800051dc:	0527e063          	bltu	a5,s2,8000521c <fileclose+0xa8>
    begin_op();
    800051e0:	00000097          	auipc	ra,0x0
    800051e4:	ac8080e7          	jalr	-1336(ra) # 80004ca8 <begin_op>
    iput(ff.ip);
    800051e8:	854e                	mv	a0,s3
    800051ea:	fffff097          	auipc	ra,0xfffff
    800051ee:	f90080e7          	jalr	-112(ra) # 8000417a <iput>
    end_op();
    800051f2:	00000097          	auipc	ra,0x0
    800051f6:	b36080e7          	jalr	-1226(ra) # 80004d28 <end_op>
    800051fa:	a00d                	j	8000521c <fileclose+0xa8>
    panic("fileclose");
    800051fc:	00005517          	auipc	a0,0x5
    80005200:	85450513          	addi	a0,a0,-1964 # 80009a50 <syscalls+0x2b8>
    80005204:	ffffb097          	auipc	ra,0xffffb
    80005208:	326080e7          	jalr	806(ra) # 8000052a <panic>
    release(&ftable.lock);
    8000520c:	0003b517          	auipc	a0,0x3b
    80005210:	7ac50513          	addi	a0,a0,1964 # 800409b8 <ftable>
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	a62080e7          	jalr	-1438(ra) # 80000c76 <release>
  }
}
    8000521c:	70e2                	ld	ra,56(sp)
    8000521e:	7442                	ld	s0,48(sp)
    80005220:	74a2                	ld	s1,40(sp)
    80005222:	7902                	ld	s2,32(sp)
    80005224:	69e2                	ld	s3,24(sp)
    80005226:	6a42                	ld	s4,16(sp)
    80005228:	6aa2                	ld	s5,8(sp)
    8000522a:	6121                	addi	sp,sp,64
    8000522c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000522e:	85d6                	mv	a1,s5
    80005230:	8552                	mv	a0,s4
    80005232:	00000097          	auipc	ra,0x0
    80005236:	542080e7          	jalr	1346(ra) # 80005774 <pipeclose>
    8000523a:	b7cd                	j	8000521c <fileclose+0xa8>

000000008000523c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000523c:	715d                	addi	sp,sp,-80
    8000523e:	e486                	sd	ra,72(sp)
    80005240:	e0a2                	sd	s0,64(sp)
    80005242:	fc26                	sd	s1,56(sp)
    80005244:	f84a                	sd	s2,48(sp)
    80005246:	f44e                	sd	s3,40(sp)
    80005248:	0880                	addi	s0,sp,80
    8000524a:	84aa                	mv	s1,a0
    8000524c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000524e:	ffffd097          	auipc	ra,0xffffd
    80005252:	83e080e7          	jalr	-1986(ra) # 80001a8c <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005256:	409c                	lw	a5,0(s1)
    80005258:	37f9                	addiw	a5,a5,-2
    8000525a:	4705                	li	a4,1
    8000525c:	04f76763          	bltu	a4,a5,800052aa <filestat+0x6e>
    80005260:	892a                	mv	s2,a0
    ilock(f->ip);
    80005262:	6c88                	ld	a0,24(s1)
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	d5c080e7          	jalr	-676(ra) # 80003fc0 <ilock>
    stati(f->ip, &st);
    8000526c:	fb840593          	addi	a1,s0,-72
    80005270:	6c88                	ld	a0,24(s1)
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	fd8080e7          	jalr	-40(ra) # 8000424a <stati>
    iunlock(f->ip);
    8000527a:	6c88                	ld	a0,24(s1)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	e06080e7          	jalr	-506(ra) # 80004082 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005284:	46e1                	li	a3,24
    80005286:	fb840613          	addi	a2,s0,-72
    8000528a:	85ce                	mv	a1,s3
    8000528c:	05093503          	ld	a0,80(s2)
    80005290:	ffffc097          	auipc	ra,0xffffc
    80005294:	4a8080e7          	jalr	1192(ra) # 80001738 <copyout>
    80005298:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000529c:	60a6                	ld	ra,72(sp)
    8000529e:	6406                	ld	s0,64(sp)
    800052a0:	74e2                	ld	s1,56(sp)
    800052a2:	7942                	ld	s2,48(sp)
    800052a4:	79a2                	ld	s3,40(sp)
    800052a6:	6161                	addi	sp,sp,80
    800052a8:	8082                	ret
  return -1;
    800052aa:	557d                	li	a0,-1
    800052ac:	bfc5                	j	8000529c <filestat+0x60>

00000000800052ae <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800052ae:	7179                	addi	sp,sp,-48
    800052b0:	f406                	sd	ra,40(sp)
    800052b2:	f022                	sd	s0,32(sp)
    800052b4:	ec26                	sd	s1,24(sp)
    800052b6:	e84a                	sd	s2,16(sp)
    800052b8:	e44e                	sd	s3,8(sp)
    800052ba:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800052bc:	00854783          	lbu	a5,8(a0)
    800052c0:	c3d5                	beqz	a5,80005364 <fileread+0xb6>
    800052c2:	84aa                	mv	s1,a0
    800052c4:	89ae                	mv	s3,a1
    800052c6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800052c8:	411c                	lw	a5,0(a0)
    800052ca:	4705                	li	a4,1
    800052cc:	04e78963          	beq	a5,a4,8000531e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800052d0:	470d                	li	a4,3
    800052d2:	04e78d63          	beq	a5,a4,8000532c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800052d6:	4709                	li	a4,2
    800052d8:	06e79e63          	bne	a5,a4,80005354 <fileread+0xa6>
    ilock(f->ip);
    800052dc:	6d08                	ld	a0,24(a0)
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	ce2080e7          	jalr	-798(ra) # 80003fc0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800052e6:	874a                	mv	a4,s2
    800052e8:	5094                	lw	a3,32(s1)
    800052ea:	864e                	mv	a2,s3
    800052ec:	4585                	li	a1,1
    800052ee:	6c88                	ld	a0,24(s1)
    800052f0:	fffff097          	auipc	ra,0xfffff
    800052f4:	f84080e7          	jalr	-124(ra) # 80004274 <readi>
    800052f8:	892a                	mv	s2,a0
    800052fa:	00a05563          	blez	a0,80005304 <fileread+0x56>
      f->off += r;
    800052fe:	509c                	lw	a5,32(s1)
    80005300:	9fa9                	addw	a5,a5,a0
    80005302:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005304:	6c88                	ld	a0,24(s1)
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	d7c080e7          	jalr	-644(ra) # 80004082 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000530e:	854a                	mv	a0,s2
    80005310:	70a2                	ld	ra,40(sp)
    80005312:	7402                	ld	s0,32(sp)
    80005314:	64e2                	ld	s1,24(sp)
    80005316:	6942                	ld	s2,16(sp)
    80005318:	69a2                	ld	s3,8(sp)
    8000531a:	6145                	addi	sp,sp,48
    8000531c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000531e:	6908                	ld	a0,16(a0)
    80005320:	00000097          	auipc	ra,0x0
    80005324:	5b6080e7          	jalr	1462(ra) # 800058d6 <piperead>
    80005328:	892a                	mv	s2,a0
    8000532a:	b7d5                	j	8000530e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000532c:	02451783          	lh	a5,36(a0)
    80005330:	03079693          	slli	a3,a5,0x30
    80005334:	92c1                	srli	a3,a3,0x30
    80005336:	4725                	li	a4,9
    80005338:	02d76863          	bltu	a4,a3,80005368 <fileread+0xba>
    8000533c:	0792                	slli	a5,a5,0x4
    8000533e:	0003b717          	auipc	a4,0x3b
    80005342:	5da70713          	addi	a4,a4,1498 # 80040918 <devsw>
    80005346:	97ba                	add	a5,a5,a4
    80005348:	639c                	ld	a5,0(a5)
    8000534a:	c38d                	beqz	a5,8000536c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000534c:	4505                	li	a0,1
    8000534e:	9782                	jalr	a5
    80005350:	892a                	mv	s2,a0
    80005352:	bf75                	j	8000530e <fileread+0x60>
    panic("fileread");
    80005354:	00004517          	auipc	a0,0x4
    80005358:	70c50513          	addi	a0,a0,1804 # 80009a60 <syscalls+0x2c8>
    8000535c:	ffffb097          	auipc	ra,0xffffb
    80005360:	1ce080e7          	jalr	462(ra) # 8000052a <panic>
    return -1;
    80005364:	597d                	li	s2,-1
    80005366:	b765                	j	8000530e <fileread+0x60>
      return -1;
    80005368:	597d                	li	s2,-1
    8000536a:	b755                	j	8000530e <fileread+0x60>
    8000536c:	597d                	li	s2,-1
    8000536e:	b745                	j	8000530e <fileread+0x60>

0000000080005370 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005370:	715d                	addi	sp,sp,-80
    80005372:	e486                	sd	ra,72(sp)
    80005374:	e0a2                	sd	s0,64(sp)
    80005376:	fc26                	sd	s1,56(sp)
    80005378:	f84a                	sd	s2,48(sp)
    8000537a:	f44e                	sd	s3,40(sp)
    8000537c:	f052                	sd	s4,32(sp)
    8000537e:	ec56                	sd	s5,24(sp)
    80005380:	e85a                	sd	s6,16(sp)
    80005382:	e45e                	sd	s7,8(sp)
    80005384:	e062                	sd	s8,0(sp)
    80005386:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005388:	00954783          	lbu	a5,9(a0)
    8000538c:	10078663          	beqz	a5,80005498 <filewrite+0x128>
    80005390:	892a                	mv	s2,a0
    80005392:	8aae                	mv	s5,a1
    80005394:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005396:	411c                	lw	a5,0(a0)
    80005398:	4705                	li	a4,1
    8000539a:	02e78263          	beq	a5,a4,800053be <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000539e:	470d                	li	a4,3
    800053a0:	02e78663          	beq	a5,a4,800053cc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800053a4:	4709                	li	a4,2
    800053a6:	0ee79163          	bne	a5,a4,80005488 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800053aa:	0ac05d63          	blez	a2,80005464 <filewrite+0xf4>
    int i = 0;
    800053ae:	4981                	li	s3,0
    800053b0:	6b05                	lui	s6,0x1
    800053b2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800053b6:	6b85                	lui	s7,0x1
    800053b8:	c00b8b9b          	addiw	s7,s7,-1024
    800053bc:	a861                	j	80005454 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800053be:	6908                	ld	a0,16(a0)
    800053c0:	00000097          	auipc	ra,0x0
    800053c4:	424080e7          	jalr	1060(ra) # 800057e4 <pipewrite>
    800053c8:	8a2a                	mv	s4,a0
    800053ca:	a045                	j	8000546a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800053cc:	02451783          	lh	a5,36(a0)
    800053d0:	03079693          	slli	a3,a5,0x30
    800053d4:	92c1                	srli	a3,a3,0x30
    800053d6:	4725                	li	a4,9
    800053d8:	0cd76263          	bltu	a4,a3,8000549c <filewrite+0x12c>
    800053dc:	0792                	slli	a5,a5,0x4
    800053de:	0003b717          	auipc	a4,0x3b
    800053e2:	53a70713          	addi	a4,a4,1338 # 80040918 <devsw>
    800053e6:	97ba                	add	a5,a5,a4
    800053e8:	679c                	ld	a5,8(a5)
    800053ea:	cbdd                	beqz	a5,800054a0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800053ec:	4505                	li	a0,1
    800053ee:	9782                	jalr	a5
    800053f0:	8a2a                	mv	s4,a0
    800053f2:	a8a5                	j	8000546a <filewrite+0xfa>
    800053f4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800053f8:	00000097          	auipc	ra,0x0
    800053fc:	8b0080e7          	jalr	-1872(ra) # 80004ca8 <begin_op>
      ilock(f->ip);
    80005400:	01893503          	ld	a0,24(s2)
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	bbc080e7          	jalr	-1092(ra) # 80003fc0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000540c:	8762                	mv	a4,s8
    8000540e:	02092683          	lw	a3,32(s2)
    80005412:	01598633          	add	a2,s3,s5
    80005416:	4585                	li	a1,1
    80005418:	01893503          	ld	a0,24(s2)
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	f50080e7          	jalr	-176(ra) # 8000436c <writei>
    80005424:	84aa                	mv	s1,a0
    80005426:	00a05763          	blez	a0,80005434 <filewrite+0xc4>
        f->off += r;
    8000542a:	02092783          	lw	a5,32(s2)
    8000542e:	9fa9                	addw	a5,a5,a0
    80005430:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005434:	01893503          	ld	a0,24(s2)
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	c4a080e7          	jalr	-950(ra) # 80004082 <iunlock>
      end_op();
    80005440:	00000097          	auipc	ra,0x0
    80005444:	8e8080e7          	jalr	-1816(ra) # 80004d28 <end_op>

      if(r != n1){
    80005448:	009c1f63          	bne	s8,s1,80005466 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000544c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005450:	0149db63          	bge	s3,s4,80005466 <filewrite+0xf6>
      int n1 = n - i;
    80005454:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005458:	84be                	mv	s1,a5
    8000545a:	2781                	sext.w	a5,a5
    8000545c:	f8fb5ce3          	bge	s6,a5,800053f4 <filewrite+0x84>
    80005460:	84de                	mv	s1,s7
    80005462:	bf49                	j	800053f4 <filewrite+0x84>
    int i = 0;
    80005464:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005466:	013a1f63          	bne	s4,s3,80005484 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000546a:	8552                	mv	a0,s4
    8000546c:	60a6                	ld	ra,72(sp)
    8000546e:	6406                	ld	s0,64(sp)
    80005470:	74e2                	ld	s1,56(sp)
    80005472:	7942                	ld	s2,48(sp)
    80005474:	79a2                	ld	s3,40(sp)
    80005476:	7a02                	ld	s4,32(sp)
    80005478:	6ae2                	ld	s5,24(sp)
    8000547a:	6b42                	ld	s6,16(sp)
    8000547c:	6ba2                	ld	s7,8(sp)
    8000547e:	6c02                	ld	s8,0(sp)
    80005480:	6161                	addi	sp,sp,80
    80005482:	8082                	ret
    ret = (i == n ? n : -1);
    80005484:	5a7d                	li	s4,-1
    80005486:	b7d5                	j	8000546a <filewrite+0xfa>
    panic("filewrite");
    80005488:	00004517          	auipc	a0,0x4
    8000548c:	5e850513          	addi	a0,a0,1512 # 80009a70 <syscalls+0x2d8>
    80005490:	ffffb097          	auipc	ra,0xffffb
    80005494:	09a080e7          	jalr	154(ra) # 8000052a <panic>
    return -1;
    80005498:	5a7d                	li	s4,-1
    8000549a:	bfc1                	j	8000546a <filewrite+0xfa>
      return -1;
    8000549c:	5a7d                	li	s4,-1
    8000549e:	b7f1                	j	8000546a <filewrite+0xfa>
    800054a0:	5a7d                	li	s4,-1
    800054a2:	b7e1                	j	8000546a <filewrite+0xfa>

00000000800054a4 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    800054a4:	7179                	addi	sp,sp,-48
    800054a6:	f406                	sd	ra,40(sp)
    800054a8:	f022                	sd	s0,32(sp)
    800054aa:	ec26                	sd	s1,24(sp)
    800054ac:	e84a                	sd	s2,16(sp)
    800054ae:	e44e                	sd	s3,8(sp)
    800054b0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800054b2:	00854783          	lbu	a5,8(a0)
    800054b6:	c3d5                	beqz	a5,8000555a <kfileread+0xb6>
    800054b8:	84aa                	mv	s1,a0
    800054ba:	89ae                	mv	s3,a1
    800054bc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800054be:	411c                	lw	a5,0(a0)
    800054c0:	4705                	li	a4,1
    800054c2:	04e78963          	beq	a5,a4,80005514 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800054c6:	470d                	li	a4,3
    800054c8:	04e78d63          	beq	a5,a4,80005522 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800054cc:	4709                	li	a4,2
    800054ce:	06e79e63          	bne	a5,a4,8000554a <kfileread+0xa6>
    ilock(f->ip);
    800054d2:	6d08                	ld	a0,24(a0)
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	aec080e7          	jalr	-1300(ra) # 80003fc0 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    800054dc:	874a                	mv	a4,s2
    800054de:	5094                	lw	a3,32(s1)
    800054e0:	864e                	mv	a2,s3
    800054e2:	4581                	li	a1,0
    800054e4:	6c88                	ld	a0,24(s1)
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	d8e080e7          	jalr	-626(ra) # 80004274 <readi>
    800054ee:	892a                	mv	s2,a0
    800054f0:	00a05563          	blez	a0,800054fa <kfileread+0x56>
      f->off += r;
    800054f4:	509c                	lw	a5,32(s1)
    800054f6:	9fa9                	addw	a5,a5,a0
    800054f8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800054fa:	6c88                	ld	a0,24(s1)
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	b86080e7          	jalr	-1146(ra) # 80004082 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005504:	854a                	mv	a0,s2
    80005506:	70a2                	ld	ra,40(sp)
    80005508:	7402                	ld	s0,32(sp)
    8000550a:	64e2                	ld	s1,24(sp)
    8000550c:	6942                	ld	s2,16(sp)
    8000550e:	69a2                	ld	s3,8(sp)
    80005510:	6145                	addi	sp,sp,48
    80005512:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005514:	6908                	ld	a0,16(a0)
    80005516:	00000097          	auipc	ra,0x0
    8000551a:	3c0080e7          	jalr	960(ra) # 800058d6 <piperead>
    8000551e:	892a                	mv	s2,a0
    80005520:	b7d5                	j	80005504 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005522:	02451783          	lh	a5,36(a0)
    80005526:	03079693          	slli	a3,a5,0x30
    8000552a:	92c1                	srli	a3,a3,0x30
    8000552c:	4725                	li	a4,9
    8000552e:	02d76863          	bltu	a4,a3,8000555e <kfileread+0xba>
    80005532:	0792                	slli	a5,a5,0x4
    80005534:	0003b717          	auipc	a4,0x3b
    80005538:	3e470713          	addi	a4,a4,996 # 80040918 <devsw>
    8000553c:	97ba                	add	a5,a5,a4
    8000553e:	639c                	ld	a5,0(a5)
    80005540:	c38d                	beqz	a5,80005562 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005542:	4505                	li	a0,1
    80005544:	9782                	jalr	a5
    80005546:	892a                	mv	s2,a0
    80005548:	bf75                	j	80005504 <kfileread+0x60>
    panic("fileread");
    8000554a:	00004517          	auipc	a0,0x4
    8000554e:	51650513          	addi	a0,a0,1302 # 80009a60 <syscalls+0x2c8>
    80005552:	ffffb097          	auipc	ra,0xffffb
    80005556:	fd8080e7          	jalr	-40(ra) # 8000052a <panic>
    return -1;
    8000555a:	597d                	li	s2,-1
    8000555c:	b765                	j	80005504 <kfileread+0x60>
      return -1;
    8000555e:	597d                	li	s2,-1
    80005560:	b755                	j	80005504 <kfileread+0x60>
    80005562:	597d                	li	s2,-1
    80005564:	b745                	j	80005504 <kfileread+0x60>

0000000080005566 <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    80005566:	715d                	addi	sp,sp,-80
    80005568:	e486                	sd	ra,72(sp)
    8000556a:	e0a2                	sd	s0,64(sp)
    8000556c:	fc26                	sd	s1,56(sp)
    8000556e:	f84a                	sd	s2,48(sp)
    80005570:	f44e                	sd	s3,40(sp)
    80005572:	f052                	sd	s4,32(sp)
    80005574:	ec56                	sd	s5,24(sp)
    80005576:	e85a                	sd	s6,16(sp)
    80005578:	e45e                	sd	s7,8(sp)
    8000557a:	e062                	sd	s8,0(sp)
    8000557c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000557e:	00954783          	lbu	a5,9(a0)
    80005582:	10078663          	beqz	a5,8000568e <kfilewrite+0x128>
    80005586:	892a                	mv	s2,a0
    80005588:	8aae                	mv	s5,a1
    8000558a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000558c:	411c                	lw	a5,0(a0)
    8000558e:	4705                	li	a4,1
    80005590:	02e78263          	beq	a5,a4,800055b4 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);

  } else if(f->type == FD_DEVICE){
    80005594:	470d                	li	a4,3
    80005596:	02e78663          	beq	a5,a4,800055c2 <kfilewrite+0x5c>

    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;

    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000559a:	4709                	li	a4,2
    8000559c:	0ee79163          	bne	a5,a4,8000567e <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800055a0:	0ac05d63          	blez	a2,8000565a <kfilewrite+0xf4>
    int i = 0;
    800055a4:	4981                	li	s3,0
    800055a6:	6b05                	lui	s6,0x1
    800055a8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800055ac:	6b85                	lui	s7,0x1
    800055ae:	c00b8b9b          	addiw	s7,s7,-1024
    800055b2:	a861                	j	8000564a <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800055b4:	6908                	ld	a0,16(a0)
    800055b6:	00000097          	auipc	ra,0x0
    800055ba:	22e080e7          	jalr	558(ra) # 800057e4 <pipewrite>
    800055be:	8a2a                	mv	s4,a0
    800055c0:	a045                	j	80005660 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800055c2:	02451783          	lh	a5,36(a0)
    800055c6:	03079693          	slli	a3,a5,0x30
    800055ca:	92c1                	srli	a3,a3,0x30
    800055cc:	4725                	li	a4,9
    800055ce:	0cd76263          	bltu	a4,a3,80005692 <kfilewrite+0x12c>
    800055d2:	0792                	slli	a5,a5,0x4
    800055d4:	0003b717          	auipc	a4,0x3b
    800055d8:	34470713          	addi	a4,a4,836 # 80040918 <devsw>
    800055dc:	97ba                	add	a5,a5,a4
    800055de:	679c                	ld	a5,8(a5)
    800055e0:	cbdd                	beqz	a5,80005696 <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800055e2:	4505                	li	a0,1
    800055e4:	9782                	jalr	a5
    800055e6:	8a2a                	mv	s4,a0
    800055e8:	a8a5                	j	80005660 <kfilewrite+0xfa>
    800055ea:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	6ba080e7          	jalr	1722(ra) # 80004ca8 <begin_op>
      ilock(f->ip);
    800055f6:	01893503          	ld	a0,24(s2)
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	9c6080e7          	jalr	-1594(ra) # 80003fc0 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80005602:	8762                	mv	a4,s8
    80005604:	02092683          	lw	a3,32(s2)
    80005608:	01598633          	add	a2,s3,s5
    8000560c:	4581                	li	a1,0
    8000560e:	01893503          	ld	a0,24(s2)
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	d5a080e7          	jalr	-678(ra) # 8000436c <writei>
    8000561a:	84aa                	mv	s1,a0
    8000561c:	00a05763          	blez	a0,8000562a <kfilewrite+0xc4>
        f->off += r;
    80005620:	02092783          	lw	a5,32(s2)
    80005624:	9fa9                	addw	a5,a5,a0
    80005626:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000562a:	01893503          	ld	a0,24(s2)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	a54080e7          	jalr	-1452(ra) # 80004082 <iunlock>
      end_op();
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	6f2080e7          	jalr	1778(ra) # 80004d28 <end_op>

      if(r != n1){
    8000563e:	009c1f63          	bne	s8,s1,8000565c <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005642:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005646:	0149db63          	bge	s3,s4,8000565c <kfilewrite+0xf6>
      int n1 = n - i;
    8000564a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000564e:	84be                	mv	s1,a5
    80005650:	2781                	sext.w	a5,a5
    80005652:	f8fb5ce3          	bge	s6,a5,800055ea <kfilewrite+0x84>
    80005656:	84de                	mv	s1,s7
    80005658:	bf49                	j	800055ea <kfilewrite+0x84>
    int i = 0;
    8000565a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000565c:	013a1f63          	bne	s4,s3,8000567a <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005660:	8552                	mv	a0,s4
    80005662:	60a6                	ld	ra,72(sp)
    80005664:	6406                	ld	s0,64(sp)
    80005666:	74e2                	ld	s1,56(sp)
    80005668:	7942                	ld	s2,48(sp)
    8000566a:	79a2                	ld	s3,40(sp)
    8000566c:	7a02                	ld	s4,32(sp)
    8000566e:	6ae2                	ld	s5,24(sp)
    80005670:	6b42                	ld	s6,16(sp)
    80005672:	6ba2                	ld	s7,8(sp)
    80005674:	6c02                	ld	s8,0(sp)
    80005676:	6161                	addi	sp,sp,80
    80005678:	8082                	ret
    ret = (i == n ? n : -1);
    8000567a:	5a7d                	li	s4,-1
    8000567c:	b7d5                	j	80005660 <kfilewrite+0xfa>
    panic("filewrite");
    8000567e:	00004517          	auipc	a0,0x4
    80005682:	3f250513          	addi	a0,a0,1010 # 80009a70 <syscalls+0x2d8>
    80005686:	ffffb097          	auipc	ra,0xffffb
    8000568a:	ea4080e7          	jalr	-348(ra) # 8000052a <panic>
    return -1;
    8000568e:	5a7d                	li	s4,-1
    80005690:	bfc1                	j	80005660 <kfilewrite+0xfa>
      return -1;
    80005692:	5a7d                	li	s4,-1
    80005694:	b7f1                	j	80005660 <kfilewrite+0xfa>
    80005696:	5a7d                	li	s4,-1
    80005698:	b7e1                	j	80005660 <kfilewrite+0xfa>

000000008000569a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000569a:	7179                	addi	sp,sp,-48
    8000569c:	f406                	sd	ra,40(sp)
    8000569e:	f022                	sd	s0,32(sp)
    800056a0:	ec26                	sd	s1,24(sp)
    800056a2:	e84a                	sd	s2,16(sp)
    800056a4:	e44e                	sd	s3,8(sp)
    800056a6:	e052                	sd	s4,0(sp)
    800056a8:	1800                	addi	s0,sp,48
    800056aa:	84aa                	mv	s1,a0
    800056ac:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800056ae:	0005b023          	sd	zero,0(a1)
    800056b2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800056b6:	00000097          	auipc	ra,0x0
    800056ba:	a02080e7          	jalr	-1534(ra) # 800050b8 <filealloc>
    800056be:	e088                	sd	a0,0(s1)
    800056c0:	c551                	beqz	a0,8000574c <pipealloc+0xb2>
    800056c2:	00000097          	auipc	ra,0x0
    800056c6:	9f6080e7          	jalr	-1546(ra) # 800050b8 <filealloc>
    800056ca:	00aa3023          	sd	a0,0(s4)
    800056ce:	c92d                	beqz	a0,80005740 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800056d0:	ffffb097          	auipc	ra,0xffffb
    800056d4:	402080e7          	jalr	1026(ra) # 80000ad2 <kalloc>
    800056d8:	892a                	mv	s2,a0
    800056da:	c125                	beqz	a0,8000573a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800056dc:	4985                	li	s3,1
    800056de:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800056e2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800056e6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800056ea:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800056ee:	00004597          	auipc	a1,0x4
    800056f2:	39258593          	addi	a1,a1,914 # 80009a80 <syscalls+0x2e8>
    800056f6:	ffffb097          	auipc	ra,0xffffb
    800056fa:	43c080e7          	jalr	1084(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800056fe:	609c                	ld	a5,0(s1)
    80005700:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005704:	609c                	ld	a5,0(s1)
    80005706:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000570a:	609c                	ld	a5,0(s1)
    8000570c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005710:	609c                	ld	a5,0(s1)
    80005712:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005716:	000a3783          	ld	a5,0(s4)
    8000571a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000571e:	000a3783          	ld	a5,0(s4)
    80005722:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005726:	000a3783          	ld	a5,0(s4)
    8000572a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000572e:	000a3783          	ld	a5,0(s4)
    80005732:	0127b823          	sd	s2,16(a5)
  return 0;
    80005736:	4501                	li	a0,0
    80005738:	a025                	j	80005760 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000573a:	6088                	ld	a0,0(s1)
    8000573c:	e501                	bnez	a0,80005744 <pipealloc+0xaa>
    8000573e:	a039                	j	8000574c <pipealloc+0xb2>
    80005740:	6088                	ld	a0,0(s1)
    80005742:	c51d                	beqz	a0,80005770 <pipealloc+0xd6>
    fileclose(*f0);
    80005744:	00000097          	auipc	ra,0x0
    80005748:	a30080e7          	jalr	-1488(ra) # 80005174 <fileclose>
  if(*f1)
    8000574c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005750:	557d                	li	a0,-1
  if(*f1)
    80005752:	c799                	beqz	a5,80005760 <pipealloc+0xc6>
    fileclose(*f1);
    80005754:	853e                	mv	a0,a5
    80005756:	00000097          	auipc	ra,0x0
    8000575a:	a1e080e7          	jalr	-1506(ra) # 80005174 <fileclose>
  return -1;
    8000575e:	557d                	li	a0,-1
}
    80005760:	70a2                	ld	ra,40(sp)
    80005762:	7402                	ld	s0,32(sp)
    80005764:	64e2                	ld	s1,24(sp)
    80005766:	6942                	ld	s2,16(sp)
    80005768:	69a2                	ld	s3,8(sp)
    8000576a:	6a02                	ld	s4,0(sp)
    8000576c:	6145                	addi	sp,sp,48
    8000576e:	8082                	ret
  return -1;
    80005770:	557d                	li	a0,-1
    80005772:	b7fd                	j	80005760 <pipealloc+0xc6>

0000000080005774 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005774:	1101                	addi	sp,sp,-32
    80005776:	ec06                	sd	ra,24(sp)
    80005778:	e822                	sd	s0,16(sp)
    8000577a:	e426                	sd	s1,8(sp)
    8000577c:	e04a                	sd	s2,0(sp)
    8000577e:	1000                	addi	s0,sp,32
    80005780:	84aa                	mv	s1,a0
    80005782:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	43e080e7          	jalr	1086(ra) # 80000bc2 <acquire>
  if(writable){
    8000578c:	02090d63          	beqz	s2,800057c6 <pipeclose+0x52>
    pi->writeopen = 0;
    80005790:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005794:	21848513          	addi	a0,s1,536
    80005798:	ffffc097          	auipc	ra,0xffffc
    8000579c:	6fa080e7          	jalr	1786(ra) # 80001e92 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800057a0:	2204b783          	ld	a5,544(s1)
    800057a4:	eb95                	bnez	a5,800057d8 <pipeclose+0x64>
    release(&pi->lock);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffb097          	auipc	ra,0xffffb
    800057ac:	4ce080e7          	jalr	1230(ra) # 80000c76 <release>
    kfree((char*)pi);
    800057b0:	8526                	mv	a0,s1
    800057b2:	ffffb097          	auipc	ra,0xffffb
    800057b6:	224080e7          	jalr	548(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    800057ba:	60e2                	ld	ra,24(sp)
    800057bc:	6442                	ld	s0,16(sp)
    800057be:	64a2                	ld	s1,8(sp)
    800057c0:	6902                	ld	s2,0(sp)
    800057c2:	6105                	addi	sp,sp,32
    800057c4:	8082                	ret
    pi->readopen = 0;
    800057c6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800057ca:	21c48513          	addi	a0,s1,540
    800057ce:	ffffc097          	auipc	ra,0xffffc
    800057d2:	6c4080e7          	jalr	1732(ra) # 80001e92 <wakeup>
    800057d6:	b7e9                	j	800057a0 <pipeclose+0x2c>
    release(&pi->lock);
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffb097          	auipc	ra,0xffffb
    800057de:	49c080e7          	jalr	1180(ra) # 80000c76 <release>
}
    800057e2:	bfe1                	j	800057ba <pipeclose+0x46>

00000000800057e4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800057e4:	711d                	addi	sp,sp,-96
    800057e6:	ec86                	sd	ra,88(sp)
    800057e8:	e8a2                	sd	s0,80(sp)
    800057ea:	e4a6                	sd	s1,72(sp)
    800057ec:	e0ca                	sd	s2,64(sp)
    800057ee:	fc4e                	sd	s3,56(sp)
    800057f0:	f852                	sd	s4,48(sp)
    800057f2:	f456                	sd	s5,40(sp)
    800057f4:	f05a                	sd	s6,32(sp)
    800057f6:	ec5e                	sd	s7,24(sp)
    800057f8:	e862                	sd	s8,16(sp)
    800057fa:	1080                	addi	s0,sp,96
    800057fc:	84aa                	mv	s1,a0
    800057fe:	8aae                	mv	s5,a1
    80005800:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005802:	ffffc097          	auipc	ra,0xffffc
    80005806:	28a080e7          	jalr	650(ra) # 80001a8c <myproc>
    8000580a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000580c:	8526                	mv	a0,s1
    8000580e:	ffffb097          	auipc	ra,0xffffb
    80005812:	3b4080e7          	jalr	948(ra) # 80000bc2 <acquire>
  while(i < n){
    80005816:	0b405363          	blez	s4,800058bc <pipewrite+0xd8>
  int i = 0;
    8000581a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000581c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000581e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005822:	21c48b93          	addi	s7,s1,540
    80005826:	a089                	j	80005868 <pipewrite+0x84>
      release(&pi->lock);
    80005828:	8526                	mv	a0,s1
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	44c080e7          	jalr	1100(ra) # 80000c76 <release>
      return -1;
    80005832:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005834:	854a                	mv	a0,s2
    80005836:	60e6                	ld	ra,88(sp)
    80005838:	6446                	ld	s0,80(sp)
    8000583a:	64a6                	ld	s1,72(sp)
    8000583c:	6906                	ld	s2,64(sp)
    8000583e:	79e2                	ld	s3,56(sp)
    80005840:	7a42                	ld	s4,48(sp)
    80005842:	7aa2                	ld	s5,40(sp)
    80005844:	7b02                	ld	s6,32(sp)
    80005846:	6be2                	ld	s7,24(sp)
    80005848:	6c42                	ld	s8,16(sp)
    8000584a:	6125                	addi	sp,sp,96
    8000584c:	8082                	ret
      wakeup(&pi->nread);
    8000584e:	8562                	mv	a0,s8
    80005850:	ffffc097          	auipc	ra,0xffffc
    80005854:	642080e7          	jalr	1602(ra) # 80001e92 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005858:	85a6                	mv	a1,s1
    8000585a:	855e                	mv	a0,s7
    8000585c:	ffffc097          	auipc	ra,0xffffc
    80005860:	5d2080e7          	jalr	1490(ra) # 80001e2e <sleep>
  while(i < n){
    80005864:	05495d63          	bge	s2,s4,800058be <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005868:	2204a783          	lw	a5,544(s1)
    8000586c:	dfd5                	beqz	a5,80005828 <pipewrite+0x44>
    8000586e:	0289a783          	lw	a5,40(s3)
    80005872:	fbdd                	bnez	a5,80005828 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005874:	2184a783          	lw	a5,536(s1)
    80005878:	21c4a703          	lw	a4,540(s1)
    8000587c:	2007879b          	addiw	a5,a5,512
    80005880:	fcf707e3          	beq	a4,a5,8000584e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005884:	4685                	li	a3,1
    80005886:	01590633          	add	a2,s2,s5
    8000588a:	faf40593          	addi	a1,s0,-81
    8000588e:	0509b503          	ld	a0,80(s3)
    80005892:	ffffc097          	auipc	ra,0xffffc
    80005896:	f32080e7          	jalr	-206(ra) # 800017c4 <copyin>
    8000589a:	03650263          	beq	a0,s6,800058be <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000589e:	21c4a783          	lw	a5,540(s1)
    800058a2:	0017871b          	addiw	a4,a5,1
    800058a6:	20e4ae23          	sw	a4,540(s1)
    800058aa:	1ff7f793          	andi	a5,a5,511
    800058ae:	97a6                	add	a5,a5,s1
    800058b0:	faf44703          	lbu	a4,-81(s0)
    800058b4:	00e78c23          	sb	a4,24(a5)
      i++;
    800058b8:	2905                	addiw	s2,s2,1
    800058ba:	b76d                	j	80005864 <pipewrite+0x80>
  int i = 0;
    800058bc:	4901                	li	s2,0
  wakeup(&pi->nread);
    800058be:	21848513          	addi	a0,s1,536
    800058c2:	ffffc097          	auipc	ra,0xffffc
    800058c6:	5d0080e7          	jalr	1488(ra) # 80001e92 <wakeup>
  release(&pi->lock);
    800058ca:	8526                	mv	a0,s1
    800058cc:	ffffb097          	auipc	ra,0xffffb
    800058d0:	3aa080e7          	jalr	938(ra) # 80000c76 <release>
  return i;
    800058d4:	b785                	j	80005834 <pipewrite+0x50>

00000000800058d6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800058d6:	715d                	addi	sp,sp,-80
    800058d8:	e486                	sd	ra,72(sp)
    800058da:	e0a2                	sd	s0,64(sp)
    800058dc:	fc26                	sd	s1,56(sp)
    800058de:	f84a                	sd	s2,48(sp)
    800058e0:	f44e                	sd	s3,40(sp)
    800058e2:	f052                	sd	s4,32(sp)
    800058e4:	ec56                	sd	s5,24(sp)
    800058e6:	e85a                	sd	s6,16(sp)
    800058e8:	0880                	addi	s0,sp,80
    800058ea:	84aa                	mv	s1,a0
    800058ec:	892e                	mv	s2,a1
    800058ee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800058f0:	ffffc097          	auipc	ra,0xffffc
    800058f4:	19c080e7          	jalr	412(ra) # 80001a8c <myproc>
    800058f8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffb097          	auipc	ra,0xffffb
    80005900:	2c6080e7          	jalr	710(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005904:	2184a703          	lw	a4,536(s1)
    80005908:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000590c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005910:	02f71463          	bne	a4,a5,80005938 <piperead+0x62>
    80005914:	2244a783          	lw	a5,548(s1)
    80005918:	c385                	beqz	a5,80005938 <piperead+0x62>
    if(pr->killed){
    8000591a:	028a2783          	lw	a5,40(s4)
    8000591e:	ebc1                	bnez	a5,800059ae <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005920:	85a6                	mv	a1,s1
    80005922:	854e                	mv	a0,s3
    80005924:	ffffc097          	auipc	ra,0xffffc
    80005928:	50a080e7          	jalr	1290(ra) # 80001e2e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000592c:	2184a703          	lw	a4,536(s1)
    80005930:	21c4a783          	lw	a5,540(s1)
    80005934:	fef700e3          	beq	a4,a5,80005914 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005938:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000593a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000593c:	05505363          	blez	s5,80005982 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005940:	2184a783          	lw	a5,536(s1)
    80005944:	21c4a703          	lw	a4,540(s1)
    80005948:	02f70d63          	beq	a4,a5,80005982 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000594c:	0017871b          	addiw	a4,a5,1
    80005950:	20e4ac23          	sw	a4,536(s1)
    80005954:	1ff7f793          	andi	a5,a5,511
    80005958:	97a6                	add	a5,a5,s1
    8000595a:	0187c783          	lbu	a5,24(a5)
    8000595e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005962:	4685                	li	a3,1
    80005964:	fbf40613          	addi	a2,s0,-65
    80005968:	85ca                	mv	a1,s2
    8000596a:	050a3503          	ld	a0,80(s4)
    8000596e:	ffffc097          	auipc	ra,0xffffc
    80005972:	dca080e7          	jalr	-566(ra) # 80001738 <copyout>
    80005976:	01650663          	beq	a0,s6,80005982 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000597a:	2985                	addiw	s3,s3,1
    8000597c:	0905                	addi	s2,s2,1
    8000597e:	fd3a91e3          	bne	s5,s3,80005940 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005982:	21c48513          	addi	a0,s1,540
    80005986:	ffffc097          	auipc	ra,0xffffc
    8000598a:	50c080e7          	jalr	1292(ra) # 80001e92 <wakeup>
  release(&pi->lock);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffb097          	auipc	ra,0xffffb
    80005994:	2e6080e7          	jalr	742(ra) # 80000c76 <release>
  return i;
}
    80005998:	854e                	mv	a0,s3
    8000599a:	60a6                	ld	ra,72(sp)
    8000599c:	6406                	ld	s0,64(sp)
    8000599e:	74e2                	ld	s1,56(sp)
    800059a0:	7942                	ld	s2,48(sp)
    800059a2:	79a2                	ld	s3,40(sp)
    800059a4:	7a02                	ld	s4,32(sp)
    800059a6:	6ae2                	ld	s5,24(sp)
    800059a8:	6b42                	ld	s6,16(sp)
    800059aa:	6161                	addi	sp,sp,80
    800059ac:	8082                	ret
      release(&pi->lock);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffb097          	auipc	ra,0xffffb
    800059b4:	2c6080e7          	jalr	710(ra) # 80000c76 <release>
      return -1;
    800059b8:	59fd                	li	s3,-1
    800059ba:	bff9                	j	80005998 <piperead+0xc2>

00000000800059bc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800059bc:	de010113          	addi	sp,sp,-544
    800059c0:	20113c23          	sd	ra,536(sp)
    800059c4:	20813823          	sd	s0,528(sp)
    800059c8:	20913423          	sd	s1,520(sp)
    800059cc:	21213023          	sd	s2,512(sp)
    800059d0:	ffce                	sd	s3,504(sp)
    800059d2:	fbd2                	sd	s4,496(sp)
    800059d4:	f7d6                	sd	s5,488(sp)
    800059d6:	f3da                	sd	s6,480(sp)
    800059d8:	efde                	sd	s7,472(sp)
    800059da:	ebe2                	sd	s8,464(sp)
    800059dc:	e7e6                	sd	s9,456(sp)
    800059de:	e3ea                	sd	s10,448(sp)
    800059e0:	ff6e                	sd	s11,440(sp)
    800059e2:	1400                	addi	s0,sp,544
    800059e4:	892a                	mv	s2,a0
    800059e6:	dea43423          	sd	a0,-536(s0)
    800059ea:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800059ee:	ffffc097          	auipc	ra,0xffffc
    800059f2:	09e080e7          	jalr	158(ra) # 80001a8c <myproc>
    800059f6:	84aa                	mv	s1,a0

  begin_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	2b0080e7          	jalr	688(ra) # 80004ca8 <begin_op>

  if((ip = namei(path)) == 0){
    80005a00:	854a                	mv	a0,s2
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	d74080e7          	jalr	-652(ra) # 80004776 <namei>
    80005a0a:	c93d                	beqz	a0,80005a80 <exec+0xc4>
    80005a0c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	5b2080e7          	jalr	1458(ra) # 80003fc0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005a16:	04000713          	li	a4,64
    80005a1a:	4681                	li	a3,0
    80005a1c:	e4840613          	addi	a2,s0,-440
    80005a20:	4581                	li	a1,0
    80005a22:	8556                	mv	a0,s5
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	850080e7          	jalr	-1968(ra) # 80004274 <readi>
    80005a2c:	04000793          	li	a5,64
    80005a30:	00f51a63          	bne	a0,a5,80005a44 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005a34:	e4842703          	lw	a4,-440(s0)
    80005a38:	464c47b7          	lui	a5,0x464c4
    80005a3c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005a40:	04f70663          	beq	a4,a5,80005a8c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005a44:	8556                	mv	a0,s5
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	7dc080e7          	jalr	2012(ra) # 80004222 <iunlockput>
    end_op();
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	2da080e7          	jalr	730(ra) # 80004d28 <end_op>
  }
  return -1;
    80005a56:	557d                	li	a0,-1
}
    80005a58:	21813083          	ld	ra,536(sp)
    80005a5c:	21013403          	ld	s0,528(sp)
    80005a60:	20813483          	ld	s1,520(sp)
    80005a64:	20013903          	ld	s2,512(sp)
    80005a68:	79fe                	ld	s3,504(sp)
    80005a6a:	7a5e                	ld	s4,496(sp)
    80005a6c:	7abe                	ld	s5,488(sp)
    80005a6e:	7b1e                	ld	s6,480(sp)
    80005a70:	6bfe                	ld	s7,472(sp)
    80005a72:	6c5e                	ld	s8,464(sp)
    80005a74:	6cbe                	ld	s9,456(sp)
    80005a76:	6d1e                	ld	s10,448(sp)
    80005a78:	7dfa                	ld	s11,440(sp)
    80005a7a:	22010113          	addi	sp,sp,544
    80005a7e:	8082                	ret
    end_op();
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	2a8080e7          	jalr	680(ra) # 80004d28 <end_op>
    return -1;
    80005a88:	557d                	li	a0,-1
    80005a8a:	b7f9                	j	80005a58 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005a8c:	8526                	mv	a0,s1
    80005a8e:	ffffc097          	auipc	ra,0xffffc
    80005a92:	0c2080e7          	jalr	194(ra) # 80001b50 <proc_pagetable>
    80005a96:	8b2a                	mv	s6,a0
    80005a98:	d555                	beqz	a0,80005a44 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005a9a:	e6842783          	lw	a5,-408(s0)
    80005a9e:	e8045703          	lhu	a4,-384(s0)
    80005aa2:	c735                	beqz	a4,80005b0e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005aa4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005aa6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005aaa:	6a05                	lui	s4,0x1
    80005aac:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005ab0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005ab4:	6d85                	lui	s11,0x1
    80005ab6:	7d7d                	lui	s10,0xfffff
    80005ab8:	a4bd                	j	80005d26 <exec+0x36a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005aba:	00004517          	auipc	a0,0x4
    80005abe:	fce50513          	addi	a0,a0,-50 # 80009a88 <syscalls+0x2f0>
    80005ac2:	ffffb097          	auipc	ra,0xffffb
    80005ac6:	a68080e7          	jalr	-1432(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005aca:	874a                	mv	a4,s2
    80005acc:	009c86bb          	addw	a3,s9,s1
    80005ad0:	4581                	li	a1,0
    80005ad2:	8556                	mv	a0,s5
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	7a0080e7          	jalr	1952(ra) # 80004274 <readi>
    80005adc:	2501                	sext.w	a0,a0
    80005ade:	1ea91463          	bne	s2,a0,80005cc6 <exec+0x30a>
  for(i = 0; i < sz; i += PGSIZE){
    80005ae2:	009d84bb          	addw	s1,s11,s1
    80005ae6:	013d09bb          	addw	s3,s10,s3
    80005aea:	2174fe63          	bgeu	s1,s7,80005d06 <exec+0x34a>
    pa = walkaddr(pagetable, va + i);
    80005aee:	02049593          	slli	a1,s1,0x20
    80005af2:	9181                	srli	a1,a1,0x20
    80005af4:	95e2                	add	a1,a1,s8
    80005af6:	855a                	mv	a0,s6
    80005af8:	ffffb097          	auipc	ra,0xffffb
    80005afc:	554080e7          	jalr	1364(ra) # 8000104c <walkaddr>
    80005b00:	862a                	mv	a2,a0
    if(pa == 0)
    80005b02:	dd45                	beqz	a0,80005aba <exec+0xfe>
      n = PGSIZE;
    80005b04:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005b06:	fd49f2e3          	bgeu	s3,s4,80005aca <exec+0x10e>
      n = sz - i;
    80005b0a:	894e                	mv	s2,s3
    80005b0c:	bf7d                	j	80005aca <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005b0e:	4481                	li	s1,0
  iunlockput(ip);
    80005b10:	8556                	mv	a0,s5
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	710080e7          	jalr	1808(ra) # 80004222 <iunlockput>
  end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	20e080e7          	jalr	526(ra) # 80004d28 <end_op>
  p = myproc();
    80005b22:	ffffc097          	auipc	ra,0xffffc
    80005b26:	f6a080e7          	jalr	-150(ra) # 80001a8c <myproc>
    80005b2a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005b2c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005b30:	6785                	lui	a5,0x1
    80005b32:	17fd                	addi	a5,a5,-1
    80005b34:	94be                	add	s1,s1,a5
    80005b36:	77fd                	lui	a5,0xfffff
    80005b38:	8fe5                	and	a5,a5,s1
    80005b3a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005b3e:	6609                	lui	a2,0x2
    80005b40:	963e                	add	a2,a2,a5
    80005b42:	85be                	mv	a1,a5
    80005b44:	855a                	mv	a0,s6
    80005b46:	ffffc097          	auipc	ra,0xffffc
    80005b4a:	90c080e7          	jalr	-1780(ra) # 80001452 <uvmalloc>
    80005b4e:	8c2a                	mv	s8,a0
  ip = 0;
    80005b50:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005b52:	16050a63          	beqz	a0,80005cc6 <exec+0x30a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005b56:	75f9                	lui	a1,0xffffe
    80005b58:	95aa                	add	a1,a1,a0
    80005b5a:	855a                	mv	a0,s6
    80005b5c:	ffffc097          	auipc	ra,0xffffc
    80005b60:	baa080e7          	jalr	-1110(ra) # 80001706 <uvmclear>
  stackbase = sp - PGSIZE;
    80005b64:	7afd                	lui	s5,0xfffff
    80005b66:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005b68:	df043783          	ld	a5,-528(s0)
    80005b6c:	6388                	ld	a0,0(a5)
    80005b6e:	c925                	beqz	a0,80005bde <exec+0x222>
    80005b70:	e8840993          	addi	s3,s0,-376
    80005b74:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005b78:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005b7a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005b7c:	ffffb097          	auipc	ra,0xffffb
    80005b80:	2c6080e7          	jalr	710(ra) # 80000e42 <strlen>
    80005b84:	0015079b          	addiw	a5,a0,1
    80005b88:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005b8c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005b90:	15596f63          	bltu	s2,s5,80005cee <exec+0x332>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005b94:	df043d83          	ld	s11,-528(s0)
    80005b98:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005b9c:	8552                	mv	a0,s4
    80005b9e:	ffffb097          	auipc	ra,0xffffb
    80005ba2:	2a4080e7          	jalr	676(ra) # 80000e42 <strlen>
    80005ba6:	0015069b          	addiw	a3,a0,1
    80005baa:	8652                	mv	a2,s4
    80005bac:	85ca                	mv	a1,s2
    80005bae:	855a                	mv	a0,s6
    80005bb0:	ffffc097          	auipc	ra,0xffffc
    80005bb4:	b88080e7          	jalr	-1144(ra) # 80001738 <copyout>
    80005bb8:	12054f63          	bltz	a0,80005cf6 <exec+0x33a>
    ustack[argc] = sp;
    80005bbc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005bc0:	0485                	addi	s1,s1,1
    80005bc2:	008d8793          	addi	a5,s11,8
    80005bc6:	def43823          	sd	a5,-528(s0)
    80005bca:	008db503          	ld	a0,8(s11)
    80005bce:	c911                	beqz	a0,80005be2 <exec+0x226>
    if(argc >= MAXARG)
    80005bd0:	09a1                	addi	s3,s3,8
    80005bd2:	fb9995e3          	bne	s3,s9,80005b7c <exec+0x1c0>
  sz = sz1;
    80005bd6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005bda:	4a81                	li	s5,0
    80005bdc:	a0ed                	j	80005cc6 <exec+0x30a>
  sp = sz;
    80005bde:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005be0:	4481                	li	s1,0
  ustack[argc] = 0;
    80005be2:	00349793          	slli	a5,s1,0x3
    80005be6:	f9040713          	addi	a4,s0,-112
    80005bea:	97ba                	add	a5,a5,a4
    80005bec:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffb9ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005bf0:	00148693          	addi	a3,s1,1
    80005bf4:	068e                	slli	a3,a3,0x3
    80005bf6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005bfa:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005bfe:	01597663          	bgeu	s2,s5,80005c0a <exec+0x24e>
  sz = sz1;
    80005c02:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005c06:	4a81                	li	s5,0
    80005c08:	a87d                	j	80005cc6 <exec+0x30a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005c0a:	e8840613          	addi	a2,s0,-376
    80005c0e:	85ca                	mv	a1,s2
    80005c10:	855a                	mv	a0,s6
    80005c12:	ffffc097          	auipc	ra,0xffffc
    80005c16:	b26080e7          	jalr	-1242(ra) # 80001738 <copyout>
    80005c1a:	0e054263          	bltz	a0,80005cfe <exec+0x342>
  p->trapframe->a1 = sp;
    80005c1e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005c22:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005c26:	de843783          	ld	a5,-536(s0)
    80005c2a:	0007c703          	lbu	a4,0(a5)
    80005c2e:	cf11                	beqz	a4,80005c4a <exec+0x28e>
    80005c30:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005c32:	02f00693          	li	a3,47
    80005c36:	a039                	j	80005c44 <exec+0x288>
      last = s+1;
    80005c38:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005c3c:	0785                	addi	a5,a5,1
    80005c3e:	fff7c703          	lbu	a4,-1(a5)
    80005c42:	c701                	beqz	a4,80005c4a <exec+0x28e>
    if(*s == '/')
    80005c44:	fed71ce3          	bne	a4,a3,80005c3c <exec+0x280>
    80005c48:	bfc5                	j	80005c38 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005c4a:	4641                	li	a2,16
    80005c4c:	de843583          	ld	a1,-536(s0)
    80005c50:	158b8513          	addi	a0,s7,344
    80005c54:	ffffb097          	auipc	ra,0xffffb
    80005c58:	1bc080e7          	jalr	444(ra) # 80000e10 <safestrcpy>
  if(myproc()->pid >2)
    80005c5c:	ffffc097          	auipc	ra,0xffffc
    80005c60:	e30080e7          	jalr	-464(ra) # 80001a8c <myproc>
    80005c64:	5918                	lw	a4,48(a0)
    80005c66:	4789                	li	a5,2
    80005c68:	02e7d663          	bge	a5,a4,80005c94 <exec+0x2d8>
    80005c6c:	170b8793          	addi	a5,s7,368
    80005c70:	3f0b8693          	addi	a3,s7,1008
    80005c74:	a029                	j	80005c7e <exec+0x2c2>
    for (int i=0; i<MAX_PSYC_PAGES; i++)
    80005c76:	02878793          	addi	a5,a5,40
    80005c7a:	00d78d63          	beq	a5,a3,80005c94 <exec+0x2d8>
      if(p->files_in_physicalmem[i].isAvailable==0)
    80005c7e:	873e                	mv	a4,a5
    80005c80:	5007a603          	lw	a2,1280(a5)
    80005c84:	e219                	bnez	a2,80005c8a <exec+0x2ce>
        p->files_in_physicalmem[i].pagetable = pagetable;
    80005c86:	5167b423          	sd	s6,1288(a5)
      if(p->files_in_swap[i].isAvailable==0)
    80005c8a:	4310                	lw	a2,0(a4)
    80005c8c:	f66d                	bnez	a2,80005c76 <exec+0x2ba>
        p->files_in_swap[i].pagetable = pagetable;
    80005c8e:	01673423          	sd	s6,8(a4)
    80005c92:	b7d5                	j	80005c76 <exec+0x2ba>
  oldpagetable = p->pagetable;
    80005c94:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005c98:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005c9c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005ca0:	058bb783          	ld	a5,88(s7)
    80005ca4:	e6043703          	ld	a4,-416(s0)
    80005ca8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005caa:	058bb783          	ld	a5,88(s7)
    80005cae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005cb2:	85ea                	mv	a1,s10
    80005cb4:	ffffc097          	auipc	ra,0xffffc
    80005cb8:	f38080e7          	jalr	-200(ra) # 80001bec <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005cbc:	0004851b          	sext.w	a0,s1
    80005cc0:	bb61                	j	80005a58 <exec+0x9c>
    80005cc2:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005cc6:	df843583          	ld	a1,-520(s0)
    80005cca:	855a                	mv	a0,s6
    80005ccc:	ffffc097          	auipc	ra,0xffffc
    80005cd0:	f20080e7          	jalr	-224(ra) # 80001bec <proc_freepagetable>
  if(ip){
    80005cd4:	d60a98e3          	bnez	s5,80005a44 <exec+0x88>
  return -1;
    80005cd8:	557d                	li	a0,-1
    80005cda:	bbbd                	j	80005a58 <exec+0x9c>
    80005cdc:	de943c23          	sd	s1,-520(s0)
    80005ce0:	b7dd                	j	80005cc6 <exec+0x30a>
    80005ce2:	de943c23          	sd	s1,-520(s0)
    80005ce6:	b7c5                	j	80005cc6 <exec+0x30a>
    80005ce8:	de943c23          	sd	s1,-520(s0)
    80005cec:	bfe9                	j	80005cc6 <exec+0x30a>
  sz = sz1;
    80005cee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cf2:	4a81                	li	s5,0
    80005cf4:	bfc9                	j	80005cc6 <exec+0x30a>
  sz = sz1;
    80005cf6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005cfa:	4a81                	li	s5,0
    80005cfc:	b7e9                	j	80005cc6 <exec+0x30a>
  sz = sz1;
    80005cfe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d02:	4a81                	li	s5,0
    80005d04:	b7c9                	j	80005cc6 <exec+0x30a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d06:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005d0a:	e0843783          	ld	a5,-504(s0)
    80005d0e:	0017869b          	addiw	a3,a5,1
    80005d12:	e0d43423          	sd	a3,-504(s0)
    80005d16:	e0043783          	ld	a5,-512(s0)
    80005d1a:	0387879b          	addiw	a5,a5,56
    80005d1e:	e8045703          	lhu	a4,-384(s0)
    80005d22:	dee6d7e3          	bge	a3,a4,80005b10 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005d26:	2781                	sext.w	a5,a5
    80005d28:	e0f43023          	sd	a5,-512(s0)
    80005d2c:	03800713          	li	a4,56
    80005d30:	86be                	mv	a3,a5
    80005d32:	e1040613          	addi	a2,s0,-496
    80005d36:	4581                	li	a1,0
    80005d38:	8556                	mv	a0,s5
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	53a080e7          	jalr	1338(ra) # 80004274 <readi>
    80005d42:	03800793          	li	a5,56
    80005d46:	f6f51ee3          	bne	a0,a5,80005cc2 <exec+0x306>
    if(ph.type != ELF_PROG_LOAD)
    80005d4a:	e1042783          	lw	a5,-496(s0)
    80005d4e:	4705                	li	a4,1
    80005d50:	fae79de3          	bne	a5,a4,80005d0a <exec+0x34e>
    if(ph.memsz < ph.filesz)
    80005d54:	e3843603          	ld	a2,-456(s0)
    80005d58:	e3043783          	ld	a5,-464(s0)
    80005d5c:	f8f660e3          	bltu	a2,a5,80005cdc <exec+0x320>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005d60:	e2043783          	ld	a5,-480(s0)
    80005d64:	963e                	add	a2,a2,a5
    80005d66:	f6f66ee3          	bltu	a2,a5,80005ce2 <exec+0x326>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d6a:	85a6                	mv	a1,s1
    80005d6c:	855a                	mv	a0,s6
    80005d6e:	ffffb097          	auipc	ra,0xffffb
    80005d72:	6e4080e7          	jalr	1764(ra) # 80001452 <uvmalloc>
    80005d76:	dea43c23          	sd	a0,-520(s0)
    80005d7a:	d53d                	beqz	a0,80005ce8 <exec+0x32c>
    if(ph.vaddr % PGSIZE != 0)
    80005d7c:	e2043c03          	ld	s8,-480(s0)
    80005d80:	de043783          	ld	a5,-544(s0)
    80005d84:	00fc77b3          	and	a5,s8,a5
    80005d88:	ff9d                	bnez	a5,80005cc6 <exec+0x30a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005d8a:	e1842c83          	lw	s9,-488(s0)
    80005d8e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005d92:	f60b8ae3          	beqz	s7,80005d06 <exec+0x34a>
    80005d96:	89de                	mv	s3,s7
    80005d98:	4481                	li	s1,0
    80005d9a:	bb91                	j	80005aee <exec+0x132>

0000000080005d9c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005d9c:	7179                	addi	sp,sp,-48
    80005d9e:	f406                	sd	ra,40(sp)
    80005da0:	f022                	sd	s0,32(sp)
    80005da2:	ec26                	sd	s1,24(sp)
    80005da4:	e84a                	sd	s2,16(sp)
    80005da6:	1800                	addi	s0,sp,48
    80005da8:	892e                	mv	s2,a1
    80005daa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005dac:	fdc40593          	addi	a1,s0,-36
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	69e080e7          	jalr	1694(ra) # 8000344e <argint>
    80005db8:	04054063          	bltz	a0,80005df8 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005dbc:	fdc42703          	lw	a4,-36(s0)
    80005dc0:	47bd                	li	a5,15
    80005dc2:	02e7ed63          	bltu	a5,a4,80005dfc <argfd+0x60>
    80005dc6:	ffffc097          	auipc	ra,0xffffc
    80005dca:	cc6080e7          	jalr	-826(ra) # 80001a8c <myproc>
    80005dce:	fdc42703          	lw	a4,-36(s0)
    80005dd2:	01a70793          	addi	a5,a4,26
    80005dd6:	078e                	slli	a5,a5,0x3
    80005dd8:	953e                	add	a0,a0,a5
    80005dda:	611c                	ld	a5,0(a0)
    80005ddc:	c395                	beqz	a5,80005e00 <argfd+0x64>
    return -1;
  if(pfd)
    80005dde:	00090463          	beqz	s2,80005de6 <argfd+0x4a>
    *pfd = fd;
    80005de2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005de6:	4501                	li	a0,0
  if(pf)
    80005de8:	c091                	beqz	s1,80005dec <argfd+0x50>
    *pf = f;
    80005dea:	e09c                	sd	a5,0(s1)
}
    80005dec:	70a2                	ld	ra,40(sp)
    80005dee:	7402                	ld	s0,32(sp)
    80005df0:	64e2                	ld	s1,24(sp)
    80005df2:	6942                	ld	s2,16(sp)
    80005df4:	6145                	addi	sp,sp,48
    80005df6:	8082                	ret
    return -1;
    80005df8:	557d                	li	a0,-1
    80005dfa:	bfcd                	j	80005dec <argfd+0x50>
    return -1;
    80005dfc:	557d                	li	a0,-1
    80005dfe:	b7fd                	j	80005dec <argfd+0x50>
    80005e00:	557d                	li	a0,-1
    80005e02:	b7ed                	j	80005dec <argfd+0x50>

0000000080005e04 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005e04:	1101                	addi	sp,sp,-32
    80005e06:	ec06                	sd	ra,24(sp)
    80005e08:	e822                	sd	s0,16(sp)
    80005e0a:	e426                	sd	s1,8(sp)
    80005e0c:	1000                	addi	s0,sp,32
    80005e0e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e10:	ffffc097          	auipc	ra,0xffffc
    80005e14:	c7c080e7          	jalr	-900(ra) # 80001a8c <myproc>
    80005e18:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005e1a:	0d050793          	addi	a5,a0,208
    80005e1e:	4501                	li	a0,0
    80005e20:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005e22:	6398                	ld	a4,0(a5)
    80005e24:	cb19                	beqz	a4,80005e3a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005e26:	2505                	addiw	a0,a0,1
    80005e28:	07a1                	addi	a5,a5,8
    80005e2a:	fed51ce3          	bne	a0,a3,80005e22 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005e2e:	557d                	li	a0,-1
}
    80005e30:	60e2                	ld	ra,24(sp)
    80005e32:	6442                	ld	s0,16(sp)
    80005e34:	64a2                	ld	s1,8(sp)
    80005e36:	6105                	addi	sp,sp,32
    80005e38:	8082                	ret
      p->ofile[fd] = f;
    80005e3a:	01a50793          	addi	a5,a0,26
    80005e3e:	078e                	slli	a5,a5,0x3
    80005e40:	963e                	add	a2,a2,a5
    80005e42:	e204                	sd	s1,0(a2)
      return fd;
    80005e44:	b7f5                	j	80005e30 <fdalloc+0x2c>

0000000080005e46 <sys_dup>:

uint64
sys_dup(void)
{
    80005e46:	7179                	addi	sp,sp,-48
    80005e48:	f406                	sd	ra,40(sp)
    80005e4a:	f022                	sd	s0,32(sp)
    80005e4c:	ec26                	sd	s1,24(sp)
    80005e4e:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80005e50:	fd840613          	addi	a2,s0,-40
    80005e54:	4581                	li	a1,0
    80005e56:	4501                	li	a0,0
    80005e58:	00000097          	auipc	ra,0x0
    80005e5c:	f44080e7          	jalr	-188(ra) # 80005d9c <argfd>
    return -1;
    80005e60:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005e62:	02054363          	bltz	a0,80005e88 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005e66:	fd843503          	ld	a0,-40(s0)
    80005e6a:	00000097          	auipc	ra,0x0
    80005e6e:	f9a080e7          	jalr	-102(ra) # 80005e04 <fdalloc>
    80005e72:	84aa                	mv	s1,a0
    return -1;
    80005e74:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e76:	00054963          	bltz	a0,80005e88 <sys_dup+0x42>
  filedup(f);
    80005e7a:	fd843503          	ld	a0,-40(s0)
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	2a4080e7          	jalr	676(ra) # 80005122 <filedup>
  return fd;
    80005e86:	87a6                	mv	a5,s1
}
    80005e88:	853e                	mv	a0,a5
    80005e8a:	70a2                	ld	ra,40(sp)
    80005e8c:	7402                	ld	s0,32(sp)
    80005e8e:	64e2                	ld	s1,24(sp)
    80005e90:	6145                	addi	sp,sp,48
    80005e92:	8082                	ret

0000000080005e94 <sys_read>:

uint64
sys_read(void)
{
    80005e94:	7179                	addi	sp,sp,-48
    80005e96:	f406                	sd	ra,40(sp)
    80005e98:	f022                	sd	s0,32(sp)
    80005e9a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e9c:	fe840613          	addi	a2,s0,-24
    80005ea0:	4581                	li	a1,0
    80005ea2:	4501                	li	a0,0
    80005ea4:	00000097          	auipc	ra,0x0
    80005ea8:	ef8080e7          	jalr	-264(ra) # 80005d9c <argfd>
    return -1;
    80005eac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005eae:	04054163          	bltz	a0,80005ef0 <sys_read+0x5c>
    80005eb2:	fe440593          	addi	a1,s0,-28
    80005eb6:	4509                	li	a0,2
    80005eb8:	ffffd097          	auipc	ra,0xffffd
    80005ebc:	596080e7          	jalr	1430(ra) # 8000344e <argint>
    return -1;
    80005ec0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ec2:	02054763          	bltz	a0,80005ef0 <sys_read+0x5c>
    80005ec6:	fd840593          	addi	a1,s0,-40
    80005eca:	4505                	li	a0,1
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	5a4080e7          	jalr	1444(ra) # 80003470 <argaddr>
    return -1;
    80005ed4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ed6:	00054d63          	bltz	a0,80005ef0 <sys_read+0x5c>
  return fileread(f, p, n);
    80005eda:	fe442603          	lw	a2,-28(s0)
    80005ede:	fd843583          	ld	a1,-40(s0)
    80005ee2:	fe843503          	ld	a0,-24(s0)
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	3c8080e7          	jalr	968(ra) # 800052ae <fileread>
    80005eee:	87aa                	mv	a5,a0
}
    80005ef0:	853e                	mv	a0,a5
    80005ef2:	70a2                	ld	ra,40(sp)
    80005ef4:	7402                	ld	s0,32(sp)
    80005ef6:	6145                	addi	sp,sp,48
    80005ef8:	8082                	ret

0000000080005efa <sys_write>:

uint64
sys_write(void)
{
    80005efa:	7179                	addi	sp,sp,-48
    80005efc:	f406                	sd	ra,40(sp)
    80005efe:	f022                	sd	s0,32(sp)
    80005f00:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f02:	fe840613          	addi	a2,s0,-24
    80005f06:	4581                	li	a1,0
    80005f08:	4501                	li	a0,0
    80005f0a:	00000097          	auipc	ra,0x0
    80005f0e:	e92080e7          	jalr	-366(ra) # 80005d9c <argfd>
    return -1;
    80005f12:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f14:	04054163          	bltz	a0,80005f56 <sys_write+0x5c>
    80005f18:	fe440593          	addi	a1,s0,-28
    80005f1c:	4509                	li	a0,2
    80005f1e:	ffffd097          	auipc	ra,0xffffd
    80005f22:	530080e7          	jalr	1328(ra) # 8000344e <argint>
    return -1;
    80005f26:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f28:	02054763          	bltz	a0,80005f56 <sys_write+0x5c>
    80005f2c:	fd840593          	addi	a1,s0,-40
    80005f30:	4505                	li	a0,1
    80005f32:	ffffd097          	auipc	ra,0xffffd
    80005f36:	53e080e7          	jalr	1342(ra) # 80003470 <argaddr>
    return -1;
    80005f3a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005f3c:	00054d63          	bltz	a0,80005f56 <sys_write+0x5c>

  return filewrite(f, p, n);
    80005f40:	fe442603          	lw	a2,-28(s0)
    80005f44:	fd843583          	ld	a1,-40(s0)
    80005f48:	fe843503          	ld	a0,-24(s0)
    80005f4c:	fffff097          	auipc	ra,0xfffff
    80005f50:	424080e7          	jalr	1060(ra) # 80005370 <filewrite>
    80005f54:	87aa                	mv	a5,a0
}
    80005f56:	853e                	mv	a0,a5
    80005f58:	70a2                	ld	ra,40(sp)
    80005f5a:	7402                	ld	s0,32(sp)
    80005f5c:	6145                	addi	sp,sp,48
    80005f5e:	8082                	ret

0000000080005f60 <sys_close>:

uint64
sys_close(void)
{
    80005f60:	1101                	addi	sp,sp,-32
    80005f62:	ec06                	sd	ra,24(sp)
    80005f64:	e822                	sd	s0,16(sp)
    80005f66:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005f68:	fe040613          	addi	a2,s0,-32
    80005f6c:	fec40593          	addi	a1,s0,-20
    80005f70:	4501                	li	a0,0
    80005f72:	00000097          	auipc	ra,0x0
    80005f76:	e2a080e7          	jalr	-470(ra) # 80005d9c <argfd>
    return -1;
    80005f7a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005f7c:	02054463          	bltz	a0,80005fa4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	b0c080e7          	jalr	-1268(ra) # 80001a8c <myproc>
    80005f88:	fec42783          	lw	a5,-20(s0)
    80005f8c:	07e9                	addi	a5,a5,26
    80005f8e:	078e                	slli	a5,a5,0x3
    80005f90:	97aa                	add	a5,a5,a0
    80005f92:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005f96:	fe043503          	ld	a0,-32(s0)
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	1da080e7          	jalr	474(ra) # 80005174 <fileclose>
  return 0;
    80005fa2:	4781                	li	a5,0
}
    80005fa4:	853e                	mv	a0,a5
    80005fa6:	60e2                	ld	ra,24(sp)
    80005fa8:	6442                	ld	s0,16(sp)
    80005faa:	6105                	addi	sp,sp,32
    80005fac:	8082                	ret

0000000080005fae <sys_fstat>:

uint64
sys_fstat(void)
{
    80005fae:	1101                	addi	sp,sp,-32
    80005fb0:	ec06                	sd	ra,24(sp)
    80005fb2:	e822                	sd	s0,16(sp)
    80005fb4:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fb6:	fe840613          	addi	a2,s0,-24
    80005fba:	4581                	li	a1,0
    80005fbc:	4501                	li	a0,0
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	dde080e7          	jalr	-546(ra) # 80005d9c <argfd>
    return -1;
    80005fc6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fc8:	02054563          	bltz	a0,80005ff2 <sys_fstat+0x44>
    80005fcc:	fe040593          	addi	a1,s0,-32
    80005fd0:	4505                	li	a0,1
    80005fd2:	ffffd097          	auipc	ra,0xffffd
    80005fd6:	49e080e7          	jalr	1182(ra) # 80003470 <argaddr>
    return -1;
    80005fda:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005fdc:	00054b63          	bltz	a0,80005ff2 <sys_fstat+0x44>
  return filestat(f, st);
    80005fe0:	fe043583          	ld	a1,-32(s0)
    80005fe4:	fe843503          	ld	a0,-24(s0)
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	254080e7          	jalr	596(ra) # 8000523c <filestat>
    80005ff0:	87aa                	mv	a5,a0
}
    80005ff2:	853e                	mv	a0,a5
    80005ff4:	60e2                	ld	ra,24(sp)
    80005ff6:	6442                	ld	s0,16(sp)
    80005ff8:	6105                	addi	sp,sp,32
    80005ffa:	8082                	ret

0000000080005ffc <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005ffc:	7169                	addi	sp,sp,-304
    80005ffe:	f606                	sd	ra,296(sp)
    80006000:	f222                	sd	s0,288(sp)
    80006002:	ee26                	sd	s1,280(sp)
    80006004:	ea4a                	sd	s2,272(sp)
    80006006:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006008:	08000613          	li	a2,128
    8000600c:	ed040593          	addi	a1,s0,-304
    80006010:	4501                	li	a0,0
    80006012:	ffffd097          	auipc	ra,0xffffd
    80006016:	480080e7          	jalr	1152(ra) # 80003492 <argstr>
    return -1;
    8000601a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000601c:	10054e63          	bltz	a0,80006138 <sys_link+0x13c>
    80006020:	08000613          	li	a2,128
    80006024:	f5040593          	addi	a1,s0,-176
    80006028:	4505                	li	a0,1
    8000602a:	ffffd097          	auipc	ra,0xffffd
    8000602e:	468080e7          	jalr	1128(ra) # 80003492 <argstr>
    return -1;
    80006032:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006034:	10054263          	bltz	a0,80006138 <sys_link+0x13c>

  begin_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	c70080e7          	jalr	-912(ra) # 80004ca8 <begin_op>
  if((ip = namei(old)) == 0){
    80006040:	ed040513          	addi	a0,s0,-304
    80006044:	ffffe097          	auipc	ra,0xffffe
    80006048:	732080e7          	jalr	1842(ra) # 80004776 <namei>
    8000604c:	84aa                	mv	s1,a0
    8000604e:	c551                	beqz	a0,800060da <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80006050:	ffffe097          	auipc	ra,0xffffe
    80006054:	f70080e7          	jalr	-144(ra) # 80003fc0 <ilock>
  if(ip->type == T_DIR){
    80006058:	04449703          	lh	a4,68(s1)
    8000605c:	4785                	li	a5,1
    8000605e:	08f70463          	beq	a4,a5,800060e6 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006062:	04a4d783          	lhu	a5,74(s1)
    80006066:	2785                	addiw	a5,a5,1
    80006068:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000606c:	8526                	mv	a0,s1
    8000606e:	ffffe097          	auipc	ra,0xffffe
    80006072:	e88080e7          	jalr	-376(ra) # 80003ef6 <iupdate>
  iunlock(ip);
    80006076:	8526                	mv	a0,s1
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	00a080e7          	jalr	10(ra) # 80004082 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80006080:	fd040593          	addi	a1,s0,-48
    80006084:	f5040513          	addi	a0,s0,-176
    80006088:	ffffe097          	auipc	ra,0xffffe
    8000608c:	70c080e7          	jalr	1804(ra) # 80004794 <nameiparent>
    80006090:	892a                	mv	s2,a0
    80006092:	c935                	beqz	a0,80006106 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006094:	ffffe097          	auipc	ra,0xffffe
    80006098:	f2c080e7          	jalr	-212(ra) # 80003fc0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000609c:	00092703          	lw	a4,0(s2)
    800060a0:	409c                	lw	a5,0(s1)
    800060a2:	04f71d63          	bne	a4,a5,800060fc <sys_link+0x100>
    800060a6:	40d0                	lw	a2,4(s1)
    800060a8:	fd040593          	addi	a1,s0,-48
    800060ac:	854a                	mv	a0,s2
    800060ae:	ffffe097          	auipc	ra,0xffffe
    800060b2:	606080e7          	jalr	1542(ra) # 800046b4 <dirlink>
    800060b6:	04054363          	bltz	a0,800060fc <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	166080e7          	jalr	358(ra) # 80004222 <iunlockput>
  iput(ip);
    800060c4:	8526                	mv	a0,s1
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	0b4080e7          	jalr	180(ra) # 8000417a <iput>

  end_op();
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	c5a080e7          	jalr	-934(ra) # 80004d28 <end_op>

  return 0;
    800060d6:	4781                	li	a5,0
    800060d8:	a085                	j	80006138 <sys_link+0x13c>
    end_op();
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	c4e080e7          	jalr	-946(ra) # 80004d28 <end_op>
    return -1;
    800060e2:	57fd                	li	a5,-1
    800060e4:	a891                	j	80006138 <sys_link+0x13c>
    iunlockput(ip);
    800060e6:	8526                	mv	a0,s1
    800060e8:	ffffe097          	auipc	ra,0xffffe
    800060ec:	13a080e7          	jalr	314(ra) # 80004222 <iunlockput>
    end_op();
    800060f0:	fffff097          	auipc	ra,0xfffff
    800060f4:	c38080e7          	jalr	-968(ra) # 80004d28 <end_op>
    return -1;
    800060f8:	57fd                	li	a5,-1
    800060fa:	a83d                	j	80006138 <sys_link+0x13c>
    iunlockput(dp);
    800060fc:	854a                	mv	a0,s2
    800060fe:	ffffe097          	auipc	ra,0xffffe
    80006102:	124080e7          	jalr	292(ra) # 80004222 <iunlockput>

bad:
  ilock(ip);
    80006106:	8526                	mv	a0,s1
    80006108:	ffffe097          	auipc	ra,0xffffe
    8000610c:	eb8080e7          	jalr	-328(ra) # 80003fc0 <ilock>
  ip->nlink--;
    80006110:	04a4d783          	lhu	a5,74(s1)
    80006114:	37fd                	addiw	a5,a5,-1
    80006116:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000611a:	8526                	mv	a0,s1
    8000611c:	ffffe097          	auipc	ra,0xffffe
    80006120:	dda080e7          	jalr	-550(ra) # 80003ef6 <iupdate>
  iunlockput(ip);
    80006124:	8526                	mv	a0,s1
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	0fc080e7          	jalr	252(ra) # 80004222 <iunlockput>
  end_op();
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	bfa080e7          	jalr	-1030(ra) # 80004d28 <end_op>
  return -1;
    80006136:	57fd                	li	a5,-1
}
    80006138:	853e                	mv	a0,a5
    8000613a:	70b2                	ld	ra,296(sp)
    8000613c:	7412                	ld	s0,288(sp)
    8000613e:	64f2                	ld	s1,280(sp)
    80006140:	6952                	ld	s2,272(sp)
    80006142:	6155                	addi	sp,sp,304
    80006144:	8082                	ret

0000000080006146 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006146:	4578                	lw	a4,76(a0)
    80006148:	02000793          	li	a5,32
    8000614c:	04e7fa63          	bgeu	a5,a4,800061a0 <isdirempty+0x5a>
{
    80006150:	7179                	addi	sp,sp,-48
    80006152:	f406                	sd	ra,40(sp)
    80006154:	f022                	sd	s0,32(sp)
    80006156:	ec26                	sd	s1,24(sp)
    80006158:	e84a                	sd	s2,16(sp)
    8000615a:	1800                	addi	s0,sp,48
    8000615c:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000615e:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006162:	4741                	li	a4,16
    80006164:	86a6                	mv	a3,s1
    80006166:	fd040613          	addi	a2,s0,-48
    8000616a:	4581                	li	a1,0
    8000616c:	854a                	mv	a0,s2
    8000616e:	ffffe097          	auipc	ra,0xffffe
    80006172:	106080e7          	jalr	262(ra) # 80004274 <readi>
    80006176:	47c1                	li	a5,16
    80006178:	00f51c63          	bne	a0,a5,80006190 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    8000617c:	fd045783          	lhu	a5,-48(s0)
    80006180:	e395                	bnez	a5,800061a4 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006182:	24c1                	addiw	s1,s1,16
    80006184:	04c92783          	lw	a5,76(s2)
    80006188:	fcf4ede3          	bltu	s1,a5,80006162 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    8000618c:	4505                	li	a0,1
    8000618e:	a821                	j	800061a6 <isdirempty+0x60>
      panic("isdirempty: readi");
    80006190:	00004517          	auipc	a0,0x4
    80006194:	91850513          	addi	a0,a0,-1768 # 80009aa8 <syscalls+0x310>
    80006198:	ffffa097          	auipc	ra,0xffffa
    8000619c:	392080e7          	jalr	914(ra) # 8000052a <panic>
  return 1;
    800061a0:	4505                	li	a0,1
}
    800061a2:	8082                	ret
      return 0;
    800061a4:	4501                	li	a0,0
}
    800061a6:	70a2                	ld	ra,40(sp)
    800061a8:	7402                	ld	s0,32(sp)
    800061aa:	64e2                	ld	s1,24(sp)
    800061ac:	6942                	ld	s2,16(sp)
    800061ae:	6145                	addi	sp,sp,48
    800061b0:	8082                	ret

00000000800061b2 <sys_unlink>:

uint64
sys_unlink(void)
{
    800061b2:	7155                	addi	sp,sp,-208
    800061b4:	e586                	sd	ra,200(sp)
    800061b6:	e1a2                	sd	s0,192(sp)
    800061b8:	fd26                	sd	s1,184(sp)
    800061ba:	f94a                	sd	s2,176(sp)
    800061bc:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800061be:	08000613          	li	a2,128
    800061c2:	f4040593          	addi	a1,s0,-192
    800061c6:	4501                	li	a0,0
    800061c8:	ffffd097          	auipc	ra,0xffffd
    800061cc:	2ca080e7          	jalr	714(ra) # 80003492 <argstr>
    800061d0:	16054363          	bltz	a0,80006336 <sys_unlink+0x184>
    return -1;

  begin_op();
    800061d4:	fffff097          	auipc	ra,0xfffff
    800061d8:	ad4080e7          	jalr	-1324(ra) # 80004ca8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800061dc:	fc040593          	addi	a1,s0,-64
    800061e0:	f4040513          	addi	a0,s0,-192
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	5b0080e7          	jalr	1456(ra) # 80004794 <nameiparent>
    800061ec:	84aa                	mv	s1,a0
    800061ee:	c961                	beqz	a0,800062be <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    800061f0:	ffffe097          	auipc	ra,0xffffe
    800061f4:	dd0080e7          	jalr	-560(ra) # 80003fc0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800061f8:	00003597          	auipc	a1,0x3
    800061fc:	79058593          	addi	a1,a1,1936 # 80009988 <syscalls+0x1f0>
    80006200:	fc040513          	addi	a0,s0,-64
    80006204:	ffffe097          	auipc	ra,0xffffe
    80006208:	286080e7          	jalr	646(ra) # 8000448a <namecmp>
    8000620c:	c175                	beqz	a0,800062f0 <sys_unlink+0x13e>
    8000620e:	00003597          	auipc	a1,0x3
    80006212:	78258593          	addi	a1,a1,1922 # 80009990 <syscalls+0x1f8>
    80006216:	fc040513          	addi	a0,s0,-64
    8000621a:	ffffe097          	auipc	ra,0xffffe
    8000621e:	270080e7          	jalr	624(ra) # 8000448a <namecmp>
    80006222:	c579                	beqz	a0,800062f0 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006224:	f3c40613          	addi	a2,s0,-196
    80006228:	fc040593          	addi	a1,s0,-64
    8000622c:	8526                	mv	a0,s1
    8000622e:	ffffe097          	auipc	ra,0xffffe
    80006232:	276080e7          	jalr	630(ra) # 800044a4 <dirlookup>
    80006236:	892a                	mv	s2,a0
    80006238:	cd45                	beqz	a0,800062f0 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    8000623a:	ffffe097          	auipc	ra,0xffffe
    8000623e:	d86080e7          	jalr	-634(ra) # 80003fc0 <ilock>

  if(ip->nlink < 1)
    80006242:	04a91783          	lh	a5,74(s2)
    80006246:	08f05263          	blez	a5,800062ca <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000624a:	04491703          	lh	a4,68(s2)
    8000624e:	4785                	li	a5,1
    80006250:	08f70563          	beq	a4,a5,800062da <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006254:	4641                	li	a2,16
    80006256:	4581                	li	a1,0
    80006258:	fd040513          	addi	a0,s0,-48
    8000625c:	ffffb097          	auipc	ra,0xffffb
    80006260:	a62080e7          	jalr	-1438(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006264:	4741                	li	a4,16
    80006266:	f3c42683          	lw	a3,-196(s0)
    8000626a:	fd040613          	addi	a2,s0,-48
    8000626e:	4581                	li	a1,0
    80006270:	8526                	mv	a0,s1
    80006272:	ffffe097          	auipc	ra,0xffffe
    80006276:	0fa080e7          	jalr	250(ra) # 8000436c <writei>
    8000627a:	47c1                	li	a5,16
    8000627c:	08f51a63          	bne	a0,a5,80006310 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80006280:	04491703          	lh	a4,68(s2)
    80006284:	4785                	li	a5,1
    80006286:	08f70d63          	beq	a4,a5,80006320 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000628a:	8526                	mv	a0,s1
    8000628c:	ffffe097          	auipc	ra,0xffffe
    80006290:	f96080e7          	jalr	-106(ra) # 80004222 <iunlockput>

  ip->nlink--;
    80006294:	04a95783          	lhu	a5,74(s2)
    80006298:	37fd                	addiw	a5,a5,-1
    8000629a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000629e:	854a                	mv	a0,s2
    800062a0:	ffffe097          	auipc	ra,0xffffe
    800062a4:	c56080e7          	jalr	-938(ra) # 80003ef6 <iupdate>
  iunlockput(ip);
    800062a8:	854a                	mv	a0,s2
    800062aa:	ffffe097          	auipc	ra,0xffffe
    800062ae:	f78080e7          	jalr	-136(ra) # 80004222 <iunlockput>

  end_op();
    800062b2:	fffff097          	auipc	ra,0xfffff
    800062b6:	a76080e7          	jalr	-1418(ra) # 80004d28 <end_op>

  return 0;
    800062ba:	4501                	li	a0,0
    800062bc:	a0a1                	j	80006304 <sys_unlink+0x152>
    end_op();
    800062be:	fffff097          	auipc	ra,0xfffff
    800062c2:	a6a080e7          	jalr	-1430(ra) # 80004d28 <end_op>
    return -1;
    800062c6:	557d                	li	a0,-1
    800062c8:	a835                	j	80006304 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800062ca:	00003517          	auipc	a0,0x3
    800062ce:	6ce50513          	addi	a0,a0,1742 # 80009998 <syscalls+0x200>
    800062d2:	ffffa097          	auipc	ra,0xffffa
    800062d6:	258080e7          	jalr	600(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800062da:	854a                	mv	a0,s2
    800062dc:	00000097          	auipc	ra,0x0
    800062e0:	e6a080e7          	jalr	-406(ra) # 80006146 <isdirempty>
    800062e4:	f925                	bnez	a0,80006254 <sys_unlink+0xa2>
    iunlockput(ip);
    800062e6:	854a                	mv	a0,s2
    800062e8:	ffffe097          	auipc	ra,0xffffe
    800062ec:	f3a080e7          	jalr	-198(ra) # 80004222 <iunlockput>

bad:
  iunlockput(dp);
    800062f0:	8526                	mv	a0,s1
    800062f2:	ffffe097          	auipc	ra,0xffffe
    800062f6:	f30080e7          	jalr	-208(ra) # 80004222 <iunlockput>
  end_op();
    800062fa:	fffff097          	auipc	ra,0xfffff
    800062fe:	a2e080e7          	jalr	-1490(ra) # 80004d28 <end_op>
  return -1;
    80006302:	557d                	li	a0,-1
}
    80006304:	60ae                	ld	ra,200(sp)
    80006306:	640e                	ld	s0,192(sp)
    80006308:	74ea                	ld	s1,184(sp)
    8000630a:	794a                	ld	s2,176(sp)
    8000630c:	6169                	addi	sp,sp,208
    8000630e:	8082                	ret
    panic("unlink: writei");
    80006310:	00003517          	auipc	a0,0x3
    80006314:	6a050513          	addi	a0,a0,1696 # 800099b0 <syscalls+0x218>
    80006318:	ffffa097          	auipc	ra,0xffffa
    8000631c:	212080e7          	jalr	530(ra) # 8000052a <panic>
    dp->nlink--;
    80006320:	04a4d783          	lhu	a5,74(s1)
    80006324:	37fd                	addiw	a5,a5,-1
    80006326:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000632a:	8526                	mv	a0,s1
    8000632c:	ffffe097          	auipc	ra,0xffffe
    80006330:	bca080e7          	jalr	-1078(ra) # 80003ef6 <iupdate>
    80006334:	bf99                	j	8000628a <sys_unlink+0xd8>
    return -1;
    80006336:	557d                	li	a0,-1
    80006338:	b7f1                	j	80006304 <sys_unlink+0x152>

000000008000633a <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    8000633a:	715d                	addi	sp,sp,-80
    8000633c:	e486                	sd	ra,72(sp)
    8000633e:	e0a2                	sd	s0,64(sp)
    80006340:	fc26                	sd	s1,56(sp)
    80006342:	f84a                	sd	s2,48(sp)
    80006344:	f44e                	sd	s3,40(sp)
    80006346:	f052                	sd	s4,32(sp)
    80006348:	ec56                	sd	s5,24(sp)
    8000634a:	0880                	addi	s0,sp,80
    8000634c:	89ae                	mv	s3,a1
    8000634e:	8ab2                	mv	s5,a2
    80006350:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006352:	fb040593          	addi	a1,s0,-80
    80006356:	ffffe097          	auipc	ra,0xffffe
    8000635a:	43e080e7          	jalr	1086(ra) # 80004794 <nameiparent>
    8000635e:	892a                	mv	s2,a0
    80006360:	12050e63          	beqz	a0,8000649c <create+0x162>
    return 0;

  ilock(dp);
    80006364:	ffffe097          	auipc	ra,0xffffe
    80006368:	c5c080e7          	jalr	-932(ra) # 80003fc0 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000636c:	4601                	li	a2,0
    8000636e:	fb040593          	addi	a1,s0,-80
    80006372:	854a                	mv	a0,s2
    80006374:	ffffe097          	auipc	ra,0xffffe
    80006378:	130080e7          	jalr	304(ra) # 800044a4 <dirlookup>
    8000637c:	84aa                	mv	s1,a0
    8000637e:	c921                	beqz	a0,800063ce <create+0x94>
    iunlockput(dp);
    80006380:	854a                	mv	a0,s2
    80006382:	ffffe097          	auipc	ra,0xffffe
    80006386:	ea0080e7          	jalr	-352(ra) # 80004222 <iunlockput>
    ilock(ip);
    8000638a:	8526                	mv	a0,s1
    8000638c:	ffffe097          	auipc	ra,0xffffe
    80006390:	c34080e7          	jalr	-972(ra) # 80003fc0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006394:	2981                	sext.w	s3,s3
    80006396:	4789                	li	a5,2
    80006398:	02f99463          	bne	s3,a5,800063c0 <create+0x86>
    8000639c:	0444d783          	lhu	a5,68(s1)
    800063a0:	37f9                	addiw	a5,a5,-2
    800063a2:	17c2                	slli	a5,a5,0x30
    800063a4:	93c1                	srli	a5,a5,0x30
    800063a6:	4705                	li	a4,1
    800063a8:	00f76c63          	bltu	a4,a5,800063c0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800063ac:	8526                	mv	a0,s1
    800063ae:	60a6                	ld	ra,72(sp)
    800063b0:	6406                	ld	s0,64(sp)
    800063b2:	74e2                	ld	s1,56(sp)
    800063b4:	7942                	ld	s2,48(sp)
    800063b6:	79a2                	ld	s3,40(sp)
    800063b8:	7a02                	ld	s4,32(sp)
    800063ba:	6ae2                	ld	s5,24(sp)
    800063bc:	6161                	addi	sp,sp,80
    800063be:	8082                	ret
    iunlockput(ip);
    800063c0:	8526                	mv	a0,s1
    800063c2:	ffffe097          	auipc	ra,0xffffe
    800063c6:	e60080e7          	jalr	-416(ra) # 80004222 <iunlockput>
    return 0;
    800063ca:	4481                	li	s1,0
    800063cc:	b7c5                	j	800063ac <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800063ce:	85ce                	mv	a1,s3
    800063d0:	00092503          	lw	a0,0(s2)
    800063d4:	ffffe097          	auipc	ra,0xffffe
    800063d8:	a54080e7          	jalr	-1452(ra) # 80003e28 <ialloc>
    800063dc:	84aa                	mv	s1,a0
    800063de:	c521                	beqz	a0,80006426 <create+0xec>
  ilock(ip);
    800063e0:	ffffe097          	auipc	ra,0xffffe
    800063e4:	be0080e7          	jalr	-1056(ra) # 80003fc0 <ilock>
  ip->major = major;
    800063e8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800063ec:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800063f0:	4a05                	li	s4,1
    800063f2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800063f6:	8526                	mv	a0,s1
    800063f8:	ffffe097          	auipc	ra,0xffffe
    800063fc:	afe080e7          	jalr	-1282(ra) # 80003ef6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006400:	2981                	sext.w	s3,s3
    80006402:	03498a63          	beq	s3,s4,80006436 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006406:	40d0                	lw	a2,4(s1)
    80006408:	fb040593          	addi	a1,s0,-80
    8000640c:	854a                	mv	a0,s2
    8000640e:	ffffe097          	auipc	ra,0xffffe
    80006412:	2a6080e7          	jalr	678(ra) # 800046b4 <dirlink>
    80006416:	06054b63          	bltz	a0,8000648c <create+0x152>
  iunlockput(dp);
    8000641a:	854a                	mv	a0,s2
    8000641c:	ffffe097          	auipc	ra,0xffffe
    80006420:	e06080e7          	jalr	-506(ra) # 80004222 <iunlockput>
  return ip;
    80006424:	b761                	j	800063ac <create+0x72>
    panic("create: ialloc");
    80006426:	00003517          	auipc	a0,0x3
    8000642a:	69a50513          	addi	a0,a0,1690 # 80009ac0 <syscalls+0x328>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	0fc080e7          	jalr	252(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006436:	04a95783          	lhu	a5,74(s2)
    8000643a:	2785                	addiw	a5,a5,1
    8000643c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006440:	854a                	mv	a0,s2
    80006442:	ffffe097          	auipc	ra,0xffffe
    80006446:	ab4080e7          	jalr	-1356(ra) # 80003ef6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000644a:	40d0                	lw	a2,4(s1)
    8000644c:	00003597          	auipc	a1,0x3
    80006450:	53c58593          	addi	a1,a1,1340 # 80009988 <syscalls+0x1f0>
    80006454:	8526                	mv	a0,s1
    80006456:	ffffe097          	auipc	ra,0xffffe
    8000645a:	25e080e7          	jalr	606(ra) # 800046b4 <dirlink>
    8000645e:	00054f63          	bltz	a0,8000647c <create+0x142>
    80006462:	00492603          	lw	a2,4(s2)
    80006466:	00003597          	auipc	a1,0x3
    8000646a:	52a58593          	addi	a1,a1,1322 # 80009990 <syscalls+0x1f8>
    8000646e:	8526                	mv	a0,s1
    80006470:	ffffe097          	auipc	ra,0xffffe
    80006474:	244080e7          	jalr	580(ra) # 800046b4 <dirlink>
    80006478:	f80557e3          	bgez	a0,80006406 <create+0xcc>
      panic("create dots");
    8000647c:	00003517          	auipc	a0,0x3
    80006480:	65450513          	addi	a0,a0,1620 # 80009ad0 <syscalls+0x338>
    80006484:	ffffa097          	auipc	ra,0xffffa
    80006488:	0a6080e7          	jalr	166(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000648c:	00003517          	auipc	a0,0x3
    80006490:	65450513          	addi	a0,a0,1620 # 80009ae0 <syscalls+0x348>
    80006494:	ffffa097          	auipc	ra,0xffffa
    80006498:	096080e7          	jalr	150(ra) # 8000052a <panic>
    return 0;
    8000649c:	84aa                	mv	s1,a0
    8000649e:	b739                	j	800063ac <create+0x72>

00000000800064a0 <sys_open>:

uint64
sys_open(void)
{
    800064a0:	7131                	addi	sp,sp,-192
    800064a2:	fd06                	sd	ra,184(sp)
    800064a4:	f922                	sd	s0,176(sp)
    800064a6:	f526                	sd	s1,168(sp)
    800064a8:	f14a                	sd	s2,160(sp)
    800064aa:	ed4e                	sd	s3,152(sp)
    800064ac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064ae:	08000613          	li	a2,128
    800064b2:	f5040593          	addi	a1,s0,-176
    800064b6:	4501                	li	a0,0
    800064b8:	ffffd097          	auipc	ra,0xffffd
    800064bc:	fda080e7          	jalr	-38(ra) # 80003492 <argstr>
    return -1;
    800064c0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064c2:	0c054163          	bltz	a0,80006584 <sys_open+0xe4>
    800064c6:	f4c40593          	addi	a1,s0,-180
    800064ca:	4505                	li	a0,1
    800064cc:	ffffd097          	auipc	ra,0xffffd
    800064d0:	f82080e7          	jalr	-126(ra) # 8000344e <argint>
    800064d4:	0a054863          	bltz	a0,80006584 <sys_open+0xe4>

  begin_op();
    800064d8:	ffffe097          	auipc	ra,0xffffe
    800064dc:	7d0080e7          	jalr	2000(ra) # 80004ca8 <begin_op>

  if(omode & O_CREATE){
    800064e0:	f4c42783          	lw	a5,-180(s0)
    800064e4:	2007f793          	andi	a5,a5,512
    800064e8:	cbdd                	beqz	a5,8000659e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800064ea:	4681                	li	a3,0
    800064ec:	4601                	li	a2,0
    800064ee:	4589                	li	a1,2
    800064f0:	f5040513          	addi	a0,s0,-176
    800064f4:	00000097          	auipc	ra,0x0
    800064f8:	e46080e7          	jalr	-442(ra) # 8000633a <create>
    800064fc:	892a                	mv	s2,a0
    if(ip == 0){
    800064fe:	c959                	beqz	a0,80006594 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006500:	04491703          	lh	a4,68(s2)
    80006504:	478d                	li	a5,3
    80006506:	00f71763          	bne	a4,a5,80006514 <sys_open+0x74>
    8000650a:	04695703          	lhu	a4,70(s2)
    8000650e:	47a5                	li	a5,9
    80006510:	0ce7ec63          	bltu	a5,a4,800065e8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006514:	fffff097          	auipc	ra,0xfffff
    80006518:	ba4080e7          	jalr	-1116(ra) # 800050b8 <filealloc>
    8000651c:	89aa                	mv	s3,a0
    8000651e:	10050263          	beqz	a0,80006622 <sys_open+0x182>
    80006522:	00000097          	auipc	ra,0x0
    80006526:	8e2080e7          	jalr	-1822(ra) # 80005e04 <fdalloc>
    8000652a:	84aa                	mv	s1,a0
    8000652c:	0e054663          	bltz	a0,80006618 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006530:	04491703          	lh	a4,68(s2)
    80006534:	478d                	li	a5,3
    80006536:	0cf70463          	beq	a4,a5,800065fe <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000653a:	4789                	li	a5,2
    8000653c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006540:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006544:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006548:	f4c42783          	lw	a5,-180(s0)
    8000654c:	0017c713          	xori	a4,a5,1
    80006550:	8b05                	andi	a4,a4,1
    80006552:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006556:	0037f713          	andi	a4,a5,3
    8000655a:	00e03733          	snez	a4,a4
    8000655e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006562:	4007f793          	andi	a5,a5,1024
    80006566:	c791                	beqz	a5,80006572 <sys_open+0xd2>
    80006568:	04491703          	lh	a4,68(s2)
    8000656c:	4789                	li	a5,2
    8000656e:	08f70f63          	beq	a4,a5,8000660c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006572:	854a                	mv	a0,s2
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	b0e080e7          	jalr	-1266(ra) # 80004082 <iunlock>
  end_op();
    8000657c:	ffffe097          	auipc	ra,0xffffe
    80006580:	7ac080e7          	jalr	1964(ra) # 80004d28 <end_op>

  return fd;
}
    80006584:	8526                	mv	a0,s1
    80006586:	70ea                	ld	ra,184(sp)
    80006588:	744a                	ld	s0,176(sp)
    8000658a:	74aa                	ld	s1,168(sp)
    8000658c:	790a                	ld	s2,160(sp)
    8000658e:	69ea                	ld	s3,152(sp)
    80006590:	6129                	addi	sp,sp,192
    80006592:	8082                	ret
      end_op();
    80006594:	ffffe097          	auipc	ra,0xffffe
    80006598:	794080e7          	jalr	1940(ra) # 80004d28 <end_op>
      return -1;
    8000659c:	b7e5                	j	80006584 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000659e:	f5040513          	addi	a0,s0,-176
    800065a2:	ffffe097          	auipc	ra,0xffffe
    800065a6:	1d4080e7          	jalr	468(ra) # 80004776 <namei>
    800065aa:	892a                	mv	s2,a0
    800065ac:	c905                	beqz	a0,800065dc <sys_open+0x13c>
    ilock(ip);
    800065ae:	ffffe097          	auipc	ra,0xffffe
    800065b2:	a12080e7          	jalr	-1518(ra) # 80003fc0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800065b6:	04491703          	lh	a4,68(s2)
    800065ba:	4785                	li	a5,1
    800065bc:	f4f712e3          	bne	a4,a5,80006500 <sys_open+0x60>
    800065c0:	f4c42783          	lw	a5,-180(s0)
    800065c4:	dba1                	beqz	a5,80006514 <sys_open+0x74>
      iunlockput(ip);
    800065c6:	854a                	mv	a0,s2
    800065c8:	ffffe097          	auipc	ra,0xffffe
    800065cc:	c5a080e7          	jalr	-934(ra) # 80004222 <iunlockput>
      end_op();
    800065d0:	ffffe097          	auipc	ra,0xffffe
    800065d4:	758080e7          	jalr	1880(ra) # 80004d28 <end_op>
      return -1;
    800065d8:	54fd                	li	s1,-1
    800065da:	b76d                	j	80006584 <sys_open+0xe4>
      end_op();
    800065dc:	ffffe097          	auipc	ra,0xffffe
    800065e0:	74c080e7          	jalr	1868(ra) # 80004d28 <end_op>
      return -1;
    800065e4:	54fd                	li	s1,-1
    800065e6:	bf79                	j	80006584 <sys_open+0xe4>
    iunlockput(ip);
    800065e8:	854a                	mv	a0,s2
    800065ea:	ffffe097          	auipc	ra,0xffffe
    800065ee:	c38080e7          	jalr	-968(ra) # 80004222 <iunlockput>
    end_op();
    800065f2:	ffffe097          	auipc	ra,0xffffe
    800065f6:	736080e7          	jalr	1846(ra) # 80004d28 <end_op>
    return -1;
    800065fa:	54fd                	li	s1,-1
    800065fc:	b761                	j	80006584 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800065fe:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006602:	04691783          	lh	a5,70(s2)
    80006606:	02f99223          	sh	a5,36(s3)
    8000660a:	bf2d                	j	80006544 <sys_open+0xa4>
    itrunc(ip);
    8000660c:	854a                	mv	a0,s2
    8000660e:	ffffe097          	auipc	ra,0xffffe
    80006612:	ac0080e7          	jalr	-1344(ra) # 800040ce <itrunc>
    80006616:	bfb1                	j	80006572 <sys_open+0xd2>
      fileclose(f);
    80006618:	854e                	mv	a0,s3
    8000661a:	fffff097          	auipc	ra,0xfffff
    8000661e:	b5a080e7          	jalr	-1190(ra) # 80005174 <fileclose>
    iunlockput(ip);
    80006622:	854a                	mv	a0,s2
    80006624:	ffffe097          	auipc	ra,0xffffe
    80006628:	bfe080e7          	jalr	-1026(ra) # 80004222 <iunlockput>
    end_op();
    8000662c:	ffffe097          	auipc	ra,0xffffe
    80006630:	6fc080e7          	jalr	1788(ra) # 80004d28 <end_op>
    return -1;
    80006634:	54fd                	li	s1,-1
    80006636:	b7b9                	j	80006584 <sys_open+0xe4>

0000000080006638 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006638:	7175                	addi	sp,sp,-144
    8000663a:	e506                	sd	ra,136(sp)
    8000663c:	e122                	sd	s0,128(sp)
    8000663e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006640:	ffffe097          	auipc	ra,0xffffe
    80006644:	668080e7          	jalr	1640(ra) # 80004ca8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006648:	08000613          	li	a2,128
    8000664c:	f7040593          	addi	a1,s0,-144
    80006650:	4501                	li	a0,0
    80006652:	ffffd097          	auipc	ra,0xffffd
    80006656:	e40080e7          	jalr	-448(ra) # 80003492 <argstr>
    8000665a:	02054963          	bltz	a0,8000668c <sys_mkdir+0x54>
    8000665e:	4681                	li	a3,0
    80006660:	4601                	li	a2,0
    80006662:	4585                	li	a1,1
    80006664:	f7040513          	addi	a0,s0,-144
    80006668:	00000097          	auipc	ra,0x0
    8000666c:	cd2080e7          	jalr	-814(ra) # 8000633a <create>
    80006670:	cd11                	beqz	a0,8000668c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006672:	ffffe097          	auipc	ra,0xffffe
    80006676:	bb0080e7          	jalr	-1104(ra) # 80004222 <iunlockput>
  end_op();
    8000667a:	ffffe097          	auipc	ra,0xffffe
    8000667e:	6ae080e7          	jalr	1710(ra) # 80004d28 <end_op>
  return 0;
    80006682:	4501                	li	a0,0
}
    80006684:	60aa                	ld	ra,136(sp)
    80006686:	640a                	ld	s0,128(sp)
    80006688:	6149                	addi	sp,sp,144
    8000668a:	8082                	ret
    end_op();
    8000668c:	ffffe097          	auipc	ra,0xffffe
    80006690:	69c080e7          	jalr	1692(ra) # 80004d28 <end_op>
    return -1;
    80006694:	557d                	li	a0,-1
    80006696:	b7fd                	j	80006684 <sys_mkdir+0x4c>

0000000080006698 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006698:	7135                	addi	sp,sp,-160
    8000669a:	ed06                	sd	ra,152(sp)
    8000669c:	e922                	sd	s0,144(sp)
    8000669e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800066a0:	ffffe097          	auipc	ra,0xffffe
    800066a4:	608080e7          	jalr	1544(ra) # 80004ca8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066a8:	08000613          	li	a2,128
    800066ac:	f7040593          	addi	a1,s0,-144
    800066b0:	4501                	li	a0,0
    800066b2:	ffffd097          	auipc	ra,0xffffd
    800066b6:	de0080e7          	jalr	-544(ra) # 80003492 <argstr>
    800066ba:	04054a63          	bltz	a0,8000670e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800066be:	f6c40593          	addi	a1,s0,-148
    800066c2:	4505                	li	a0,1
    800066c4:	ffffd097          	auipc	ra,0xffffd
    800066c8:	d8a080e7          	jalr	-630(ra) # 8000344e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066cc:	04054163          	bltz	a0,8000670e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800066d0:	f6840593          	addi	a1,s0,-152
    800066d4:	4509                	li	a0,2
    800066d6:	ffffd097          	auipc	ra,0xffffd
    800066da:	d78080e7          	jalr	-648(ra) # 8000344e <argint>
     argint(1, &major) < 0 ||
    800066de:	02054863          	bltz	a0,8000670e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800066e2:	f6841683          	lh	a3,-152(s0)
    800066e6:	f6c41603          	lh	a2,-148(s0)
    800066ea:	458d                	li	a1,3
    800066ec:	f7040513          	addi	a0,s0,-144
    800066f0:	00000097          	auipc	ra,0x0
    800066f4:	c4a080e7          	jalr	-950(ra) # 8000633a <create>
     argint(2, &minor) < 0 ||
    800066f8:	c919                	beqz	a0,8000670e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066fa:	ffffe097          	auipc	ra,0xffffe
    800066fe:	b28080e7          	jalr	-1240(ra) # 80004222 <iunlockput>
  end_op();
    80006702:	ffffe097          	auipc	ra,0xffffe
    80006706:	626080e7          	jalr	1574(ra) # 80004d28 <end_op>
  return 0;
    8000670a:	4501                	li	a0,0
    8000670c:	a031                	j	80006718 <sys_mknod+0x80>
    end_op();
    8000670e:	ffffe097          	auipc	ra,0xffffe
    80006712:	61a080e7          	jalr	1562(ra) # 80004d28 <end_op>
    return -1;
    80006716:	557d                	li	a0,-1
}
    80006718:	60ea                	ld	ra,152(sp)
    8000671a:	644a                	ld	s0,144(sp)
    8000671c:	610d                	addi	sp,sp,160
    8000671e:	8082                	ret

0000000080006720 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006720:	7135                	addi	sp,sp,-160
    80006722:	ed06                	sd	ra,152(sp)
    80006724:	e922                	sd	s0,144(sp)
    80006726:	e526                	sd	s1,136(sp)
    80006728:	e14a                	sd	s2,128(sp)
    8000672a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000672c:	ffffb097          	auipc	ra,0xffffb
    80006730:	360080e7          	jalr	864(ra) # 80001a8c <myproc>
    80006734:	892a                	mv	s2,a0
  
  begin_op();
    80006736:	ffffe097          	auipc	ra,0xffffe
    8000673a:	572080e7          	jalr	1394(ra) # 80004ca8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000673e:	08000613          	li	a2,128
    80006742:	f6040593          	addi	a1,s0,-160
    80006746:	4501                	li	a0,0
    80006748:	ffffd097          	auipc	ra,0xffffd
    8000674c:	d4a080e7          	jalr	-694(ra) # 80003492 <argstr>
    80006750:	04054b63          	bltz	a0,800067a6 <sys_chdir+0x86>
    80006754:	f6040513          	addi	a0,s0,-160
    80006758:	ffffe097          	auipc	ra,0xffffe
    8000675c:	01e080e7          	jalr	30(ra) # 80004776 <namei>
    80006760:	84aa                	mv	s1,a0
    80006762:	c131                	beqz	a0,800067a6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006764:	ffffe097          	auipc	ra,0xffffe
    80006768:	85c080e7          	jalr	-1956(ra) # 80003fc0 <ilock>
  if(ip->type != T_DIR){
    8000676c:	04449703          	lh	a4,68(s1)
    80006770:	4785                	li	a5,1
    80006772:	04f71063          	bne	a4,a5,800067b2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006776:	8526                	mv	a0,s1
    80006778:	ffffe097          	auipc	ra,0xffffe
    8000677c:	90a080e7          	jalr	-1782(ra) # 80004082 <iunlock>
  iput(p->cwd);
    80006780:	15093503          	ld	a0,336(s2)
    80006784:	ffffe097          	auipc	ra,0xffffe
    80006788:	9f6080e7          	jalr	-1546(ra) # 8000417a <iput>
  end_op();
    8000678c:	ffffe097          	auipc	ra,0xffffe
    80006790:	59c080e7          	jalr	1436(ra) # 80004d28 <end_op>
  p->cwd = ip;
    80006794:	14993823          	sd	s1,336(s2)
  return 0;
    80006798:	4501                	li	a0,0
}
    8000679a:	60ea                	ld	ra,152(sp)
    8000679c:	644a                	ld	s0,144(sp)
    8000679e:	64aa                	ld	s1,136(sp)
    800067a0:	690a                	ld	s2,128(sp)
    800067a2:	610d                	addi	sp,sp,160
    800067a4:	8082                	ret
    end_op();
    800067a6:	ffffe097          	auipc	ra,0xffffe
    800067aa:	582080e7          	jalr	1410(ra) # 80004d28 <end_op>
    return -1;
    800067ae:	557d                	li	a0,-1
    800067b0:	b7ed                	j	8000679a <sys_chdir+0x7a>
    iunlockput(ip);
    800067b2:	8526                	mv	a0,s1
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	a6e080e7          	jalr	-1426(ra) # 80004222 <iunlockput>
    end_op();
    800067bc:	ffffe097          	auipc	ra,0xffffe
    800067c0:	56c080e7          	jalr	1388(ra) # 80004d28 <end_op>
    return -1;
    800067c4:	557d                	li	a0,-1
    800067c6:	bfd1                	j	8000679a <sys_chdir+0x7a>

00000000800067c8 <sys_exec>:

uint64
sys_exec(void)
{
    800067c8:	7145                	addi	sp,sp,-464
    800067ca:	e786                	sd	ra,456(sp)
    800067cc:	e3a2                	sd	s0,448(sp)
    800067ce:	ff26                	sd	s1,440(sp)
    800067d0:	fb4a                	sd	s2,432(sp)
    800067d2:	f74e                	sd	s3,424(sp)
    800067d4:	f352                	sd	s4,416(sp)
    800067d6:	ef56                	sd	s5,408(sp)
    800067d8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800067da:	08000613          	li	a2,128
    800067de:	f4040593          	addi	a1,s0,-192
    800067e2:	4501                	li	a0,0
    800067e4:	ffffd097          	auipc	ra,0xffffd
    800067e8:	cae080e7          	jalr	-850(ra) # 80003492 <argstr>
    return -1;
    800067ec:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800067ee:	0c054a63          	bltz	a0,800068c2 <sys_exec+0xfa>
    800067f2:	e3840593          	addi	a1,s0,-456
    800067f6:	4505                	li	a0,1
    800067f8:	ffffd097          	auipc	ra,0xffffd
    800067fc:	c78080e7          	jalr	-904(ra) # 80003470 <argaddr>
    80006800:	0c054163          	bltz	a0,800068c2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006804:	10000613          	li	a2,256
    80006808:	4581                	li	a1,0
    8000680a:	e4040513          	addi	a0,s0,-448
    8000680e:	ffffa097          	auipc	ra,0xffffa
    80006812:	4b0080e7          	jalr	1200(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006816:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000681a:	89a6                	mv	s3,s1
    8000681c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000681e:	02000a13          	li	s4,32
    80006822:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006826:	00391793          	slli	a5,s2,0x3
    8000682a:	e3040593          	addi	a1,s0,-464
    8000682e:	e3843503          	ld	a0,-456(s0)
    80006832:	953e                	add	a0,a0,a5
    80006834:	ffffd097          	auipc	ra,0xffffd
    80006838:	b80080e7          	jalr	-1152(ra) # 800033b4 <fetchaddr>
    8000683c:	02054a63          	bltz	a0,80006870 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006840:	e3043783          	ld	a5,-464(s0)
    80006844:	c3b9                	beqz	a5,8000688a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006846:	ffffa097          	auipc	ra,0xffffa
    8000684a:	28c080e7          	jalr	652(ra) # 80000ad2 <kalloc>
    8000684e:	85aa                	mv	a1,a0
    80006850:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006854:	cd11                	beqz	a0,80006870 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006856:	6605                	lui	a2,0x1
    80006858:	e3043503          	ld	a0,-464(s0)
    8000685c:	ffffd097          	auipc	ra,0xffffd
    80006860:	baa080e7          	jalr	-1110(ra) # 80003406 <fetchstr>
    80006864:	00054663          	bltz	a0,80006870 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006868:	0905                	addi	s2,s2,1
    8000686a:	09a1                	addi	s3,s3,8
    8000686c:	fb491be3          	bne	s2,s4,80006822 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006870:	10048913          	addi	s2,s1,256
    80006874:	6088                	ld	a0,0(s1)
    80006876:	c529                	beqz	a0,800068c0 <sys_exec+0xf8>
    kfree(argv[i]);
    80006878:	ffffa097          	auipc	ra,0xffffa
    8000687c:	15e080e7          	jalr	350(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006880:	04a1                	addi	s1,s1,8
    80006882:	ff2499e3          	bne	s1,s2,80006874 <sys_exec+0xac>
  return -1;
    80006886:	597d                	li	s2,-1
    80006888:	a82d                	j	800068c2 <sys_exec+0xfa>
      argv[i] = 0;
    8000688a:	0a8e                	slli	s5,s5,0x3
    8000688c:	fc040793          	addi	a5,s0,-64
    80006890:	9abe                	add	s5,s5,a5
    80006892:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffb9e80>
  int ret = exec(path, argv);
    80006896:	e4040593          	addi	a1,s0,-448
    8000689a:	f4040513          	addi	a0,s0,-192
    8000689e:	fffff097          	auipc	ra,0xfffff
    800068a2:	11e080e7          	jalr	286(ra) # 800059bc <exec>
    800068a6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068a8:	10048993          	addi	s3,s1,256
    800068ac:	6088                	ld	a0,0(s1)
    800068ae:	c911                	beqz	a0,800068c2 <sys_exec+0xfa>
    kfree(argv[i]);
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	126080e7          	jalr	294(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068b8:	04a1                	addi	s1,s1,8
    800068ba:	ff3499e3          	bne	s1,s3,800068ac <sys_exec+0xe4>
    800068be:	a011                	j	800068c2 <sys_exec+0xfa>
  return -1;
    800068c0:	597d                	li	s2,-1
}
    800068c2:	854a                	mv	a0,s2
    800068c4:	60be                	ld	ra,456(sp)
    800068c6:	641e                	ld	s0,448(sp)
    800068c8:	74fa                	ld	s1,440(sp)
    800068ca:	795a                	ld	s2,432(sp)
    800068cc:	79ba                	ld	s3,424(sp)
    800068ce:	7a1a                	ld	s4,416(sp)
    800068d0:	6afa                	ld	s5,408(sp)
    800068d2:	6179                	addi	sp,sp,464
    800068d4:	8082                	ret

00000000800068d6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800068d6:	7139                	addi	sp,sp,-64
    800068d8:	fc06                	sd	ra,56(sp)
    800068da:	f822                	sd	s0,48(sp)
    800068dc:	f426                	sd	s1,40(sp)
    800068de:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800068e0:	ffffb097          	auipc	ra,0xffffb
    800068e4:	1ac080e7          	jalr	428(ra) # 80001a8c <myproc>
    800068e8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800068ea:	fd840593          	addi	a1,s0,-40
    800068ee:	4501                	li	a0,0
    800068f0:	ffffd097          	auipc	ra,0xffffd
    800068f4:	b80080e7          	jalr	-1152(ra) # 80003470 <argaddr>
    return -1;
    800068f8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800068fa:	0e054063          	bltz	a0,800069da <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800068fe:	fc840593          	addi	a1,s0,-56
    80006902:	fd040513          	addi	a0,s0,-48
    80006906:	fffff097          	auipc	ra,0xfffff
    8000690a:	d94080e7          	jalr	-620(ra) # 8000569a <pipealloc>
    return -1;
    8000690e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006910:	0c054563          	bltz	a0,800069da <sys_pipe+0x104>
  fd0 = -1;
    80006914:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006918:	fd043503          	ld	a0,-48(s0)
    8000691c:	fffff097          	auipc	ra,0xfffff
    80006920:	4e8080e7          	jalr	1256(ra) # 80005e04 <fdalloc>
    80006924:	fca42223          	sw	a0,-60(s0)
    80006928:	08054c63          	bltz	a0,800069c0 <sys_pipe+0xea>
    8000692c:	fc843503          	ld	a0,-56(s0)
    80006930:	fffff097          	auipc	ra,0xfffff
    80006934:	4d4080e7          	jalr	1236(ra) # 80005e04 <fdalloc>
    80006938:	fca42023          	sw	a0,-64(s0)
    8000693c:	06054863          	bltz	a0,800069ac <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006940:	4691                	li	a3,4
    80006942:	fc440613          	addi	a2,s0,-60
    80006946:	fd843583          	ld	a1,-40(s0)
    8000694a:	68a8                	ld	a0,80(s1)
    8000694c:	ffffb097          	auipc	ra,0xffffb
    80006950:	dec080e7          	jalr	-532(ra) # 80001738 <copyout>
    80006954:	02054063          	bltz	a0,80006974 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006958:	4691                	li	a3,4
    8000695a:	fc040613          	addi	a2,s0,-64
    8000695e:	fd843583          	ld	a1,-40(s0)
    80006962:	0591                	addi	a1,a1,4
    80006964:	68a8                	ld	a0,80(s1)
    80006966:	ffffb097          	auipc	ra,0xffffb
    8000696a:	dd2080e7          	jalr	-558(ra) # 80001738 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000696e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006970:	06055563          	bgez	a0,800069da <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006974:	fc442783          	lw	a5,-60(s0)
    80006978:	07e9                	addi	a5,a5,26
    8000697a:	078e                	slli	a5,a5,0x3
    8000697c:	97a6                	add	a5,a5,s1
    8000697e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006982:	fc042503          	lw	a0,-64(s0)
    80006986:	0569                	addi	a0,a0,26
    80006988:	050e                	slli	a0,a0,0x3
    8000698a:	9526                	add	a0,a0,s1
    8000698c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006990:	fd043503          	ld	a0,-48(s0)
    80006994:	ffffe097          	auipc	ra,0xffffe
    80006998:	7e0080e7          	jalr	2016(ra) # 80005174 <fileclose>
    fileclose(wf);
    8000699c:	fc843503          	ld	a0,-56(s0)
    800069a0:	ffffe097          	auipc	ra,0xffffe
    800069a4:	7d4080e7          	jalr	2004(ra) # 80005174 <fileclose>
    return -1;
    800069a8:	57fd                	li	a5,-1
    800069aa:	a805                	j	800069da <sys_pipe+0x104>
    if(fd0 >= 0)
    800069ac:	fc442783          	lw	a5,-60(s0)
    800069b0:	0007c863          	bltz	a5,800069c0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800069b4:	01a78513          	addi	a0,a5,26
    800069b8:	050e                	slli	a0,a0,0x3
    800069ba:	9526                	add	a0,a0,s1
    800069bc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800069c0:	fd043503          	ld	a0,-48(s0)
    800069c4:	ffffe097          	auipc	ra,0xffffe
    800069c8:	7b0080e7          	jalr	1968(ra) # 80005174 <fileclose>
    fileclose(wf);
    800069cc:	fc843503          	ld	a0,-56(s0)
    800069d0:	ffffe097          	auipc	ra,0xffffe
    800069d4:	7a4080e7          	jalr	1956(ra) # 80005174 <fileclose>
    return -1;
    800069d8:	57fd                	li	a5,-1
}
    800069da:	853e                	mv	a0,a5
    800069dc:	70e2                	ld	ra,56(sp)
    800069de:	7442                	ld	s0,48(sp)
    800069e0:	74a2                	ld	s1,40(sp)
    800069e2:	6121                	addi	sp,sp,64
    800069e4:	8082                	ret
	...

00000000800069f0 <kernelvec>:
    800069f0:	7111                	addi	sp,sp,-256
    800069f2:	e006                	sd	ra,0(sp)
    800069f4:	e40a                	sd	sp,8(sp)
    800069f6:	e80e                	sd	gp,16(sp)
    800069f8:	ec12                	sd	tp,24(sp)
    800069fa:	f016                	sd	t0,32(sp)
    800069fc:	f41a                	sd	t1,40(sp)
    800069fe:	f81e                	sd	t2,48(sp)
    80006a00:	fc22                	sd	s0,56(sp)
    80006a02:	e0a6                	sd	s1,64(sp)
    80006a04:	e4aa                	sd	a0,72(sp)
    80006a06:	e8ae                	sd	a1,80(sp)
    80006a08:	ecb2                	sd	a2,88(sp)
    80006a0a:	f0b6                	sd	a3,96(sp)
    80006a0c:	f4ba                	sd	a4,104(sp)
    80006a0e:	f8be                	sd	a5,112(sp)
    80006a10:	fcc2                	sd	a6,120(sp)
    80006a12:	e146                	sd	a7,128(sp)
    80006a14:	e54a                	sd	s2,136(sp)
    80006a16:	e94e                	sd	s3,144(sp)
    80006a18:	ed52                	sd	s4,152(sp)
    80006a1a:	f156                	sd	s5,160(sp)
    80006a1c:	f55a                	sd	s6,168(sp)
    80006a1e:	f95e                	sd	s7,176(sp)
    80006a20:	fd62                	sd	s8,184(sp)
    80006a22:	e1e6                	sd	s9,192(sp)
    80006a24:	e5ea                	sd	s10,200(sp)
    80006a26:	e9ee                	sd	s11,208(sp)
    80006a28:	edf2                	sd	t3,216(sp)
    80006a2a:	f1f6                	sd	t4,224(sp)
    80006a2c:	f5fa                	sd	t5,232(sp)
    80006a2e:	f9fe                	sd	t6,240(sp)
    80006a30:	851fc0ef          	jal	ra,80003280 <kerneltrap>
    80006a34:	6082                	ld	ra,0(sp)
    80006a36:	6122                	ld	sp,8(sp)
    80006a38:	61c2                	ld	gp,16(sp)
    80006a3a:	7282                	ld	t0,32(sp)
    80006a3c:	7322                	ld	t1,40(sp)
    80006a3e:	73c2                	ld	t2,48(sp)
    80006a40:	7462                	ld	s0,56(sp)
    80006a42:	6486                	ld	s1,64(sp)
    80006a44:	6526                	ld	a0,72(sp)
    80006a46:	65c6                	ld	a1,80(sp)
    80006a48:	6666                	ld	a2,88(sp)
    80006a4a:	7686                	ld	a3,96(sp)
    80006a4c:	7726                	ld	a4,104(sp)
    80006a4e:	77c6                	ld	a5,112(sp)
    80006a50:	7866                	ld	a6,120(sp)
    80006a52:	688a                	ld	a7,128(sp)
    80006a54:	692a                	ld	s2,136(sp)
    80006a56:	69ca                	ld	s3,144(sp)
    80006a58:	6a6a                	ld	s4,152(sp)
    80006a5a:	7a8a                	ld	s5,160(sp)
    80006a5c:	7b2a                	ld	s6,168(sp)
    80006a5e:	7bca                	ld	s7,176(sp)
    80006a60:	7c6a                	ld	s8,184(sp)
    80006a62:	6c8e                	ld	s9,192(sp)
    80006a64:	6d2e                	ld	s10,200(sp)
    80006a66:	6dce                	ld	s11,208(sp)
    80006a68:	6e6e                	ld	t3,216(sp)
    80006a6a:	7e8e                	ld	t4,224(sp)
    80006a6c:	7f2e                	ld	t5,232(sp)
    80006a6e:	7fce                	ld	t6,240(sp)
    80006a70:	6111                	addi	sp,sp,256
    80006a72:	10200073          	sret
    80006a76:	00000013          	nop
    80006a7a:	00000013          	nop
    80006a7e:	0001                	nop

0000000080006a80 <timervec>:
    80006a80:	34051573          	csrrw	a0,mscratch,a0
    80006a84:	e10c                	sd	a1,0(a0)
    80006a86:	e510                	sd	a2,8(a0)
    80006a88:	e914                	sd	a3,16(a0)
    80006a8a:	6d0c                	ld	a1,24(a0)
    80006a8c:	7110                	ld	a2,32(a0)
    80006a8e:	6194                	ld	a3,0(a1)
    80006a90:	96b2                	add	a3,a3,a2
    80006a92:	e194                	sd	a3,0(a1)
    80006a94:	4589                	li	a1,2
    80006a96:	14459073          	csrw	sip,a1
    80006a9a:	6914                	ld	a3,16(a0)
    80006a9c:	6510                	ld	a2,8(a0)
    80006a9e:	610c                	ld	a1,0(a0)
    80006aa0:	34051573          	csrrw	a0,mscratch,a0
    80006aa4:	30200073          	mret
	...

0000000080006aaa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006aaa:	1141                	addi	sp,sp,-16
    80006aac:	e422                	sd	s0,8(sp)
    80006aae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006ab0:	0c0007b7          	lui	a5,0xc000
    80006ab4:	4705                	li	a4,1
    80006ab6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006ab8:	c3d8                	sw	a4,4(a5)
}
    80006aba:	6422                	ld	s0,8(sp)
    80006abc:	0141                	addi	sp,sp,16
    80006abe:	8082                	ret

0000000080006ac0 <plicinithart>:

void
plicinithart(void)
{
    80006ac0:	1141                	addi	sp,sp,-16
    80006ac2:	e406                	sd	ra,8(sp)
    80006ac4:	e022                	sd	s0,0(sp)
    80006ac6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ac8:	ffffb097          	auipc	ra,0xffffb
    80006acc:	f98080e7          	jalr	-104(ra) # 80001a60 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006ad0:	0085171b          	slliw	a4,a0,0x8
    80006ad4:	0c0027b7          	lui	a5,0xc002
    80006ad8:	97ba                	add	a5,a5,a4
    80006ada:	40200713          	li	a4,1026
    80006ade:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006ae2:	00d5151b          	slliw	a0,a0,0xd
    80006ae6:	0c2017b7          	lui	a5,0xc201
    80006aea:	953e                	add	a0,a0,a5
    80006aec:	00052023          	sw	zero,0(a0)
}
    80006af0:	60a2                	ld	ra,8(sp)
    80006af2:	6402                	ld	s0,0(sp)
    80006af4:	0141                	addi	sp,sp,16
    80006af6:	8082                	ret

0000000080006af8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006af8:	1141                	addi	sp,sp,-16
    80006afa:	e406                	sd	ra,8(sp)
    80006afc:	e022                	sd	s0,0(sp)
    80006afe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006b00:	ffffb097          	auipc	ra,0xffffb
    80006b04:	f60080e7          	jalr	-160(ra) # 80001a60 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006b08:	00d5179b          	slliw	a5,a0,0xd
    80006b0c:	0c201537          	lui	a0,0xc201
    80006b10:	953e                	add	a0,a0,a5
  return irq;
}
    80006b12:	4148                	lw	a0,4(a0)
    80006b14:	60a2                	ld	ra,8(sp)
    80006b16:	6402                	ld	s0,0(sp)
    80006b18:	0141                	addi	sp,sp,16
    80006b1a:	8082                	ret

0000000080006b1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006b1c:	1101                	addi	sp,sp,-32
    80006b1e:	ec06                	sd	ra,24(sp)
    80006b20:	e822                	sd	s0,16(sp)
    80006b22:	e426                	sd	s1,8(sp)
    80006b24:	1000                	addi	s0,sp,32
    80006b26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006b28:	ffffb097          	auipc	ra,0xffffb
    80006b2c:	f38080e7          	jalr	-200(ra) # 80001a60 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006b30:	00d5151b          	slliw	a0,a0,0xd
    80006b34:	0c2017b7          	lui	a5,0xc201
    80006b38:	97aa                	add	a5,a5,a0
    80006b3a:	c3c4                	sw	s1,4(a5)
}
    80006b3c:	60e2                	ld	ra,24(sp)
    80006b3e:	6442                	ld	s0,16(sp)
    80006b40:	64a2                	ld	s1,8(sp)
    80006b42:	6105                	addi	sp,sp,32
    80006b44:	8082                	ret

0000000080006b46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006b46:	1141                	addi	sp,sp,-16
    80006b48:	e406                	sd	ra,8(sp)
    80006b4a:	e022                	sd	s0,0(sp)
    80006b4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006b4e:	479d                	li	a5,7
    80006b50:	06a7c963          	blt	a5,a0,80006bc2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006b54:	0003b797          	auipc	a5,0x3b
    80006b58:	4ac78793          	addi	a5,a5,1196 # 80042000 <disk>
    80006b5c:	00a78733          	add	a4,a5,a0
    80006b60:	6789                	lui	a5,0x2
    80006b62:	97ba                	add	a5,a5,a4
    80006b64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006b68:	e7ad                	bnez	a5,80006bd2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006b6a:	00451793          	slli	a5,a0,0x4
    80006b6e:	0003d717          	auipc	a4,0x3d
    80006b72:	49270713          	addi	a4,a4,1170 # 80044000 <disk+0x2000>
    80006b76:	6314                	ld	a3,0(a4)
    80006b78:	96be                	add	a3,a3,a5
    80006b7a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006b7e:	6314                	ld	a3,0(a4)
    80006b80:	96be                	add	a3,a3,a5
    80006b82:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006b86:	6314                	ld	a3,0(a4)
    80006b88:	96be                	add	a3,a3,a5
    80006b8a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006b8e:	6318                	ld	a4,0(a4)
    80006b90:	97ba                	add	a5,a5,a4
    80006b92:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006b96:	0003b797          	auipc	a5,0x3b
    80006b9a:	46a78793          	addi	a5,a5,1130 # 80042000 <disk>
    80006b9e:	97aa                	add	a5,a5,a0
    80006ba0:	6509                	lui	a0,0x2
    80006ba2:	953e                	add	a0,a0,a5
    80006ba4:	4785                	li	a5,1
    80006ba6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006baa:	0003d517          	auipc	a0,0x3d
    80006bae:	46e50513          	addi	a0,a0,1134 # 80044018 <disk+0x2018>
    80006bb2:	ffffb097          	auipc	ra,0xffffb
    80006bb6:	2e0080e7          	jalr	736(ra) # 80001e92 <wakeup>
}
    80006bba:	60a2                	ld	ra,8(sp)
    80006bbc:	6402                	ld	s0,0(sp)
    80006bbe:	0141                	addi	sp,sp,16
    80006bc0:	8082                	ret
    panic("free_desc 1");
    80006bc2:	00003517          	auipc	a0,0x3
    80006bc6:	f2e50513          	addi	a0,a0,-210 # 80009af0 <syscalls+0x358>
    80006bca:	ffffa097          	auipc	ra,0xffffa
    80006bce:	960080e7          	jalr	-1696(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006bd2:	00003517          	auipc	a0,0x3
    80006bd6:	f2e50513          	addi	a0,a0,-210 # 80009b00 <syscalls+0x368>
    80006bda:	ffffa097          	auipc	ra,0xffffa
    80006bde:	950080e7          	jalr	-1712(ra) # 8000052a <panic>

0000000080006be2 <virtio_disk_init>:
{
    80006be2:	1101                	addi	sp,sp,-32
    80006be4:	ec06                	sd	ra,24(sp)
    80006be6:	e822                	sd	s0,16(sp)
    80006be8:	e426                	sd	s1,8(sp)
    80006bea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006bec:	00003597          	auipc	a1,0x3
    80006bf0:	f2458593          	addi	a1,a1,-220 # 80009b10 <syscalls+0x378>
    80006bf4:	0003d517          	auipc	a0,0x3d
    80006bf8:	53450513          	addi	a0,a0,1332 # 80044128 <disk+0x2128>
    80006bfc:	ffffa097          	auipc	ra,0xffffa
    80006c00:	f36080e7          	jalr	-202(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c04:	100017b7          	lui	a5,0x10001
    80006c08:	4398                	lw	a4,0(a5)
    80006c0a:	2701                	sext.w	a4,a4
    80006c0c:	747277b7          	lui	a5,0x74727
    80006c10:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006c14:	0ef71163          	bne	a4,a5,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006c18:	100017b7          	lui	a5,0x10001
    80006c1c:	43dc                	lw	a5,4(a5)
    80006c1e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006c20:	4705                	li	a4,1
    80006c22:	0ce79a63          	bne	a5,a4,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c26:	100017b7          	lui	a5,0x10001
    80006c2a:	479c                	lw	a5,8(a5)
    80006c2c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006c2e:	4709                	li	a4,2
    80006c30:	0ce79363          	bne	a5,a4,80006cf6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006c34:	100017b7          	lui	a5,0x10001
    80006c38:	47d8                	lw	a4,12(a5)
    80006c3a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006c3c:	554d47b7          	lui	a5,0x554d4
    80006c40:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006c44:	0af71963          	bne	a4,a5,80006cf6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c48:	100017b7          	lui	a5,0x10001
    80006c4c:	4705                	li	a4,1
    80006c4e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c50:	470d                	li	a4,3
    80006c52:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006c54:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006c56:	c7ffe737          	lui	a4,0xc7ffe
    80006c5a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb975f>
    80006c5e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006c60:	2701                	sext.w	a4,a4
    80006c62:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c64:	472d                	li	a4,11
    80006c66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006c68:	473d                	li	a4,15
    80006c6a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006c6c:	6705                	lui	a4,0x1
    80006c6e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006c70:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006c74:	5bdc                	lw	a5,52(a5)
    80006c76:	2781                	sext.w	a5,a5
  if(max == 0)
    80006c78:	c7d9                	beqz	a5,80006d06 <virtio_disk_init+0x124>
  if(max < NUM)
    80006c7a:	471d                	li	a4,7
    80006c7c:	08f77d63          	bgeu	a4,a5,80006d16 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006c80:	100014b7          	lui	s1,0x10001
    80006c84:	47a1                	li	a5,8
    80006c86:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006c88:	6609                	lui	a2,0x2
    80006c8a:	4581                	li	a1,0
    80006c8c:	0003b517          	auipc	a0,0x3b
    80006c90:	37450513          	addi	a0,a0,884 # 80042000 <disk>
    80006c94:	ffffa097          	auipc	ra,0xffffa
    80006c98:	02a080e7          	jalr	42(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006c9c:	0003b717          	auipc	a4,0x3b
    80006ca0:	36470713          	addi	a4,a4,868 # 80042000 <disk>
    80006ca4:	00c75793          	srli	a5,a4,0xc
    80006ca8:	2781                	sext.w	a5,a5
    80006caa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006cac:	0003d797          	auipc	a5,0x3d
    80006cb0:	35478793          	addi	a5,a5,852 # 80044000 <disk+0x2000>
    80006cb4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006cb6:	0003b717          	auipc	a4,0x3b
    80006cba:	3ca70713          	addi	a4,a4,970 # 80042080 <disk+0x80>
    80006cbe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006cc0:	0003c717          	auipc	a4,0x3c
    80006cc4:	34070713          	addi	a4,a4,832 # 80043000 <disk+0x1000>
    80006cc8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006cca:	4705                	li	a4,1
    80006ccc:	00e78c23          	sb	a4,24(a5)
    80006cd0:	00e78ca3          	sb	a4,25(a5)
    80006cd4:	00e78d23          	sb	a4,26(a5)
    80006cd8:	00e78da3          	sb	a4,27(a5)
    80006cdc:	00e78e23          	sb	a4,28(a5)
    80006ce0:	00e78ea3          	sb	a4,29(a5)
    80006ce4:	00e78f23          	sb	a4,30(a5)
    80006ce8:	00e78fa3          	sb	a4,31(a5)
}
    80006cec:	60e2                	ld	ra,24(sp)
    80006cee:	6442                	ld	s0,16(sp)
    80006cf0:	64a2                	ld	s1,8(sp)
    80006cf2:	6105                	addi	sp,sp,32
    80006cf4:	8082                	ret
    panic("could not find virtio disk");
    80006cf6:	00003517          	auipc	a0,0x3
    80006cfa:	e2a50513          	addi	a0,a0,-470 # 80009b20 <syscalls+0x388>
    80006cfe:	ffffa097          	auipc	ra,0xffffa
    80006d02:	82c080e7          	jalr	-2004(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006d06:	00003517          	auipc	a0,0x3
    80006d0a:	e3a50513          	addi	a0,a0,-454 # 80009b40 <syscalls+0x3a8>
    80006d0e:	ffffa097          	auipc	ra,0xffffa
    80006d12:	81c080e7          	jalr	-2020(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006d16:	00003517          	auipc	a0,0x3
    80006d1a:	e4a50513          	addi	a0,a0,-438 # 80009b60 <syscalls+0x3c8>
    80006d1e:	ffffa097          	auipc	ra,0xffffa
    80006d22:	80c080e7          	jalr	-2036(ra) # 8000052a <panic>

0000000080006d26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006d26:	7119                	addi	sp,sp,-128
    80006d28:	fc86                	sd	ra,120(sp)
    80006d2a:	f8a2                	sd	s0,112(sp)
    80006d2c:	f4a6                	sd	s1,104(sp)
    80006d2e:	f0ca                	sd	s2,96(sp)
    80006d30:	ecce                	sd	s3,88(sp)
    80006d32:	e8d2                	sd	s4,80(sp)
    80006d34:	e4d6                	sd	s5,72(sp)
    80006d36:	e0da                	sd	s6,64(sp)
    80006d38:	fc5e                	sd	s7,56(sp)
    80006d3a:	f862                	sd	s8,48(sp)
    80006d3c:	f466                	sd	s9,40(sp)
    80006d3e:	f06a                	sd	s10,32(sp)
    80006d40:	ec6e                	sd	s11,24(sp)
    80006d42:	0100                	addi	s0,sp,128
    80006d44:	8aaa                	mv	s5,a0
    80006d46:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006d48:	00c52c83          	lw	s9,12(a0)
    80006d4c:	001c9c9b          	slliw	s9,s9,0x1
    80006d50:	1c82                	slli	s9,s9,0x20
    80006d52:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006d56:	0003d517          	auipc	a0,0x3d
    80006d5a:	3d250513          	addi	a0,a0,978 # 80044128 <disk+0x2128>
    80006d5e:	ffffa097          	auipc	ra,0xffffa
    80006d62:	e64080e7          	jalr	-412(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006d66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006d68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006d6a:	0003bc17          	auipc	s8,0x3b
    80006d6e:	296c0c13          	addi	s8,s8,662 # 80042000 <disk>
    80006d72:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006d74:	4b0d                	li	s6,3
    80006d76:	a0ad                	j	80006de0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006d78:	00fc0733          	add	a4,s8,a5
    80006d7c:	975e                	add	a4,a4,s7
    80006d7e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006d82:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006d84:	0207c563          	bltz	a5,80006dae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006d88:	2905                	addiw	s2,s2,1
    80006d8a:	0611                	addi	a2,a2,4
    80006d8c:	19690d63          	beq	s2,s6,80006f26 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006d90:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006d92:	0003d717          	auipc	a4,0x3d
    80006d96:	28670713          	addi	a4,a4,646 # 80044018 <disk+0x2018>
    80006d9a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006d9c:	00074683          	lbu	a3,0(a4)
    80006da0:	fee1                	bnez	a3,80006d78 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006da2:	2785                	addiw	a5,a5,1
    80006da4:	0705                	addi	a4,a4,1
    80006da6:	fe979be3          	bne	a5,s1,80006d9c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006daa:	57fd                	li	a5,-1
    80006dac:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006dae:	01205d63          	blez	s2,80006dc8 <virtio_disk_rw+0xa2>
    80006db2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006db4:	000a2503          	lw	a0,0(s4)
    80006db8:	00000097          	auipc	ra,0x0
    80006dbc:	d8e080e7          	jalr	-626(ra) # 80006b46 <free_desc>
      for(int j = 0; j < i; j++)
    80006dc0:	2d85                	addiw	s11,s11,1
    80006dc2:	0a11                	addi	s4,s4,4
    80006dc4:	ffb918e3          	bne	s2,s11,80006db4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006dc8:	0003d597          	auipc	a1,0x3d
    80006dcc:	36058593          	addi	a1,a1,864 # 80044128 <disk+0x2128>
    80006dd0:	0003d517          	auipc	a0,0x3d
    80006dd4:	24850513          	addi	a0,a0,584 # 80044018 <disk+0x2018>
    80006dd8:	ffffb097          	auipc	ra,0xffffb
    80006ddc:	056080e7          	jalr	86(ra) # 80001e2e <sleep>
  for(int i = 0; i < 3; i++){
    80006de0:	f8040a13          	addi	s4,s0,-128
{
    80006de4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006de6:	894e                	mv	s2,s3
    80006de8:	b765                	j	80006d90 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006dea:	0003d697          	auipc	a3,0x3d
    80006dee:	2166b683          	ld	a3,534(a3) # 80044000 <disk+0x2000>
    80006df2:	96ba                	add	a3,a3,a4
    80006df4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006df8:	0003b817          	auipc	a6,0x3b
    80006dfc:	20880813          	addi	a6,a6,520 # 80042000 <disk>
    80006e00:	0003d697          	auipc	a3,0x3d
    80006e04:	20068693          	addi	a3,a3,512 # 80044000 <disk+0x2000>
    80006e08:	6290                	ld	a2,0(a3)
    80006e0a:	963a                	add	a2,a2,a4
    80006e0c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006e10:	0015e593          	ori	a1,a1,1
    80006e14:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006e18:	f8842603          	lw	a2,-120(s0)
    80006e1c:	628c                	ld	a1,0(a3)
    80006e1e:	972e                	add	a4,a4,a1
    80006e20:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006e24:	20050593          	addi	a1,a0,512
    80006e28:	0592                	slli	a1,a1,0x4
    80006e2a:	95c2                	add	a1,a1,a6
    80006e2c:	577d                	li	a4,-1
    80006e2e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006e32:	00461713          	slli	a4,a2,0x4
    80006e36:	6290                	ld	a2,0(a3)
    80006e38:	963a                	add	a2,a2,a4
    80006e3a:	03078793          	addi	a5,a5,48
    80006e3e:	97c2                	add	a5,a5,a6
    80006e40:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006e42:	629c                	ld	a5,0(a3)
    80006e44:	97ba                	add	a5,a5,a4
    80006e46:	4605                	li	a2,1
    80006e48:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006e4a:	629c                	ld	a5,0(a3)
    80006e4c:	97ba                	add	a5,a5,a4
    80006e4e:	4809                	li	a6,2
    80006e50:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006e54:	629c                	ld	a5,0(a3)
    80006e56:	973e                	add	a4,a4,a5
    80006e58:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006e5c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006e60:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006e64:	6698                	ld	a4,8(a3)
    80006e66:	00275783          	lhu	a5,2(a4)
    80006e6a:	8b9d                	andi	a5,a5,7
    80006e6c:	0786                	slli	a5,a5,0x1
    80006e6e:	97ba                	add	a5,a5,a4
    80006e70:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006e74:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006e78:	6698                	ld	a4,8(a3)
    80006e7a:	00275783          	lhu	a5,2(a4)
    80006e7e:	2785                	addiw	a5,a5,1
    80006e80:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006e84:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006e88:	100017b7          	lui	a5,0x10001
    80006e8c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006e90:	004aa783          	lw	a5,4(s5)
    80006e94:	02c79163          	bne	a5,a2,80006eb6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006e98:	0003d917          	auipc	s2,0x3d
    80006e9c:	29090913          	addi	s2,s2,656 # 80044128 <disk+0x2128>
  while(b->disk == 1) {
    80006ea0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006ea2:	85ca                	mv	a1,s2
    80006ea4:	8556                	mv	a0,s5
    80006ea6:	ffffb097          	auipc	ra,0xffffb
    80006eaa:	f88080e7          	jalr	-120(ra) # 80001e2e <sleep>
  while(b->disk == 1) {
    80006eae:	004aa783          	lw	a5,4(s5)
    80006eb2:	fe9788e3          	beq	a5,s1,80006ea2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006eb6:	f8042903          	lw	s2,-128(s0)
    80006eba:	20090793          	addi	a5,s2,512
    80006ebe:	00479713          	slli	a4,a5,0x4
    80006ec2:	0003b797          	auipc	a5,0x3b
    80006ec6:	13e78793          	addi	a5,a5,318 # 80042000 <disk>
    80006eca:	97ba                	add	a5,a5,a4
    80006ecc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006ed0:	0003d997          	auipc	s3,0x3d
    80006ed4:	13098993          	addi	s3,s3,304 # 80044000 <disk+0x2000>
    80006ed8:	00491713          	slli	a4,s2,0x4
    80006edc:	0009b783          	ld	a5,0(s3)
    80006ee0:	97ba                	add	a5,a5,a4
    80006ee2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ee6:	854a                	mv	a0,s2
    80006ee8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006eec:	00000097          	auipc	ra,0x0
    80006ef0:	c5a080e7          	jalr	-934(ra) # 80006b46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006ef4:	8885                	andi	s1,s1,1
    80006ef6:	f0ed                	bnez	s1,80006ed8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006ef8:	0003d517          	auipc	a0,0x3d
    80006efc:	23050513          	addi	a0,a0,560 # 80044128 <disk+0x2128>
    80006f00:	ffffa097          	auipc	ra,0xffffa
    80006f04:	d76080e7          	jalr	-650(ra) # 80000c76 <release>
}
    80006f08:	70e6                	ld	ra,120(sp)
    80006f0a:	7446                	ld	s0,112(sp)
    80006f0c:	74a6                	ld	s1,104(sp)
    80006f0e:	7906                	ld	s2,96(sp)
    80006f10:	69e6                	ld	s3,88(sp)
    80006f12:	6a46                	ld	s4,80(sp)
    80006f14:	6aa6                	ld	s5,72(sp)
    80006f16:	6b06                	ld	s6,64(sp)
    80006f18:	7be2                	ld	s7,56(sp)
    80006f1a:	7c42                	ld	s8,48(sp)
    80006f1c:	7ca2                	ld	s9,40(sp)
    80006f1e:	7d02                	ld	s10,32(sp)
    80006f20:	6de2                	ld	s11,24(sp)
    80006f22:	6109                	addi	sp,sp,128
    80006f24:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006f26:	f8042503          	lw	a0,-128(s0)
    80006f2a:	20050793          	addi	a5,a0,512
    80006f2e:	0792                	slli	a5,a5,0x4
  if(write)
    80006f30:	0003b817          	auipc	a6,0x3b
    80006f34:	0d080813          	addi	a6,a6,208 # 80042000 <disk>
    80006f38:	00f80733          	add	a4,a6,a5
    80006f3c:	01a036b3          	snez	a3,s10
    80006f40:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006f44:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006f48:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f4c:	7679                	lui	a2,0xffffe
    80006f4e:	963e                	add	a2,a2,a5
    80006f50:	0003d697          	auipc	a3,0x3d
    80006f54:	0b068693          	addi	a3,a3,176 # 80044000 <disk+0x2000>
    80006f58:	6298                	ld	a4,0(a3)
    80006f5a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006f5c:	0a878593          	addi	a1,a5,168
    80006f60:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006f62:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006f64:	6298                	ld	a4,0(a3)
    80006f66:	9732                	add	a4,a4,a2
    80006f68:	45c1                	li	a1,16
    80006f6a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006f6c:	6298                	ld	a4,0(a3)
    80006f6e:	9732                	add	a4,a4,a2
    80006f70:	4585                	li	a1,1
    80006f72:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006f76:	f8442703          	lw	a4,-124(s0)
    80006f7a:	628c                	ld	a1,0(a3)
    80006f7c:	962e                	add	a2,a2,a1
    80006f7e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffb900e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006f82:	0712                	slli	a4,a4,0x4
    80006f84:	6290                	ld	a2,0(a3)
    80006f86:	963a                	add	a2,a2,a4
    80006f88:	058a8593          	addi	a1,s5,88
    80006f8c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006f8e:	6294                	ld	a3,0(a3)
    80006f90:	96ba                	add	a3,a3,a4
    80006f92:	40000613          	li	a2,1024
    80006f96:	c690                	sw	a2,8(a3)
  if(write)
    80006f98:	e40d19e3          	bnez	s10,80006dea <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006f9c:	0003d697          	auipc	a3,0x3d
    80006fa0:	0646b683          	ld	a3,100(a3) # 80044000 <disk+0x2000>
    80006fa4:	96ba                	add	a3,a3,a4
    80006fa6:	4609                	li	a2,2
    80006fa8:	00c69623          	sh	a2,12(a3)
    80006fac:	b5b1                	j	80006df8 <virtio_disk_rw+0xd2>

0000000080006fae <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006fae:	1101                	addi	sp,sp,-32
    80006fb0:	ec06                	sd	ra,24(sp)
    80006fb2:	e822                	sd	s0,16(sp)
    80006fb4:	e426                	sd	s1,8(sp)
    80006fb6:	e04a                	sd	s2,0(sp)
    80006fb8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006fba:	0003d517          	auipc	a0,0x3d
    80006fbe:	16e50513          	addi	a0,a0,366 # 80044128 <disk+0x2128>
    80006fc2:	ffffa097          	auipc	ra,0xffffa
    80006fc6:	c00080e7          	jalr	-1024(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006fca:	10001737          	lui	a4,0x10001
    80006fce:	533c                	lw	a5,96(a4)
    80006fd0:	8b8d                	andi	a5,a5,3
    80006fd2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006fd4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006fd8:	0003d797          	auipc	a5,0x3d
    80006fdc:	02878793          	addi	a5,a5,40 # 80044000 <disk+0x2000>
    80006fe0:	6b94                	ld	a3,16(a5)
    80006fe2:	0207d703          	lhu	a4,32(a5)
    80006fe6:	0026d783          	lhu	a5,2(a3)
    80006fea:	06f70163          	beq	a4,a5,8000704c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006fee:	0003b917          	auipc	s2,0x3b
    80006ff2:	01290913          	addi	s2,s2,18 # 80042000 <disk>
    80006ff6:	0003d497          	auipc	s1,0x3d
    80006ffa:	00a48493          	addi	s1,s1,10 # 80044000 <disk+0x2000>
    __sync_synchronize();
    80006ffe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007002:	6898                	ld	a4,16(s1)
    80007004:	0204d783          	lhu	a5,32(s1)
    80007008:	8b9d                	andi	a5,a5,7
    8000700a:	078e                	slli	a5,a5,0x3
    8000700c:	97ba                	add	a5,a5,a4
    8000700e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007010:	20078713          	addi	a4,a5,512
    80007014:	0712                	slli	a4,a4,0x4
    80007016:	974a                	add	a4,a4,s2
    80007018:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000701c:	e731                	bnez	a4,80007068 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000701e:	20078793          	addi	a5,a5,512
    80007022:	0792                	slli	a5,a5,0x4
    80007024:	97ca                	add	a5,a5,s2
    80007026:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007028:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000702c:	ffffb097          	auipc	ra,0xffffb
    80007030:	e66080e7          	jalr	-410(ra) # 80001e92 <wakeup>

    disk.used_idx += 1;
    80007034:	0204d783          	lhu	a5,32(s1)
    80007038:	2785                	addiw	a5,a5,1
    8000703a:	17c2                	slli	a5,a5,0x30
    8000703c:	93c1                	srli	a5,a5,0x30
    8000703e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007042:	6898                	ld	a4,16(s1)
    80007044:	00275703          	lhu	a4,2(a4)
    80007048:	faf71be3          	bne	a4,a5,80006ffe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000704c:	0003d517          	auipc	a0,0x3d
    80007050:	0dc50513          	addi	a0,a0,220 # 80044128 <disk+0x2128>
    80007054:	ffffa097          	auipc	ra,0xffffa
    80007058:	c22080e7          	jalr	-990(ra) # 80000c76 <release>
}
    8000705c:	60e2                	ld	ra,24(sp)
    8000705e:	6442                	ld	s0,16(sp)
    80007060:	64a2                	ld	s1,8(sp)
    80007062:	6902                	ld	s2,0(sp)
    80007064:	6105                	addi	sp,sp,32
    80007066:	8082                	ret
      panic("virtio_disk_intr status");
    80007068:	00003517          	auipc	a0,0x3
    8000706c:	b1850513          	addi	a0,a0,-1256 # 80009b80 <syscalls+0x3e8>
    80007070:	ffff9097          	auipc	ra,0xffff9
    80007074:	4ba080e7          	jalr	1210(ra) # 8000052a <panic>
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
