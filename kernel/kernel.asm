
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
    80000068:	c3c78793          	addi	a5,a5,-964 # 80006ca0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbe7ff>
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
    80000122:	10a080e7          	jalr	266(ra) # 80002228 <either_copyin>
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
    800001b6:	9b6080e7          	jalr	-1610(ra) # 80001b68 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	d7e080e7          	jalr	-642(ra) # 80001f40 <sleep>
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
    80000202:	fd4080e7          	jalr	-44(ra) # 800021d2 <either_copyout>
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
    800002e2:	fa0080e7          	jalr	-96(ra) # 8000227e <procdump>
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
    80000436:	b72080e7          	jalr	-1166(ra) # 80001fa4 <wakeup>
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
    80000464:	0003b797          	auipc	a5,0x3b
    80000468:	2b478793          	addi	a5,a5,692 # 8003b718 <devsw>
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
    8000055c:	ed050513          	addi	a0,a0,-304 # 80009428 <digits+0x3e8>
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
    80000882:	726080e7          	jalr	1830(ra) # 80001fa4 <wakeup>
    
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
    8000090e:	636080e7          	jalr	1590(ra) # 80001f40 <sleep>
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
    800009ea:	0003f797          	auipc	a5,0x3f
    800009ee:	61678793          	addi	a5,a5,1558 # 80040000 <end>
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
    80000aba:	0003f517          	auipc	a0,0x3f
    80000abe:	54650513          	addi	a0,a0,1350 # 80040000 <end>
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
    80000b60:	ff0080e7          	jalr	-16(ra) # 80001b4c <mycpu>
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
    80000b92:	fbe080e7          	jalr	-66(ra) # 80001b4c <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	fb2080e7          	jalr	-78(ra) # 80001b4c <mycpu>
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
    80000bb6:	f9a080e7          	jalr	-102(ra) # 80001b4c <mycpu>
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
    80000bf6:	f5a080e7          	jalr	-166(ra) # 80001b4c <mycpu>
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
    80000c22:	f2e080e7          	jalr	-210(ra) # 80001b4c <mycpu>
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
    80000e78:	cc8080e7          	jalr	-824(ra) # 80001b3c <cpuid>
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
    80000e94:	cac080e7          	jalr	-852(ra) # 80001b3c <cpuid>
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
    80000eb6:	152080e7          	jalr	338(ra) # 80003004 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	e26080e7          	jalr	-474(ra) # 80006ce0 <plicinithart>
  }
  scheduler();
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	ecc080e7          	jalr	-308(ra) # 80001d8e <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	54e50513          	addi	a0,a0,1358 # 80009428 <digits+0x3e8>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	52e50513          	addi	a0,a0,1326 # 80009428 <digits+0x3e8>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	36c080e7          	jalr	876(ra) # 8000127e <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	b6a080e7          	jalr	-1174(ra) # 80001a8c <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	0b2080e7          	jalr	178(ra) # 80002fdc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	0d2080e7          	jalr	210(ra) # 80003004 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	d90080e7          	jalr	-624(ra) # 80006cca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	d9e080e7          	jalr	-610(ra) # 80006ce0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	848080e7          	jalr	-1976(ra) # 80003792 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	eda080e7          	jalr	-294(ra) # 80003e2c <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	19a080e7          	jalr	410(ra) # 800050f4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	ea0080e7          	jalr	-352(ra) # 80006e02 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	700080e7          	jalr	1792(ra) # 8000266a <userinit>
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
    80000fbe:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4af9                	li	s5,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4a09                	li	s4,2
  if(va >= MAXVA)
    80000fc8:	04b7f363          	bgeu	a5,a1,8000100e <walk+0x68>
    panic("walk");
    80000fcc:	00008517          	auipc	a0,0x8
    80000fd0:	10450513          	addi	a0,a0,260 # 800090d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0){
    80000fdc:	040b0763          	beqz	s6,8000102a <walk+0x84>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c121                	beqz	a0,8000102a <walk+0x84>
        printf("DEBUG, walk couldn't alloc. level: %d\n", level);
        return 0;

      }
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V; //TODO maybe add | PTE_U
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a7d                	addiw	s4,s4,-1
    80001008:	3add                	addiw	s5,s5,-9
    8000100a:	020a0b63          	beqz	s4,80001040 <walk+0x9a>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100e:	0159d933          	srl	s2,s3,s5
    80001012:	1ff97913          	andi	s2,s2,511
    80001016:	090e                	slli	s2,s2,0x3
    80001018:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000101a:	00093483          	ld	s1,0(s2)
    8000101e:	0014f793          	andi	a5,s1,1
    80001022:	dfcd                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001024:	80a9                	srli	s1,s1,0xa
    80001026:	04b2                	slli	s1,s1,0xc
    80001028:	bff9                	j	80001006 <walk+0x60>
        printf("DEBUG, walk couldn't alloc. level: %d\n", level);
    8000102a:	85d2                	mv	a1,s4
    8000102c:	00008517          	auipc	a0,0x8
    80001030:	0ac50513          	addi	a0,a0,172 # 800090d8 <digits+0x98>
    80001034:	fffff097          	auipc	ra,0xfffff
    80001038:	540080e7          	jalr	1344(ra) # 80000574 <printf>
        return 0;
    8000103c:	4501                	li	a0,0
    8000103e:	a039                	j	8000104c <walk+0xa6>
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret

0000000080001060 <walkaddr>:
// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
    80001060:	1101                	addi	sp,sp,-32
    80001062:	ec06                	sd	ra,24(sp)
    80001064:	e822                	sd	s0,16(sp)
    80001066:	e426                	sd	s1,8(sp)
    80001068:	1000                	addi	s0,sp,32
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA){
    8000106a:	57fd                	li	a5,-1
    8000106c:	83e9                	srli	a5,a5,0x1a
    8000106e:	02b7e863          	bltu	a5,a1,8000109e <walkaddr+0x3e>
    printf("va >= MAXVA\n");
    return 0;
  }

  pte = walk(pagetable, va, 0);
    80001072:	4601                	li	a2,0
    80001074:	00000097          	auipc	ra,0x0
    80001078:	f32080e7          	jalr	-206(ra) # 80000fa6 <walk>
  if(pte == 0){
    8000107c:	c91d                	beqz	a0,800010b2 <walkaddr+0x52>
    printf("pte == 0\n");
    return 0;
  }

  if((*pte & PTE_V) == 0){
    8000107e:	610c                	ld	a1,0(a0)
    80001080:	0015f493          	andi	s1,a1,1
    80001084:	c0a9                	beqz	s1,800010c6 <walkaddr+0x66>
    printf("*pte & PTE_V\n");
    return 0;
  }
  if((*pte & PTE_U) == 0){
    80001086:	0105f493          	andi	s1,a1,16
    8000108a:	c4b9                	beqz	s1,800010d8 <walkaddr+0x78>
    printf("*pte & PTE_U. *pte: %d\n", *pte);
    return 0;
  }
  pa = PTE2PA(*pte);
    8000108c:	81a9                	srli	a1,a1,0xa
    8000108e:	00c59493          	slli	s1,a1,0xc
  return pa;
}
    80001092:	8526                	mv	a0,s1
    80001094:	60e2                	ld	ra,24(sp)
    80001096:	6442                	ld	s0,16(sp)
    80001098:	64a2                	ld	s1,8(sp)
    8000109a:	6105                	addi	sp,sp,32
    8000109c:	8082                	ret
    printf("va >= MAXVA\n");
    8000109e:	00008517          	auipc	a0,0x8
    800010a2:	06250513          	addi	a0,a0,98 # 80009100 <digits+0xc0>
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	4ce080e7          	jalr	1230(ra) # 80000574 <printf>
    return 0;
    800010ae:	4481                	li	s1,0
    800010b0:	b7cd                	j	80001092 <walkaddr+0x32>
    printf("pte == 0\n");
    800010b2:	00008517          	auipc	a0,0x8
    800010b6:	05e50513          	addi	a0,a0,94 # 80009110 <digits+0xd0>
    800010ba:	fffff097          	auipc	ra,0xfffff
    800010be:	4ba080e7          	jalr	1210(ra) # 80000574 <printf>
    return 0;
    800010c2:	4481                	li	s1,0
    800010c4:	b7f9                	j	80001092 <walkaddr+0x32>
    printf("*pte & PTE_V\n");
    800010c6:	00008517          	auipc	a0,0x8
    800010ca:	05a50513          	addi	a0,a0,90 # 80009120 <digits+0xe0>
    800010ce:	fffff097          	auipc	ra,0xfffff
    800010d2:	4a6080e7          	jalr	1190(ra) # 80000574 <printf>
    return 0;
    800010d6:	bf75                	j	80001092 <walkaddr+0x32>
    printf("*pte & PTE_U. *pte: %d\n", *pte);
    800010d8:	00008517          	auipc	a0,0x8
    800010dc:	05850513          	addi	a0,a0,88 # 80009130 <digits+0xf0>
    800010e0:	fffff097          	auipc	ra,0xfffff
    800010e4:	494080e7          	jalr	1172(ra) # 80000574 <printf>
    return 0;
    800010e8:	b76d                	j	80001092 <walkaddr+0x32>

00000000800010ea <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ea:	715d                	addi	sp,sp,-80
    800010ec:	e486                	sd	ra,72(sp)
    800010ee:	e0a2                	sd	s0,64(sp)
    800010f0:	fc26                	sd	s1,56(sp)
    800010f2:	f84a                	sd	s2,48(sp)
    800010f4:	f44e                	sd	s3,40(sp)
    800010f6:	f052                	sd	s4,32(sp)
    800010f8:	ec56                	sd	s5,24(sp)
    800010fa:	e85a                	sd	s6,16(sp)
    800010fc:	e45e                	sd	s7,8(sp)
    800010fe:	0880                	addi	s0,sp,80
    80001100:	8aaa                	mv	s5,a0
    80001102:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001104:	777d                	lui	a4,0xfffff
    80001106:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000110a:	167d                	addi	a2,a2,-1
    8000110c:	00b609b3          	add	s3,a2,a1
    80001110:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001114:	893e                	mv	s2,a5
    80001116:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000111a:	6b85                	lui	s7,0x1
    8000111c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001120:	4605                	li	a2,1
    80001122:	85ca                	mv	a1,s2
    80001124:	8556                	mv	a0,s5
    80001126:	00000097          	auipc	ra,0x0
    8000112a:	e80080e7          	jalr	-384(ra) # 80000fa6 <walk>
    8000112e:	c51d                	beqz	a0,8000115c <mappages+0x72>
    if(*pte & PTE_V)
    80001130:	611c                	ld	a5,0(a0)
    80001132:	8b85                	andi	a5,a5,1
    80001134:	ef81                	bnez	a5,8000114c <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001136:	80b1                	srli	s1,s1,0xc
    80001138:	04aa                	slli	s1,s1,0xa
    8000113a:	0164e4b3          	or	s1,s1,s6
    8000113e:	0014e493          	ori	s1,s1,1
    80001142:	e104                	sd	s1,0(a0)
    if(a == last)
    80001144:	03390863          	beq	s2,s3,80001174 <mappages+0x8a>
    a += PGSIZE;
    80001148:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000114a:	bfc9                	j	8000111c <mappages+0x32>
      panic("remap");
    8000114c:	00008517          	auipc	a0,0x8
    80001150:	ffc50513          	addi	a0,a0,-4 # 80009148 <digits+0x108>
    80001154:	fffff097          	auipc	ra,0xfffff
    80001158:	3d6080e7          	jalr	982(ra) # 8000052a <panic>
      return -1;
    8000115c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000115e:	60a6                	ld	ra,72(sp)
    80001160:	6406                	ld	s0,64(sp)
    80001162:	74e2                	ld	s1,56(sp)
    80001164:	7942                	ld	s2,48(sp)
    80001166:	79a2                	ld	s3,40(sp)
    80001168:	7a02                	ld	s4,32(sp)
    8000116a:	6ae2                	ld	s5,24(sp)
    8000116c:	6b42                	ld	s6,16(sp)
    8000116e:	6ba2                	ld	s7,8(sp)
    80001170:	6161                	addi	sp,sp,80
    80001172:	8082                	ret
  return 0;
    80001174:	4501                	li	a0,0
    80001176:	b7e5                	j	8000115e <mappages+0x74>

0000000080001178 <kvmmap>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
    80001180:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001182:	86b2                	mv	a3,a2
    80001184:	863e                	mv	a2,a5
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	f64080e7          	jalr	-156(ra) # 800010ea <mappages>
    8000118e:	e509                	bnez	a0,80001198 <kvmmap+0x20>
}
    80001190:	60a2                	ld	ra,8(sp)
    80001192:	6402                	ld	s0,0(sp)
    80001194:	0141                	addi	sp,sp,16
    80001196:	8082                	ret
    panic("kvmmap");
    80001198:	00008517          	auipc	a0,0x8
    8000119c:	fb850513          	addi	a0,a0,-72 # 80009150 <digits+0x110>
    800011a0:	fffff097          	auipc	ra,0xfffff
    800011a4:	38a080e7          	jalr	906(ra) # 8000052a <panic>

00000000800011a8 <kvmmake>:
{
    800011a8:	1101                	addi	sp,sp,-32
    800011aa:	ec06                	sd	ra,24(sp)
    800011ac:	e822                	sd	s0,16(sp)
    800011ae:	e426                	sd	s1,8(sp)
    800011b0:	e04a                	sd	s2,0(sp)
    800011b2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	91e080e7          	jalr	-1762(ra) # 80000ad2 <kalloc>
    800011bc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011be:	6605                	lui	a2,0x1
    800011c0:	4581                	li	a1,0
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	afc080e7          	jalr	-1284(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ca:	4719                	li	a4,6
    800011cc:	6685                	lui	a3,0x1
    800011ce:	10000637          	lui	a2,0x10000
    800011d2:	100005b7          	lui	a1,0x10000
    800011d6:	8526                	mv	a0,s1
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	fa0080e7          	jalr	-96(ra) # 80001178 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011e0:	4719                	li	a4,6
    800011e2:	6685                	lui	a3,0x1
    800011e4:	10001637          	lui	a2,0x10001
    800011e8:	100015b7          	lui	a1,0x10001
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f8a080e7          	jalr	-118(ra) # 80001178 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	004006b7          	lui	a3,0x400
    800011fc:	0c000637          	lui	a2,0xc000
    80001200:	0c0005b7          	lui	a1,0xc000
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f72080e7          	jalr	-142(ra) # 80001178 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000120e:	00008917          	auipc	s2,0x8
    80001212:	df290913          	addi	s2,s2,-526 # 80009000 <etext>
    80001216:	4729                	li	a4,10
    80001218:	80008697          	auipc	a3,0x80008
    8000121c:	de868693          	addi	a3,a3,-536 # 9000 <_entry-0x7fff7000>
    80001220:	4605                	li	a2,1
    80001222:	067e                	slli	a2,a2,0x1f
    80001224:	85b2                	mv	a1,a2
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	f50080e7          	jalr	-176(ra) # 80001178 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001230:	4719                	li	a4,6
    80001232:	46c5                	li	a3,17
    80001234:	06ee                	slli	a3,a3,0x1b
    80001236:	412686b3          	sub	a3,a3,s2
    8000123a:	864a                	mv	a2,s2
    8000123c:	85ca                	mv	a1,s2
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f38080e7          	jalr	-200(ra) # 80001178 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001248:	4729                	li	a4,10
    8000124a:	6685                	lui	a3,0x1
    8000124c:	00007617          	auipc	a2,0x7
    80001250:	db460613          	addi	a2,a2,-588 # 80008000 <_trampoline>
    80001254:	040005b7          	lui	a1,0x4000
    80001258:	15fd                	addi	a1,a1,-1
    8000125a:	05b2                	slli	a1,a1,0xc
    8000125c:	8526                	mv	a0,s1
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f1a080e7          	jalr	-230(ra) # 80001178 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001266:	8526                	mv	a0,s1
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	78e080e7          	jalr	1934(ra) # 800019f6 <proc_mapstacks>
}
    80001270:	8526                	mv	a0,s1
    80001272:	60e2                	ld	ra,24(sp)
    80001274:	6442                	ld	s0,16(sp)
    80001276:	64a2                	ld	s1,8(sp)
    80001278:	6902                	ld	s2,0(sp)
    8000127a:	6105                	addi	sp,sp,32
    8000127c:	8082                	ret

000000008000127e <kvminit>:
{
    8000127e:	1141                	addi	sp,sp,-16
    80001280:	e406                	sd	ra,8(sp)
    80001282:	e022                	sd	s0,0(sp)
    80001284:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	f22080e7          	jalr	-222(ra) # 800011a8 <kvmmake>
    8000128e:	00009797          	auipc	a5,0x9
    80001292:	d8a7b923          	sd	a0,-622(a5) # 8000a020 <kernel_pagetable>
}
    80001296:	60a2                	ld	ra,8(sp)
    80001298:	6402                	ld	s0,0(sp)
    8000129a:	0141                	addi	sp,sp,16
    8000129c:	8082                	ret

000000008000129e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000129e:	711d                	addi	sp,sp,-96
    800012a0:	ec86                	sd	ra,88(sp)
    800012a2:	e8a2                	sd	s0,80(sp)
    800012a4:	e4a6                	sd	s1,72(sp)
    800012a6:	e0ca                	sd	s2,64(sp)
    800012a8:	fc4e                	sd	s3,56(sp)
    800012aa:	f852                	sd	s4,48(sp)
    800012ac:	f456                	sd	s5,40(sp)
    800012ae:	f05a                	sd	s6,32(sp)
    800012b0:	ec5e                	sd	s7,24(sp)
    800012b2:	e862                	sd	s8,16(sp)
    800012b4:	e466                	sd	s9,8(sp)
    800012b6:	e06a                	sd	s10,0(sp)
    800012b8:	1080                	addi	s0,sp,96
  // printf("hello from uvmunmap. npages: %d\n", npages);
  // if (myproc()->pid smyproc(), myproc()->files_in_physicalmem);
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012ba:	03459793          	slli	a5,a1,0x34
    800012be:	ef99                	bnez	a5,800012dc <uvmunmap+0x3e>
    800012c0:	89aa                	mv	s3,a0
    800012c2:	892e                	mv	s2,a1
    800012c4:	8bb6                	mv	s7,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    800012c6:	0632                	slli	a2,a2,0xc
    800012c8:	00b60b33          	add	s6,a2,a1
    800012cc:	1565f963          	bgeu	a1,s6,8000141e <uvmunmap+0x180>
  {
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012d0:	4a05                	li	s4,1
      kfree((void*)pa);
    }
    #ifndef NONE
    struct proc *p = myproc();
    //we don't want a process changing its parents' memory
    if((p->pagetable == pagetable) && (p->pid > 2))
    800012d2:	4c89                	li	s9,2
              }
              //else, head will be the next page
              else {
                p->index_of_head_p = p->files_in_physicalmem[i].index_of_next_p;
              }
              p->files_in_physicalmem[i].index_of_prev_p = -1;
    800012d4:	5d7d                	li	s10,-1
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    800012d6:	4ac1                	li	s5,16
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    800012d8:	6c05                	lui	s8,0x1
    800012da:	a8a9                	j	80001334 <uvmunmap+0x96>
    panic("uvmunmap: not aligned");
    800012dc:	00008517          	auipc	a0,0x8
    800012e0:	e7c50513          	addi	a0,a0,-388 # 80009158 <digits+0x118>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	246080e7          	jalr	582(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800012ec:	00008517          	auipc	a0,0x8
    800012f0:	e8450513          	addi	a0,a0,-380 # 80009170 <digits+0x130>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	236080e7          	jalr	566(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012fc:	00008517          	auipc	a0,0x8
    80001300:	e8450513          	addi	a0,a0,-380 # 80009180 <digits+0x140>
    80001304:	fffff097          	auipc	ra,0xfffff
    80001308:	226080e7          	jalr	550(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    8000130c:	00008517          	auipc	a0,0x8
    80001310:	e8c50513          	addi	a0,a0,-372 # 80009198 <digits+0x158>
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	216080e7          	jalr	534(ra) # 8000052a <panic>
    struct proc *p = myproc();
    8000131c:	00001097          	auipc	ra,0x1
    80001320:	84c080e7          	jalr	-1972(ra) # 80001b68 <myproc>
    if((p->pagetable == pagetable) && (p->pid > 2))
    80001324:	693c                	ld	a5,80(a0)
    80001326:	05378463          	beq	a5,s3,8000136e <uvmunmap+0xd0>
        // p->num_of_pages--;
        // p->num_of_pages_in_phys--;
      }
    }
    #endif
    *pte = 0;
    8000132a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
    8000132e:	9962                	add	s2,s2,s8
    80001330:	0f697763          	bgeu	s2,s6,8000141e <uvmunmap+0x180>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001334:	4601                	li	a2,0
    80001336:	85ca                	mv	a1,s2
    80001338:	854e                	mv	a0,s3
    8000133a:	00000097          	auipc	ra,0x0
    8000133e:	c6c080e7          	jalr	-916(ra) # 80000fa6 <walk>
    80001342:	84aa                	mv	s1,a0
    80001344:	d545                	beqz	a0,800012ec <uvmunmap+0x4e>
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
    80001346:	6108                	ld	a0,0(a0)
    80001348:	20157793          	andi	a5,a0,513
    8000134c:	dbc5                	beqz	a5,800012fc <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000134e:	3ff57793          	andi	a5,a0,1023
    80001352:	fb478de3          	beq	a5,s4,8000130c <uvmunmap+0x6e>
    if(do_free && (*pte & PTE_PG) == 0)
    80001356:	fc0b83e3          	beqz	s7,8000131c <uvmunmap+0x7e>
    8000135a:	20057793          	andi	a5,a0,512
    8000135e:	ffdd                	bnez	a5,8000131c <uvmunmap+0x7e>
      uint64 pa = PTE2PA(*pte);
    80001360:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001362:	0532                	slli	a0,a0,0xc
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	672080e7          	jalr	1650(ra) # 800009d6 <kfree>
    8000136c:	bf45                	j	8000131c <uvmunmap+0x7e>
    if((p->pagetable == pagetable) && (p->pid > 2))
    8000136e:	591c                	lw	a5,48(a0)
    80001370:	fafcdde3          	bge	s9,a5,8000132a <uvmunmap+0x8c>
    80001374:	17050793          	addi	a5,a0,368
    80001378:	4a050613          	addi	a2,a0,1184
    8000137c:	a029                	j	80001386 <uvmunmap+0xe8>
      for(int i = 0; i < MAX_SWAP_PAGES; i++){
    8000137e:	03078793          	addi	a5,a5,48
    80001382:	00c78f63          	beq	a5,a2,800013a0 <uvmunmap+0x102>
        if((p->files_in_swap[i].isAvailable == 0) && p->files_in_swap[i].va == a){
    80001386:	4398                	lw	a4,0(a5)
    80001388:	fb7d                	bnez	a4,8000137e <uvmunmap+0xe0>
    8000138a:	6f98                	ld	a4,24(a5)
    8000138c:	ff2719e3          	bne	a4,s2,8000137e <uvmunmap+0xe0>
          p->files_in_swap[i].isAvailable = 1;
    80001390:	0147a023          	sw	s4,0(a5)
          p->num_of_pages--;
    80001394:	7a052703          	lw	a4,1952(a0)
    80001398:	377d                	addiw	a4,a4,-1
    8000139a:	7ae52023          	sw	a4,1952(a0)
    8000139e:	b7c5                	j	8000137e <uvmunmap+0xe0>
    800013a0:	4a050793          	addi	a5,a0,1184
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    800013a4:	4701                	li	a4,0
    800013a6:	a821                	j	800013be <uvmunmap+0x120>
    800013a8:	7ac52823          	sw	a2,1968(a0)
              p->files_in_physicalmem[i].index_of_prev_p = -1;
    800013ac:	03a6a423          	sw	s10,40(a3) # 1028 <_entry-0x7fffefd8>
              p->files_in_physicalmem[i].index_of_next_p = -1;
    800013b0:	03a6a223          	sw	s10,36(a3)
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
    800013b4:	2705                	addiw	a4,a4,1
    800013b6:	03078793          	addi	a5,a5,48
    800013ba:	f75708e3          	beq	a4,s5,8000132a <uvmunmap+0x8c>
        if((p->files_in_physicalmem[i].isAvailable == 0) && p->files_in_physicalmem[i].va == a)
    800013be:	86be                	mv	a3,a5
    800013c0:	4390                	lw	a2,0(a5)
    800013c2:	fa6d                	bnez	a2,800013b4 <uvmunmap+0x116>
    800013c4:	6f90                	ld	a2,24(a5)
    800013c6:	ff2617e3          	bne	a2,s2,800013b4 <uvmunmap+0x116>
          p->files_in_physicalmem[i].va = 0;
    800013ca:	0007bc23          	sd	zero,24(a5)
          p->files_in_physicalmem[i].isAvailable = 1;
    800013ce:	0147a023          	sw	s4,0(a5)
          p->num_of_pages--;
    800013d2:	7a052603          	lw	a2,1952(a0)
    800013d6:	367d                	addiw	a2,a2,-1
    800013d8:	7ac52023          	sw	a2,1952(a0)
          p->num_of_pages_in_phys--;
    800013dc:	7a452603          	lw	a2,1956(a0)
    800013e0:	367d                	addiw	a2,a2,-1
    800013e2:	7ac52223          	sw	a2,1956(a0)
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[i].index_of_prev_p;
    800013e6:	53cc                	lw	a1,36(a5)
    800013e8:	0287a803          	lw	a6,40(a5)
    800013ec:	00159613          	slli	a2,a1,0x1
    800013f0:	962e                	add	a2,a2,a1
    800013f2:	0612                	slli	a2,a2,0x4
    800013f4:	962a                	add	a2,a2,a0
    800013f6:	4d062423          	sw	a6,1224(a2)
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[i].index_of_next_p;
    800013fa:	0287a803          	lw	a6,40(a5)
    800013fe:	00181613          	slli	a2,a6,0x1
    80001402:	9642                	add	a2,a2,a6
    80001404:	0612                	slli	a2,a2,0x4
    80001406:	962a                	add	a2,a2,a0
    80001408:	4cb62223          	sw	a1,1220(a2)
            if(p->index_of_head_p == i){
    8000140c:	7b052603          	lw	a2,1968(a0)
    80001410:	fae612e3          	bne	a2,a4,800013b4 <uvmunmap+0x116>
              if(p->index_of_head_p == p->files_in_physicalmem[i].index_of_next_p){
    80001414:	53d0                	lw	a2,36(a5)
    80001416:	f8e619e3          	bne	a2,a4,800013a8 <uvmunmap+0x10a>
                p->index_of_head_p = -1;
    8000141a:	866a                	mv	a2,s10
    8000141c:	b771                	j	800013a8 <uvmunmap+0x10a>
  }
  // printf("leaving uvmunmap\n");
  // if(myproc()->pid >2)
    // print_page_array(myproc(), myproc()->files_in_physicalmem);

}
    8000141e:	60e6                	ld	ra,88(sp)
    80001420:	6446                	ld	s0,80(sp)
    80001422:	64a6                	ld	s1,72(sp)
    80001424:	6906                	ld	s2,64(sp)
    80001426:	79e2                	ld	s3,56(sp)
    80001428:	7a42                	ld	s4,48(sp)
    8000142a:	7aa2                	ld	s5,40(sp)
    8000142c:	7b02                	ld	s6,32(sp)
    8000142e:	6be2                	ld	s7,24(sp)
    80001430:	6c42                	ld	s8,16(sp)
    80001432:	6ca2                	ld	s9,8(sp)
    80001434:	6d02                	ld	s10,0(sp)
    80001436:	6125                	addi	sp,sp,96
    80001438:	8082                	ret

000000008000143a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000143a:	1101                	addi	sp,sp,-32
    8000143c:	ec06                	sd	ra,24(sp)
    8000143e:	e822                	sd	s0,16(sp)
    80001440:	e426                	sd	s1,8(sp)
    80001442:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001444:	fffff097          	auipc	ra,0xfffff
    80001448:	68e080e7          	jalr	1678(ra) # 80000ad2 <kalloc>
    8000144c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000144e:	c519                	beqz	a0,8000145c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001450:	6605                	lui	a2,0x1
    80001452:	4581                	li	a1,0
    80001454:	00000097          	auipc	ra,0x0
    80001458:	86a080e7          	jalr	-1942(ra) # 80000cbe <memset>
  return pagetable;
}
    8000145c:	8526                	mv	a0,s1
    8000145e:	60e2                	ld	ra,24(sp)
    80001460:	6442                	ld	s0,16(sp)
    80001462:	64a2                	ld	s1,8(sp)
    80001464:	6105                	addi	sp,sp,32
    80001466:	8082                	ret

0000000080001468 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001468:	7179                	addi	sp,sp,-48
    8000146a:	f406                	sd	ra,40(sp)
    8000146c:	f022                	sd	s0,32(sp)
    8000146e:	ec26                	sd	s1,24(sp)
    80001470:	e84a                	sd	s2,16(sp)
    80001472:	e44e                	sd	s3,8(sp)
    80001474:	e052                	sd	s4,0(sp)
    80001476:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001478:	6785                	lui	a5,0x1
    8000147a:	04f67863          	bgeu	a2,a5,800014ca <uvminit+0x62>
    8000147e:	8a2a                	mv	s4,a0
    80001480:	89ae                	mv	s3,a1
    80001482:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001484:	fffff097          	auipc	ra,0xfffff
    80001488:	64e080e7          	jalr	1614(ra) # 80000ad2 <kalloc>
    8000148c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000148e:	6605                	lui	a2,0x1
    80001490:	4581                	li	a1,0
    80001492:	00000097          	auipc	ra,0x0
    80001496:	82c080e7          	jalr	-2004(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000149a:	4779                	li	a4,30
    8000149c:	86ca                	mv	a3,s2
    8000149e:	6605                	lui	a2,0x1
    800014a0:	4581                	li	a1,0
    800014a2:	8552                	mv	a0,s4
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	c46080e7          	jalr	-954(ra) # 800010ea <mappages>
  memmove(mem, src, sz);
    800014ac:	8626                	mv	a2,s1
    800014ae:	85ce                	mv	a1,s3
    800014b0:	854a                	mv	a0,s2
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	868080e7          	jalr	-1944(ra) # 80000d1a <memmove>
}
    800014ba:	70a2                	ld	ra,40(sp)
    800014bc:	7402                	ld	s0,32(sp)
    800014be:	64e2                	ld	s1,24(sp)
    800014c0:	6942                	ld	s2,16(sp)
    800014c2:	69a2                	ld	s3,8(sp)
    800014c4:	6a02                	ld	s4,0(sp)
    800014c6:	6145                	addi	sp,sp,48
    800014c8:	8082                	ret
    panic("inituvm: more than a page");
    800014ca:	00008517          	auipc	a0,0x8
    800014ce:	ce650513          	addi	a0,a0,-794 # 800091b0 <digits+0x170>
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	058080e7          	jalr	88(ra) # 8000052a <panic>

00000000800014da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014da:	1101                	addi	sp,sp,-32
    800014dc:	ec06                	sd	ra,24(sp)
    800014de:	e822                	sd	s0,16(sp)
    800014e0:	e426                	sd	s1,8(sp)
    800014e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014e6:	00b67d63          	bgeu	a2,a1,80001500 <uvmdealloc+0x26>
    800014ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014ec:	6785                	lui	a5,0x1
    800014ee:	17fd                	addi	a5,a5,-1
    800014f0:	00f60733          	add	a4,a2,a5
    800014f4:	767d                	lui	a2,0xfffff
    800014f6:	8f71                	and	a4,a4,a2
    800014f8:	97ae                	add	a5,a5,a1
    800014fa:	8ff1                	and	a5,a5,a2
    800014fc:	00f76863          	bltu	a4,a5,8000150c <uvmdealloc+0x32>
    // printf("calling uvmunmap. pid: %d\n", myproc()->pid);
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001500:	8526                	mv	a0,s1
    80001502:	60e2                	ld	ra,24(sp)
    80001504:	6442                	ld	s0,16(sp)
    80001506:	64a2                	ld	s1,8(sp)
    80001508:	6105                	addi	sp,sp,32
    8000150a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000150c:	8f99                	sub	a5,a5,a4
    8000150e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001510:	4685                	li	a3,1
    80001512:	0007861b          	sext.w	a2,a5
    80001516:	85ba                	mv	a1,a4
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	d86080e7          	jalr	-634(ra) # 8000129e <uvmunmap>
    80001520:	b7c5                	j	80001500 <uvmdealloc+0x26>

0000000080001522 <uvmalloc>:
  if(newsz < oldsz)
    80001522:	12b66163          	bltu	a2,a1,80001644 <uvmalloc+0x122>
{
    80001526:	711d                	addi	sp,sp,-96
    80001528:	ec86                	sd	ra,88(sp)
    8000152a:	e8a2                	sd	s0,80(sp)
    8000152c:	e4a6                	sd	s1,72(sp)
    8000152e:	e0ca                	sd	s2,64(sp)
    80001530:	fc4e                	sd	s3,56(sp)
    80001532:	f852                	sd	s4,48(sp)
    80001534:	f456                	sd	s5,40(sp)
    80001536:	f05a                	sd	s6,32(sp)
    80001538:	ec5e                	sd	s7,24(sp)
    8000153a:	e862                	sd	s8,16(sp)
    8000153c:	e466                	sd	s9,8(sp)
    8000153e:	1080                	addi	s0,sp,96
    80001540:	8a2a                	mv	s4,a0
    80001542:	8b32                	mv	s6,a2
  oldsz = PGROUNDUP(oldsz);
    80001544:	6a85                	lui	s5,0x1
    80001546:	1afd                	addi	s5,s5,-1
    80001548:	95d6                	add	a1,a1,s5
    8000154a:	7afd                	lui	s5,0xfffff
    8000154c:	0155fab3          	and	s5,a1,s5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001550:	0ecafc63          	bgeu	s5,a2,80001648 <uvmalloc+0x126>
    80001554:	89d6                	mv	s3,s5
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    80001556:	4bfd                	li	s7,31
    if (p->pid > 2 && p->pagetable == pagetable) {
    80001558:	4c09                	li	s8,2
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    8000155a:	4cbd                	li	s9,15
    8000155c:	a8bd                	j	800015da <uvmalloc+0xb8>
      printf("not enough free pages\n");
    8000155e:	00008517          	auipc	a0,0x8
    80001562:	c7250513          	addi	a0,a0,-910 # 800091d0 <digits+0x190>
    80001566:	fffff097          	auipc	ra,0xfffff
    8000156a:	00e080e7          	jalr	14(ra) # 80000574 <printf>
      return 0;
    8000156e:	4501                	li	a0,0
}
    80001570:	60e6                	ld	ra,88(sp)
    80001572:	6446                	ld	s0,80(sp)
    80001574:	64a6                	ld	s1,72(sp)
    80001576:	6906                	ld	s2,64(sp)
    80001578:	79e2                	ld	s3,56(sp)
    8000157a:	7a42                	ld	s4,48(sp)
    8000157c:	7aa2                	ld	s5,40(sp)
    8000157e:	7b02                	ld	s6,32(sp)
    80001580:	6be2                	ld	s7,24(sp)
    80001582:	6c42                	ld	s8,16(sp)
    80001584:	6ca2                	ld	s9,8(sp)
    80001586:	6125                	addi	sp,sp,96
    80001588:	8082                	ret
      uvmdealloc(pagetable, a, oldsz);
    8000158a:	8656                	mv	a2,s5
    8000158c:	85ce                	mv	a1,s3
    8000158e:	8552                	mv	a0,s4
    80001590:	00000097          	auipc	ra,0x0
    80001594:	f4a080e7          	jalr	-182(ra) # 800014da <uvmdealloc>
      return 0;
    80001598:	4501                	li	a0,0
    8000159a:	bfd9                	j	80001570 <uvmalloc+0x4e>
      kfree(mem);
    8000159c:	8526                	mv	a0,s1
    8000159e:	fffff097          	auipc	ra,0xfffff
    800015a2:	438080e7          	jalr	1080(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015a6:	8656                	mv	a2,s5
    800015a8:	85ce                	mv	a1,s3
    800015aa:	8552                	mv	a0,s4
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	f2e080e7          	jalr	-210(ra) # 800014da <uvmdealloc>
      return 0;
    800015b4:	4501                	li	a0,0
    800015b6:	bf6d                	j	80001570 <uvmalloc+0x4e>
        swap_to_swapFile(p, p->pagetable);
    800015b8:	85d2                	mv	a1,s4
    800015ba:	854a                	mv	a0,s2
    800015bc:	00001097          	auipc	ra,0x1
    800015c0:	688080e7          	jalr	1672(ra) # 80002c44 <swap_to_swapFile>
        add_page_to_phys(p, pagetable, a);
    800015c4:	864e                	mv	a2,s3
    800015c6:	85d2                	mv	a1,s4
    800015c8:	854a                	mv	a0,s2
    800015ca:	00001097          	auipc	ra,0x1
    800015ce:	122080e7          	jalr	290(ra) # 800026ec <add_page_to_phys>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	0769f563          	bgeu	s3,s6,80001640 <uvmalloc+0x11e>
    struct proc* p = myproc();
    800015da:	00000097          	auipc	ra,0x0
    800015de:	58e080e7          	jalr	1422(ra) # 80001b68 <myproc>
    800015e2:	892a                	mv	s2,a0
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
    800015e4:	7a052783          	lw	a5,1952(a0)
    800015e8:	f6fbcbe3          	blt	s7,a5,8000155e <uvmalloc+0x3c>
    mem = kalloc();
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	4e6080e7          	jalr	1254(ra) # 80000ad2 <kalloc>
    800015f4:	84aa                	mv	s1,a0
    if(mem == 0){
    800015f6:	d951                	beqz	a0,8000158a <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800015f8:	6605                	lui	a2,0x1
    800015fa:	4581                	li	a1,0
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	6c2080e7          	jalr	1730(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001604:	4779                	li	a4,30
    80001606:	86a6                	mv	a3,s1
    80001608:	6605                	lui	a2,0x1
    8000160a:	85ce                	mv	a1,s3
    8000160c:	8552                	mv	a0,s4
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	adc080e7          	jalr	-1316(ra) # 800010ea <mappages>
    80001616:	f159                	bnez	a0,8000159c <uvmalloc+0x7a>
    if (p->pid > 2 && p->pagetable == pagetable) {
    80001618:	03092783          	lw	a5,48(s2)
    8000161c:	fafc5be3          	bge	s8,a5,800015d2 <uvmalloc+0xb0>
    80001620:	05093783          	ld	a5,80(s2)
    80001624:	fb4797e3          	bne	a5,s4,800015d2 <uvmalloc+0xb0>
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80001628:	7a492783          	lw	a5,1956(s2)
    8000162c:	f8fcc6e3          	blt	s9,a5,800015b8 <uvmalloc+0x96>
        add_page_to_phys(p, pagetable, a); //a= va
    80001630:	864e                	mv	a2,s3
    80001632:	85d2                	mv	a1,s4
    80001634:	854a                	mv	a0,s2
    80001636:	00001097          	auipc	ra,0x1
    8000163a:	0b6080e7          	jalr	182(ra) # 800026ec <add_page_to_phys>
    8000163e:	bf51                	j	800015d2 <uvmalloc+0xb0>
  return newsz;
    80001640:	855a                	mv	a0,s6
    80001642:	b73d                	j	80001570 <uvmalloc+0x4e>
    return oldsz;
    80001644:	852e                	mv	a0,a1
}
    80001646:	8082                	ret
  return newsz;
    80001648:	8532                	mv	a0,a2
    8000164a:	b71d                	j	80001570 <uvmalloc+0x4e>

000000008000164c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000164c:	7179                	addi	sp,sp,-48
    8000164e:	f406                	sd	ra,40(sp)
    80001650:	f022                	sd	s0,32(sp)
    80001652:	ec26                	sd	s1,24(sp)
    80001654:	e84a                	sd	s2,16(sp)
    80001656:	e44e                	sd	s3,8(sp)
    80001658:	e052                	sd	s4,0(sp)
    8000165a:	1800                	addi	s0,sp,48
    8000165c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000165e:	84aa                	mv	s1,a0
    80001660:	6905                	lui	s2,0x1
    80001662:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001664:	4985                	li	s3,1
    80001666:	a821                	j	8000167e <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001668:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000166a:	0532                	slli	a0,a0,0xc
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	fe0080e7          	jalr	-32(ra) # 8000164c <freewalk>
      pagetable[i] = 0;
    80001674:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001678:	04a1                	addi	s1,s1,8
    8000167a:	03248163          	beq	s1,s2,8000169c <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000167e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001680:	00f57793          	andi	a5,a0,15
    80001684:	ff3782e3          	beq	a5,s3,80001668 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001688:	8905                	andi	a0,a0,1
    8000168a:	d57d                	beqz	a0,80001678 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000168c:	00008517          	auipc	a0,0x8
    80001690:	b5c50513          	addi	a0,a0,-1188 # 800091e8 <digits+0x1a8>
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	e96080e7          	jalr	-362(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    8000169c:	8552                	mv	a0,s4
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	338080e7          	jalr	824(ra) # 800009d6 <kfree>
}
    800016a6:	70a2                	ld	ra,40(sp)
    800016a8:	7402                	ld	s0,32(sp)
    800016aa:	64e2                	ld	s1,24(sp)
    800016ac:	6942                	ld	s2,16(sp)
    800016ae:	69a2                	ld	s3,8(sp)
    800016b0:	6a02                	ld	s4,0(sp)
    800016b2:	6145                	addi	sp,sp,48
    800016b4:	8082                	ret

00000000800016b6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016b6:	1101                	addi	sp,sp,-32
    800016b8:	ec06                	sd	ra,24(sp)
    800016ba:	e822                	sd	s0,16(sp)
    800016bc:	e426                	sd	s1,8(sp)
    800016be:	1000                	addi	s0,sp,32
    800016c0:	84aa                	mv	s1,a0
  if(sz > 0)
    800016c2:	e999                	bnez	a1,800016d8 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016c4:	8526                	mv	a0,s1
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	f86080e7          	jalr	-122(ra) # 8000164c <freewalk>
}
    800016ce:	60e2                	ld	ra,24(sp)
    800016d0:	6442                	ld	s0,16(sp)
    800016d2:	64a2                	ld	s1,8(sp)
    800016d4:	6105                	addi	sp,sp,32
    800016d6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016d8:	6605                	lui	a2,0x1
    800016da:	167d                	addi	a2,a2,-1
    800016dc:	962e                	add	a2,a2,a1
    800016de:	4685                	li	a3,1
    800016e0:	8231                	srli	a2,a2,0xc
    800016e2:	4581                	li	a1,0
    800016e4:	00000097          	auipc	ra,0x0
    800016e8:	bba080e7          	jalr	-1094(ra) # 8000129e <uvmunmap>
    800016ec:	bfe1                	j	800016c4 <uvmfree+0xe>

00000000800016ee <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016ee:	10060263          	beqz	a2,800017f2 <uvmcopy+0x104>
{
    800016f2:	715d                	addi	sp,sp,-80
    800016f4:	e486                	sd	ra,72(sp)
    800016f6:	e0a2                	sd	s0,64(sp)
    800016f8:	fc26                	sd	s1,56(sp)
    800016fa:	f84a                	sd	s2,48(sp)
    800016fc:	f44e                	sd	s3,40(sp)
    800016fe:	f052                	sd	s4,32(sp)
    80001700:	ec56                	sd	s5,24(sp)
    80001702:	e85a                	sd	s6,16(sp)
    80001704:	e45e                	sd	s7,8(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8aaa                	mv	s5,a0
    8000170a:	8a2e                	mv	s4,a1
    8000170c:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000170e:	4901                	li	s2,0
    80001710:	a015                	j	80001734 <uvmcopy+0x46>
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    80001712:	00008517          	auipc	a0,0x8
    80001716:	ae650513          	addi	a0,a0,-1306 # 800091f8 <digits+0x1b8>
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	e10080e7          	jalr	-496(ra) # 8000052a <panic>
      if (*pte & PTE_PG) {
        pte_t *new_pte;
        //map a new pte for this page in child. take care of valid and pte_pg flags accordingly
        if((new_pte = walk(new, i, 1)) == 0) {panic("uvmcopy: can't create pte\n");}
        *new_pte |= PTE_PG;
        *new_pte &= ~PTE_V;
    80001722:	611c                	ld	a5,0(a0)
    80001724:	9bf9                	andi	a5,a5,-2
    80001726:	2007e793          	ori	a5,a5,512
    8000172a:	e11c                	sd	a5,0(a0)
  for(i = 0; i < sz; i += PGSIZE){
    8000172c:	6785                	lui	a5,0x1
    8000172e:	993e                	add	s2,s2,a5
    80001730:	0b397563          	bgeu	s2,s3,800017da <uvmcopy+0xec>
    if((pte = walk(old, i, 0)) == 0)
    80001734:	4601                	li	a2,0
    80001736:	85ca                	mv	a1,s2
    80001738:	8556                	mv	a0,s5
    8000173a:	00000097          	auipc	ra,0x0
    8000173e:	86c080e7          	jalr	-1940(ra) # 80000fa6 <walk>
    80001742:	d961                	beqz	a0,80001712 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0) {
    80001744:	6118                	ld	a4,0(a0)
    80001746:	00177793          	andi	a5,a4,1
    8000174a:	ef85                	bnez	a5,80001782 <uvmcopy+0x94>
      if (*pte & PTE_PG) {
    8000174c:	20077713          	andi	a4,a4,512
    80001750:	c30d                	beqz	a4,80001772 <uvmcopy+0x84>
        if((new_pte = walk(new, i, 1)) == 0) {panic("uvmcopy: can't create pte\n");}
    80001752:	4605                	li	a2,1
    80001754:	85ca                	mv	a1,s2
    80001756:	8552                	mv	a0,s4
    80001758:	00000097          	auipc	ra,0x0
    8000175c:	84e080e7          	jalr	-1970(ra) # 80000fa6 <walk>
    80001760:	f169                	bnez	a0,80001722 <uvmcopy+0x34>
    80001762:	00008517          	auipc	a0,0x8
    80001766:	ab650513          	addi	a0,a0,-1354 # 80009218 <digits+0x1d8>
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	dc0080e7          	jalr	-576(ra) # 8000052a <panic>
        continue;
        // goto cont;
      }
      #endif
      //if we got here, page is invalid AND wasn't paged out
      panic("uvmcopy: page not present");
    80001772:	00008517          	auipc	a0,0x8
    80001776:	ac650513          	addi	a0,a0,-1338 # 80009238 <digits+0x1f8>
    8000177a:	fffff097          	auipc	ra,0xfffff
    8000177e:	db0080e7          	jalr	-592(ra) # 8000052a <panic>
    }
    // cont:
    pa = PTE2PA(*pte);
    80001782:	00a75593          	srli	a1,a4,0xa
    80001786:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000178a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	344080e7          	jalr	836(ra) # 80000ad2 <kalloc>
    80001796:	8b2a                	mv	s6,a0
    80001798:	c515                	beqz	a0,800017c4 <uvmcopy+0xd6>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000179a:	6605                	lui	a2,0x1
    8000179c:	85de                	mv	a1,s7
    8000179e:	fffff097          	auipc	ra,0xfffff
    800017a2:	57c080e7          	jalr	1404(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800017a6:	8726                	mv	a4,s1
    800017a8:	86da                	mv	a3,s6
    800017aa:	6605                	lui	a2,0x1
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	93a080e7          	jalr	-1734(ra) # 800010ea <mappages>
    800017b8:	d935                	beqz	a0,8000172c <uvmcopy+0x3e>
      kfree(mem);
    800017ba:	855a                	mv	a0,s6
    800017bc:	fffff097          	auipc	ra,0xfffff
    800017c0:	21a080e7          	jalr	538(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017c4:	4685                	li	a3,1
    800017c6:	00c95613          	srli	a2,s2,0xc
    800017ca:	4581                	li	a1,0
    800017cc:	8552                	mv	a0,s4
    800017ce:	00000097          	auipc	ra,0x0
    800017d2:	ad0080e7          	jalr	-1328(ra) # 8000129e <uvmunmap>
  return -1;
    800017d6:	557d                	li	a0,-1
    800017d8:	a011                	j	800017dc <uvmcopy+0xee>
  return 0;
    800017da:	4501                	li	a0,0
}
    800017dc:	60a6                	ld	ra,72(sp)
    800017de:	6406                	ld	s0,64(sp)
    800017e0:	74e2                	ld	s1,56(sp)
    800017e2:	7942                	ld	s2,48(sp)
    800017e4:	79a2                	ld	s3,40(sp)
    800017e6:	7a02                	ld	s4,32(sp)
    800017e8:	6ae2                	ld	s5,24(sp)
    800017ea:	6b42                	ld	s6,16(sp)
    800017ec:	6ba2                	ld	s7,8(sp)
    800017ee:	6161                	addi	sp,sp,80
    800017f0:	8082                	ret
  return 0;
    800017f2:	4501                	li	a0,0
}
    800017f4:	8082                	ret

00000000800017f6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017f6:	1141                	addi	sp,sp,-16
    800017f8:	e406                	sd	ra,8(sp)
    800017fa:	e022                	sd	s0,0(sp)
    800017fc:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800017fe:	4601                	li	a2,0
    80001800:	fffff097          	auipc	ra,0xfffff
    80001804:	7a6080e7          	jalr	1958(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001808:	c901                	beqz	a0,80001818 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000180a:	611c                	ld	a5,0(a0)
    8000180c:	9bbd                	andi	a5,a5,-17
    8000180e:	e11c                	sd	a5,0(a0)
  // printf("turning off PTE_U\n");
}
    80001810:	60a2                	ld	ra,8(sp)
    80001812:	6402                	ld	s0,0(sp)
    80001814:	0141                	addi	sp,sp,16
    80001816:	8082                	ret
    panic("uvmclear");
    80001818:	00008517          	auipc	a0,0x8
    8000181c:	a4050513          	addi	a0,a0,-1472 # 80009258 <digits+0x218>
    80001820:	fffff097          	auipc	ra,0xfffff
    80001824:	d0a080e7          	jalr	-758(ra) # 8000052a <panic>

0000000080001828 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001828:	c6bd                	beqz	a3,80001896 <copyout+0x6e>
{
    8000182a:	715d                	addi	sp,sp,-80
    8000182c:	e486                	sd	ra,72(sp)
    8000182e:	e0a2                	sd	s0,64(sp)
    80001830:	fc26                	sd	s1,56(sp)
    80001832:	f84a                	sd	s2,48(sp)
    80001834:	f44e                	sd	s3,40(sp)
    80001836:	f052                	sd	s4,32(sp)
    80001838:	ec56                	sd	s5,24(sp)
    8000183a:	e85a                	sd	s6,16(sp)
    8000183c:	e45e                	sd	s7,8(sp)
    8000183e:	e062                	sd	s8,0(sp)
    80001840:	0880                	addi	s0,sp,80
    80001842:	8b2a                	mv	s6,a0
    80001844:	8c2e                	mv	s8,a1
    80001846:	8a32                	mv	s4,a2
    80001848:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000184a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000184c:	6a85                	lui	s5,0x1
    8000184e:	a015                	j	80001872 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001850:	9562                	add	a0,a0,s8
    80001852:	0004861b          	sext.w	a2,s1
    80001856:	85d2                	mv	a1,s4
    80001858:	41250533          	sub	a0,a0,s2
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	4be080e7          	jalr	1214(ra) # 80000d1a <memmove>

    len -= n;
    80001864:	409989b3          	sub	s3,s3,s1
    src += n;
    80001868:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000186a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000186e:	02098263          	beqz	s3,80001892 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001872:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001876:	85ca                	mv	a1,s2
    80001878:	855a                	mv	a0,s6
    8000187a:	fffff097          	auipc	ra,0xfffff
    8000187e:	7e6080e7          	jalr	2022(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    80001882:	cd01                	beqz	a0,8000189a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001884:	418904b3          	sub	s1,s2,s8
    80001888:	94d6                	add	s1,s1,s5
    if(n > len)
    8000188a:	fc99f3e3          	bgeu	s3,s1,80001850 <copyout+0x28>
    8000188e:	84ce                	mv	s1,s3
    80001890:	b7c1                	j	80001850 <copyout+0x28>
  }
  return 0;
    80001892:	4501                	li	a0,0
    80001894:	a021                	j	8000189c <copyout+0x74>
    80001896:	4501                	li	a0,0
}
    80001898:	8082                	ret
      return -1;
    8000189a:	557d                	li	a0,-1
}
    8000189c:	60a6                	ld	ra,72(sp)
    8000189e:	6406                	ld	s0,64(sp)
    800018a0:	74e2                	ld	s1,56(sp)
    800018a2:	7942                	ld	s2,48(sp)
    800018a4:	79a2                	ld	s3,40(sp)
    800018a6:	7a02                	ld	s4,32(sp)
    800018a8:	6ae2                	ld	s5,24(sp)
    800018aa:	6b42                	ld	s6,16(sp)
    800018ac:	6ba2                	ld	s7,8(sp)
    800018ae:	6c02                	ld	s8,0(sp)
    800018b0:	6161                	addi	sp,sp,80
    800018b2:	8082                	ret

00000000800018b4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018b4:	caa5                	beqz	a3,80001924 <copyin+0x70>
{
    800018b6:	715d                	addi	sp,sp,-80
    800018b8:	e486                	sd	ra,72(sp)
    800018ba:	e0a2                	sd	s0,64(sp)
    800018bc:	fc26                	sd	s1,56(sp)
    800018be:	f84a                	sd	s2,48(sp)
    800018c0:	f44e                	sd	s3,40(sp)
    800018c2:	f052                	sd	s4,32(sp)
    800018c4:	ec56                	sd	s5,24(sp)
    800018c6:	e85a                	sd	s6,16(sp)
    800018c8:	e45e                	sd	s7,8(sp)
    800018ca:	e062                	sd	s8,0(sp)
    800018cc:	0880                	addi	s0,sp,80
    800018ce:	8b2a                	mv	s6,a0
    800018d0:	8a2e                	mv	s4,a1
    800018d2:	8c32                	mv	s8,a2
    800018d4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018d6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d8:	6a85                	lui	s5,0x1
    800018da:	a01d                	j	80001900 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018dc:	018505b3          	add	a1,a0,s8
    800018e0:	0004861b          	sext.w	a2,s1
    800018e4:	412585b3          	sub	a1,a1,s2
    800018e8:	8552                	mv	a0,s4
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	430080e7          	jalr	1072(ra) # 80000d1a <memmove>

    len -= n;
    800018f2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018f6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018f8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018fc:	02098263          	beqz	s3,80001920 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001900:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001904:	85ca                	mv	a1,s2
    80001906:	855a                	mv	a0,s6
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	758080e7          	jalr	1880(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    80001910:	cd01                	beqz	a0,80001928 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001912:	418904b3          	sub	s1,s2,s8
    80001916:	94d6                	add	s1,s1,s5
    if(n > len)
    80001918:	fc99f2e3          	bgeu	s3,s1,800018dc <copyin+0x28>
    8000191c:	84ce                	mv	s1,s3
    8000191e:	bf7d                	j	800018dc <copyin+0x28>
  }
  return 0;
    80001920:	4501                	li	a0,0
    80001922:	a021                	j	8000192a <copyin+0x76>
    80001924:	4501                	li	a0,0
}
    80001926:	8082                	ret
      return -1;
    80001928:	557d                	li	a0,-1
}
    8000192a:	60a6                	ld	ra,72(sp)
    8000192c:	6406                	ld	s0,64(sp)
    8000192e:	74e2                	ld	s1,56(sp)
    80001930:	7942                	ld	s2,48(sp)
    80001932:	79a2                	ld	s3,40(sp)
    80001934:	7a02                	ld	s4,32(sp)
    80001936:	6ae2                	ld	s5,24(sp)
    80001938:	6b42                	ld	s6,16(sp)
    8000193a:	6ba2                	ld	s7,8(sp)
    8000193c:	6c02                	ld	s8,0(sp)
    8000193e:	6161                	addi	sp,sp,80
    80001940:	8082                	ret

0000000080001942 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001942:	c6c5                	beqz	a3,800019ea <copyinstr+0xa8>
{
    80001944:	715d                	addi	sp,sp,-80
    80001946:	e486                	sd	ra,72(sp)
    80001948:	e0a2                	sd	s0,64(sp)
    8000194a:	fc26                	sd	s1,56(sp)
    8000194c:	f84a                	sd	s2,48(sp)
    8000194e:	f44e                	sd	s3,40(sp)
    80001950:	f052                	sd	s4,32(sp)
    80001952:	ec56                	sd	s5,24(sp)
    80001954:	e85a                	sd	s6,16(sp)
    80001956:	e45e                	sd	s7,8(sp)
    80001958:	0880                	addi	s0,sp,80
    8000195a:	8a2a                	mv	s4,a0
    8000195c:	8b2e                	mv	s6,a1
    8000195e:	8bb2                	mv	s7,a2
    80001960:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001962:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001964:	6985                	lui	s3,0x1
    80001966:	a035                	j	80001992 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001968:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000196c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000196e:	0017b793          	seqz	a5,a5
    80001972:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001976:	60a6                	ld	ra,72(sp)
    80001978:	6406                	ld	s0,64(sp)
    8000197a:	74e2                	ld	s1,56(sp)
    8000197c:	7942                	ld	s2,48(sp)
    8000197e:	79a2                	ld	s3,40(sp)
    80001980:	7a02                	ld	s4,32(sp)
    80001982:	6ae2                	ld	s5,24(sp)
    80001984:	6b42                	ld	s6,16(sp)
    80001986:	6ba2                	ld	s7,8(sp)
    80001988:	6161                	addi	sp,sp,80
    8000198a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000198c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001990:	c8a9                	beqz	s1,800019e2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001992:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001996:	85ca                	mv	a1,s2
    80001998:	8552                	mv	a0,s4
    8000199a:	fffff097          	auipc	ra,0xfffff
    8000199e:	6c6080e7          	jalr	1734(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    800019a2:	c131                	beqz	a0,800019e6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800019a4:	41790833          	sub	a6,s2,s7
    800019a8:	984e                	add	a6,a6,s3
    if(n > max)
    800019aa:	0104f363          	bgeu	s1,a6,800019b0 <copyinstr+0x6e>
    800019ae:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019b0:	955e                	add	a0,a0,s7
    800019b2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019b6:	fc080be3          	beqz	a6,8000198c <copyinstr+0x4a>
    800019ba:	985a                	add	a6,a6,s6
    800019bc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019be:	41650633          	sub	a2,a0,s6
    800019c2:	14fd                	addi	s1,s1,-1
    800019c4:	9b26                	add	s6,s6,s1
    800019c6:	00f60733          	add	a4,a2,a5
    800019ca:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbf000>
    800019ce:	df49                	beqz	a4,80001968 <copyinstr+0x26>
        *dst = *p;
    800019d0:	00e78023          	sb	a4,0(a5)
      --max;
    800019d4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019d8:	0785                	addi	a5,a5,1
    while(n > 0){
    800019da:	ff0796e3          	bne	a5,a6,800019c6 <copyinstr+0x84>
      dst++;
    800019de:	8b42                	mv	s6,a6
    800019e0:	b775                	j	8000198c <copyinstr+0x4a>
    800019e2:	4781                	li	a5,0
    800019e4:	b769                	j	8000196e <copyinstr+0x2c>
      return -1;
    800019e6:	557d                	li	a0,-1
    800019e8:	b779                	j	80001976 <copyinstr+0x34>
  int got_null = 0;
    800019ea:	4781                	li	a5,0
  if(got_null){
    800019ec:	0017b793          	seqz	a5,a5
    800019f0:	40f00533          	neg	a0,a5
}
    800019f4:	8082                	ret

00000000800019f6 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800019f6:	7139                	addi	sp,sp,-64
    800019f8:	fc06                	sd	ra,56(sp)
    800019fa:	f822                	sd	s0,48(sp)
    800019fc:	f426                	sd	s1,40(sp)
    800019fe:	f04a                	sd	s2,32(sp)
    80001a00:	ec4e                	sd	s3,24(sp)
    80001a02:	e852                	sd	s4,16(sp)
    80001a04:	e456                	sd	s5,8(sp)
    80001a06:	e05a                	sd	s6,0(sp)
    80001a08:	0080                	addi	s0,sp,64
    80001a0a:	89aa                	mv	s3,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001a0c:	00011497          	auipc	s1,0x11
    80001a10:	cc448493          	addi	s1,s1,-828 # 800126d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a14:	8b26                	mv	s6,s1
    80001a16:	00007a97          	auipc	s5,0x7
    80001a1a:	5eaa8a93          	addi	s5,s5,1514 # 80009000 <etext>
    80001a1e:	04000937          	lui	s2,0x4000
    80001a22:	197d                	addi	s2,s2,-1
    80001a24:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a26:	00030a17          	auipc	s4,0x30
    80001a2a:	aaaa0a13          	addi	s4,s4,-1366 # 800314d0 <tickslock>
    char *pa = kalloc();
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	0a4080e7          	jalr	164(ra) # 80000ad2 <kalloc>
    80001a36:	862a                	mv	a2,a0
    if(pa == 0)
    80001a38:	c131                	beqz	a0,80001a7c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001a3a:	416485b3          	sub	a1,s1,s6
    80001a3e:	858d                	srai	a1,a1,0x3
    80001a40:	000ab783          	ld	a5,0(s5)
    80001a44:	02f585b3          	mul	a1,a1,a5
    80001a48:	2585                	addiw	a1,a1,1
    80001a4a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a4e:	4719                	li	a4,6
    80001a50:	6685                	lui	a3,0x1
    80001a52:	40b905b3          	sub	a1,s2,a1
    80001a56:	854e                	mv	a0,s3
    80001a58:	fffff097          	auipc	ra,0xfffff
    80001a5c:	720080e7          	jalr	1824(ra) # 80001178 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a60:	7b848493          	addi	s1,s1,1976
    80001a64:	fd4495e3          	bne	s1,s4,80001a2e <proc_mapstacks+0x38>
  }
}
    80001a68:	70e2                	ld	ra,56(sp)
    80001a6a:	7442                	ld	s0,48(sp)
    80001a6c:	74a2                	ld	s1,40(sp)
    80001a6e:	7902                	ld	s2,32(sp)
    80001a70:	69e2                	ld	s3,24(sp)
    80001a72:	6a42                	ld	s4,16(sp)
    80001a74:	6aa2                	ld	s5,8(sp)
    80001a76:	6b02                	ld	s6,0(sp)
    80001a78:	6121                	addi	sp,sp,64
    80001a7a:	8082                	ret
      panic("kalloc");
    80001a7c:	00007517          	auipc	a0,0x7
    80001a80:	7ec50513          	addi	a0,a0,2028 # 80009268 <digits+0x228>
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	aa6080e7          	jalr	-1370(ra) # 8000052a <panic>

0000000080001a8c <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001a8c:	7139                	addi	sp,sp,-64
    80001a8e:	fc06                	sd	ra,56(sp)
    80001a90:	f822                	sd	s0,48(sp)
    80001a92:	f426                	sd	s1,40(sp)
    80001a94:	f04a                	sd	s2,32(sp)
    80001a96:	ec4e                	sd	s3,24(sp)
    80001a98:	e852                	sd	s4,16(sp)
    80001a9a:	e456                	sd	s5,8(sp)
    80001a9c:	e05a                	sd	s6,0(sp)
    80001a9e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001aa0:	00007597          	auipc	a1,0x7
    80001aa4:	7d058593          	addi	a1,a1,2000 # 80009270 <digits+0x230>
    80001aa8:	00010517          	auipc	a0,0x10
    80001aac:	7f850513          	addi	a0,a0,2040 # 800122a0 <pid_lock>
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	082080e7          	jalr	130(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001ab8:	00007597          	auipc	a1,0x7
    80001abc:	7c058593          	addi	a1,a1,1984 # 80009278 <digits+0x238>
    80001ac0:	00010517          	auipc	a0,0x10
    80001ac4:	7f850513          	addi	a0,a0,2040 # 800122b8 <wait_lock>
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	06a080e7          	jalr	106(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad0:	00011497          	auipc	s1,0x11
    80001ad4:	c0048493          	addi	s1,s1,-1024 # 800126d0 <proc>
      initlock(&p->lock, "proc");
    80001ad8:	00007b17          	auipc	s6,0x7
    80001adc:	7b0b0b13          	addi	s6,s6,1968 # 80009288 <digits+0x248>
      p->kstack = KSTACK((int) (p - proc));
    80001ae0:	8aa6                	mv	s5,s1
    80001ae2:	00007a17          	auipc	s4,0x7
    80001ae6:	51ea0a13          	addi	s4,s4,1310 # 80009000 <etext>
    80001aea:	04000937          	lui	s2,0x4000
    80001aee:	197d                	addi	s2,s2,-1
    80001af0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af2:	00030997          	auipc	s3,0x30
    80001af6:	9de98993          	addi	s3,s3,-1570 # 800314d0 <tickslock>
      initlock(&p->lock, "proc");
    80001afa:	85da                	mv	a1,s6
    80001afc:	8526                	mv	a0,s1
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	034080e7          	jalr	52(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001b06:	415487b3          	sub	a5,s1,s5
    80001b0a:	878d                	srai	a5,a5,0x3
    80001b0c:	000a3703          	ld	a4,0(s4)
    80001b10:	02e787b3          	mul	a5,a5,a4
    80001b14:	2785                	addiw	a5,a5,1
    80001b16:	00d7979b          	slliw	a5,a5,0xd
    80001b1a:	40f907b3          	sub	a5,s2,a5
    80001b1e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b20:	7b848493          	addi	s1,s1,1976
    80001b24:	fd349be3          	bne	s1,s3,80001afa <procinit+0x6e>
  }
}
    80001b28:	70e2                	ld	ra,56(sp)
    80001b2a:	7442                	ld	s0,48(sp)
    80001b2c:	74a2                	ld	s1,40(sp)
    80001b2e:	7902                	ld	s2,32(sp)
    80001b30:	69e2                	ld	s3,24(sp)
    80001b32:	6a42                	ld	s4,16(sp)
    80001b34:	6aa2                	ld	s5,8(sp)
    80001b36:	6b02                	ld	s6,0(sp)
    80001b38:	6121                	addi	sp,sp,64
    80001b3a:	8082                	ret

0000000080001b3c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b3c:	1141                	addi	sp,sp,-16
    80001b3e:	e422                	sd	s0,8(sp)
    80001b40:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b42:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b44:	2501                	sext.w	a0,a0
    80001b46:	6422                	ld	s0,8(sp)
    80001b48:	0141                	addi	sp,sp,16
    80001b4a:	8082                	ret

0000000080001b4c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001b4c:	1141                	addi	sp,sp,-16
    80001b4e:	e422                	sd	s0,8(sp)
    80001b50:	0800                	addi	s0,sp,16
    80001b52:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b54:	2781                	sext.w	a5,a5
    80001b56:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b58:	00010517          	auipc	a0,0x10
    80001b5c:	77850513          	addi	a0,a0,1912 # 800122d0 <cpus>
    80001b60:	953e                	add	a0,a0,a5
    80001b62:	6422                	ld	s0,8(sp)
    80001b64:	0141                	addi	sp,sp,16
    80001b66:	8082                	ret

0000000080001b68 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	addi	s0,sp,32
  push_off();
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	004080e7          	jalr	4(ra) # 80000b76 <push_off>
    80001b7a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b7c:	2781                	sext.w	a5,a5
    80001b7e:	079e                	slli	a5,a5,0x7
    80001b80:	00010717          	auipc	a4,0x10
    80001b84:	72070713          	addi	a4,a4,1824 # 800122a0 <pid_lock>
    80001b88:	97ba                	add	a5,a5,a4
    80001b8a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	08a080e7          	jalr	138(ra) # 80000c16 <pop_off>
  return p;
}
    80001b94:	8526                	mv	a0,s1
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ba0:	1141                	addi	sp,sp,-16
    80001ba2:	e406                	sd	ra,8(sp)
    80001ba4:	e022                	sd	s0,0(sp)
    80001ba6:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	fc0080e7          	jalr	-64(ra) # 80001b68 <myproc>
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	0c6080e7          	jalr	198(ra) # 80000c76 <release>

  if (first) {
    80001bb8:	00008797          	auipc	a5,0x8
    80001bbc:	f287a783          	lw	a5,-216(a5) # 80009ae0 <first.1>
    80001bc0:	eb89                	bnez	a5,80001bd2 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001bc2:	00001097          	auipc	ra,0x1
    80001bc6:	45a080e7          	jalr	1114(ra) # 8000301c <usertrapret>
}
    80001bca:	60a2                	ld	ra,8(sp)
    80001bcc:	6402                	ld	s0,0(sp)
    80001bce:	0141                	addi	sp,sp,16
    80001bd0:	8082                	ret
    first = 0;
    80001bd2:	00008797          	auipc	a5,0x8
    80001bd6:	f007a723          	sw	zero,-242(a5) # 80009ae0 <first.1>
    fsinit(ROOTDEV);
    80001bda:	4505                	li	a0,1
    80001bdc:	00002097          	auipc	ra,0x2
    80001be0:	1d0080e7          	jalr	464(ra) # 80003dac <fsinit>
    80001be4:	bff9                	j	80001bc2 <forkret+0x22>

0000000080001be6 <allocpid>:
allocpid() {
    80001be6:	1101                	addi	sp,sp,-32
    80001be8:	ec06                	sd	ra,24(sp)
    80001bea:	e822                	sd	s0,16(sp)
    80001bec:	e426                	sd	s1,8(sp)
    80001bee:	e04a                	sd	s2,0(sp)
    80001bf0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bf2:	00010917          	auipc	s2,0x10
    80001bf6:	6ae90913          	addi	s2,s2,1710 # 800122a0 <pid_lock>
    80001bfa:	854a                	mv	a0,s2
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	fc6080e7          	jalr	-58(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001c04:	00008797          	auipc	a5,0x8
    80001c08:	ee078793          	addi	a5,a5,-288 # 80009ae4 <nextpid>
    80001c0c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c0e:	0014871b          	addiw	a4,s1,1
    80001c12:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c14:	854a                	mv	a0,s2
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	060080e7          	jalr	96(ra) # 80000c76 <release>
}
    80001c1e:	8526                	mv	a0,s1
    80001c20:	60e2                	ld	ra,24(sp)
    80001c22:	6442                	ld	s0,16(sp)
    80001c24:	64a2                	ld	s1,8(sp)
    80001c26:	6902                	ld	s2,0(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret

0000000080001c2c <proc_pagetable>:
{
    80001c2c:	1101                	addi	sp,sp,-32
    80001c2e:	ec06                	sd	ra,24(sp)
    80001c30:	e822                	sd	s0,16(sp)
    80001c32:	e426                	sd	s1,8(sp)
    80001c34:	e04a                	sd	s2,0(sp)
    80001c36:	1000                	addi	s0,sp,32
    80001c38:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	800080e7          	jalr	-2048(ra) # 8000143a <uvmcreate>
    80001c42:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c44:	c121                	beqz	a0,80001c84 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c46:	4729                	li	a4,10
    80001c48:	00006697          	auipc	a3,0x6
    80001c4c:	3b868693          	addi	a3,a3,952 # 80008000 <_trampoline>
    80001c50:	6605                	lui	a2,0x1
    80001c52:	040005b7          	lui	a1,0x4000
    80001c56:	15fd                	addi	a1,a1,-1
    80001c58:	05b2                	slli	a1,a1,0xc
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	490080e7          	jalr	1168(ra) # 800010ea <mappages>
    80001c62:	02054863          	bltz	a0,80001c92 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c66:	4719                	li	a4,6
    80001c68:	05893683          	ld	a3,88(s2)
    80001c6c:	6605                	lui	a2,0x1
    80001c6e:	020005b7          	lui	a1,0x2000
    80001c72:	15fd                	addi	a1,a1,-1
    80001c74:	05b6                	slli	a1,a1,0xd
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	472080e7          	jalr	1138(ra) # 800010ea <mappages>
    80001c80:	02054163          	bltz	a0,80001ca2 <proc_pagetable+0x76>
}
    80001c84:	8526                	mv	a0,s1
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
    uvmfree(pagetable, 0);
    80001c92:	4581                	li	a1,0
    80001c94:	8526                	mv	a0,s1
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	a20080e7          	jalr	-1504(ra) # 800016b6 <uvmfree>
    return 0;
    80001c9e:	4481                	li	s1,0
    80001ca0:	b7d5                	j	80001c84 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ca2:	4681                	li	a3,0
    80001ca4:	4605                	li	a2,1
    80001ca6:	040005b7          	lui	a1,0x4000
    80001caa:	15fd                	addi	a1,a1,-1
    80001cac:	05b2                	slli	a1,a1,0xc
    80001cae:	8526                	mv	a0,s1
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	5ee080e7          	jalr	1518(ra) # 8000129e <uvmunmap>
    uvmfree(pagetable, 0);
    80001cb8:	4581                	li	a1,0
    80001cba:	8526                	mv	a0,s1
    80001cbc:	00000097          	auipc	ra,0x0
    80001cc0:	9fa080e7          	jalr	-1542(ra) # 800016b6 <uvmfree>
    return 0;
    80001cc4:	4481                	li	s1,0
    80001cc6:	bf7d                	j	80001c84 <proc_pagetable+0x58>

0000000080001cc8 <proc_freepagetable>:
{
    80001cc8:	1101                	addi	sp,sp,-32
    80001cca:	ec06                	sd	ra,24(sp)
    80001ccc:	e822                	sd	s0,16(sp)
    80001cce:	e426                	sd	s1,8(sp)
    80001cd0:	e04a                	sd	s2,0(sp)
    80001cd2:	1000                	addi	s0,sp,32
    80001cd4:	84aa                	mv	s1,a0
    80001cd6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cd8:	4681                	li	a3,0
    80001cda:	4605                	li	a2,1
    80001cdc:	040005b7          	lui	a1,0x4000
    80001ce0:	15fd                	addi	a1,a1,-1
    80001ce2:	05b2                	slli	a1,a1,0xc
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	5ba080e7          	jalr	1466(ra) # 8000129e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cec:	4681                	li	a3,0
    80001cee:	4605                	li	a2,1
    80001cf0:	020005b7          	lui	a1,0x2000
    80001cf4:	15fd                	addi	a1,a1,-1
    80001cf6:	05b6                	slli	a1,a1,0xd
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	5a4080e7          	jalr	1444(ra) # 8000129e <uvmunmap>
  uvmfree(pagetable, sz);
    80001d02:	85ca                	mv	a1,s2
    80001d04:	8526                	mv	a0,s1
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	9b0080e7          	jalr	-1616(ra) # 800016b6 <uvmfree>
}
    80001d0e:	60e2                	ld	ra,24(sp)
    80001d10:	6442                	ld	s0,16(sp)
    80001d12:	64a2                	ld	s1,8(sp)
    80001d14:	6902                	ld	s2,0(sp)
    80001d16:	6105                	addi	sp,sp,32
    80001d18:	8082                	ret

0000000080001d1a <growproc>:
{
    80001d1a:	1101                	addi	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	e04a                	sd	s2,0(sp)
    80001d24:	1000                	addi	s0,sp,32
    80001d26:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d28:	00000097          	auipc	ra,0x0
    80001d2c:	e40080e7          	jalr	-448(ra) # 80001b68 <myproc>
    80001d30:	892a                	mv	s2,a0
  sz = p->sz;
    80001d32:	652c                	ld	a1,72(a0)
    80001d34:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d38:	00904f63          	bgtz	s1,80001d56 <growproc+0x3c>
  } else if(n < 0){
    80001d3c:	0204cc63          	bltz	s1,80001d74 <growproc+0x5a>
  p->sz = sz;
    80001d40:	1602                	slli	a2,a2,0x20
    80001d42:	9201                	srli	a2,a2,0x20
    80001d44:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d48:	4501                	li	a0,0
}
    80001d4a:	60e2                	ld	ra,24(sp)
    80001d4c:	6442                	ld	s0,16(sp)
    80001d4e:	64a2                	ld	s1,8(sp)
    80001d50:	6902                	ld	s2,0(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d56:	9e25                	addw	a2,a2,s1
    80001d58:	1602                	slli	a2,a2,0x20
    80001d5a:	9201                	srli	a2,a2,0x20
    80001d5c:	1582                	slli	a1,a1,0x20
    80001d5e:	9181                	srli	a1,a1,0x20
    80001d60:	6928                	ld	a0,80(a0)
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	7c0080e7          	jalr	1984(ra) # 80001522 <uvmalloc>
    80001d6a:	0005061b          	sext.w	a2,a0
    80001d6e:	fa69                	bnez	a2,80001d40 <growproc+0x26>
      return -1;
    80001d70:	557d                	li	a0,-1
    80001d72:	bfe1                	j	80001d4a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d74:	9e25                	addw	a2,a2,s1
    80001d76:	1602                	slli	a2,a2,0x20
    80001d78:	9201                	srli	a2,a2,0x20
    80001d7a:	1582                	slli	a1,a1,0x20
    80001d7c:	9181                	srli	a1,a1,0x20
    80001d7e:	6928                	ld	a0,80(a0)
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	75a080e7          	jalr	1882(ra) # 800014da <uvmdealloc>
    80001d88:	0005061b          	sext.w	a2,a0
    80001d8c:	bf55                	j	80001d40 <growproc+0x26>

0000000080001d8e <scheduler>:
{
    80001d8e:	7139                	addi	sp,sp,-64
    80001d90:	fc06                	sd	ra,56(sp)
    80001d92:	f822                	sd	s0,48(sp)
    80001d94:	f426                	sd	s1,40(sp)
    80001d96:	f04a                	sd	s2,32(sp)
    80001d98:	ec4e                	sd	s3,24(sp)
    80001d9a:	e852                	sd	s4,16(sp)
    80001d9c:	e456                	sd	s5,8(sp)
    80001d9e:	e05a                	sd	s6,0(sp)
    80001da0:	0080                	addi	s0,sp,64
    80001da2:	8792                	mv	a5,tp
  int id = r_tp();
    80001da4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001da6:	00779a93          	slli	s5,a5,0x7
    80001daa:	00010717          	auipc	a4,0x10
    80001dae:	4f670713          	addi	a4,a4,1270 # 800122a0 <pid_lock>
    80001db2:	9756                	add	a4,a4,s5
    80001db4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001db8:	00010717          	auipc	a4,0x10
    80001dbc:	52070713          	addi	a4,a4,1312 # 800122d8 <cpus+0x8>
    80001dc0:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001dc2:	498d                	li	s3,3
        p->state = RUNNING;
    80001dc4:	4b11                	li	s6,4
        c->proc = p;
    80001dc6:	079e                	slli	a5,a5,0x7
    80001dc8:	00010a17          	auipc	s4,0x10
    80001dcc:	4d8a0a13          	addi	s4,s4,1240 # 800122a0 <pid_lock>
    80001dd0:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dd2:	0002f917          	auipc	s2,0x2f
    80001dd6:	6fe90913          	addi	s2,s2,1790 # 800314d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dde:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de2:	10079073          	csrw	sstatus,a5
    80001de6:	00011497          	auipc	s1,0x11
    80001dea:	8ea48493          	addi	s1,s1,-1814 # 800126d0 <proc>
    80001dee:	a811                	j	80001e02 <scheduler+0x74>
      release(&p->lock);
    80001df0:	8526                	mv	a0,s1
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	e84080e7          	jalr	-380(ra) # 80000c76 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dfa:	7b848493          	addi	s1,s1,1976
    80001dfe:	fd248ee3          	beq	s1,s2,80001dda <scheduler+0x4c>
      acquire(&p->lock);
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	dbe080e7          	jalr	-578(ra) # 80000bc2 <acquire>
      if(p->state == RUNNABLE) {
    80001e0c:	4c9c                	lw	a5,24(s1)
    80001e0e:	ff3791e3          	bne	a5,s3,80001df0 <scheduler+0x62>
        p->state = RUNNING;
    80001e12:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001e16:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e1a:	06048593          	addi	a1,s1,96
    80001e1e:	8556                	mv	a0,s5
    80001e20:	00001097          	auipc	ra,0x1
    80001e24:	152080e7          	jalr	338(ra) # 80002f72 <swtch>
        c->proc = 0;
    80001e28:	020a3823          	sd	zero,48(s4)
    80001e2c:	b7d1                	j	80001df0 <scheduler+0x62>

0000000080001e2e <sched>:
{
    80001e2e:	7179                	addi	sp,sp,-48
    80001e30:	f406                	sd	ra,40(sp)
    80001e32:	f022                	sd	s0,32(sp)
    80001e34:	ec26                	sd	s1,24(sp)
    80001e36:	e84a                	sd	s2,16(sp)
    80001e38:	e44e                	sd	s3,8(sp)
    80001e3a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	d2c080e7          	jalr	-724(ra) # 80001b68 <myproc>
    80001e44:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	d02080e7          	jalr	-766(ra) # 80000b48 <holding>
    80001e4e:	c93d                	beqz	a0,80001ec4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e50:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e52:	2781                	sext.w	a5,a5
    80001e54:	079e                	slli	a5,a5,0x7
    80001e56:	00010717          	auipc	a4,0x10
    80001e5a:	44a70713          	addi	a4,a4,1098 # 800122a0 <pid_lock>
    80001e5e:	97ba                	add	a5,a5,a4
    80001e60:	0a87a703          	lw	a4,168(a5)
    80001e64:	4785                	li	a5,1
    80001e66:	06f71763          	bne	a4,a5,80001ed4 <sched+0xa6>
  if(p->state == RUNNING)
    80001e6a:	4c98                	lw	a4,24(s1)
    80001e6c:	4791                	li	a5,4
    80001e6e:	06f70b63          	beq	a4,a5,80001ee4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e72:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e76:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e78:	efb5                	bnez	a5,80001ef4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e7a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e7c:	00010917          	auipc	s2,0x10
    80001e80:	42490913          	addi	s2,s2,1060 # 800122a0 <pid_lock>
    80001e84:	2781                	sext.w	a5,a5
    80001e86:	079e                	slli	a5,a5,0x7
    80001e88:	97ca                	add	a5,a5,s2
    80001e8a:	0ac7a983          	lw	s3,172(a5)
    80001e8e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e90:	2781                	sext.w	a5,a5
    80001e92:	079e                	slli	a5,a5,0x7
    80001e94:	00010597          	auipc	a1,0x10
    80001e98:	44458593          	addi	a1,a1,1092 # 800122d8 <cpus+0x8>
    80001e9c:	95be                	add	a1,a1,a5
    80001e9e:	06048513          	addi	a0,s1,96
    80001ea2:	00001097          	auipc	ra,0x1
    80001ea6:	0d0080e7          	jalr	208(ra) # 80002f72 <swtch>
    80001eaa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eac:	2781                	sext.w	a5,a5
    80001eae:	079e                	slli	a5,a5,0x7
    80001eb0:	97ca                	add	a5,a5,s2
    80001eb2:	0b37a623          	sw	s3,172(a5)
}
    80001eb6:	70a2                	ld	ra,40(sp)
    80001eb8:	7402                	ld	s0,32(sp)
    80001eba:	64e2                	ld	s1,24(sp)
    80001ebc:	6942                	ld	s2,16(sp)
    80001ebe:	69a2                	ld	s3,8(sp)
    80001ec0:	6145                	addi	sp,sp,48
    80001ec2:	8082                	ret
    panic("sched p->lock");
    80001ec4:	00007517          	auipc	a0,0x7
    80001ec8:	3cc50513          	addi	a0,a0,972 # 80009290 <digits+0x250>
    80001ecc:	ffffe097          	auipc	ra,0xffffe
    80001ed0:	65e080e7          	jalr	1630(ra) # 8000052a <panic>
    panic("sched locks");
    80001ed4:	00007517          	auipc	a0,0x7
    80001ed8:	3cc50513          	addi	a0,a0,972 # 800092a0 <digits+0x260>
    80001edc:	ffffe097          	auipc	ra,0xffffe
    80001ee0:	64e080e7          	jalr	1614(ra) # 8000052a <panic>
    panic("sched running");
    80001ee4:	00007517          	auipc	a0,0x7
    80001ee8:	3cc50513          	addi	a0,a0,972 # 800092b0 <digits+0x270>
    80001eec:	ffffe097          	auipc	ra,0xffffe
    80001ef0:	63e080e7          	jalr	1598(ra) # 8000052a <panic>
    panic("sched interruptible");
    80001ef4:	00007517          	auipc	a0,0x7
    80001ef8:	3cc50513          	addi	a0,a0,972 # 800092c0 <digits+0x280>
    80001efc:	ffffe097          	auipc	ra,0xffffe
    80001f00:	62e080e7          	jalr	1582(ra) # 8000052a <panic>

0000000080001f04 <yield>:
{
    80001f04:	1101                	addi	sp,sp,-32
    80001f06:	ec06                	sd	ra,24(sp)
    80001f08:	e822                	sd	s0,16(sp)
    80001f0a:	e426                	sd	s1,8(sp)
    80001f0c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f0e:	00000097          	auipc	ra,0x0
    80001f12:	c5a080e7          	jalr	-934(ra) # 80001b68 <myproc>
    80001f16:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	caa080e7          	jalr	-854(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80001f20:	478d                	li	a5,3
    80001f22:	cc9c                	sw	a5,24(s1)
  sched();
    80001f24:	00000097          	auipc	ra,0x0
    80001f28:	f0a080e7          	jalr	-246(ra) # 80001e2e <sched>
  release(&p->lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	d48080e7          	jalr	-696(ra) # 80000c76 <release>
}
    80001f36:	60e2                	ld	ra,24(sp)
    80001f38:	6442                	ld	s0,16(sp)
    80001f3a:	64a2                	ld	s1,8(sp)
    80001f3c:	6105                	addi	sp,sp,32
    80001f3e:	8082                	ret

0000000080001f40 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f40:	7179                	addi	sp,sp,-48
    80001f42:	f406                	sd	ra,40(sp)
    80001f44:	f022                	sd	s0,32(sp)
    80001f46:	ec26                	sd	s1,24(sp)
    80001f48:	e84a                	sd	s2,16(sp)
    80001f4a:	e44e                	sd	s3,8(sp)
    80001f4c:	1800                	addi	s0,sp,48
    80001f4e:	89aa                	mv	s3,a0
    80001f50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	c16080e7          	jalr	-1002(ra) # 80001b68 <myproc>
    80001f5a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	c66080e7          	jalr	-922(ra) # 80000bc2 <acquire>
  release(lk);
    80001f64:	854a                	mv	a0,s2
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d10080e7          	jalr	-752(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80001f6e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f72:	4789                	li	a5,2
    80001f74:	cc9c                	sw	a5,24(s1)

  sched();
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	eb8080e7          	jalr	-328(ra) # 80001e2e <sched>

  // Tidy up.
  p->chan = 0;
    80001f7e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	cf2080e7          	jalr	-782(ra) # 80000c76 <release>
  acquire(lk);
    80001f8c:	854a                	mv	a0,s2
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	c34080e7          	jalr	-972(ra) # 80000bc2 <acquire>
}
    80001f96:	70a2                	ld	ra,40(sp)
    80001f98:	7402                	ld	s0,32(sp)
    80001f9a:	64e2                	ld	s1,24(sp)
    80001f9c:	6942                	ld	s2,16(sp)
    80001f9e:	69a2                	ld	s3,8(sp)
    80001fa0:	6145                	addi	sp,sp,48
    80001fa2:	8082                	ret

0000000080001fa4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001fa4:	7139                	addi	sp,sp,-64
    80001fa6:	fc06                	sd	ra,56(sp)
    80001fa8:	f822                	sd	s0,48(sp)
    80001faa:	f426                	sd	s1,40(sp)
    80001fac:	f04a                	sd	s2,32(sp)
    80001fae:	ec4e                	sd	s3,24(sp)
    80001fb0:	e852                	sd	s4,16(sp)
    80001fb2:	e456                	sd	s5,8(sp)
    80001fb4:	0080                	addi	s0,sp,64
    80001fb6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001fb8:	00010497          	auipc	s1,0x10
    80001fbc:	71848493          	addi	s1,s1,1816 # 800126d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fc0:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fc2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fc4:	0002f917          	auipc	s2,0x2f
    80001fc8:	50c90913          	addi	s2,s2,1292 # 800314d0 <tickslock>
    80001fcc:	a811                	j	80001fe0 <wakeup+0x3c>
      }
      release(&p->lock);
    80001fce:	8526                	mv	a0,s1
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	ca6080e7          	jalr	-858(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fd8:	7b848493          	addi	s1,s1,1976
    80001fdc:	03248663          	beq	s1,s2,80002008 <wakeup+0x64>
    if(p != myproc()){
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	b88080e7          	jalr	-1144(ra) # 80001b68 <myproc>
    80001fe8:	fea488e3          	beq	s1,a0,80001fd8 <wakeup+0x34>
      acquire(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	bd4080e7          	jalr	-1068(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001ff6:	4c9c                	lw	a5,24(s1)
    80001ff8:	fd379be3          	bne	a5,s3,80001fce <wakeup+0x2a>
    80001ffc:	709c                	ld	a5,32(s1)
    80001ffe:	fd4798e3          	bne	a5,s4,80001fce <wakeup+0x2a>
        p->state = RUNNABLE;
    80002002:	0154ac23          	sw	s5,24(s1)
    80002006:	b7e1                	j	80001fce <wakeup+0x2a>
    }
  }
}
    80002008:	70e2                	ld	ra,56(sp)
    8000200a:	7442                	ld	s0,48(sp)
    8000200c:	74a2                	ld	s1,40(sp)
    8000200e:	7902                	ld	s2,32(sp)
    80002010:	69e2                	ld	s3,24(sp)
    80002012:	6a42                	ld	s4,16(sp)
    80002014:	6aa2                	ld	s5,8(sp)
    80002016:	6121                	addi	sp,sp,64
    80002018:	8082                	ret

000000008000201a <reparent>:
{
    8000201a:	7179                	addi	sp,sp,-48
    8000201c:	f406                	sd	ra,40(sp)
    8000201e:	f022                	sd	s0,32(sp)
    80002020:	ec26                	sd	s1,24(sp)
    80002022:	e84a                	sd	s2,16(sp)
    80002024:	e44e                	sd	s3,8(sp)
    80002026:	e052                	sd	s4,0(sp)
    80002028:	1800                	addi	s0,sp,48
    8000202a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000202c:	00010497          	auipc	s1,0x10
    80002030:	6a448493          	addi	s1,s1,1700 # 800126d0 <proc>
      pp->parent = initproc;
    80002034:	00008a17          	auipc	s4,0x8
    80002038:	ffca0a13          	addi	s4,s4,-4 # 8000a030 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000203c:	0002f997          	auipc	s3,0x2f
    80002040:	49498993          	addi	s3,s3,1172 # 800314d0 <tickslock>
    80002044:	a029                	j	8000204e <reparent+0x34>
    80002046:	7b848493          	addi	s1,s1,1976
    8000204a:	01348d63          	beq	s1,s3,80002064 <reparent+0x4a>
    if(pp->parent == p){
    8000204e:	7c9c                	ld	a5,56(s1)
    80002050:	ff279be3          	bne	a5,s2,80002046 <reparent+0x2c>
      pp->parent = initproc;
    80002054:	000a3503          	ld	a0,0(s4)
    80002058:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	f4a080e7          	jalr	-182(ra) # 80001fa4 <wakeup>
    80002062:	b7d5                	j	80002046 <reparent+0x2c>
}
    80002064:	70a2                	ld	ra,40(sp)
    80002066:	7402                	ld	s0,32(sp)
    80002068:	64e2                	ld	s1,24(sp)
    8000206a:	6942                	ld	s2,16(sp)
    8000206c:	69a2                	ld	s3,8(sp)
    8000206e:	6a02                	ld	s4,0(sp)
    80002070:	6145                	addi	sp,sp,48
    80002072:	8082                	ret

0000000080002074 <exit>:
{
    80002074:	7179                	addi	sp,sp,-48
    80002076:	f406                	sd	ra,40(sp)
    80002078:	f022                	sd	s0,32(sp)
    8000207a:	ec26                	sd	s1,24(sp)
    8000207c:	e84a                	sd	s2,16(sp)
    8000207e:	e44e                	sd	s3,8(sp)
    80002080:	e052                	sd	s4,0(sp)
    80002082:	1800                	addi	s0,sp,48
    80002084:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002086:	00000097          	auipc	ra,0x0
    8000208a:	ae2080e7          	jalr	-1310(ra) # 80001b68 <myproc>
    8000208e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002090:	00008797          	auipc	a5,0x8
    80002094:	fa07b783          	ld	a5,-96(a5) # 8000a030 <initproc>
    80002098:	0d050493          	addi	s1,a0,208
    8000209c:	15050913          	addi	s2,a0,336
    800020a0:	02a79363          	bne	a5,a0,800020c6 <exit+0x52>
    panic("init exiting");
    800020a4:	00007517          	auipc	a0,0x7
    800020a8:	23450513          	addi	a0,a0,564 # 800092d8 <digits+0x298>
    800020ac:	ffffe097          	auipc	ra,0xffffe
    800020b0:	47e080e7          	jalr	1150(ra) # 8000052a <panic>
      fileclose(f);
    800020b4:	00003097          	auipc	ra,0x3
    800020b8:	124080e7          	jalr	292(ra) # 800051d8 <fileclose>
      p->ofile[fd] = 0;
    800020bc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020c0:	04a1                	addi	s1,s1,8
    800020c2:	01248563          	beq	s1,s2,800020cc <exit+0x58>
    if(p->ofile[fd]){
    800020c6:	6088                	ld	a0,0(s1)
    800020c8:	f575                	bnez	a0,800020b4 <exit+0x40>
    800020ca:	bfdd                	j	800020c0 <exit+0x4c>
  if (p->pid > 2) {
    800020cc:	0309a703          	lw	a4,48(s3)
    800020d0:	4789                	li	a5,2
    800020d2:	08e7c163          	blt	a5,a4,80002154 <exit+0xe0>
  begin_op();
    800020d6:	00003097          	auipc	ra,0x3
    800020da:	c36080e7          	jalr	-970(ra) # 80004d0c <begin_op>
  iput(p->cwd);
    800020de:	1509b503          	ld	a0,336(s3)
    800020e2:	00002097          	auipc	ra,0x2
    800020e6:	0fc080e7          	jalr	252(ra) # 800041de <iput>
  end_op();
    800020ea:	00003097          	auipc	ra,0x3
    800020ee:	ca2080e7          	jalr	-862(ra) # 80004d8c <end_op>
  p->cwd = 0;
    800020f2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020f6:	00010497          	auipc	s1,0x10
    800020fa:	1c248493          	addi	s1,s1,450 # 800122b8 <wait_lock>
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	ac2080e7          	jalr	-1342(ra) # 80000bc2 <acquire>
  reparent(p);
    80002108:	854e                	mv	a0,s3
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	f10080e7          	jalr	-240(ra) # 8000201a <reparent>
  wakeup(p->parent);
    80002112:	0389b503          	ld	a0,56(s3)
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	e8e080e7          	jalr	-370(ra) # 80001fa4 <wakeup>
  acquire(&p->lock);
    8000211e:	854e                	mv	a0,s3
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	aa2080e7          	jalr	-1374(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002128:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000212c:	4795                	li	a5,5
    8000212e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002132:	8526                	mv	a0,s1
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	b42080e7          	jalr	-1214(ra) # 80000c76 <release>
  sched();
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	cf2080e7          	jalr	-782(ra) # 80001e2e <sched>
  panic("zombie exit");
    80002144:	00007517          	auipc	a0,0x7
    80002148:	1a450513          	addi	a0,a0,420 # 800092e8 <digits+0x2a8>
    8000214c:	ffffe097          	auipc	ra,0xffffe
    80002150:	3de080e7          	jalr	990(ra) # 8000052a <panic>
	  removeSwapFile(p);
    80002154:	854e                	mv	a0,s3
    80002156:	00002097          	auipc	ra,0x2
    8000215a:	730080e7          	jalr	1840(ra) # 80004886 <removeSwapFile>
    8000215e:	bfa5                	j	800020d6 <exit+0x62>

0000000080002160 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002160:	7179                	addi	sp,sp,-48
    80002162:	f406                	sd	ra,40(sp)
    80002164:	f022                	sd	s0,32(sp)
    80002166:	ec26                	sd	s1,24(sp)
    80002168:	e84a                	sd	s2,16(sp)
    8000216a:	e44e                	sd	s3,8(sp)
    8000216c:	1800                	addi	s0,sp,48
    8000216e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002170:	00010497          	auipc	s1,0x10
    80002174:	56048493          	addi	s1,s1,1376 # 800126d0 <proc>
    80002178:	0002f997          	auipc	s3,0x2f
    8000217c:	35898993          	addi	s3,s3,856 # 800314d0 <tickslock>
    acquire(&p->lock);
    80002180:	8526                	mv	a0,s1
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	a40080e7          	jalr	-1472(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    8000218a:	589c                	lw	a5,48(s1)
    8000218c:	01278d63          	beq	a5,s2,800021a6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002190:	8526                	mv	a0,s1
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	ae4080e7          	jalr	-1308(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000219a:	7b848493          	addi	s1,s1,1976
    8000219e:	ff3491e3          	bne	s1,s3,80002180 <kill+0x20>
  }
  return -1;
    800021a2:	557d                	li	a0,-1
    800021a4:	a829                	j	800021be <kill+0x5e>
      p->killed = 1;
    800021a6:	4785                	li	a5,1
    800021a8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021aa:	4c98                	lw	a4,24(s1)
    800021ac:	4789                	li	a5,2
    800021ae:	00f70f63          	beq	a4,a5,800021cc <kill+0x6c>
      release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ac2080e7          	jalr	-1342(ra) # 80000c76 <release>
      return 0;
    800021bc:	4501                	li	a0,0
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6145                	addi	sp,sp,48
    800021ca:	8082                	ret
        p->state = RUNNABLE;
    800021cc:	478d                	li	a5,3
    800021ce:	cc9c                	sw	a5,24(s1)
    800021d0:	b7cd                	j	800021b2 <kill+0x52>

00000000800021d2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800021d2:	7179                	addi	sp,sp,-48
    800021d4:	f406                	sd	ra,40(sp)
    800021d6:	f022                	sd	s0,32(sp)
    800021d8:	ec26                	sd	s1,24(sp)
    800021da:	e84a                	sd	s2,16(sp)
    800021dc:	e44e                	sd	s3,8(sp)
    800021de:	e052                	sd	s4,0(sp)
    800021e0:	1800                	addi	s0,sp,48
    800021e2:	84aa                	mv	s1,a0
    800021e4:	892e                	mv	s2,a1
    800021e6:	89b2                	mv	s3,a2
    800021e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	97e080e7          	jalr	-1666(ra) # 80001b68 <myproc>
  if(user_dst){
    800021f2:	c08d                	beqz	s1,80002214 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800021f4:	86d2                	mv	a3,s4
    800021f6:	864e                	mv	a2,s3
    800021f8:	85ca                	mv	a1,s2
    800021fa:	6928                	ld	a0,80(a0)
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	62c080e7          	jalr	1580(ra) # 80001828 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002204:	70a2                	ld	ra,40(sp)
    80002206:	7402                	ld	s0,32(sp)
    80002208:	64e2                	ld	s1,24(sp)
    8000220a:	6942                	ld	s2,16(sp)
    8000220c:	69a2                	ld	s3,8(sp)
    8000220e:	6a02                	ld	s4,0(sp)
    80002210:	6145                	addi	sp,sp,48
    80002212:	8082                	ret
    memmove((char *)dst, src, len);
    80002214:	000a061b          	sext.w	a2,s4
    80002218:	85ce                	mv	a1,s3
    8000221a:	854a                	mv	a0,s2
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	afe080e7          	jalr	-1282(ra) # 80000d1a <memmove>
    return 0;
    80002224:	8526                	mv	a0,s1
    80002226:	bff9                	j	80002204 <either_copyout+0x32>

0000000080002228 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002228:	7179                	addi	sp,sp,-48
    8000222a:	f406                	sd	ra,40(sp)
    8000222c:	f022                	sd	s0,32(sp)
    8000222e:	ec26                	sd	s1,24(sp)
    80002230:	e84a                	sd	s2,16(sp)
    80002232:	e44e                	sd	s3,8(sp)
    80002234:	e052                	sd	s4,0(sp)
    80002236:	1800                	addi	s0,sp,48
    80002238:	892a                	mv	s2,a0
    8000223a:	84ae                	mv	s1,a1
    8000223c:	89b2                	mv	s3,a2
    8000223e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002240:	00000097          	auipc	ra,0x0
    80002244:	928080e7          	jalr	-1752(ra) # 80001b68 <myproc>
  if(user_src){
    80002248:	c08d                	beqz	s1,8000226a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000224a:	86d2                	mv	a3,s4
    8000224c:	864e                	mv	a2,s3
    8000224e:	85ca                	mv	a1,s2
    80002250:	6928                	ld	a0,80(a0)
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	662080e7          	jalr	1634(ra) # 800018b4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000225a:	70a2                	ld	ra,40(sp)
    8000225c:	7402                	ld	s0,32(sp)
    8000225e:	64e2                	ld	s1,24(sp)
    80002260:	6942                	ld	s2,16(sp)
    80002262:	69a2                	ld	s3,8(sp)
    80002264:	6a02                	ld	s4,0(sp)
    80002266:	6145                	addi	sp,sp,48
    80002268:	8082                	ret
    memmove(dst, (char*)src, len);
    8000226a:	000a061b          	sext.w	a2,s4
    8000226e:	85ce                	mv	a1,s3
    80002270:	854a                	mv	a0,s2
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	aa8080e7          	jalr	-1368(ra) # 80000d1a <memmove>
    return 0;
    8000227a:	8526                	mv	a0,s1
    8000227c:	bff9                	j	8000225a <either_copyin+0x32>

000000008000227e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000227e:	715d                	addi	sp,sp,-80
    80002280:	e486                	sd	ra,72(sp)
    80002282:	e0a2                	sd	s0,64(sp)
    80002284:	fc26                	sd	s1,56(sp)
    80002286:	f84a                	sd	s2,48(sp)
    80002288:	f44e                	sd	s3,40(sp)
    8000228a:	f052                	sd	s4,32(sp)
    8000228c:	ec56                	sd	s5,24(sp)
    8000228e:	e85a                	sd	s6,16(sp)
    80002290:	e45e                	sd	s7,8(sp)
    80002292:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002294:	00007517          	auipc	a0,0x7
    80002298:	19450513          	addi	a0,a0,404 # 80009428 <digits+0x3e8>
    8000229c:	ffffe097          	auipc	ra,0xffffe
    800022a0:	2d8080e7          	jalr	728(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a4:	00010497          	auipc	s1,0x10
    800022a8:	58448493          	addi	s1,s1,1412 # 80012828 <proc+0x158>
    800022ac:	0002f917          	auipc	s2,0x2f
    800022b0:	37c90913          	addi	s2,s2,892 # 80031628 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022b4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022b6:	00007997          	auipc	s3,0x7
    800022ba:	04298993          	addi	s3,s3,66 # 800092f8 <digits+0x2b8>
    printf("%d %s %s", p->pid, state, p->name);
    800022be:	00007a97          	auipc	s5,0x7
    800022c2:	042a8a93          	addi	s5,s5,66 # 80009300 <digits+0x2c0>
    printf("\n");
    800022c6:	00007a17          	auipc	s4,0x7
    800022ca:	162a0a13          	addi	s4,s4,354 # 80009428 <digits+0x3e8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ce:	00007b97          	auipc	s7,0x7
    800022d2:	282b8b93          	addi	s7,s7,642 # 80009550 <states.0>
    800022d6:	a00d                	j	800022f8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800022d8:	ed86a583          	lw	a1,-296(a3)
    800022dc:	8556                	mv	a0,s5
    800022de:	ffffe097          	auipc	ra,0xffffe
    800022e2:	296080e7          	jalr	662(ra) # 80000574 <printf>
    printf("\n");
    800022e6:	8552                	mv	a0,s4
    800022e8:	ffffe097          	auipc	ra,0xffffe
    800022ec:	28c080e7          	jalr	652(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f0:	7b848493          	addi	s1,s1,1976
    800022f4:	03248263          	beq	s1,s2,80002318 <procdump+0x9a>
    if(p->state == UNUSED)
    800022f8:	86a6                	mv	a3,s1
    800022fa:	ec04a783          	lw	a5,-320(s1)
    800022fe:	dbed                	beqz	a5,800022f0 <procdump+0x72>
      state = "???";
    80002300:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002302:	fcfb6be3          	bltu	s6,a5,800022d8 <procdump+0x5a>
    80002306:	02079713          	slli	a4,a5,0x20
    8000230a:	01d75793          	srli	a5,a4,0x1d
    8000230e:	97de                	add	a5,a5,s7
    80002310:	6390                	ld	a2,0(a5)
    80002312:	f279                	bnez	a2,800022d8 <procdump+0x5a>
      state = "???";
    80002314:	864e                	mv	a2,s3
    80002316:	b7c9                	j	800022d8 <procdump+0x5a>
  }
}
    80002318:	60a6                	ld	ra,72(sp)
    8000231a:	6406                	ld	s0,64(sp)
    8000231c:	74e2                	ld	s1,56(sp)
    8000231e:	7942                	ld	s2,48(sp)
    80002320:	79a2                	ld	s3,40(sp)
    80002322:	7a02                	ld	s4,32(sp)
    80002324:	6ae2                	ld	s5,24(sp)
    80002326:	6b42                	ld	s6,16(sp)
    80002328:	6ba2                	ld	s7,8(sp)
    8000232a:	6161                	addi	sp,sp,80
    8000232c:	8082                	ret

000000008000232e <find_free_index>:
 ///////////////////////// - swap functions - /////////////////////////
// #ifndef NONE


//returns a free index in page_struct array. which_arr==0 if it's physical memory, which_arr==1 if swapfile
 int find_free_index(struct page_struct* pagearr, int which_arr) {
    8000232e:	1141                	addi	sp,sp,-16
    80002330:	e422                	sd	s0,8(sp)
    80002332:	0800                	addi	s0,sp,16
    80002334:	87aa                	mv	a5,a0
  struct page_struct *arr;
  int i = 0;
  if(which_arr == 0){
    80002336:	ed89                	bnez	a1,80002350 <find_free_index+0x22>
    for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    80002338:	46c1                	li	a3,16
      // printf("pid: %d, i: %d, pagearr[i].isAvailable: %d\n",myproc()->pid, i, pagearr[i].isAvailable);
      if(arr->isAvailable){
    8000233a:	4398                	lw	a4,0(a5)
    8000233c:	e70d                	bnez	a4,80002366 <find_free_index+0x38>
        return i;
      }
      i++;
    8000233e:	2585                	addiw	a1,a1,1
    for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    80002340:	03078793          	addi	a5,a5,48
    80002344:	fed59be3          	bne	a1,a3,8000233a <find_free_index+0xc>
        return i;
      }
      i++;
    }
  }
  return -1; //in case there no space
    80002348:	557d                	li	a0,-1
 }
    8000234a:	6422                	ld	s0,8(sp)
    8000234c:	0141                	addi	sp,sp,16
    8000234e:	8082                	ret
  int i = 0;
    80002350:	4501                	li	a0,0
    for(arr = pagearr; arr < &pagearr[MAX_SWAP_PAGES]; arr++){
    80002352:	46c5                	li	a3,17
      if(arr->isAvailable){
    80002354:	4398                	lw	a4,0(a5)
    80002356:	fb75                	bnez	a4,8000234a <find_free_index+0x1c>
      i++;
    80002358:	2505                	addiw	a0,a0,1
    for(arr = pagearr; arr < &pagearr[MAX_SWAP_PAGES]; arr++){
    8000235a:	03078793          	addi	a5,a5,48
    8000235e:	fed51be3          	bne	a0,a3,80002354 <find_free_index+0x26>
  return -1; //in case there no space
    80002362:	557d                	li	a0,-1
    80002364:	b7dd                	j	8000234a <find_free_index+0x1c>
    80002366:	852e                	mv	a0,a1
    80002368:	b7cd                	j	8000234a <find_free_index+0x1c>

000000008000236a <init_meta_data>:

 void init_meta_data(struct proc* p) {
    8000236a:	1141                	addi	sp,sp,-16
    8000236c:	e422                	sd	s0,8(sp)
    8000236e:	0800                	addi	s0,sp,16
  p->num_of_pages = 0;
    80002370:	7a052023          	sw	zero,1952(a0)
  p->num_of_pages_in_phys = 0;
    80002374:	7a052223          	sw	zero,1956(a0)
  struct page_struct *pa_swap;
  // printf("allocproc, p->pid: %d, p->files_in_swap: %d\n", p->pid, p->files_in_swap);
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_SWAP_PAGES] ; pa_swap++) {
    80002378:	17050793          	addi	a5,a0,368
    8000237c:	4a050713          	addi	a4,a0,1184
    80002380:	883a                	mv	a6,a4
    pa_swap->pagetable = p->pagetable;
    pa_swap->isAvailable = 1;
    80002382:	4585                	li	a1,1

    pa_swap->va = -1;
    80002384:	56fd                	li	a3,-1
    pa_swap->pagetable = p->pagetable;
    80002386:	6930                	ld	a2,80(a0)
    80002388:	e790                	sd	a2,8(a5)
    pa_swap->isAvailable = 1;
    8000238a:	c38c                	sw	a1,0(a5)
    pa_swap->va = -1;
    8000238c:	ef94                	sd	a3,24(a5)
    pa_swap->offset = -1;
    8000238e:	d394                	sw	a3,32(a5)
    #ifdef NFUA
     pa_swap->counter_NFUA = 0;
    #endif
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
    80002390:	d794                	sw	a3,40(a5)
      pa_swap->index_of_next_p = -1;
    80002392:	d3d4                	sw	a3,36(a5)
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_SWAP_PAGES] ; pa_swap++) {
    80002394:	03078793          	addi	a5,a5,48
    80002398:	ff0797e3          	bne	a5,a6,80002386 <init_meta_data+0x1c>
    #endif
  }

  struct page_struct *pa_psyc;

  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    8000239c:	7a050593          	addi	a1,a0,1952
    pa_psyc->pagetable = p->pagetable;
    pa_psyc->isAvailable = 1;
    800023a0:	4605                	li	a2,1
    pa_psyc->va = -1;
    800023a2:	57fd                	li	a5,-1
    pa_psyc->pagetable = p->pagetable;
    800023a4:	6934                	ld	a3,80(a0)
    800023a6:	e714                	sd	a3,8(a4)
    pa_psyc->isAvailable = 1;
    800023a8:	c310                	sw	a2,0(a4)
    pa_psyc->va = -1;
    800023aa:	ef1c                	sd	a5,24(a4)
    pa_psyc->offset = -1;
    800023ac:	d31c                	sw	a5,32(a4)
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
    800023ae:	4cf52423          	sw	a5,1224(a0)
      pa_swap->index_of_next_p = -1;
    800023b2:	4cf52223          	sw	a5,1220(a0)
  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    800023b6:	03070713          	addi	a4,a4,48
    800023ba:	fee595e3          	bne	a1,a4,800023a4 <init_meta_data+0x3a>
    #endif
  }

  #ifdef SCFIFO
    p->index_of_head_p = -1;  //no pages in ram so no head
    800023be:	57fd                	li	a5,-1
    800023c0:	7af52823          	sw	a5,1968(a0)
  #endif
}
    800023c4:	6422                	ld	s0,8(sp)
    800023c6:	0141                	addi	sp,sp,16
    800023c8:	8082                	ret

00000000800023ca <freeproc>:
{
    800023ca:	1101                	addi	sp,sp,-32
    800023cc:	ec06                	sd	ra,24(sp)
    800023ce:	e822                	sd	s0,16(sp)
    800023d0:	e426                	sd	s1,8(sp)
    800023d2:	1000                	addi	s0,sp,32
    800023d4:	84aa                	mv	s1,a0
  if(p->trapframe)
    800023d6:	6d28                	ld	a0,88(a0)
    800023d8:	c509                	beqz	a0,800023e2 <freeproc+0x18>
    kfree((void*)p->trapframe);
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	5fc080e7          	jalr	1532(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    800023e2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800023e6:	68a8                	ld	a0,80(s1)
    800023e8:	c511                	beqz	a0,800023f4 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800023ea:	64ac                	ld	a1,72(s1)
    800023ec:	00000097          	auipc	ra,0x0
    800023f0:	8dc080e7          	jalr	-1828(ra) # 80001cc8 <proc_freepagetable>
  p->pagetable = 0;
    800023f4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800023f8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800023fc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80002400:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80002404:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80002408:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000240c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80002410:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80002414:	0004ac23          	sw	zero,24(s1)
  init_meta_data(p); //TODO not sure
    80002418:	8526                	mv	a0,s1
    8000241a:	00000097          	auipc	ra,0x0
    8000241e:	f50080e7          	jalr	-176(ra) # 8000236a <init_meta_data>
  p->num_of_pages = 0;
    80002422:	7a04a023          	sw	zero,1952(s1)
}
    80002426:	60e2                	ld	ra,24(sp)
    80002428:	6442                	ld	s0,16(sp)
    8000242a:	64a2                	ld	s1,8(sp)
    8000242c:	6105                	addi	sp,sp,32
    8000242e:	8082                	ret

0000000080002430 <wait>:
{
    80002430:	715d                	addi	sp,sp,-80
    80002432:	e486                	sd	ra,72(sp)
    80002434:	e0a2                	sd	s0,64(sp)
    80002436:	fc26                	sd	s1,56(sp)
    80002438:	f84a                	sd	s2,48(sp)
    8000243a:	f44e                	sd	s3,40(sp)
    8000243c:	f052                	sd	s4,32(sp)
    8000243e:	ec56                	sd	s5,24(sp)
    80002440:	e85a                	sd	s6,16(sp)
    80002442:	e45e                	sd	s7,8(sp)
    80002444:	e062                	sd	s8,0(sp)
    80002446:	0880                	addi	s0,sp,80
    80002448:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	71e080e7          	jalr	1822(ra) # 80001b68 <myproc>
    80002452:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002454:	00010517          	auipc	a0,0x10
    80002458:	e6450513          	addi	a0,a0,-412 # 800122b8 <wait_lock>
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	766080e7          	jalr	1894(ra) # 80000bc2 <acquire>
    havekids = 0;
    80002464:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002466:	4a15                	li	s4,5
        havekids = 1;
    80002468:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000246a:	0002f997          	auipc	s3,0x2f
    8000246e:	06698993          	addi	s3,s3,102 # 800314d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002472:	00010c17          	auipc	s8,0x10
    80002476:	e46c0c13          	addi	s8,s8,-442 # 800122b8 <wait_lock>
    havekids = 0;
    8000247a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000247c:	00010497          	auipc	s1,0x10
    80002480:	25448493          	addi	s1,s1,596 # 800126d0 <proc>
    80002484:	a0bd                	j	800024f2 <wait+0xc2>
          pid = np->pid;
    80002486:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000248a:	000b0e63          	beqz	s6,800024a6 <wait+0x76>
    8000248e:	4691                	li	a3,4
    80002490:	02c48613          	addi	a2,s1,44
    80002494:	85da                	mv	a1,s6
    80002496:	05093503          	ld	a0,80(s2)
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	38e080e7          	jalr	910(ra) # 80001828 <copyout>
    800024a2:	02054563          	bltz	a0,800024cc <wait+0x9c>
          freeproc(np);
    800024a6:	8526                	mv	a0,s1
    800024a8:	00000097          	auipc	ra,0x0
    800024ac:	f22080e7          	jalr	-222(ra) # 800023ca <freeproc>
          release(&np->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	7c4080e7          	jalr	1988(ra) # 80000c76 <release>
          release(&wait_lock);
    800024ba:	00010517          	auipc	a0,0x10
    800024be:	dfe50513          	addi	a0,a0,-514 # 800122b8 <wait_lock>
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7b4080e7          	jalr	1972(ra) # 80000c76 <release>
          return pid;
    800024ca:	a09d                	j	80002530 <wait+0x100>
            release(&np->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	7a8080e7          	jalr	1960(ra) # 80000c76 <release>
            release(&wait_lock);
    800024d6:	00010517          	auipc	a0,0x10
    800024da:	de250513          	addi	a0,a0,-542 # 800122b8 <wait_lock>
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	798080e7          	jalr	1944(ra) # 80000c76 <release>
            return -1;
    800024e6:	59fd                	li	s3,-1
    800024e8:	a0a1                	j	80002530 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800024ea:	7b848493          	addi	s1,s1,1976
    800024ee:	03348463          	beq	s1,s3,80002516 <wait+0xe6>
      if(np->parent == p){
    800024f2:	7c9c                	ld	a5,56(s1)
    800024f4:	ff279be3          	bne	a5,s2,800024ea <wait+0xba>
        acquire(&np->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	6c8080e7          	jalr	1736(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002502:	4c9c                	lw	a5,24(s1)
    80002504:	f94781e3          	beq	a5,s4,80002486 <wait+0x56>
        release(&np->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	76c080e7          	jalr	1900(ra) # 80000c76 <release>
        havekids = 1;
    80002512:	8756                	mv	a4,s5
    80002514:	bfd9                	j	800024ea <wait+0xba>
    if(!havekids || p->killed){
    80002516:	c701                	beqz	a4,8000251e <wait+0xee>
    80002518:	02892783          	lw	a5,40(s2)
    8000251c:	c79d                	beqz	a5,8000254a <wait+0x11a>
      release(&wait_lock);
    8000251e:	00010517          	auipc	a0,0x10
    80002522:	d9a50513          	addi	a0,a0,-614 # 800122b8 <wait_lock>
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	750080e7          	jalr	1872(ra) # 80000c76 <release>
      return -1;
    8000252e:	59fd                	li	s3,-1
}
    80002530:	854e                	mv	a0,s3
    80002532:	60a6                	ld	ra,72(sp)
    80002534:	6406                	ld	s0,64(sp)
    80002536:	74e2                	ld	s1,56(sp)
    80002538:	7942                	ld	s2,48(sp)
    8000253a:	79a2                	ld	s3,40(sp)
    8000253c:	7a02                	ld	s4,32(sp)
    8000253e:	6ae2                	ld	s5,24(sp)
    80002540:	6b42                	ld	s6,16(sp)
    80002542:	6ba2                	ld	s7,8(sp)
    80002544:	6c02                	ld	s8,0(sp)
    80002546:	6161                	addi	sp,sp,80
    80002548:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000254a:	85e2                	mv	a1,s8
    8000254c:	854a                	mv	a0,s2
    8000254e:	00000097          	auipc	ra,0x0
    80002552:	9f2080e7          	jalr	-1550(ra) # 80001f40 <sleep>
    havekids = 0;
    80002556:	b715                	j	8000247a <wait+0x4a>

0000000080002558 <allocproc>:
{
    80002558:	1101                	addi	sp,sp,-32
    8000255a:	ec06                	sd	ra,24(sp)
    8000255c:	e822                	sd	s0,16(sp)
    8000255e:	e426                	sd	s1,8(sp)
    80002560:	e04a                	sd	s2,0(sp)
    80002562:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002564:	00010497          	auipc	s1,0x10
    80002568:	16c48493          	addi	s1,s1,364 # 800126d0 <proc>
    8000256c:	0002f917          	auipc	s2,0x2f
    80002570:	f6490913          	addi	s2,s2,-156 # 800314d0 <tickslock>
    acquire(&p->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	64c080e7          	jalr	1612(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    8000257e:	4c9c                	lw	a5,24(s1)
    80002580:	cf81                	beqz	a5,80002598 <allocproc+0x40>
      release(&p->lock);
    80002582:	8526                	mv	a0,s1
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	6f2080e7          	jalr	1778(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000258c:	7b848493          	addi	s1,s1,1976
    80002590:	ff2492e3          	bne	s1,s2,80002574 <allocproc+0x1c>
  return 0;
    80002594:	4481                	li	s1,0
    80002596:	a059                	j	8000261c <allocproc+0xc4>
  p->pid = allocpid();
    80002598:	fffff097          	auipc	ra,0xfffff
    8000259c:	64e080e7          	jalr	1614(ra) # 80001be6 <allocpid>
    800025a0:	d888                	sw	a0,48(s1)
  p->state = USED;
    800025a2:	4785                	li	a5,1
    800025a4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	52c080e7          	jalr	1324(ra) # 80000ad2 <kalloc>
    800025ae:	892a                	mv	s2,a0
    800025b0:	eca8                	sd	a0,88(s1)
    800025b2:	cd25                	beqz	a0,8000262a <allocproc+0xd2>
  p->pagetable = proc_pagetable(p);
    800025b4:	8526                	mv	a0,s1
    800025b6:	fffff097          	auipc	ra,0xfffff
    800025ba:	676080e7          	jalr	1654(ra) # 80001c2c <proc_pagetable>
    800025be:	892a                	mv	s2,a0
    800025c0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800025c2:	c141                	beqz	a0,80002642 <allocproc+0xea>
  memset(&p->context, 0, sizeof(p->context));
    800025c4:	07000613          	li	a2,112
    800025c8:	4581                	li	a1,0
    800025ca:	06048513          	addi	a0,s1,96
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	6f0080e7          	jalr	1776(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    800025d6:	fffff797          	auipc	a5,0xfffff
    800025da:	5ca78793          	addi	a5,a5,1482 # 80001ba0 <forkret>
    800025de:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800025e0:	60bc                	ld	a5,64(s1)
    800025e2:	6705                	lui	a4,0x1
    800025e4:	97ba                	add	a5,a5,a4
    800025e6:	f4bc                	sd	a5,104(s1)
  if (p->pid > 2){
    800025e8:	5898                	lw	a4,48(s1)
    800025ea:	4789                	li	a5,2
    800025ec:	02e7d363          	bge	a5,a4,80002612 <allocproc+0xba>
    release(&p->lock);
    800025f0:	8526                	mv	a0,s1
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	684080e7          	jalr	1668(ra) # 80000c76 <release>
    if(createSwapFile(p) < 0)
    800025fa:	8526                	mv	a0,s1
    800025fc:	00002097          	auipc	ra,0x2
    80002600:	432080e7          	jalr	1074(ra) # 80004a2e <createSwapFile>
    80002604:	04054b63          	bltz	a0,8000265a <allocproc+0x102>
    acquire(&p->lock);
    80002608:	8526                	mv	a0,s1
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	5b8080e7          	jalr	1464(ra) # 80000bc2 <acquire>
  init_meta_data(p);
    80002612:	8526                	mv	a0,s1
    80002614:	00000097          	auipc	ra,0x0
    80002618:	d56080e7          	jalr	-682(ra) # 8000236a <init_meta_data>
}
    8000261c:	8526                	mv	a0,s1
    8000261e:	60e2                	ld	ra,24(sp)
    80002620:	6442                	ld	s0,16(sp)
    80002622:	64a2                	ld	s1,8(sp)
    80002624:	6902                	ld	s2,0(sp)
    80002626:	6105                	addi	sp,sp,32
    80002628:	8082                	ret
    freeproc(p);
    8000262a:	8526                	mv	a0,s1
    8000262c:	00000097          	auipc	ra,0x0
    80002630:	d9e080e7          	jalr	-610(ra) # 800023ca <freeproc>
    release(&p->lock);
    80002634:	8526                	mv	a0,s1
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	640080e7          	jalr	1600(ra) # 80000c76 <release>
    return 0;
    8000263e:	84ca                	mv	s1,s2
    80002640:	bff1                	j	8000261c <allocproc+0xc4>
    freeproc(p);
    80002642:	8526                	mv	a0,s1
    80002644:	00000097          	auipc	ra,0x0
    80002648:	d86080e7          	jalr	-634(ra) # 800023ca <freeproc>
    release(&p->lock);
    8000264c:	8526                	mv	a0,s1
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	628080e7          	jalr	1576(ra) # 80000c76 <release>
    return 0;
    80002656:	84ca                	mv	s1,s2
    80002658:	b7d1                	j	8000261c <allocproc+0xc4>
      panic("allocproc swapfile creation failed\n");
    8000265a:	00007517          	auipc	a0,0x7
    8000265e:	cb650513          	addi	a0,a0,-842 # 80009310 <digits+0x2d0>
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	ec8080e7          	jalr	-312(ra) # 8000052a <panic>

000000008000266a <userinit>:
{
    8000266a:	1101                	addi	sp,sp,-32
    8000266c:	ec06                	sd	ra,24(sp)
    8000266e:	e822                	sd	s0,16(sp)
    80002670:	e426                	sd	s1,8(sp)
    80002672:	1000                	addi	s0,sp,32
  p = allocproc();
    80002674:	00000097          	auipc	ra,0x0
    80002678:	ee4080e7          	jalr	-284(ra) # 80002558 <allocproc>
    8000267c:	84aa                	mv	s1,a0
  initproc = p;
    8000267e:	00008797          	auipc	a5,0x8
    80002682:	9aa7b923          	sd	a0,-1614(a5) # 8000a030 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002686:	03400613          	li	a2,52
    8000268a:	00007597          	auipc	a1,0x7
    8000268e:	46658593          	addi	a1,a1,1126 # 80009af0 <initcode>
    80002692:	6928                	ld	a0,80(a0)
    80002694:	fffff097          	auipc	ra,0xfffff
    80002698:	dd4080e7          	jalr	-556(ra) # 80001468 <uvminit>
  p->sz = PGSIZE;
    8000269c:	6785                	lui	a5,0x1
    8000269e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800026a0:	6cb8                	ld	a4,88(s1)
    800026a2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800026a6:	6cb8                	ld	a4,88(s1)
    800026a8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800026aa:	4641                	li	a2,16
    800026ac:	00007597          	auipc	a1,0x7
    800026b0:	c8c58593          	addi	a1,a1,-884 # 80009338 <digits+0x2f8>
    800026b4:	15848513          	addi	a0,s1,344
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	758080e7          	jalr	1880(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    800026c0:	00007517          	auipc	a0,0x7
    800026c4:	c8850513          	addi	a0,a0,-888 # 80009348 <digits+0x308>
    800026c8:	00002097          	auipc	ra,0x2
    800026cc:	112080e7          	jalr	274(ra) # 800047da <namei>
    800026d0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800026d4:	478d                	li	a5,3
    800026d6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	59c080e7          	jalr	1436(ra) # 80000c76 <release>
}
    800026e2:	60e2                	ld	ra,24(sp)
    800026e4:	6442                	ld	s0,16(sp)
    800026e6:	64a2                	ld	s1,8(sp)
    800026e8:	6105                	addi	sp,sp,32
    800026ea:	8082                	ret

00000000800026ec <add_page_to_phys>:

 /*
  Adds a page_struct (for the given va) to ram array
 */
int add_page_to_phys(struct proc* p, pagetable_t pagetable, uint64 va) {
    800026ec:	7139                	addi	sp,sp,-64
    800026ee:	fc06                	sd	ra,56(sp)
    800026f0:	f822                	sd	s0,48(sp)
    800026f2:	f426                	sd	s1,40(sp)
    800026f4:	f04a                	sd	s2,32(sp)
    800026f6:	ec4e                	sd	s3,24(sp)
    800026f8:	e852                	sd	s4,16(sp)
    800026fa:	e456                	sd	s5,8(sp)
    800026fc:	0080                	addi	s0,sp,64
    800026fe:	84aa                	mv	s1,a0
    80002700:	8aae                	mv	s5,a1
    80002702:	8a32                	mv	s4,a2

  int index = find_free_index(p->files_in_physicalmem, 0);
    80002704:	4581                	li	a1,0
    80002706:	4a050513          	addi	a0,a0,1184
    8000270a:	00000097          	auipc	ra,0x0
    8000270e:	c24080e7          	jalr	-988(ra) # 8000232e <find_free_index>

  if (index == -1){
    80002712:	57fd                	li	a5,-1
    80002714:	0af50163          	beq	a0,a5,800027b6 <add_page_to_phys+0xca>
    80002718:	89aa                	mv	s3,a0
    panic("no free index in ram\n");
  }

  p->files_in_physicalmem[index].isAvailable = 0;
    8000271a:	00151913          	slli	s2,a0,0x1
    8000271e:	992a                	add	s2,s2,a0
    80002720:	0912                	slli	s2,s2,0x4
    80002722:	9926                	add	s2,s2,s1
    80002724:	4a092023          	sw	zero,1184(s2)
  p->files_in_physicalmem[index].pagetable = pagetable;
    80002728:	4b593423          	sd	s5,1192(s2)
  p->files_in_physicalmem[index].page = walk(pagetable, va, 0);
    8000272c:	4601                	li	a2,0
    8000272e:	85d2                	mv	a1,s4
    80002730:	8556                	mv	a0,s5
    80002732:	fffff097          	auipc	ra,0xfffff
    80002736:	874080e7          	jalr	-1932(ra) # 80000fa6 <walk>
    8000273a:	4aa93823          	sd	a0,1200(s2)
  p->files_in_physicalmem[index].va = va;
    8000273e:	4b493c23          	sd	s4,1208(s2)
  p->files_in_physicalmem[index].offset = -1;   //offset is a field for files in swap_file only
    80002742:	57fd                	li	a5,-1
    80002744:	4cf92023          	sw	a5,1216(s2)
    p->files_in_physicalmem[index].counter_LAPA = -1;
  #endif

  #ifdef SCFIFO
    //if this is the first page added to ram aray, initialize values accordingly
    if(p->index_of_head_p == -1){
    80002748:	7b04a683          	lw	a3,1968(s1)
    8000274c:	06f68d63          	beq	a3,a5,800027c6 <add_page_to_phys+0xda>
      p->files_in_physicalmem[index].index_of_prev_p = index;
      p->files_in_physicalmem[index].index_of_next_p = index;
    }
    else {
      //head's previous prev is curr's new prev
      p->files_in_physicalmem[index].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
    80002750:	00169713          	slli	a4,a3,0x1
    80002754:	00d707b3          	add	a5,a4,a3
    80002758:	0792                	slli	a5,a5,0x4
    8000275a:	97a6                	add	a5,a5,s1
    8000275c:	4c87a603          	lw	a2,1224(a5) # 14c8 <_entry-0x7fffeb38>
    80002760:	00199793          	slli	a5,s3,0x1
    80002764:	97ce                	add	a5,a5,s3
    80002766:	0792                	slli	a5,a5,0x4
    80002768:	97a6                	add	a5,a5,s1
    8000276a:	4cc7a423          	sw	a2,1224(a5)
      //curr is last. curr's next is head
      p->files_in_physicalmem[index].index_of_next_p = p->index_of_head_p;
    8000276e:	4cd7a223          	sw	a3,1220(a5)
      //head's prev is curr
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = index;
    80002772:	9736                	add	a4,a4,a3
    80002774:	0712                	slli	a4,a4,0x4
    80002776:	9726                	add	a4,a4,s1
    80002778:	4d372423          	sw	s3,1224(a4)
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[index].index_of_prev_p].index_of_next_p = index;
    8000277c:	4c87a703          	lw	a4,1224(a5)
    80002780:	00171793          	slli	a5,a4,0x1
    80002784:	97ba                	add	a5,a5,a4
    80002786:	0792                	slli	a5,a5,0x4
    80002788:	97a6                	add	a5,a5,s1
    8000278a:	4d37a223          	sw	s3,1220(a5)
    }
  #endif

  p->num_of_pages++;
    8000278e:	7a04a783          	lw	a5,1952(s1)
    80002792:	2785                	addiw	a5,a5,1
    80002794:	7af4a023          	sw	a5,1952(s1)
  p->num_of_pages_in_phys++;
    80002798:	7a44a783          	lw	a5,1956(s1)
    8000279c:	2785                	addiw	a5,a5,1
    8000279e:	7af4a223          	sw	a5,1956(s1)
  return 0;
}
    800027a2:	4501                	li	a0,0
    800027a4:	70e2                	ld	ra,56(sp)
    800027a6:	7442                	ld	s0,48(sp)
    800027a8:	74a2                	ld	s1,40(sp)
    800027aa:	7902                	ld	s2,32(sp)
    800027ac:	69e2                	ld	s3,24(sp)
    800027ae:	6a42                	ld	s4,16(sp)
    800027b0:	6aa2                	ld	s5,8(sp)
    800027b2:	6121                	addi	sp,sp,64
    800027b4:	8082                	ret
    panic("no free index in ram\n");
    800027b6:	00007517          	auipc	a0,0x7
    800027ba:	b9a50513          	addi	a0,a0,-1126 # 80009350 <digits+0x310>
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	d6c080e7          	jalr	-660(ra) # 8000052a <panic>
      p->index_of_head_p = index;
    800027c6:	7b34a823          	sw	s3,1968(s1)
      p->files_in_physicalmem[index].index_of_prev_p = index;
    800027ca:	4d392423          	sw	s3,1224(s2)
      p->files_in_physicalmem[index].index_of_next_p = index;
    800027ce:	4d392223          	sw	s3,1220(s2)
    800027d2:	bf75                	j	8000278e <add_page_to_phys+0xa2>

00000000800027d4 <find_index_file_arr>:


int find_index_file_arr(struct proc* p, uint64 address) {
    800027d4:	1141                	addi	sp,sp,-16
    800027d6:	e422                	sd	s0,8(sp)
    800027d8:	0800                	addi	s0,sp,16
  // uint64 va = PGROUNDDOWN(address);
  for (int i=0; i<MAX_SWAP_PAGES; i++) {
    800027da:	17050793          	addi	a5,a0,368
    800027de:	4501                	li	a0,0
    800027e0:	46c5                	li	a3,17
    800027e2:	a031                	j	800027ee <find_index_file_arr+0x1a>
    800027e4:	2505                	addiw	a0,a0,1
    800027e6:	03078793          	addi	a5,a5,48
    800027ea:	00d50863          	beq	a0,a3,800027fa <find_index_file_arr+0x26>
    if ((p->files_in_swap[i].isAvailable == 0) && p->files_in_swap[i].va == address) {
    800027ee:	4398                	lw	a4,0(a5)
    800027f0:	fb75                	bnez	a4,800027e4 <find_index_file_arr+0x10>
    800027f2:	6f98                	ld	a4,24(a5)
    800027f4:	feb718e3          	bne	a4,a1,800027e4 <find_index_file_arr+0x10>
    800027f8:	a011                	j	800027fc <find_index_file_arr+0x28>
      // printf("DEBUG found index in swapfilearr: %d\n", i);
      return i;
    }
  }
  return -1;
    800027fa:	557d                	li	a0,-1
}
    800027fc:	6422                	ld	s0,8(sp)
    800027fe:	0141                	addi	sp,sp,16
    80002800:	8082                	ret

0000000080002802 <copy_file>:
  p->num_of_pages_in_phys--;
  return 0;
}


int copy_file(struct proc* dest, struct proc* source) {
    80002802:	715d                	addi	sp,sp,-80
    80002804:	e486                	sd	ra,72(sp)
    80002806:	e0a2                	sd	s0,64(sp)
    80002808:	fc26                	sd	s1,56(sp)
    8000280a:	f84a                	sd	s2,48(sp)
    8000280c:	f44e                	sd	s3,40(sp)
    8000280e:	f052                	sd	s4,32(sp)
    80002810:	ec56                	sd	s5,24(sp)
    80002812:	e85a                	sd	s6,16(sp)
    80002814:	e45e                	sd	s7,8(sp)
    80002816:	0880                	addi	s0,sp,80
    80002818:	8aaa                	mv	s5,a0
    8000281a:	8a2e                	mv	s4,a1
  //TODO maybe need to add file size
  char* buf = kalloc();
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	2b6080e7          	jalr	694(ra) # 80000ad2 <kalloc>
    80002824:	89aa                	mv	s3,a0
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    80002826:	4481                	li	s1,0
    80002828:	6b85                	lui	s7,0x1
    8000282a:	6b41                	lui	s6,0x10
    readFromSwapFile(source, buf, i, PGSIZE);
    8000282c:	0004891b          	sext.w	s2,s1
    80002830:	6685                	lui	a3,0x1
    80002832:	864a                	mv	a2,s2
    80002834:	85ce                	mv	a1,s3
    80002836:	8552                	mv	a0,s4
    80002838:	00002097          	auipc	ra,0x2
    8000283c:	2ca080e7          	jalr	714(ra) # 80004b02 <readFromSwapFile>
    writeToSwapFile(dest, buf, i, PGSIZE);
    80002840:	6685                	lui	a3,0x1
    80002842:	864a                	mv	a2,s2
    80002844:	85ce                	mv	a1,s3
    80002846:	8556                	mv	a0,s5
    80002848:	00002097          	auipc	ra,0x2
    8000284c:	296080e7          	jalr	662(ra) # 80004ade <writeToSwapFile>
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    80002850:	009b84bb          	addw	s1,s7,s1
    80002854:	fd649ce3          	bne	s1,s6,8000282c <copy_file+0x2a>
  }
  kfree(buf);
    80002858:	854e                	mv	a0,s3
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	17c080e7          	jalr	380(ra) # 800009d6 <kfree>
  return 0;
}
    80002862:	4501                	li	a0,0
    80002864:	60a6                	ld	ra,72(sp)
    80002866:	6406                	ld	s0,64(sp)
    80002868:	74e2                	ld	s1,56(sp)
    8000286a:	7942                	ld	s2,48(sp)
    8000286c:	79a2                	ld	s3,40(sp)
    8000286e:	7a02                	ld	s4,32(sp)
    80002870:	6ae2                	ld	s5,24(sp)
    80002872:	6b42                	ld	s6,16(sp)
    80002874:	6ba2                	ld	s7,8(sp)
    80002876:	6161                	addi	sp,sp,80
    80002878:	8082                	ret

000000008000287a <fork>:
{
    8000287a:	7139                	addi	sp,sp,-64
    8000287c:	fc06                	sd	ra,56(sp)
    8000287e:	f822                	sd	s0,48(sp)
    80002880:	f426                	sd	s1,40(sp)
    80002882:	f04a                	sd	s2,32(sp)
    80002884:	ec4e                	sd	s3,24(sp)
    80002886:	e852                	sd	s4,16(sp)
    80002888:	e456                	sd	s5,8(sp)
    8000288a:	e05a                	sd	s6,0(sp)
    8000288c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000288e:	fffff097          	auipc	ra,0xfffff
    80002892:	2da080e7          	jalr	730(ra) # 80001b68 <myproc>
    80002896:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	cc0080e7          	jalr	-832(ra) # 80002558 <allocproc>
    800028a0:	c13d                	beqz	a0,80002906 <fork+0x8c>
    800028a2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800028a4:	048a3603          	ld	a2,72(s4)
    800028a8:	692c                	ld	a1,80(a0)
    800028aa:	050a3503          	ld	a0,80(s4)
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	e40080e7          	jalr	-448(ra) # 800016ee <uvmcopy>
    800028b6:	06054263          	bltz	a0,8000291a <fork+0xa0>
  np->sz = p->sz;
    800028ba:	048a3783          	ld	a5,72(s4)
    800028be:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800028c2:	058a3683          	ld	a3,88(s4)
    800028c6:	87b6                	mv	a5,a3
    800028c8:	0589b703          	ld	a4,88(s3)
    800028cc:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    800028d0:	0007b803          	ld	a6,0(a5)
    800028d4:	6788                	ld	a0,8(a5)
    800028d6:	6b8c                	ld	a1,16(a5)
    800028d8:	6f90                	ld	a2,24(a5)
    800028da:	01073023          	sd	a6,0(a4)
    800028de:	e708                	sd	a0,8(a4)
    800028e0:	eb0c                	sd	a1,16(a4)
    800028e2:	ef10                	sd	a2,24(a4)
    800028e4:	02078793          	addi	a5,a5,32
    800028e8:	02070713          	addi	a4,a4,32
    800028ec:	fed792e3          	bne	a5,a3,800028d0 <fork+0x56>
  np->trapframe->a0 = 0;
    800028f0:	0589b783          	ld	a5,88(s3)
    800028f4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800028f8:	0d0a0493          	addi	s1,s4,208
    800028fc:	0d098913          	addi	s2,s3,208
    80002900:	150a0a93          	addi	s5,s4,336
    80002904:	a089                	j	80002946 <fork+0xcc>
    printf("fork allocproc failed\n");
    80002906:	00007517          	auipc	a0,0x7
    8000290a:	a6250513          	addi	a0,a0,-1438 # 80009368 <digits+0x328>
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	c66080e7          	jalr	-922(ra) # 80000574 <printf>
    return -1;
    80002916:	5b7d                	li	s6,-1
    80002918:	a20d                	j	80002a3a <fork+0x1c0>
    freeproc(np);
    8000291a:	854e                	mv	a0,s3
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	aae080e7          	jalr	-1362(ra) # 800023ca <freeproc>
    release(&np->lock);
    80002924:	854e                	mv	a0,s3
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	350080e7          	jalr	848(ra) # 80000c76 <release>
    return -1;
    8000292e:	5b7d                	li	s6,-1
    80002930:	a229                	j	80002a3a <fork+0x1c0>
      np->ofile[i] = filedup(p->ofile[i]);
    80002932:	00003097          	auipc	ra,0x3
    80002936:	854080e7          	jalr	-1964(ra) # 80005186 <filedup>
    8000293a:	00a93023          	sd	a0,0(s2)
  for(i = 0; i < NOFILE; i++)
    8000293e:	04a1                	addi	s1,s1,8
    80002940:	0921                	addi	s2,s2,8
    80002942:	01548563          	beq	s1,s5,8000294c <fork+0xd2>
    if(p->ofile[i])
    80002946:	6088                	ld	a0,0(s1)
    80002948:	f56d                	bnez	a0,80002932 <fork+0xb8>
    8000294a:	bfd5                	j	8000293e <fork+0xc4>
  np->cwd = idup(p->cwd);
    8000294c:	150a3503          	ld	a0,336(s4)
    80002950:	00001097          	auipc	ra,0x1
    80002954:	696080e7          	jalr	1686(ra) # 80003fe6 <idup>
    80002958:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000295c:	4641                	li	a2,16
    8000295e:	158a0593          	addi	a1,s4,344
    80002962:	15898513          	addi	a0,s3,344
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	4aa080e7          	jalr	1194(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    8000296e:	0309ab03          	lw	s6,48(s3)
  release(&np->lock);
    80002972:	854e                	mv	a0,s3
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	302080e7          	jalr	770(ra) # 80000c76 <release>
  if(np->pid > 2){
    8000297c:	0309a703          	lw	a4,48(s3)
    80002980:	4789                	li	a5,2
    80002982:	06e7df63          	bge	a5,a4,80002a00 <fork+0x186>
    np->num_of_pages = p->num_of_pages;
    80002986:	7a0a2783          	lw	a5,1952(s4)
    8000298a:	7af9a023          	sw	a5,1952(s3)
    np->num_of_pages_in_phys = p->num_of_pages_in_phys;
    8000298e:	7a4a2783          	lw	a5,1956(s4)
    80002992:	7af9a223          	sw	a5,1956(s3)
      np->index_of_head_p = p->index_of_head_p;
    80002996:	7b0a2783          	lw	a5,1968(s4)
    8000299a:	7af9a823          	sw	a5,1968(s3)
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    8000299e:	4a098493          	addi	s1,s3,1184
    800029a2:	4a0a0913          	addi	s2,s4,1184
    800029a6:	7a098a93          	addi	s5,s3,1952
      memmove((void *)&np->files_in_physicalmem[i], (void *)&p->files_in_physicalmem[i], sizeof(struct page_struct));
    800029aa:	03000613          	li	a2,48
    800029ae:	85ca                	mv	a1,s2
    800029b0:	8526                	mv	a0,s1
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	368080e7          	jalr	872(ra) # 80000d1a <memmove>
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
    800029ba:	03048493          	addi	s1,s1,48
    800029be:	03090913          	addi	s2,s2,48
    800029c2:	ff5494e3          	bne	s1,s5,800029aa <fork+0x130>
    800029c6:	17098493          	addi	s1,s3,368
    800029ca:	170a0913          	addi	s2,s4,368
    800029ce:	4a098a93          	addi	s5,s3,1184
      memmove((void *)&np->files_in_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
    800029d2:	03000613          	li	a2,48
    800029d6:	85ca                	mv	a1,s2
    800029d8:	8526                	mv	a0,s1
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	340080e7          	jalr	832(ra) # 80000d1a <memmove>
    for (int i = 0; i<MAX_SWAP_PAGES; i++) {
    800029e2:	03048493          	addi	s1,s1,48
    800029e6:	03090913          	addi	s2,s2,48
    800029ea:	ff5494e3          	bne	s1,s5,800029d2 <fork+0x158>
    if(p->swapFile){
    800029ee:	168a3783          	ld	a5,360(s4)
    800029f2:	c799                	beqz	a5,80002a00 <fork+0x186>
      copy_file(np, p);
    800029f4:	85d2                	mv	a1,s4
    800029f6:	854e                	mv	a0,s3
    800029f8:	00000097          	auipc	ra,0x0
    800029fc:	e0a080e7          	jalr	-502(ra) # 80002802 <copy_file>
  acquire(&wait_lock);
    80002a00:	00010497          	auipc	s1,0x10
    80002a04:	8b848493          	addi	s1,s1,-1864 # 800122b8 <wait_lock>
    80002a08:	8526                	mv	a0,s1
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	1b8080e7          	jalr	440(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002a12:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80002a16:	8526                	mv	a0,s1
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	25e080e7          	jalr	606(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002a20:	854e                	mv	a0,s3
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	1a0080e7          	jalr	416(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002a2a:	478d                	li	a5,3
    80002a2c:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002a30:	854e                	mv	a0,s3
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	244080e7          	jalr	580(ra) # 80000c76 <release>
}
    80002a3a:	855a                	mv	a0,s6
    80002a3c:	70e2                	ld	ra,56(sp)
    80002a3e:	7442                	ld	s0,48(sp)
    80002a40:	74a2                	ld	s1,40(sp)
    80002a42:	7902                	ld	s2,32(sp)
    80002a44:	69e2                	ld	s3,24(sp)
    80002a46:	6a42                	ld	s4,16(sp)
    80002a48:	6aa2                	ld	s5,8(sp)
    80002a4a:	6b02                	ld	s6,0(sp)
    80002a4c:	6121                	addi	sp,sp,64
    80002a4e:	8082                	ret

0000000080002a50 <insert_from_swap_to_ram>:


int insert_from_swap_to_ram(struct proc* p, char* buff ,uint64 va) {
    80002a50:	7179                	addi	sp,sp,-48
    80002a52:	f406                	sd	ra,40(sp)
    80002a54:	f022                	sd	s0,32(sp)
    80002a56:	ec26                	sd	s1,24(sp)
    80002a58:	e84a                	sd	s2,16(sp)
    80002a5a:	e44e                	sd	s3,8(sp)
    80002a5c:	1800                	addi	s0,sp,48
    80002a5e:	84aa                	mv	s1,a0
    80002a60:	89ae                	mv	s3,a1
    80002a62:	8932                	mv	s2,a2
    // pte_t* pte = walk(p->pagetable, va, 0); //we want to update the corresponding pte according to our changes
    // *pte |= PTE_V | PTE_W | PTE_U | PTE_X; //mark that page is in ram, is writable, and is a user page
    // *pte &= ~PTE_PG;              //page was moved from swapfile
    // *pte |= *buff;                //TODO not sure
    // printf("va in insert to ram: %d\n", va);
    if(mappages(p->pagetable, va, PGSIZE, (uint64)buff,  (PTE_W | PTE_U | PTE_X | PTE_R)) == -1)
    80002a64:	4779                	li	a4,30
    80002a66:	86ae                	mv	a3,a1
    80002a68:	6605                	lui	a2,0x1
    80002a6a:	85ca                	mv	a1,s2
    80002a6c:	6928                	ld	a0,80(a0)
    80002a6e:	ffffe097          	auipc	ra,0xffffe
    80002a72:	67c080e7          	jalr	1660(ra) # 800010ea <mappages>
    80002a76:	57fd                	li	a5,-1
    80002a78:	0cf50f63          	beq	a0,a5,80002b56 <insert_from_swap_to_ram+0x106>
      printf("walk() couldn't allocate a needed page-table page\n");
    // printf("pte: %p\n", *pte);
    // printf("va after map: %d\n", va);
    int swap_ind = find_index_file_arr(p, va);
    80002a7c:	85ca                	mv	a1,s2
    80002a7e:	8526                	mv	a0,s1
    80002a80:	00000097          	auipc	ra,0x0
    80002a84:	d54080e7          	jalr	-684(ra) # 800027d4 <find_index_file_arr>
    80002a88:	892a                	mv	s2,a0
    //if index is -1, according to swap_file_array the file isn't in swapfile
    if (swap_ind == -1) {
    80002a8a:	57fd                	li	a5,-1
    80002a8c:	0cf50e63          	beq	a0,a5,80002b68 <insert_from_swap_to_ram+0x118>
      panic("index in file is -1");
    }
    int offset = p->files_in_swap[swap_ind].offset;
    80002a90:	00151793          	slli	a5,a0,0x1
    80002a94:	97aa                	add	a5,a5,a0
    80002a96:	0792                	slli	a5,a5,0x4
    80002a98:	97a6                	add	a5,a5,s1
    80002a9a:	1907a603          	lw	a2,400(a5)
    if (offset == -1) {
    80002a9e:	57fd                	li	a5,-1
    80002aa0:	0cf60c63          	beq	a2,a5,80002b78 <insert_from_swap_to_ram+0x128>
      panic("offset is -1");
    }
    // printf("before read\n");
    readFromSwapFile(p, buff, offset, PGSIZE);
    80002aa4:	6685                	lui	a3,0x1
    80002aa6:	85ce                	mv	a1,s3
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	00002097          	auipc	ra,0x2
    80002aae:	058080e7          	jalr	88(ra) # 80004b02 <readFromSwapFile>
    // printf("afer read\n");

    //copy swap_arr[index] to mem_arr[index] and change swap_arr[index] to available
    int mem_ind = find_free_index(p->files_in_physicalmem, 0);
    80002ab2:	4581                	li	a1,0
    80002ab4:	4a048513          	addi	a0,s1,1184
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	876080e7          	jalr	-1930(ra) # 8000232e <find_free_index>
    p->files_in_physicalmem[mem_ind].pagetable = p->files_in_swap[swap_ind].pagetable;
    80002ac0:	00151793          	slli	a5,a0,0x1
    80002ac4:	97aa                	add	a5,a5,a0
    80002ac6:	0792                	slli	a5,a5,0x4
    80002ac8:	97a6                	add	a5,a5,s1
    80002aca:	00191713          	slli	a4,s2,0x1
    80002ace:	012706b3          	add	a3,a4,s2
    80002ad2:	0692                	slli	a3,a3,0x4
    80002ad4:	96a6                	add	a3,a3,s1
    80002ad6:	1786b603          	ld	a2,376(a3) # 1178 <_entry-0x7fffee88>
    80002ada:	4ac7b423          	sd	a2,1192(a5)
    p->files_in_physicalmem[mem_ind].page = p->files_in_swap[swap_ind].page;
    80002ade:	1806b603          	ld	a2,384(a3)
    80002ae2:	4ac7b823          	sd	a2,1200(a5)
    p->files_in_physicalmem[mem_ind].va = p->files_in_swap[swap_ind].va;
    80002ae6:	1886b683          	ld	a3,392(a3)
    80002aea:	4ad7bc23          	sd	a3,1208(a5)
    p->files_in_physicalmem[mem_ind].offset = -1;
    80002aee:	56fd                	li	a3,-1
    80002af0:	4cd7a023          	sw	a3,1216(a5)
    p->files_in_physicalmem[mem_ind].isAvailable = 0;
    80002af4:	4a07a023          	sw	zero,1184(a5)
    p->num_of_pages_in_phys++;
    80002af8:	7a44a683          	lw	a3,1956(s1)
    80002afc:	2685                	addiw	a3,a3,1
    80002afe:	7ad4a223          	sw	a3,1956(s1)

    p->files_in_swap[swap_ind].isAvailable = 1;
    80002b02:	974a                	add	a4,a4,s2
    80002b04:	0712                	slli	a4,a4,0x4
    80002b06:	9726                	add	a4,a4,s1
    80002b08:	4685                	li	a3,1
    80002b0a:	16d72823          	sw	a3,368(a4)
      p->files_in_physicalmem[mem_ind].counter_LAPA = -1; //0xFFFFFF
    #endif
    //in scfifo we need to maintain the field values
    #ifdef SCFIFO
      //head's previous prev is curr's new prev
      p->files_in_physicalmem[mem_ind].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
    80002b0e:	7b04a603          	lw	a2,1968(s1)
    80002b12:	00161713          	slli	a4,a2,0x1
    80002b16:	00c706b3          	add	a3,a4,a2
    80002b1a:	0692                	slli	a3,a3,0x4
    80002b1c:	96a6                	add	a3,a3,s1
    80002b1e:	4c86a683          	lw	a3,1224(a3)
    80002b22:	4cd7a423          	sw	a3,1224(a5)
      //curr is last. curr's next is head
      p->files_in_physicalmem[mem_ind].index_of_next_p = p->index_of_head_p;
    80002b26:	4cc7a223          	sw	a2,1220(a5)
      //head's prev is curr
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = mem_ind;
    80002b2a:	9732                	add	a4,a4,a2
    80002b2c:	0712                	slli	a4,a4,0x4
    80002b2e:	9726                	add	a4,a4,s1
    80002b30:	4ca72423          	sw	a0,1224(a4)
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = mem_ind;
    80002b34:	4c87a703          	lw	a4,1224(a5)
    80002b38:	00171793          	slli	a5,a4,0x1
    80002b3c:	97ba                	add	a5,a5,a4
    80002b3e:	0792                	slli	a5,a5,0x4
    80002b40:	94be                	add	s1,s1,a5
    80002b42:	4ca4a223          	sw	a0,1220(s1)
    #endif
    return 0;
  }
    80002b46:	4501                	li	a0,0
    80002b48:	70a2                	ld	ra,40(sp)
    80002b4a:	7402                	ld	s0,32(sp)
    80002b4c:	64e2                	ld	s1,24(sp)
    80002b4e:	6942                	ld	s2,16(sp)
    80002b50:	69a2                	ld	s3,8(sp)
    80002b52:	6145                	addi	sp,sp,48
    80002b54:	8082                	ret
      printf("walk() couldn't allocate a needed page-table page\n");
    80002b56:	00007517          	auipc	a0,0x7
    80002b5a:	82a50513          	addi	a0,a0,-2006 # 80009380 <digits+0x340>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	a16080e7          	jalr	-1514(ra) # 80000574 <printf>
    80002b66:	bf19                	j	80002a7c <insert_from_swap_to_ram+0x2c>
      panic("index in file is -1");
    80002b68:	00007517          	auipc	a0,0x7
    80002b6c:	85050513          	addi	a0,a0,-1968 # 800093b8 <digits+0x378>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	9ba080e7          	jalr	-1606(ra) # 8000052a <panic>
      panic("offset is -1");
    80002b78:	00007517          	auipc	a0,0x7
    80002b7c:	85850513          	addi	a0,a0,-1960 # 800093d0 <digits+0x390>
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	9aa080e7          	jalr	-1622(ra) # 8000052a <panic>

0000000080002b88 <print_page_array>:
    p->killed = 1;
  }
}
// #ifdef LAPA
//ppp
void print_page_array(struct proc* p ,struct page_struct* pagearr) {
    80002b88:	7139                	addi	sp,sp,-64
    80002b8a:	fc06                	sd	ra,56(sp)
    80002b8c:	f822                	sd	s0,48(sp)
    80002b8e:	f426                	sd	s1,40(sp)
    80002b90:	f04a                	sd	s2,32(sp)
    80002b92:	ec4e                	sd	s3,24(sp)
    80002b94:	e852                	sd	s4,16(sp)
    80002b96:	e456                	sd	s5,8(sp)
    80002b98:	0080                	addi	s0,sp,64
    80002b9a:	89aa                	mv	s3,a0
    80002b9c:	84ae                	mv	s1,a1
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002b9e:	4901                	li	s2,0
    struct page_struct curr = pagearr[i];
    printf("pid: %d, index: %d, isAvailable: %d, va: %d, offset: %d, counter_NFUA:  \n",
    80002ba0:	00007a97          	auipc	s5,0x7
    80002ba4:	840a8a93          	addi	s5,s5,-1984 # 800093e0 <digits+0x3a0>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002ba8:	4a41                	li	s4,16
    printf("pid: %d, index: %d, isAvailable: %d, va: %d, offset: %d, counter_NFUA:  \n",
    80002baa:	6c98                	ld	a4,24(s1)
    80002bac:	509c                	lw	a5,32(s1)
    80002bae:	8331                	srli	a4,a4,0xc
    80002bb0:	4094                	lw	a3,0(s1)
    80002bb2:	864a                	mv	a2,s2
    80002bb4:	0309a583          	lw	a1,48(s3)
    80002bb8:	8556                	mv	a0,s5
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	9ba080e7          	jalr	-1606(ra) # 80000574 <printf>
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    80002bc2:	2905                	addiw	s2,s2,1
    80002bc4:	03048493          	addi	s1,s1,48
    80002bc8:	ff4911e3          	bne	s2,s4,80002baa <print_page_array+0x22>
    p->pid, i, curr.isAvailable, curr.va/PGSIZE, curr.offset);
  }
}
    80002bcc:	70e2                	ld	ra,56(sp)
    80002bce:	7442                	ld	s0,48(sp)
    80002bd0:	74a2                	ld	s1,40(sp)
    80002bd2:	7902                	ld	s2,32(sp)
    80002bd4:	69e2                	ld	s3,24(sp)
    80002bd6:	6a42                	ld	s4,16(sp)
    80002bd8:	6aa2                	ld	s5,8(sp)
    80002bda:	6121                	addi	sp,sp,64
    80002bdc:	8082                	ret

0000000080002bde <calc_ndx_for_scfifo>:
  return selected;
}
#endif

#ifdef SCFIFO
int calc_ndx_for_scfifo(struct proc *p){
    80002bde:	1141                	addi	sp,sp,-16
    80002be0:	e422                	sd	s0,8(sp)
    80002be2:	0800                	addi	s0,sp,16
  struct page_struct *ram_pages = p->files_in_physicalmem;
    80002be4:	4a050593          	addi	a1,a0,1184
  int toReturn = -1;
  int head_ndx = p->index_of_head_p;
    80002be8:	7b052803          	lw	a6,1968(a0)
  int curr_ndx = p->index_of_head_p;
    80002bec:	8542                	mv	a0,a6
  struct page_struct *curr_page;
  int found = 0;
  while(found != 1){
    curr_page = &ram_pages[curr_ndx];
    80002bee:	00151793          	slli	a5,a0,0x1
    80002bf2:	97aa                	add	a5,a5,a0
    80002bf4:	0792                	slli	a5,a5,0x4
    80002bf6:	97ae                	add	a5,a5,a1
    //if page is not in physical memory, something's wrong
    // if()
    //if the page was accessed, give it a second chance
    if(*(curr_page->page) & PTE_A){
    80002bf8:	6b94                	ld	a3,16(a5)
    80002bfa:	6298                	ld	a4,0(a3)
    80002bfc:	04077613          	andi	a2,a4,64
    80002c00:	ca01                	beqz	a2,80002c10 <calc_ndx_for_scfifo+0x32>
      *(curr_page->page) &= ~PTE_A;
    80002c02:	fbf77713          	andi	a4,a4,-65
    80002c06:	e298                	sd	a4,0(a3)
      curr_ndx = curr_page->index_of_next_p;
    80002c08:	53c8                	lw	a0,36(a5)
      found = 1;
      toReturn = curr_ndx;
    }
    //the oldest page that wasn't accessed should be removed
    //if we went through all pages, finish loop
    if (curr_ndx == head_ndx){
    80002c0a:	fea812e3          	bne	a6,a0,80002bee <calc_ndx_for_scfifo+0x10>
      found = 1;
      toReturn = head_ndx;
    80002c0e:	8542                	mv	a0,a6
    }
  }
  return toReturn;
}
    80002c10:	6422                	ld	s0,8(sp)
    80002c12:	0141                	addi	sp,sp,16
    80002c14:	8082                	ret

0000000080002c16 <calc_ndx_for_ramarr_removal>:
int calc_ndx_for_ramarr_removal(struct proc *p){
    80002c16:	1141                	addi	sp,sp,-16
    80002c18:	e406                	sd	ra,8(sp)
    80002c1a:	e022                	sd	s0,0(sp)
    80002c1c:	0800                	addi	s0,sp,16
    ndx = calc_ndx_for_scfifo(p);
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	fc0080e7          	jalr	-64(ra) # 80002bde <calc_ndx_for_scfifo>
    if(ndx == -1){
    80002c26:	57fd                	li	a5,-1
    80002c28:	00f50663          	beq	a0,a5,80002c34 <calc_ndx_for_ramarr_removal+0x1e>
}
    80002c2c:	60a2                	ld	ra,8(sp)
    80002c2e:	6402                	ld	s0,0(sp)
    80002c30:	0141                	addi	sp,sp,16
    80002c32:	8082                	ret
      panic("scfifo ndx wasn't found");
    80002c34:	00006517          	auipc	a0,0x6
    80002c38:	7fc50513          	addi	a0,a0,2044 # 80009430 <digits+0x3f0>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	8ee080e7          	jalr	-1810(ra) # 8000052a <panic>

0000000080002c44 <swap_to_swapFile>:
int swap_to_swapFile(struct proc* p, pagetable_t pagetable) {
    80002c44:	715d                	addi	sp,sp,-80
    80002c46:	e486                	sd	ra,72(sp)
    80002c48:	e0a2                	sd	s0,64(sp)
    80002c4a:	fc26                	sd	s1,56(sp)
    80002c4c:	f84a                	sd	s2,48(sp)
    80002c4e:	f44e                	sd	s3,40(sp)
    80002c50:	f052                	sd	s4,32(sp)
    80002c52:	ec56                	sd	s5,24(sp)
    80002c54:	e85a                	sd	s6,16(sp)
    80002c56:	e45e                	sd	s7,8(sp)
    80002c58:	0880                	addi	s0,sp,80
    80002c5a:	84aa                	mv	s1,a0
    80002c5c:	8a2e                	mv	s4,a1
  int mem_ind = calc_ndx_for_ramarr_removal(p);  //index of page to remove from ram array
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	fb8080e7          	jalr	-72(ra) # 80002c16 <calc_ndx_for_ramarr_removal>
    80002c66:	892a                	mv	s2,a0
  int swap_ind = find_free_index(p->files_in_swap, 1);
    80002c68:	4585                	li	a1,1
    80002c6a:	17048513          	addi	a0,s1,368
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	6c0080e7          	jalr	1728(ra) # 8000232e <find_free_index>
    80002c76:	89aa                	mv	s3,a0
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[mem_ind].index_of_prev_p;
    80002c78:	00191793          	slli	a5,s2,0x1
    80002c7c:	97ca                	add	a5,a5,s2
    80002c7e:	0792                	slli	a5,a5,0x4
    80002c80:	97a6                	add	a5,a5,s1
    80002c82:	4c47a683          	lw	a3,1220(a5)
    80002c86:	4c87a603          	lw	a2,1224(a5)
    80002c8a:	00169713          	slli	a4,a3,0x1
    80002c8e:	9736                	add	a4,a4,a3
    80002c90:	0712                	slli	a4,a4,0x4
    80002c92:	9726                	add	a4,a4,s1
    80002c94:	4cc72423          	sw	a2,1224(a4)
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[mem_ind].index_of_next_p;
    80002c98:	00161793          	slli	a5,a2,0x1
    80002c9c:	97b2                	add	a5,a5,a2
    80002c9e:	0792                	slli	a5,a5,0x4
    80002ca0:	97a6                	add	a5,a5,s1
    80002ca2:	4cd7a223          	sw	a3,1220(a5)
    if(p->index_of_head_p == mem_ind){
    80002ca6:	7b04a783          	lw	a5,1968(s1)
    80002caa:	0f278a63          	beq	a5,s2,80002d9e <swap_to_swapFile+0x15a>
    p->files_in_swap[swap_ind].index_of_prev_p = -1;
    80002cae:	00199793          	slli	a5,s3,0x1
    80002cb2:	97ce                	add	a5,a5,s3
    80002cb4:	0792                	slli	a5,a5,0x4
    80002cb6:	97a6                	add	a5,a5,s1
    80002cb8:	5afd                	li	s5,-1
    80002cba:	1957ac23          	sw	s5,408(a5)
    p->files_in_swap[swap_ind].index_of_next_p = -1;
    80002cbe:	1957aa23          	sw	s5,404(a5)
  uint64 va_to_swap_file = p->files_in_physicalmem[mem_ind].va;
    80002cc2:	00191793          	slli	a5,s2,0x1
    80002cc6:	97ca                	add	a5,a5,s2
    80002cc8:	0792                	slli	a5,a5,0x4
    80002cca:	97a6                	add	a5,a5,s1
    80002ccc:	4b87bb03          	ld	s6,1208(a5)
  pte_t *pte2 = walk(pagetable_to_swap_file, va_to_swap_file, 0);
    80002cd0:	4601                	li	a2,0
    80002cd2:	85da                	mv	a1,s6
    80002cd4:	8552                	mv	a0,s4
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	2d0080e7          	jalr	720(ra) # 80000fa6 <walk>
  *pte2 |= PTE_U;
    80002cde:	611c                	ld	a5,0(a0)
    80002ce0:	0107e793          	ori	a5,a5,16
    80002ce4:	e11c                	sd	a5,0(a0)
  uint64 pa = walkaddr(pagetable_to_swap_file, va_to_swap_file);
    80002ce6:	85da                	mv	a1,s6
    80002ce8:	8552                	mv	a0,s4
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	376080e7          	jalr	886(ra) # 80001060 <walkaddr>
    80002cf2:	85aa                	mv	a1,a0
  int offset = swap_ind*PGSIZE; //find offset we want to insert to
    80002cf4:	00c99b9b          	slliw	s7,s3,0xc
  if (writeToSwapFile(p, (char *)pa, offset, PGSIZE) == -1)
    80002cf8:	6685                	lui	a3,0x1
    80002cfa:	000b861b          	sext.w	a2,s7
    80002cfe:	8526                	mv	a0,s1
    80002d00:	00002097          	auipc	ra,0x2
    80002d04:	dde080e7          	jalr	-546(ra) # 80004ade <writeToSwapFile>
    80002d08:	0d550363          	beq	a0,s5,80002dce <swap_to_swapFile+0x18a>
  p->files_in_swap[swap_ind].pagetable = pagetable_to_swap_file;
    80002d0c:	00199513          	slli	a0,s3,0x1
    80002d10:	013507b3          	add	a5,a0,s3
    80002d14:	0792                	slli	a5,a5,0x4
    80002d16:	97a6                	add	a5,a5,s1
    80002d18:	1747bc23          	sd	s4,376(a5)
  p->files_in_swap[swap_ind].va = va_to_swap_file;
    80002d1c:	1967b423          	sd	s6,392(a5)
  p->files_in_swap[swap_ind].isAvailable = 0;
    80002d20:	1607a823          	sw	zero,368(a5)
  p->files_in_swap[swap_ind].offset = offset;
    80002d24:	1977a823          	sw	s7,400(a5)
  p->files_in_swap[swap_ind].page = p->files_in_physicalmem[mem_ind].page;
    80002d28:	853e                	mv	a0,a5
    80002d2a:	00191a93          	slli	s5,s2,0x1
    80002d2e:	012a87b3          	add	a5,s5,s2
    80002d32:	0792                	slli	a5,a5,0x4
    80002d34:	97a6                	add	a5,a5,s1
    80002d36:	4b07b703          	ld	a4,1200(a5)
    80002d3a:	18e53023          	sd	a4,384(a0)
  pte_t* pte = walk(pagetable, p->files_in_physicalmem[mem_ind].va, 0);
    80002d3e:	4601                	li	a2,0
    80002d40:	4b87b583          	ld	a1,1208(a5)
    80002d44:	8552                	mv	a0,s4
    80002d46:	ffffe097          	auipc	ra,0xffffe
    80002d4a:	260080e7          	jalr	608(ra) # 80000fa6 <walk>
    80002d4e:	89aa                	mv	s3,a0
  char *pa_tofree = (char *)PTE2PA(*pte);
    80002d50:	6108                	ld	a0,0(a0)
    80002d52:	8129                	srli	a0,a0,0xa
  kfree(pa_tofree);
    80002d54:	0532                	slli	a0,a0,0xc
    80002d56:	ffffe097          	auipc	ra,0xffffe
    80002d5a:	c80080e7          	jalr	-896(ra) # 800009d6 <kfree>
  (*pte) &= ~PTE_V;
    80002d5e:	0009b783          	ld	a5,0(s3)
    80002d62:	9bf9                	andi	a5,a5,-2
  (*pte) |= PTE_PG;
    80002d64:	2007e793          	ori	a5,a5,512
    80002d68:	00f9b023          	sd	a5,0(s3)
  asm volatile("sfence.vma zero, zero");
    80002d6c:	12000073          	sfence.vma
  p->files_in_physicalmem[mem_ind].isAvailable = 1;
    80002d70:	9956                	add	s2,s2,s5
    80002d72:	0912                	slli	s2,s2,0x4
    80002d74:	9926                	add	s2,s2,s1
    80002d76:	4785                	li	a5,1
    80002d78:	4af92023          	sw	a5,1184(s2)
  p->num_of_pages_in_phys--;
    80002d7c:	7a44a783          	lw	a5,1956(s1)
    80002d80:	37fd                	addiw	a5,a5,-1
    80002d82:	7af4a223          	sw	a5,1956(s1)
}
    80002d86:	4501                	li	a0,0
    80002d88:	60a6                	ld	ra,72(sp)
    80002d8a:	6406                	ld	s0,64(sp)
    80002d8c:	74e2                	ld	s1,56(sp)
    80002d8e:	7942                	ld	s2,48(sp)
    80002d90:	79a2                	ld	s3,40(sp)
    80002d92:	7a02                	ld	s4,32(sp)
    80002d94:	6ae2                	ld	s5,24(sp)
    80002d96:	6b42                	ld	s6,16(sp)
    80002d98:	6ba2                	ld	s7,8(sp)
    80002d9a:	6161                	addi	sp,sp,80
    80002d9c:	8082                	ret
      if(p->index_of_head_p == p->files_in_physicalmem[mem_ind].index_of_next_p){
    80002d9e:	00191793          	slli	a5,s2,0x1
    80002da2:	97ca                	add	a5,a5,s2
    80002da4:	0792                	slli	a5,a5,0x4
    80002da6:	97a6                	add	a5,a5,s1
    80002da8:	4c47a783          	lw	a5,1220(a5)
    80002dac:	01278f63          	beq	a5,s2,80002dca <swap_to_swapFile+0x186>
    80002db0:	7af4a823          	sw	a5,1968(s1)
      p->files_in_physicalmem[mem_ind].index_of_prev_p = -1;
    80002db4:	00191793          	slli	a5,s2,0x1
    80002db8:	97ca                	add	a5,a5,s2
    80002dba:	0792                	slli	a5,a5,0x4
    80002dbc:	97a6                	add	a5,a5,s1
    80002dbe:	577d                	li	a4,-1
    80002dc0:	4ce7a423          	sw	a4,1224(a5)
      p->files_in_physicalmem[mem_ind].index_of_next_p = -1;
    80002dc4:	4ce7a223          	sw	a4,1220(a5)
    80002dc8:	b5dd                	j	80002cae <swap_to_swapFile+0x6a>
        p->index_of_head_p = -1;
    80002dca:	57fd                	li	a5,-1
    80002dcc:	b7d5                	j	80002db0 <swap_to_swapFile+0x16c>
    panic("an error occurred while writing to swap file");
    80002dce:	00006517          	auipc	a0,0x6
    80002dd2:	67a50513          	addi	a0,a0,1658 # 80009448 <digits+0x408>
    80002dd6:	ffffd097          	auipc	ra,0xffffd
    80002dda:	754080e7          	jalr	1876(ra) # 8000052a <panic>

0000000080002dde <swap_to_memory>:
int swap_to_memory(struct proc* p, uint64 address) {
    80002dde:	7179                	addi	sp,sp,-48
    80002de0:	f406                	sd	ra,40(sp)
    80002de2:	f022                	sd	s0,32(sp)
    80002de4:	ec26                	sd	s1,24(sp)
    80002de6:	e84a                	sd	s2,16(sp)
    80002de8:	e44e                	sd	s3,8(sp)
    80002dea:	1800                	addi	s0,sp,48
    80002dec:	84aa                	mv	s1,a0
  uint64 va = PGROUNDDOWN(address);
    80002dee:	79fd                	lui	s3,0xfffff
    80002df0:	0135f9b3          	and	s3,a1,s3
  if ((buff = kalloc()) == 0) {
    80002df4:	ffffe097          	auipc	ra,0xffffe
    80002df8:	cde080e7          	jalr	-802(ra) # 80000ad2 <kalloc>
    80002dfc:	c131                	beqz	a0,80002e40 <swap_to_memory+0x62>
    80002dfe:	892a                	mv	s2,a0
  if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    80002e00:	7a44a703          	lw	a4,1956(s1)
    80002e04:	47bd                	li	a5,15
    80002e06:	04e7c563          	blt	a5,a4,80002e50 <swap_to_memory+0x72>
    insert_from_swap_to_ram(p, buff, va);
    80002e0a:	864e                	mv	a2,s3
    80002e0c:	85aa                	mv	a1,a0
    80002e0e:	8526                	mv	a0,s1
    80002e10:	00000097          	auipc	ra,0x0
    80002e14:	c40080e7          	jalr	-960(ra) # 80002a50 <insert_from_swap_to_ram>
    uint64 pa = walkaddr(p->pagetable, va);
    80002e18:	85ce                	mv	a1,s3
    80002e1a:	68a8                	ld	a0,80(s1)
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	244080e7          	jalr	580(ra) # 80001060 <walkaddr>
    memmove((void*)pa, buff, PGSIZE); //copy page to va TODO check im not sure
    80002e24:	6605                	lui	a2,0x1
    80002e26:	85ca                	mv	a1,s2
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	ef2080e7          	jalr	-270(ra) # 80000d1a <memmove>
}
    80002e30:	4501                	li	a0,0
    80002e32:	70a2                	ld	ra,40(sp)
    80002e34:	7402                	ld	s0,32(sp)
    80002e36:	64e2                	ld	s1,24(sp)
    80002e38:	6942                	ld	s2,16(sp)
    80002e3a:	69a2                	ld	s3,8(sp)
    80002e3c:	6145                	addi	sp,sp,48
    80002e3e:	8082                	ret
    panic("kalloc failed");
    80002e40:	00006517          	auipc	a0,0x6
    80002e44:	63850513          	addi	a0,a0,1592 # 80009478 <digits+0x438>
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	6e2080e7          	jalr	1762(ra) # 8000052a <panic>
    swap_to_swapFile(p, p->pagetable);      //if there's no available place in ram, make some
    80002e50:	68ac                	ld	a1,80(s1)
    80002e52:	8526                	mv	a0,s1
    80002e54:	00000097          	auipc	ra,0x0
    80002e58:	df0080e7          	jalr	-528(ra) # 80002c44 <swap_to_swapFile>
    insert_from_swap_to_ram(p, buff, va); //move from swapfile the page we wanted to insert to ram
    80002e5c:	864e                	mv	a2,s3
    80002e5e:	85ca                	mv	a1,s2
    80002e60:	8526                	mv	a0,s1
    80002e62:	00000097          	auipc	ra,0x0
    80002e66:	bee080e7          	jalr	-1042(ra) # 80002a50 <insert_from_swap_to_ram>
    pte_t *pte = walk(p->pagetable, va, 0);
    80002e6a:	4601                	li	a2,0
    80002e6c:	85ce                	mv	a1,s3
    80002e6e:	68a8                	ld	a0,80(s1)
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	136080e7          	jalr	310(ra) # 80000fa6 <walk>
    uint64 pa = PTE2PA(*pte);
    80002e78:	6108                	ld	a0,0(a0)
    80002e7a:	8129                	srli	a0,a0,0xa
    memmove((void*)pa, buff, PGSIZE); //copy page to va TODO check im not sure
    80002e7c:	6605                	lui	a2,0x1
    80002e7e:	85ca                	mv	a1,s2
    80002e80:	0532                	slli	a0,a0,0xc
    80002e82:	ffffe097          	auipc	ra,0xffffe
    80002e86:	e98080e7          	jalr	-360(ra) # 80000d1a <memmove>
    80002e8a:	b75d                	j	80002e30 <swap_to_memory+0x52>

0000000080002e8c <hanle_page_fault>:
void hanle_page_fault(struct proc* p, uint64 va) {
    80002e8c:	1101                	addi	sp,sp,-32
    80002e8e:	ec06                	sd	ra,24(sp)
    80002e90:	e822                	sd	s0,16(sp)
    80002e92:	e426                	sd	s1,8(sp)
    80002e94:	e04a                	sd	s2,0(sp)
    80002e96:	1000                	addi	s0,sp,32
    80002e98:	84aa                	mv	s1,a0
    80002e9a:	892e                	mv	s2,a1
  pte_t* pte = walk(p->pagetable, va, 0); //identify the page
    80002e9c:	4601                	li	a2,0
    80002e9e:	6928                	ld	a0,80(a0)
    80002ea0:	ffffe097          	auipc	ra,0xffffe
    80002ea4:	106080e7          	jalr	262(ra) # 80000fa6 <walk>
  if (*pte & PTE_PG) {
    80002ea8:	611c                	ld	a5,0(a0)
    80002eaa:	2007f793          	andi	a5,a5,512
    80002eae:	cf89                	beqz	a5,80002ec8 <hanle_page_fault+0x3c>
    swap_to_memory(p, va);
    80002eb0:	85ca                	mv	a1,s2
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	f2a080e7          	jalr	-214(ra) # 80002dde <swap_to_memory>
}
    80002ebc:	60e2                	ld	ra,24(sp)
    80002ebe:	6442                	ld	s0,16(sp)
    80002ec0:	64a2                	ld	s1,8(sp)
    80002ec2:	6902                	ld	s2,0(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ec8:	142025f3          	csrr	a1,scause
    printf("usertrap1(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ecc:	5890                	lw	a2,48(s1)
    80002ece:	00006517          	auipc	a0,0x6
    80002ed2:	5ba50513          	addi	a0,a0,1466 # 80009488 <digits+0x448>
    80002ed6:	ffffd097          	auipc	ra,0xffffd
    80002eda:	69e080e7          	jalr	1694(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ede:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ee2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ee6:	00006517          	auipc	a0,0x6
    80002eea:	5d250513          	addi	a0,a0,1490 # 800094b8 <digits+0x478>
    80002eee:	ffffd097          	auipc	ra,0xffffd
    80002ef2:	686080e7          	jalr	1670(ra) # 80000574 <printf>
    p->killed = 1;
    80002ef6:	4785                	li	a5,1
    80002ef8:	d49c                	sw	a5,40(s1)
}
    80002efa:	b7c9                	j	80002ebc <hanle_page_fault+0x30>

0000000080002efc <printmem>:
}
#endif

// #endif

int printmem(void){
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	e426                	sd	s1,8(sp)
    80002f04:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	c62080e7          	jalr	-926(ra) # 80001b68 <myproc>
  if(p->pid > 2){
    80002f0e:	5918                	lw	a4,48(a0)
    80002f10:	4789                	li	a5,2
    80002f12:	04e7d763          	bge	a5,a4,80002f60 <printmem+0x64>
    80002f16:	84aa                	mv	s1,a0
    printf("printmem, files in ram array:\n");
    80002f18:	00006517          	auipc	a0,0x6
    80002f1c:	5c050513          	addi	a0,a0,1472 # 800094d8 <digits+0x498>
    80002f20:	ffffd097          	auipc	ra,0xffffd
    80002f24:	654080e7          	jalr	1620(ra) # 80000574 <printf>
    print_page_array(p, p->files_in_physicalmem);
    80002f28:	4a048593          	addi	a1,s1,1184
    80002f2c:	8526                	mv	a0,s1
    80002f2e:	00000097          	auipc	ra,0x0
    80002f32:	c5a080e7          	jalr	-934(ra) # 80002b88 <print_page_array>
    printf("printmem, files in swap array:\n");
    80002f36:	00006517          	auipc	a0,0x6
    80002f3a:	5c250513          	addi	a0,a0,1474 # 800094f8 <digits+0x4b8>
    80002f3e:	ffffd097          	auipc	ra,0xffffd
    80002f42:	636080e7          	jalr	1590(ra) # 80000574 <printf>
    print_page_array(p, p->files_in_swap);
    80002f46:	17048593          	addi	a1,s1,368
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	00000097          	auipc	ra,0x0
    80002f50:	c3c080e7          	jalr	-964(ra) # 80002b88 <print_page_array>
  }
  else{
    printf("pid < 2\n");
  }
  return 1;
    80002f54:	4505                	li	a0,1
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	64a2                	ld	s1,8(sp)
    80002f5c:	6105                	addi	sp,sp,32
    80002f5e:	8082                	ret
    printf("pid < 2\n");
    80002f60:	00006517          	auipc	a0,0x6
    80002f64:	5b850513          	addi	a0,a0,1464 # 80009518 <digits+0x4d8>
    80002f68:	ffffd097          	auipc	ra,0xffffd
    80002f6c:	60c080e7          	jalr	1548(ra) # 80000574 <printf>
    80002f70:	b7d5                	j	80002f54 <printmem+0x58>

0000000080002f72 <swtch>:
    80002f72:	00153023          	sd	ra,0(a0)
    80002f76:	00253423          	sd	sp,8(a0)
    80002f7a:	e900                	sd	s0,16(a0)
    80002f7c:	ed04                	sd	s1,24(a0)
    80002f7e:	03253023          	sd	s2,32(a0)
    80002f82:	03353423          	sd	s3,40(a0)
    80002f86:	03453823          	sd	s4,48(a0)
    80002f8a:	03553c23          	sd	s5,56(a0)
    80002f8e:	05653023          	sd	s6,64(a0)
    80002f92:	05753423          	sd	s7,72(a0)
    80002f96:	05853823          	sd	s8,80(a0)
    80002f9a:	05953c23          	sd	s9,88(a0)
    80002f9e:	07a53023          	sd	s10,96(a0)
    80002fa2:	07b53423          	sd	s11,104(a0)
    80002fa6:	0005b083          	ld	ra,0(a1)
    80002faa:	0085b103          	ld	sp,8(a1)
    80002fae:	6980                	ld	s0,16(a1)
    80002fb0:	6d84                	ld	s1,24(a1)
    80002fb2:	0205b903          	ld	s2,32(a1)
    80002fb6:	0285b983          	ld	s3,40(a1)
    80002fba:	0305ba03          	ld	s4,48(a1)
    80002fbe:	0385ba83          	ld	s5,56(a1)
    80002fc2:	0405bb03          	ld	s6,64(a1)
    80002fc6:	0485bb83          	ld	s7,72(a1)
    80002fca:	0505bc03          	ld	s8,80(a1)
    80002fce:	0585bc83          	ld	s9,88(a1)
    80002fd2:	0605bd03          	ld	s10,96(a1)
    80002fd6:	0685bd83          	ld	s11,104(a1)
    80002fda:	8082                	ret

0000000080002fdc <trapinit>:
extern int devintr();
extern void hanle_page_fault(struct proc* p, uint64 va);

void
trapinit(void)
{
    80002fdc:	1141                	addi	sp,sp,-16
    80002fde:	e406                	sd	ra,8(sp)
    80002fe0:	e022                	sd	s0,0(sp)
    80002fe2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002fe4:	00006597          	auipc	a1,0x6
    80002fe8:	59c58593          	addi	a1,a1,1436 # 80009580 <states.0+0x30>
    80002fec:	0002e517          	auipc	a0,0x2e
    80002ff0:	4e450513          	addi	a0,a0,1252 # 800314d0 <tickslock>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	b3e080e7          	jalr	-1218(ra) # 80000b32 <initlock>
}
    80002ffc:	60a2                	ld	ra,8(sp)
    80002ffe:	6402                	ld	s0,0(sp)
    80003000:	0141                	addi	sp,sp,16
    80003002:	8082                	ret

0000000080003004 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003004:	1141                	addi	sp,sp,-16
    80003006:	e422                	sd	s0,8(sp)
    80003008:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000300a:	00004797          	auipc	a5,0x4
    8000300e:	c0678793          	addi	a5,a5,-1018 # 80006c10 <kernelvec>
    80003012:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003016:	6422                	ld	s0,8(sp)
    80003018:	0141                	addi	sp,sp,16
    8000301a:	8082                	ret

000000008000301c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000301c:	1141                	addi	sp,sp,-16
    8000301e:	e406                	sd	ra,8(sp)
    80003020:	e022                	sd	s0,0(sp)
    80003022:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	b44080e7          	jalr	-1212(ra) # 80001b68 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000302c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003030:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003032:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003036:	00005617          	auipc	a2,0x5
    8000303a:	fca60613          	addi	a2,a2,-54 # 80008000 <_trampoline>
    8000303e:	00005697          	auipc	a3,0x5
    80003042:	fc268693          	addi	a3,a3,-62 # 80008000 <_trampoline>
    80003046:	8e91                	sub	a3,a3,a2
    80003048:	040007b7          	lui	a5,0x4000
    8000304c:	17fd                	addi	a5,a5,-1
    8000304e:	07b2                	slli	a5,a5,0xc
    80003050:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003052:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003056:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003058:	180026f3          	csrr	a3,satp
    8000305c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000305e:	6d38                	ld	a4,88(a0)
    80003060:	6134                	ld	a3,64(a0)
    80003062:	6585                	lui	a1,0x1
    80003064:	96ae                	add	a3,a3,a1
    80003066:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003068:	6d38                	ld	a4,88(a0)
    8000306a:	00000697          	auipc	a3,0x0
    8000306e:	13868693          	addi	a3,a3,312 # 800031a2 <usertrap>
    80003072:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003074:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003076:	8692                	mv	a3,tp
    80003078:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000307a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000307e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003082:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003086:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000308a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000308c:	6f18                	ld	a4,24(a4)
    8000308e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003092:	692c                	ld	a1,80(a0)
    80003094:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003096:	00005717          	auipc	a4,0x5
    8000309a:	ffa70713          	addi	a4,a4,-6 # 80008090 <userret>
    8000309e:	8f11                	sub	a4,a4,a2
    800030a0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800030a2:	577d                	li	a4,-1
    800030a4:	177e                	slli	a4,a4,0x3f
    800030a6:	8dd9                	or	a1,a1,a4
    800030a8:	02000537          	lui	a0,0x2000
    800030ac:	157d                	addi	a0,a0,-1
    800030ae:	0536                	slli	a0,a0,0xd
    800030b0:	9782                	jalr	a5
}
    800030b2:	60a2                	ld	ra,8(sp)
    800030b4:	6402                	ld	s0,0(sp)
    800030b6:	0141                	addi	sp,sp,16
    800030b8:	8082                	ret

00000000800030ba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800030ba:	1101                	addi	sp,sp,-32
    800030bc:	ec06                	sd	ra,24(sp)
    800030be:	e822                	sd	s0,16(sp)
    800030c0:	e426                	sd	s1,8(sp)
    800030c2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800030c4:	0002e497          	auipc	s1,0x2e
    800030c8:	40c48493          	addi	s1,s1,1036 # 800314d0 <tickslock>
    800030cc:	8526                	mv	a0,s1
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	af4080e7          	jalr	-1292(ra) # 80000bc2 <acquire>
  ticks++;
    800030d6:	00007517          	auipc	a0,0x7
    800030da:	f6250513          	addi	a0,a0,-158 # 8000a038 <ticks>
    800030de:	411c                	lw	a5,0(a0)
    800030e0:	2785                	addiw	a5,a5,1
    800030e2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	ec0080e7          	jalr	-320(ra) # 80001fa4 <wakeup>
  release(&tickslock);
    800030ec:	8526                	mv	a0,s1
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	b88080e7          	jalr	-1144(ra) # 80000c76 <release>
}
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	64a2                	ld	s1,8(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret

0000000080003100 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000310a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000310e:	00074d63          	bltz	a4,80003128 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003112:	57fd                	li	a5,-1
    80003114:	17fe                	slli	a5,a5,0x3f
    80003116:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003118:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000311a:	06f70363          	beq	a4,a5,80003180 <devintr+0x80>
  }
}
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	64a2                	ld	s1,8(sp)
    80003124:	6105                	addi	sp,sp,32
    80003126:	8082                	ret
     (scause & 0xff) == 9){
    80003128:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000312c:	46a5                	li	a3,9
    8000312e:	fed792e3          	bne	a5,a3,80003112 <devintr+0x12>
    int irq = plic_claim();
    80003132:	00004097          	auipc	ra,0x4
    80003136:	be6080e7          	jalr	-1050(ra) # 80006d18 <plic_claim>
    8000313a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000313c:	47a9                	li	a5,10
    8000313e:	02f50763          	beq	a0,a5,8000316c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003142:	4785                	li	a5,1
    80003144:	02f50963          	beq	a0,a5,80003176 <devintr+0x76>
    return 1;
    80003148:	4505                	li	a0,1
    } else if(irq){
    8000314a:	d8f1                	beqz	s1,8000311e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000314c:	85a6                	mv	a1,s1
    8000314e:	00006517          	auipc	a0,0x6
    80003152:	43a50513          	addi	a0,a0,1082 # 80009588 <states.0+0x38>
    80003156:	ffffd097          	auipc	ra,0xffffd
    8000315a:	41e080e7          	jalr	1054(ra) # 80000574 <printf>
      plic_complete(irq);
    8000315e:	8526                	mv	a0,s1
    80003160:	00004097          	auipc	ra,0x4
    80003164:	bdc080e7          	jalr	-1060(ra) # 80006d3c <plic_complete>
    return 1;
    80003168:	4505                	li	a0,1
    8000316a:	bf55                	j	8000311e <devintr+0x1e>
      uartintr();
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	81a080e7          	jalr	-2022(ra) # 80000986 <uartintr>
    80003174:	b7ed                	j	8000315e <devintr+0x5e>
      virtio_disk_intr();
    80003176:	00004097          	auipc	ra,0x4
    8000317a:	058080e7          	jalr	88(ra) # 800071ce <virtio_disk_intr>
    8000317e:	b7c5                	j	8000315e <devintr+0x5e>
    if(cpuid() == 0){
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	9bc080e7          	jalr	-1604(ra) # 80001b3c <cpuid>
    80003188:	c901                	beqz	a0,80003198 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000318a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000318e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003190:	14479073          	csrw	sip,a5
    return 2;
    80003194:	4509                	li	a0,2
    80003196:	b761                	j	8000311e <devintr+0x1e>
      clockintr();
    80003198:	00000097          	auipc	ra,0x0
    8000319c:	f22080e7          	jalr	-222(ra) # 800030ba <clockintr>
    800031a0:	b7ed                	j	8000318a <devintr+0x8a>

00000000800031a2 <usertrap>:
{
    800031a2:	1101                	addi	sp,sp,-32
    800031a4:	ec06                	sd	ra,24(sp)
    800031a6:	e822                	sd	s0,16(sp)
    800031a8:	e426                	sd	s1,8(sp)
    800031aa:	e04a                	sd	s2,0(sp)
    800031ac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031ae:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800031b2:	1007f793          	andi	a5,a5,256
    800031b6:	e3ad                	bnez	a5,80003218 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031b8:	00004797          	auipc	a5,0x4
    800031bc:	a5878793          	addi	a5,a5,-1448 # 80006c10 <kernelvec>
    800031c0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800031c4:	fffff097          	auipc	ra,0xfffff
    800031c8:	9a4080e7          	jalr	-1628(ra) # 80001b68 <myproc>
    800031cc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800031ce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031d0:	14102773          	csrr	a4,sepc
    800031d4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031d6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800031da:	47a1                	li	a5,8
    800031dc:	04f70663          	beq	a4,a5,80003228 <usertrap+0x86>
  } else if(p->pid > 2 && (r_scause() == 12 || r_scause() == 13 || r_scause() == 15)) {
    800031e0:	5918                	lw	a4,48(a0)
    800031e2:	4789                	li	a5,2
    800031e4:	02e7d163          	bge	a5,a4,80003206 <usertrap+0x64>
    800031e8:	14202773          	csrr	a4,scause
    800031ec:	47b1                	li	a5,12
    800031ee:	06f70f63          	beq	a4,a5,8000326c <usertrap+0xca>
    800031f2:	14202773          	csrr	a4,scause
    800031f6:	47b5                	li	a5,13
    800031f8:	06f70a63          	beq	a4,a5,8000326c <usertrap+0xca>
    800031fc:	14202773          	csrr	a4,scause
    80003200:	47bd                	li	a5,15
    80003202:	06f70563          	beq	a4,a5,8000326c <usertrap+0xca>
  } else if((which_dev = devintr()) != 0){
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	efa080e7          	jalr	-262(ra) # 80003100 <devintr>
    8000320e:	892a                	mv	s2,a0
    80003210:	c535                	beqz	a0,8000327c <usertrap+0xda>
  if(p->killed)
    80003212:	549c                	lw	a5,40(s1)
    80003214:	c7c5                	beqz	a5,800032bc <usertrap+0x11a>
    80003216:	a871                	j	800032b2 <usertrap+0x110>
    panic("usertrap: not from user mode");
    80003218:	00006517          	auipc	a0,0x6
    8000321c:	39050513          	addi	a0,a0,912 # 800095a8 <states.0+0x58>
    80003220:	ffffd097          	auipc	ra,0xffffd
    80003224:	30a080e7          	jalr	778(ra) # 8000052a <panic>
    if(p->killed)
    80003228:	551c                	lw	a5,40(a0)
    8000322a:	eb9d                	bnez	a5,80003260 <usertrap+0xbe>
    p->trapframe->epc += 4;
    8000322c:	6cb8                	ld	a4,88(s1)
    8000322e:	6f1c                	ld	a5,24(a4)
    80003230:	0791                	addi	a5,a5,4
    80003232:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003234:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003238:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000323c:	10079073          	csrw	sstatus,a5
    syscall();
    80003240:	00000097          	auipc	ra,0x0
    80003244:	2ce080e7          	jalr	718(ra) # 8000350e <syscall>
  if(p->killed)
    80003248:	549c                	lw	a5,40(s1)
    8000324a:	e3bd                	bnez	a5,800032b0 <usertrap+0x10e>
  usertrapret();
    8000324c:	00000097          	auipc	ra,0x0
    80003250:	dd0080e7          	jalr	-560(ra) # 8000301c <usertrapret>
}
    80003254:	60e2                	ld	ra,24(sp)
    80003256:	6442                	ld	s0,16(sp)
    80003258:	64a2                	ld	s1,8(sp)
    8000325a:	6902                	ld	s2,0(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret
      exit(-1);
    80003260:	557d                	li	a0,-1
    80003262:	fffff097          	auipc	ra,0xfffff
    80003266:	e12080e7          	jalr	-494(ra) # 80002074 <exit>
    8000326a:	b7c9                	j	8000322c <usertrap+0x8a>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000326c:	143025f3          	csrr	a1,stval
    hanle_page_fault(p, va);
    80003270:	8526                	mv	a0,s1
    80003272:	00000097          	auipc	ra,0x0
    80003276:	c1a080e7          	jalr	-998(ra) # 80002e8c <hanle_page_fault>
  } else if(p->pid > 2 && (r_scause() == 12 || r_scause() == 13 || r_scause() == 15)) {
    8000327a:	b7f9                	j	80003248 <usertrap+0xa6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000327c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003280:	5890                	lw	a2,48(s1)
    80003282:	00006517          	auipc	a0,0x6
    80003286:	34650513          	addi	a0,a0,838 # 800095c8 <states.0+0x78>
    8000328a:	ffffd097          	auipc	ra,0xffffd
    8000328e:	2ea080e7          	jalr	746(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003292:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003296:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000329a:	00006517          	auipc	a0,0x6
    8000329e:	21e50513          	addi	a0,a0,542 # 800094b8 <digits+0x478>
    800032a2:	ffffd097          	auipc	ra,0xffffd
    800032a6:	2d2080e7          	jalr	722(ra) # 80000574 <printf>
    p->killed = 1;
    800032aa:	4785                	li	a5,1
    800032ac:	d49c                	sw	a5,40(s1)
  if(p->killed)
    800032ae:	a011                	j	800032b2 <usertrap+0x110>
    800032b0:	4901                	li	s2,0
    exit(-1);
    800032b2:	557d                	li	a0,-1
    800032b4:	fffff097          	auipc	ra,0xfffff
    800032b8:	dc0080e7          	jalr	-576(ra) # 80002074 <exit>
  if(which_dev == 2)
    800032bc:	4789                	li	a5,2
    800032be:	f8f917e3          	bne	s2,a5,8000324c <usertrap+0xaa>
    yield();
    800032c2:	fffff097          	auipc	ra,0xfffff
    800032c6:	c42080e7          	jalr	-958(ra) # 80001f04 <yield>
    800032ca:	b749                	j	8000324c <usertrap+0xaa>

00000000800032cc <kerneltrap>:
{
    800032cc:	7179                	addi	sp,sp,-48
    800032ce:	f406                	sd	ra,40(sp)
    800032d0:	f022                	sd	s0,32(sp)
    800032d2:	ec26                	sd	s1,24(sp)
    800032d4:	e84a                	sd	s2,16(sp)
    800032d6:	e44e                	sd	s3,8(sp)
    800032d8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032da:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032de:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032e2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800032e6:	1004f793          	andi	a5,s1,256
    800032ea:	cb85                	beqz	a5,8000331a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032ec:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800032f0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800032f2:	ef85                	bnez	a5,8000332a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	e0c080e7          	jalr	-500(ra) # 80003100 <devintr>
    800032fc:	cd1d                	beqz	a0,8000333a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032fe:	4789                	li	a5,2
    80003300:	06f50a63          	beq	a0,a5,80003374 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003304:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003308:	10049073          	csrw	sstatus,s1
}
    8000330c:	70a2                	ld	ra,40(sp)
    8000330e:	7402                	ld	s0,32(sp)
    80003310:	64e2                	ld	s1,24(sp)
    80003312:	6942                	ld	s2,16(sp)
    80003314:	69a2                	ld	s3,8(sp)
    80003316:	6145                	addi	sp,sp,48
    80003318:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000331a:	00006517          	auipc	a0,0x6
    8000331e:	2de50513          	addi	a0,a0,734 # 800095f8 <states.0+0xa8>
    80003322:	ffffd097          	auipc	ra,0xffffd
    80003326:	208080e7          	jalr	520(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    8000332a:	00006517          	auipc	a0,0x6
    8000332e:	2f650513          	addi	a0,a0,758 # 80009620 <states.0+0xd0>
    80003332:	ffffd097          	auipc	ra,0xffffd
    80003336:	1f8080e7          	jalr	504(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    8000333a:	85ce                	mv	a1,s3
    8000333c:	00006517          	auipc	a0,0x6
    80003340:	30450513          	addi	a0,a0,772 # 80009640 <states.0+0xf0>
    80003344:	ffffd097          	auipc	ra,0xffffd
    80003348:	230080e7          	jalr	560(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000334c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003350:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003354:	00006517          	auipc	a0,0x6
    80003358:	2fc50513          	addi	a0,a0,764 # 80009650 <states.0+0x100>
    8000335c:	ffffd097          	auipc	ra,0xffffd
    80003360:	218080e7          	jalr	536(ra) # 80000574 <printf>
    panic("kerneltrap");
    80003364:	00006517          	auipc	a0,0x6
    80003368:	30450513          	addi	a0,a0,772 # 80009668 <states.0+0x118>
    8000336c:	ffffd097          	auipc	ra,0xffffd
    80003370:	1be080e7          	jalr	446(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	7f4080e7          	jalr	2036(ra) # 80001b68 <myproc>
    8000337c:	d541                	beqz	a0,80003304 <kerneltrap+0x38>
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	7ea080e7          	jalr	2026(ra) # 80001b68 <myproc>
    80003386:	4d18                	lw	a4,24(a0)
    80003388:	4791                	li	a5,4
    8000338a:	f6f71de3          	bne	a4,a5,80003304 <kerneltrap+0x38>
    yield();
    8000338e:	fffff097          	auipc	ra,0xfffff
    80003392:	b76080e7          	jalr	-1162(ra) # 80001f04 <yield>
    80003396:	b7bd                	j	80003304 <kerneltrap+0x38>

0000000080003398 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003398:	1101                	addi	sp,sp,-32
    8000339a:	ec06                	sd	ra,24(sp)
    8000339c:	e822                	sd	s0,16(sp)
    8000339e:	e426                	sd	s1,8(sp)
    800033a0:	1000                	addi	s0,sp,32
    800033a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	7c4080e7          	jalr	1988(ra) # 80001b68 <myproc>
  switch (n) {
    800033ac:	4795                	li	a5,5
    800033ae:	0497e163          	bltu	a5,s1,800033f0 <argraw+0x58>
    800033b2:	048a                	slli	s1,s1,0x2
    800033b4:	00006717          	auipc	a4,0x6
    800033b8:	2ec70713          	addi	a4,a4,748 # 800096a0 <states.0+0x150>
    800033bc:	94ba                	add	s1,s1,a4
    800033be:	409c                	lw	a5,0(s1)
    800033c0:	97ba                	add	a5,a5,a4
    800033c2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800033c4:	6d3c                	ld	a5,88(a0)
    800033c6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800033c8:	60e2                	ld	ra,24(sp)
    800033ca:	6442                	ld	s0,16(sp)
    800033cc:	64a2                	ld	s1,8(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret
    return p->trapframe->a1;
    800033d2:	6d3c                	ld	a5,88(a0)
    800033d4:	7fa8                	ld	a0,120(a5)
    800033d6:	bfcd                	j	800033c8 <argraw+0x30>
    return p->trapframe->a2;
    800033d8:	6d3c                	ld	a5,88(a0)
    800033da:	63c8                	ld	a0,128(a5)
    800033dc:	b7f5                	j	800033c8 <argraw+0x30>
    return p->trapframe->a3;
    800033de:	6d3c                	ld	a5,88(a0)
    800033e0:	67c8                	ld	a0,136(a5)
    800033e2:	b7dd                	j	800033c8 <argraw+0x30>
    return p->trapframe->a4;
    800033e4:	6d3c                	ld	a5,88(a0)
    800033e6:	6bc8                	ld	a0,144(a5)
    800033e8:	b7c5                	j	800033c8 <argraw+0x30>
    return p->trapframe->a5;
    800033ea:	6d3c                	ld	a5,88(a0)
    800033ec:	6fc8                	ld	a0,152(a5)
    800033ee:	bfe9                	j	800033c8 <argraw+0x30>
  panic("argraw");
    800033f0:	00006517          	auipc	a0,0x6
    800033f4:	28850513          	addi	a0,a0,648 # 80009678 <states.0+0x128>
    800033f8:	ffffd097          	auipc	ra,0xffffd
    800033fc:	132080e7          	jalr	306(ra) # 8000052a <panic>

0000000080003400 <fetchaddr>:
{
    80003400:	1101                	addi	sp,sp,-32
    80003402:	ec06                	sd	ra,24(sp)
    80003404:	e822                	sd	s0,16(sp)
    80003406:	e426                	sd	s1,8(sp)
    80003408:	e04a                	sd	s2,0(sp)
    8000340a:	1000                	addi	s0,sp,32
    8000340c:	84aa                	mv	s1,a0
    8000340e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003410:	ffffe097          	auipc	ra,0xffffe
    80003414:	758080e7          	jalr	1880(ra) # 80001b68 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003418:	653c                	ld	a5,72(a0)
    8000341a:	02f4f863          	bgeu	s1,a5,8000344a <fetchaddr+0x4a>
    8000341e:	00848713          	addi	a4,s1,8
    80003422:	02e7e663          	bltu	a5,a4,8000344e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003426:	46a1                	li	a3,8
    80003428:	8626                	mv	a2,s1
    8000342a:	85ca                	mv	a1,s2
    8000342c:	6928                	ld	a0,80(a0)
    8000342e:	ffffe097          	auipc	ra,0xffffe
    80003432:	486080e7          	jalr	1158(ra) # 800018b4 <copyin>
    80003436:	00a03533          	snez	a0,a0
    8000343a:	40a00533          	neg	a0,a0
}
    8000343e:	60e2                	ld	ra,24(sp)
    80003440:	6442                	ld	s0,16(sp)
    80003442:	64a2                	ld	s1,8(sp)
    80003444:	6902                	ld	s2,0(sp)
    80003446:	6105                	addi	sp,sp,32
    80003448:	8082                	ret
    return -1;
    8000344a:	557d                	li	a0,-1
    8000344c:	bfcd                	j	8000343e <fetchaddr+0x3e>
    8000344e:	557d                	li	a0,-1
    80003450:	b7fd                	j	8000343e <fetchaddr+0x3e>

0000000080003452 <fetchstr>:
{
    80003452:	7179                	addi	sp,sp,-48
    80003454:	f406                	sd	ra,40(sp)
    80003456:	f022                	sd	s0,32(sp)
    80003458:	ec26                	sd	s1,24(sp)
    8000345a:	e84a                	sd	s2,16(sp)
    8000345c:	e44e                	sd	s3,8(sp)
    8000345e:	1800                	addi	s0,sp,48
    80003460:	892a                	mv	s2,a0
    80003462:	84ae                	mv	s1,a1
    80003464:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003466:	ffffe097          	auipc	ra,0xffffe
    8000346a:	702080e7          	jalr	1794(ra) # 80001b68 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000346e:	86ce                	mv	a3,s3
    80003470:	864a                	mv	a2,s2
    80003472:	85a6                	mv	a1,s1
    80003474:	6928                	ld	a0,80(a0)
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	4cc080e7          	jalr	1228(ra) # 80001942 <copyinstr>
  if(err < 0)
    8000347e:	00054763          	bltz	a0,8000348c <fetchstr+0x3a>
  return strlen(buf);
    80003482:	8526                	mv	a0,s1
    80003484:	ffffe097          	auipc	ra,0xffffe
    80003488:	9be080e7          	jalr	-1602(ra) # 80000e42 <strlen>
}
    8000348c:	70a2                	ld	ra,40(sp)
    8000348e:	7402                	ld	s0,32(sp)
    80003490:	64e2                	ld	s1,24(sp)
    80003492:	6942                	ld	s2,16(sp)
    80003494:	69a2                	ld	s3,8(sp)
    80003496:	6145                	addi	sp,sp,48
    80003498:	8082                	ret

000000008000349a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000349a:	1101                	addi	sp,sp,-32
    8000349c:	ec06                	sd	ra,24(sp)
    8000349e:	e822                	sd	s0,16(sp)
    800034a0:	e426                	sd	s1,8(sp)
    800034a2:	1000                	addi	s0,sp,32
    800034a4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800034a6:	00000097          	auipc	ra,0x0
    800034aa:	ef2080e7          	jalr	-270(ra) # 80003398 <argraw>
    800034ae:	c088                	sw	a0,0(s1)
  return 0;
}
    800034b0:	4501                	li	a0,0
    800034b2:	60e2                	ld	ra,24(sp)
    800034b4:	6442                	ld	s0,16(sp)
    800034b6:	64a2                	ld	s1,8(sp)
    800034b8:	6105                	addi	sp,sp,32
    800034ba:	8082                	ret

00000000800034bc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800034bc:	1101                	addi	sp,sp,-32
    800034be:	ec06                	sd	ra,24(sp)
    800034c0:	e822                	sd	s0,16(sp)
    800034c2:	e426                	sd	s1,8(sp)
    800034c4:	1000                	addi	s0,sp,32
    800034c6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	ed0080e7          	jalr	-304(ra) # 80003398 <argraw>
    800034d0:	e088                	sd	a0,0(s1)
  return 0;
}
    800034d2:	4501                	li	a0,0
    800034d4:	60e2                	ld	ra,24(sp)
    800034d6:	6442                	ld	s0,16(sp)
    800034d8:	64a2                	ld	s1,8(sp)
    800034da:	6105                	addi	sp,sp,32
    800034dc:	8082                	ret

00000000800034de <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	e04a                	sd	s2,0(sp)
    800034e8:	1000                	addi	s0,sp,32
    800034ea:	84ae                	mv	s1,a1
    800034ec:	8932                	mv	s2,a2
  *ip = argraw(n);
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	eaa080e7          	jalr	-342(ra) # 80003398 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800034f6:	864a                	mv	a2,s2
    800034f8:	85a6                	mv	a1,s1
    800034fa:	00000097          	auipc	ra,0x0
    800034fe:	f58080e7          	jalr	-168(ra) # 80003452 <fetchstr>
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6902                	ld	s2,0(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret

000000008000350e <syscall>:
[SYS_printmem]  sys_printmem,
};

void
syscall(void)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	e426                	sd	s1,8(sp)
    80003516:	e04a                	sd	s2,0(sp)
    80003518:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000351a:	ffffe097          	auipc	ra,0xffffe
    8000351e:	64e080e7          	jalr	1614(ra) # 80001b68 <myproc>
    80003522:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003524:	05853903          	ld	s2,88(a0)
    80003528:	0a893783          	ld	a5,168(s2)
    8000352c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003530:	37fd                	addiw	a5,a5,-1
    80003532:	4755                	li	a4,21
    80003534:	00f76f63          	bltu	a4,a5,80003552 <syscall+0x44>
    80003538:	00369713          	slli	a4,a3,0x3
    8000353c:	00006797          	auipc	a5,0x6
    80003540:	17c78793          	addi	a5,a5,380 # 800096b8 <syscalls>
    80003544:	97ba                	add	a5,a5,a4
    80003546:	639c                	ld	a5,0(a5)
    80003548:	c789                	beqz	a5,80003552 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    8000354a:	9782                	jalr	a5
    8000354c:	06a93823          	sd	a0,112(s2)
    80003550:	a839                	j	8000356e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003552:	15848613          	addi	a2,s1,344
    80003556:	588c                	lw	a1,48(s1)
    80003558:	00006517          	auipc	a0,0x6
    8000355c:	12850513          	addi	a0,a0,296 # 80009680 <states.0+0x130>
    80003560:	ffffd097          	auipc	ra,0xffffd
    80003564:	014080e7          	jalr	20(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003568:	6cbc                	ld	a5,88(s1)
    8000356a:	577d                	li	a4,-1
    8000356c:	fbb8                	sd	a4,112(a5)
  }
}
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6902                	ld	s2,0(sp)
    80003576:	6105                	addi	sp,sp,32
    80003578:	8082                	ret

000000008000357a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000357a:	1101                	addi	sp,sp,-32
    8000357c:	ec06                	sd	ra,24(sp)
    8000357e:	e822                	sd	s0,16(sp)
    80003580:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003582:	fec40593          	addi	a1,s0,-20
    80003586:	4501                	li	a0,0
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	f12080e7          	jalr	-238(ra) # 8000349a <argint>
    return -1;
    80003590:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003592:	00054963          	bltz	a0,800035a4 <sys_exit+0x2a>
  exit(n);
    80003596:	fec42503          	lw	a0,-20(s0)
    8000359a:	fffff097          	auipc	ra,0xfffff
    8000359e:	ada080e7          	jalr	-1318(ra) # 80002074 <exit>
  return 0;  // not reached
    800035a2:	4781                	li	a5,0
}
    800035a4:	853e                	mv	a0,a5
    800035a6:	60e2                	ld	ra,24(sp)
    800035a8:	6442                	ld	s0,16(sp)
    800035aa:	6105                	addi	sp,sp,32
    800035ac:	8082                	ret

00000000800035ae <sys_getpid>:

uint64
sys_getpid(void)
{
    800035ae:	1141                	addi	sp,sp,-16
    800035b0:	e406                	sd	ra,8(sp)
    800035b2:	e022                	sd	s0,0(sp)
    800035b4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800035b6:	ffffe097          	auipc	ra,0xffffe
    800035ba:	5b2080e7          	jalr	1458(ra) # 80001b68 <myproc>
}
    800035be:	5908                	lw	a0,48(a0)
    800035c0:	60a2                	ld	ra,8(sp)
    800035c2:	6402                	ld	s0,0(sp)
    800035c4:	0141                	addi	sp,sp,16
    800035c6:	8082                	ret

00000000800035c8 <sys_fork>:

uint64
sys_fork(void)
{
    800035c8:	1141                	addi	sp,sp,-16
    800035ca:	e406                	sd	ra,8(sp)
    800035cc:	e022                	sd	s0,0(sp)
    800035ce:	0800                	addi	s0,sp,16
  return fork();
    800035d0:	fffff097          	auipc	ra,0xfffff
    800035d4:	2aa080e7          	jalr	682(ra) # 8000287a <fork>
}
    800035d8:	60a2                	ld	ra,8(sp)
    800035da:	6402                	ld	s0,0(sp)
    800035dc:	0141                	addi	sp,sp,16
    800035de:	8082                	ret

00000000800035e0 <sys_wait>:

uint64
sys_wait(void)
{
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800035e8:	fe840593          	addi	a1,s0,-24
    800035ec:	4501                	li	a0,0
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	ece080e7          	jalr	-306(ra) # 800034bc <argaddr>
    800035f6:	87aa                	mv	a5,a0
    return -1;
    800035f8:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800035fa:	0007c863          	bltz	a5,8000360a <sys_wait+0x2a>
  return wait(p);
    800035fe:	fe843503          	ld	a0,-24(s0)
    80003602:	fffff097          	auipc	ra,0xfffff
    80003606:	e2e080e7          	jalr	-466(ra) # 80002430 <wait>
}
    8000360a:	60e2                	ld	ra,24(sp)
    8000360c:	6442                	ld	s0,16(sp)
    8000360e:	6105                	addi	sp,sp,32
    80003610:	8082                	ret

0000000080003612 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003612:	7179                	addi	sp,sp,-48
    80003614:	f406                	sd	ra,40(sp)
    80003616:	f022                	sd	s0,32(sp)
    80003618:	ec26                	sd	s1,24(sp)
    8000361a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000361c:	fdc40593          	addi	a1,s0,-36
    80003620:	4501                	li	a0,0
    80003622:	00000097          	auipc	ra,0x0
    80003626:	e78080e7          	jalr	-392(ra) # 8000349a <argint>
    return -1;
    8000362a:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000362c:	00054f63          	bltz	a0,8000364a <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003630:	ffffe097          	auipc	ra,0xffffe
    80003634:	538080e7          	jalr	1336(ra) # 80001b68 <myproc>
    80003638:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    8000363a:	fdc42503          	lw	a0,-36(s0)
    8000363e:	ffffe097          	auipc	ra,0xffffe
    80003642:	6dc080e7          	jalr	1756(ra) # 80001d1a <growproc>
    80003646:	00054863          	bltz	a0,80003656 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000364a:	8526                	mv	a0,s1
    8000364c:	70a2                	ld	ra,40(sp)
    8000364e:	7402                	ld	s0,32(sp)
    80003650:	64e2                	ld	s1,24(sp)
    80003652:	6145                	addi	sp,sp,48
    80003654:	8082                	ret
    return -1;
    80003656:	54fd                	li	s1,-1
    80003658:	bfcd                	j	8000364a <sys_sbrk+0x38>

000000008000365a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000365a:	7139                	addi	sp,sp,-64
    8000365c:	fc06                	sd	ra,56(sp)
    8000365e:	f822                	sd	s0,48(sp)
    80003660:	f426                	sd	s1,40(sp)
    80003662:	f04a                	sd	s2,32(sp)
    80003664:	ec4e                	sd	s3,24(sp)
    80003666:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003668:	fcc40593          	addi	a1,s0,-52
    8000366c:	4501                	li	a0,0
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	e2c080e7          	jalr	-468(ra) # 8000349a <argint>
    return -1;
    80003676:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003678:	06054563          	bltz	a0,800036e2 <sys_sleep+0x88>
  acquire(&tickslock);
    8000367c:	0002e517          	auipc	a0,0x2e
    80003680:	e5450513          	addi	a0,a0,-428 # 800314d0 <tickslock>
    80003684:	ffffd097          	auipc	ra,0xffffd
    80003688:	53e080e7          	jalr	1342(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    8000368c:	00007917          	auipc	s2,0x7
    80003690:	9ac92903          	lw	s2,-1620(s2) # 8000a038 <ticks>
  while(ticks - ticks0 < n){
    80003694:	fcc42783          	lw	a5,-52(s0)
    80003698:	cf85                	beqz	a5,800036d0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000369a:	0002e997          	auipc	s3,0x2e
    8000369e:	e3698993          	addi	s3,s3,-458 # 800314d0 <tickslock>
    800036a2:	00007497          	auipc	s1,0x7
    800036a6:	99648493          	addi	s1,s1,-1642 # 8000a038 <ticks>
    if(myproc()->killed){
    800036aa:	ffffe097          	auipc	ra,0xffffe
    800036ae:	4be080e7          	jalr	1214(ra) # 80001b68 <myproc>
    800036b2:	551c                	lw	a5,40(a0)
    800036b4:	ef9d                	bnez	a5,800036f2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800036b6:	85ce                	mv	a1,s3
    800036b8:	8526                	mv	a0,s1
    800036ba:	fffff097          	auipc	ra,0xfffff
    800036be:	886080e7          	jalr	-1914(ra) # 80001f40 <sleep>
  while(ticks - ticks0 < n){
    800036c2:	409c                	lw	a5,0(s1)
    800036c4:	412787bb          	subw	a5,a5,s2
    800036c8:	fcc42703          	lw	a4,-52(s0)
    800036cc:	fce7efe3          	bltu	a5,a4,800036aa <sys_sleep+0x50>
  }
  release(&tickslock);
    800036d0:	0002e517          	auipc	a0,0x2e
    800036d4:	e0050513          	addi	a0,a0,-512 # 800314d0 <tickslock>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	59e080e7          	jalr	1438(ra) # 80000c76 <release>
  return 0;
    800036e0:	4781                	li	a5,0
}
    800036e2:	853e                	mv	a0,a5
    800036e4:	70e2                	ld	ra,56(sp)
    800036e6:	7442                	ld	s0,48(sp)
    800036e8:	74a2                	ld	s1,40(sp)
    800036ea:	7902                	ld	s2,32(sp)
    800036ec:	69e2                	ld	s3,24(sp)
    800036ee:	6121                	addi	sp,sp,64
    800036f0:	8082                	ret
      release(&tickslock);
    800036f2:	0002e517          	auipc	a0,0x2e
    800036f6:	dde50513          	addi	a0,a0,-546 # 800314d0 <tickslock>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	57c080e7          	jalr	1404(ra) # 80000c76 <release>
      return -1;
    80003702:	57fd                	li	a5,-1
    80003704:	bff9                	j	800036e2 <sys_sleep+0x88>

0000000080003706 <sys_kill>:

uint64
sys_kill(void)
{
    80003706:	1101                	addi	sp,sp,-32
    80003708:	ec06                	sd	ra,24(sp)
    8000370a:	e822                	sd	s0,16(sp)
    8000370c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000370e:	fec40593          	addi	a1,s0,-20
    80003712:	4501                	li	a0,0
    80003714:	00000097          	auipc	ra,0x0
    80003718:	d86080e7          	jalr	-634(ra) # 8000349a <argint>
    8000371c:	87aa                	mv	a5,a0
    return -1;
    8000371e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003720:	0007c863          	bltz	a5,80003730 <sys_kill+0x2a>
  return kill(pid);
    80003724:	fec42503          	lw	a0,-20(s0)
    80003728:	fffff097          	auipc	ra,0xfffff
    8000372c:	a38080e7          	jalr	-1480(ra) # 80002160 <kill>
}
    80003730:	60e2                	ld	ra,24(sp)
    80003732:	6442                	ld	s0,16(sp)
    80003734:	6105                	addi	sp,sp,32
    80003736:	8082                	ret

0000000080003738 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003738:	1101                	addi	sp,sp,-32
    8000373a:	ec06                	sd	ra,24(sp)
    8000373c:	e822                	sd	s0,16(sp)
    8000373e:	e426                	sd	s1,8(sp)
    80003740:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003742:	0002e517          	auipc	a0,0x2e
    80003746:	d8e50513          	addi	a0,a0,-626 # 800314d0 <tickslock>
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	478080e7          	jalr	1144(ra) # 80000bc2 <acquire>
  xticks = ticks;
    80003752:	00007497          	auipc	s1,0x7
    80003756:	8e64a483          	lw	s1,-1818(s1) # 8000a038 <ticks>
  release(&tickslock);
    8000375a:	0002e517          	auipc	a0,0x2e
    8000375e:	d7650513          	addi	a0,a0,-650 # 800314d0 <tickslock>
    80003762:	ffffd097          	auipc	ra,0xffffd
    80003766:	514080e7          	jalr	1300(ra) # 80000c76 <release>
  return xticks;
}
    8000376a:	02049513          	slli	a0,s1,0x20
    8000376e:	9101                	srli	a0,a0,0x20
    80003770:	60e2                	ld	ra,24(sp)
    80003772:	6442                	ld	s0,16(sp)
    80003774:	64a2                	ld	s1,8(sp)
    80003776:	6105                	addi	sp,sp,32
    80003778:	8082                	ret

000000008000377a <sys_printmem>:

uint64
sys_printmem(void)
{
    8000377a:	1141                	addi	sp,sp,-16
    8000377c:	e406                	sd	ra,8(sp)
    8000377e:	e022                	sd	s0,0(sp)
    80003780:	0800                	addi	s0,sp,16
  return printmem();
    80003782:	fffff097          	auipc	ra,0xfffff
    80003786:	77a080e7          	jalr	1914(ra) # 80002efc <printmem>
    8000378a:	60a2                	ld	ra,8(sp)
    8000378c:	6402                	ld	s0,0(sp)
    8000378e:	0141                	addi	sp,sp,16
    80003790:	8082                	ret

0000000080003792 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003792:	7179                	addi	sp,sp,-48
    80003794:	f406                	sd	ra,40(sp)
    80003796:	f022                	sd	s0,32(sp)
    80003798:	ec26                	sd	s1,24(sp)
    8000379a:	e84a                	sd	s2,16(sp)
    8000379c:	e44e                	sd	s3,8(sp)
    8000379e:	e052                	sd	s4,0(sp)
    800037a0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800037a2:	00006597          	auipc	a1,0x6
    800037a6:	fce58593          	addi	a1,a1,-50 # 80009770 <syscalls+0xb8>
    800037aa:	0002e517          	auipc	a0,0x2e
    800037ae:	d3e50513          	addi	a0,a0,-706 # 800314e8 <bcache>
    800037b2:	ffffd097          	auipc	ra,0xffffd
    800037b6:	380080e7          	jalr	896(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800037ba:	00036797          	auipc	a5,0x36
    800037be:	d2e78793          	addi	a5,a5,-722 # 800394e8 <bcache+0x8000>
    800037c2:	00036717          	auipc	a4,0x36
    800037c6:	f8e70713          	addi	a4,a4,-114 # 80039750 <bcache+0x8268>
    800037ca:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800037ce:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037d2:	0002e497          	auipc	s1,0x2e
    800037d6:	d2e48493          	addi	s1,s1,-722 # 80031500 <bcache+0x18>
    b->next = bcache.head.next;
    800037da:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800037dc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800037de:	00006a17          	auipc	s4,0x6
    800037e2:	f9aa0a13          	addi	s4,s4,-102 # 80009778 <syscalls+0xc0>
    b->next = bcache.head.next;
    800037e6:	2b893783          	ld	a5,696(s2)
    800037ea:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800037ec:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800037f0:	85d2                	mv	a1,s4
    800037f2:	01048513          	addi	a0,s1,16
    800037f6:	00001097          	auipc	ra,0x1
    800037fa:	7d4080e7          	jalr	2004(ra) # 80004fca <initsleeplock>
    bcache.head.next->prev = b;
    800037fe:	2b893783          	ld	a5,696(s2)
    80003802:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003804:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003808:	45848493          	addi	s1,s1,1112
    8000380c:	fd349de3          	bne	s1,s3,800037e6 <binit+0x54>
  }
}
    80003810:	70a2                	ld	ra,40(sp)
    80003812:	7402                	ld	s0,32(sp)
    80003814:	64e2                	ld	s1,24(sp)
    80003816:	6942                	ld	s2,16(sp)
    80003818:	69a2                	ld	s3,8(sp)
    8000381a:	6a02                	ld	s4,0(sp)
    8000381c:	6145                	addi	sp,sp,48
    8000381e:	8082                	ret

0000000080003820 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003820:	7179                	addi	sp,sp,-48
    80003822:	f406                	sd	ra,40(sp)
    80003824:	f022                	sd	s0,32(sp)
    80003826:	ec26                	sd	s1,24(sp)
    80003828:	e84a                	sd	s2,16(sp)
    8000382a:	e44e                	sd	s3,8(sp)
    8000382c:	1800                	addi	s0,sp,48
    8000382e:	892a                	mv	s2,a0
    80003830:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003832:	0002e517          	auipc	a0,0x2e
    80003836:	cb650513          	addi	a0,a0,-842 # 800314e8 <bcache>
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	388080e7          	jalr	904(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003842:	00036497          	auipc	s1,0x36
    80003846:	f5e4b483          	ld	s1,-162(s1) # 800397a0 <bcache+0x82b8>
    8000384a:	00036797          	auipc	a5,0x36
    8000384e:	f0678793          	addi	a5,a5,-250 # 80039750 <bcache+0x8268>
    80003852:	02f48f63          	beq	s1,a5,80003890 <bread+0x70>
    80003856:	873e                	mv	a4,a5
    80003858:	a021                	j	80003860 <bread+0x40>
    8000385a:	68a4                	ld	s1,80(s1)
    8000385c:	02e48a63          	beq	s1,a4,80003890 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003860:	449c                	lw	a5,8(s1)
    80003862:	ff279ce3          	bne	a5,s2,8000385a <bread+0x3a>
    80003866:	44dc                	lw	a5,12(s1)
    80003868:	ff3799e3          	bne	a5,s3,8000385a <bread+0x3a>
      b->refcnt++;
    8000386c:	40bc                	lw	a5,64(s1)
    8000386e:	2785                	addiw	a5,a5,1
    80003870:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003872:	0002e517          	auipc	a0,0x2e
    80003876:	c7650513          	addi	a0,a0,-906 # 800314e8 <bcache>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	3fc080e7          	jalr	1020(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003882:	01048513          	addi	a0,s1,16
    80003886:	00001097          	auipc	ra,0x1
    8000388a:	77e080e7          	jalr	1918(ra) # 80005004 <acquiresleep>
      return b;
    8000388e:	a8b9                	j	800038ec <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003890:	00036497          	auipc	s1,0x36
    80003894:	f084b483          	ld	s1,-248(s1) # 80039798 <bcache+0x82b0>
    80003898:	00036797          	auipc	a5,0x36
    8000389c:	eb878793          	addi	a5,a5,-328 # 80039750 <bcache+0x8268>
    800038a0:	00f48863          	beq	s1,a5,800038b0 <bread+0x90>
    800038a4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800038a6:	40bc                	lw	a5,64(s1)
    800038a8:	cf81                	beqz	a5,800038c0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800038aa:	64a4                	ld	s1,72(s1)
    800038ac:	fee49de3          	bne	s1,a4,800038a6 <bread+0x86>
  panic("bget: no buffers");
    800038b0:	00006517          	auipc	a0,0x6
    800038b4:	ed050513          	addi	a0,a0,-304 # 80009780 <syscalls+0xc8>
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	c72080e7          	jalr	-910(ra) # 8000052a <panic>
      b->dev = dev;
    800038c0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800038c4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800038c8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800038cc:	4785                	li	a5,1
    800038ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038d0:	0002e517          	auipc	a0,0x2e
    800038d4:	c1850513          	addi	a0,a0,-1000 # 800314e8 <bcache>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	39e080e7          	jalr	926(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800038e0:	01048513          	addi	a0,s1,16
    800038e4:	00001097          	auipc	ra,0x1
    800038e8:	720080e7          	jalr	1824(ra) # 80005004 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800038ec:	409c                	lw	a5,0(s1)
    800038ee:	cb89                	beqz	a5,80003900 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800038f0:	8526                	mv	a0,s1
    800038f2:	70a2                	ld	ra,40(sp)
    800038f4:	7402                	ld	s0,32(sp)
    800038f6:	64e2                	ld	s1,24(sp)
    800038f8:	6942                	ld	s2,16(sp)
    800038fa:	69a2                	ld	s3,8(sp)
    800038fc:	6145                	addi	sp,sp,48
    800038fe:	8082                	ret
    virtio_disk_rw(b, 0);
    80003900:	4581                	li	a1,0
    80003902:	8526                	mv	a0,s1
    80003904:	00003097          	auipc	ra,0x3
    80003908:	642080e7          	jalr	1602(ra) # 80006f46 <virtio_disk_rw>
    b->valid = 1;
    8000390c:	4785                	li	a5,1
    8000390e:	c09c                	sw	a5,0(s1)
  return b;
    80003910:	b7c5                	j	800038f0 <bread+0xd0>

0000000080003912 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003912:	1101                	addi	sp,sp,-32
    80003914:	ec06                	sd	ra,24(sp)
    80003916:	e822                	sd	s0,16(sp)
    80003918:	e426                	sd	s1,8(sp)
    8000391a:	1000                	addi	s0,sp,32
    8000391c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000391e:	0541                	addi	a0,a0,16
    80003920:	00001097          	auipc	ra,0x1
    80003924:	77e080e7          	jalr	1918(ra) # 8000509e <holdingsleep>
    80003928:	cd01                	beqz	a0,80003940 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000392a:	4585                	li	a1,1
    8000392c:	8526                	mv	a0,s1
    8000392e:	00003097          	auipc	ra,0x3
    80003932:	618080e7          	jalr	1560(ra) # 80006f46 <virtio_disk_rw>
}
    80003936:	60e2                	ld	ra,24(sp)
    80003938:	6442                	ld	s0,16(sp)
    8000393a:	64a2                	ld	s1,8(sp)
    8000393c:	6105                	addi	sp,sp,32
    8000393e:	8082                	ret
    panic("bwrite");
    80003940:	00006517          	auipc	a0,0x6
    80003944:	e5850513          	addi	a0,a0,-424 # 80009798 <syscalls+0xe0>
    80003948:	ffffd097          	auipc	ra,0xffffd
    8000394c:	be2080e7          	jalr	-1054(ra) # 8000052a <panic>

0000000080003950 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003950:	1101                	addi	sp,sp,-32
    80003952:	ec06                	sd	ra,24(sp)
    80003954:	e822                	sd	s0,16(sp)
    80003956:	e426                	sd	s1,8(sp)
    80003958:	e04a                	sd	s2,0(sp)
    8000395a:	1000                	addi	s0,sp,32
    8000395c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000395e:	01050913          	addi	s2,a0,16
    80003962:	854a                	mv	a0,s2
    80003964:	00001097          	auipc	ra,0x1
    80003968:	73a080e7          	jalr	1850(ra) # 8000509e <holdingsleep>
    8000396c:	c92d                	beqz	a0,800039de <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	6ea080e7          	jalr	1770(ra) # 8000505a <releasesleep>

  acquire(&bcache.lock);
    80003978:	0002e517          	auipc	a0,0x2e
    8000397c:	b7050513          	addi	a0,a0,-1168 # 800314e8 <bcache>
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	242080e7          	jalr	578(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003988:	40bc                	lw	a5,64(s1)
    8000398a:	37fd                	addiw	a5,a5,-1
    8000398c:	0007871b          	sext.w	a4,a5
    80003990:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003992:	eb05                	bnez	a4,800039c2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003994:	68bc                	ld	a5,80(s1)
    80003996:	64b8                	ld	a4,72(s1)
    80003998:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000399a:	64bc                	ld	a5,72(s1)
    8000399c:	68b8                	ld	a4,80(s1)
    8000399e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800039a0:	00036797          	auipc	a5,0x36
    800039a4:	b4878793          	addi	a5,a5,-1208 # 800394e8 <bcache+0x8000>
    800039a8:	2b87b703          	ld	a4,696(a5)
    800039ac:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800039ae:	00036717          	auipc	a4,0x36
    800039b2:	da270713          	addi	a4,a4,-606 # 80039750 <bcache+0x8268>
    800039b6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800039b8:	2b87b703          	ld	a4,696(a5)
    800039bc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800039be:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800039c2:	0002e517          	auipc	a0,0x2e
    800039c6:	b2650513          	addi	a0,a0,-1242 # 800314e8 <bcache>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	2ac080e7          	jalr	684(ra) # 80000c76 <release>
}
    800039d2:	60e2                	ld	ra,24(sp)
    800039d4:	6442                	ld	s0,16(sp)
    800039d6:	64a2                	ld	s1,8(sp)
    800039d8:	6902                	ld	s2,0(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret
    panic("brelse");
    800039de:	00006517          	auipc	a0,0x6
    800039e2:	dc250513          	addi	a0,a0,-574 # 800097a0 <syscalls+0xe8>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	b44080e7          	jalr	-1212(ra) # 8000052a <panic>

00000000800039ee <bpin>:

void
bpin(struct buf *b) {
    800039ee:	1101                	addi	sp,sp,-32
    800039f0:	ec06                	sd	ra,24(sp)
    800039f2:	e822                	sd	s0,16(sp)
    800039f4:	e426                	sd	s1,8(sp)
    800039f6:	1000                	addi	s0,sp,32
    800039f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039fa:	0002e517          	auipc	a0,0x2e
    800039fe:	aee50513          	addi	a0,a0,-1298 # 800314e8 <bcache>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	1c0080e7          	jalr	448(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003a0a:	40bc                	lw	a5,64(s1)
    80003a0c:	2785                	addiw	a5,a5,1
    80003a0e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a10:	0002e517          	auipc	a0,0x2e
    80003a14:	ad850513          	addi	a0,a0,-1320 # 800314e8 <bcache>
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	25e080e7          	jalr	606(ra) # 80000c76 <release>
}
    80003a20:	60e2                	ld	ra,24(sp)
    80003a22:	6442                	ld	s0,16(sp)
    80003a24:	64a2                	ld	s1,8(sp)
    80003a26:	6105                	addi	sp,sp,32
    80003a28:	8082                	ret

0000000080003a2a <bunpin>:

void
bunpin(struct buf *b) {
    80003a2a:	1101                	addi	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	1000                	addi	s0,sp,32
    80003a34:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a36:	0002e517          	auipc	a0,0x2e
    80003a3a:	ab250513          	addi	a0,a0,-1358 # 800314e8 <bcache>
    80003a3e:	ffffd097          	auipc	ra,0xffffd
    80003a42:	184080e7          	jalr	388(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003a46:	40bc                	lw	a5,64(s1)
    80003a48:	37fd                	addiw	a5,a5,-1
    80003a4a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a4c:	0002e517          	auipc	a0,0x2e
    80003a50:	a9c50513          	addi	a0,a0,-1380 # 800314e8 <bcache>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	222080e7          	jalr	546(ra) # 80000c76 <release>
}
    80003a5c:	60e2                	ld	ra,24(sp)
    80003a5e:	6442                	ld	s0,16(sp)
    80003a60:	64a2                	ld	s1,8(sp)
    80003a62:	6105                	addi	sp,sp,32
    80003a64:	8082                	ret

0000000080003a66 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a66:	1101                	addi	sp,sp,-32
    80003a68:	ec06                	sd	ra,24(sp)
    80003a6a:	e822                	sd	s0,16(sp)
    80003a6c:	e426                	sd	s1,8(sp)
    80003a6e:	e04a                	sd	s2,0(sp)
    80003a70:	1000                	addi	s0,sp,32
    80003a72:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a74:	00d5d59b          	srliw	a1,a1,0xd
    80003a78:	00036797          	auipc	a5,0x36
    80003a7c:	14c7a783          	lw	a5,332(a5) # 80039bc4 <sb+0x1c>
    80003a80:	9dbd                	addw	a1,a1,a5
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	d9e080e7          	jalr	-610(ra) # 80003820 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a8a:	0074f713          	andi	a4,s1,7
    80003a8e:	4785                	li	a5,1
    80003a90:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a94:	14ce                	slli	s1,s1,0x33
    80003a96:	90d9                	srli	s1,s1,0x36
    80003a98:	00950733          	add	a4,a0,s1
    80003a9c:	05874703          	lbu	a4,88(a4)
    80003aa0:	00e7f6b3          	and	a3,a5,a4
    80003aa4:	c69d                	beqz	a3,80003ad2 <bfree+0x6c>
    80003aa6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003aa8:	94aa                	add	s1,s1,a0
    80003aaa:	fff7c793          	not	a5,a5
    80003aae:	8ff9                	and	a5,a5,a4
    80003ab0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003ab4:	00001097          	auipc	ra,0x1
    80003ab8:	430080e7          	jalr	1072(ra) # 80004ee4 <log_write>
  brelse(bp);
    80003abc:	854a                	mv	a0,s2
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	e92080e7          	jalr	-366(ra) # 80003950 <brelse>
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6902                	ld	s2,0(sp)
    80003ace:	6105                	addi	sp,sp,32
    80003ad0:	8082                	ret
    panic("freeing free block");
    80003ad2:	00006517          	auipc	a0,0x6
    80003ad6:	cd650513          	addi	a0,a0,-810 # 800097a8 <syscalls+0xf0>
    80003ada:	ffffd097          	auipc	ra,0xffffd
    80003ade:	a50080e7          	jalr	-1456(ra) # 8000052a <panic>

0000000080003ae2 <balloc>:
{
    80003ae2:	711d                	addi	sp,sp,-96
    80003ae4:	ec86                	sd	ra,88(sp)
    80003ae6:	e8a2                	sd	s0,80(sp)
    80003ae8:	e4a6                	sd	s1,72(sp)
    80003aea:	e0ca                	sd	s2,64(sp)
    80003aec:	fc4e                	sd	s3,56(sp)
    80003aee:	f852                	sd	s4,48(sp)
    80003af0:	f456                	sd	s5,40(sp)
    80003af2:	f05a                	sd	s6,32(sp)
    80003af4:	ec5e                	sd	s7,24(sp)
    80003af6:	e862                	sd	s8,16(sp)
    80003af8:	e466                	sd	s9,8(sp)
    80003afa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003afc:	00036797          	auipc	a5,0x36
    80003b00:	0b07a783          	lw	a5,176(a5) # 80039bac <sb+0x4>
    80003b04:	cbd1                	beqz	a5,80003b98 <balloc+0xb6>
    80003b06:	8baa                	mv	s7,a0
    80003b08:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b0a:	00036b17          	auipc	s6,0x36
    80003b0e:	09eb0b13          	addi	s6,s6,158 # 80039ba8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b12:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b14:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b16:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b18:	6c89                	lui	s9,0x2
    80003b1a:	a831                	j	80003b36 <balloc+0x54>
    brelse(bp);
    80003b1c:	854a                	mv	a0,s2
    80003b1e:	00000097          	auipc	ra,0x0
    80003b22:	e32080e7          	jalr	-462(ra) # 80003950 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b26:	015c87bb          	addw	a5,s9,s5
    80003b2a:	00078a9b          	sext.w	s5,a5
    80003b2e:	004b2703          	lw	a4,4(s6)
    80003b32:	06eaf363          	bgeu	s5,a4,80003b98 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003b36:	41fad79b          	sraiw	a5,s5,0x1f
    80003b3a:	0137d79b          	srliw	a5,a5,0x13
    80003b3e:	015787bb          	addw	a5,a5,s5
    80003b42:	40d7d79b          	sraiw	a5,a5,0xd
    80003b46:	01cb2583          	lw	a1,28(s6)
    80003b4a:	9dbd                	addw	a1,a1,a5
    80003b4c:	855e                	mv	a0,s7
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	cd2080e7          	jalr	-814(ra) # 80003820 <bread>
    80003b56:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b58:	004b2503          	lw	a0,4(s6)
    80003b5c:	000a849b          	sext.w	s1,s5
    80003b60:	8662                	mv	a2,s8
    80003b62:	faa4fde3          	bgeu	s1,a0,80003b1c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003b66:	41f6579b          	sraiw	a5,a2,0x1f
    80003b6a:	01d7d69b          	srliw	a3,a5,0x1d
    80003b6e:	00c6873b          	addw	a4,a3,a2
    80003b72:	00777793          	andi	a5,a4,7
    80003b76:	9f95                	subw	a5,a5,a3
    80003b78:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b7c:	4037571b          	sraiw	a4,a4,0x3
    80003b80:	00e906b3          	add	a3,s2,a4
    80003b84:	0586c683          	lbu	a3,88(a3)
    80003b88:	00d7f5b3          	and	a1,a5,a3
    80003b8c:	cd91                	beqz	a1,80003ba8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b8e:	2605                	addiw	a2,a2,1
    80003b90:	2485                	addiw	s1,s1,1
    80003b92:	fd4618e3          	bne	a2,s4,80003b62 <balloc+0x80>
    80003b96:	b759                	j	80003b1c <balloc+0x3a>
  panic("balloc: out of blocks");
    80003b98:	00006517          	auipc	a0,0x6
    80003b9c:	c2850513          	addi	a0,a0,-984 # 800097c0 <syscalls+0x108>
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	98a080e7          	jalr	-1654(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003ba8:	974a                	add	a4,a4,s2
    80003baa:	8fd5                	or	a5,a5,a3
    80003bac:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003bb0:	854a                	mv	a0,s2
    80003bb2:	00001097          	auipc	ra,0x1
    80003bb6:	332080e7          	jalr	818(ra) # 80004ee4 <log_write>
        brelse(bp);
    80003bba:	854a                	mv	a0,s2
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	d94080e7          	jalr	-620(ra) # 80003950 <brelse>
  bp = bread(dev, bno);
    80003bc4:	85a6                	mv	a1,s1
    80003bc6:	855e                	mv	a0,s7
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	c58080e7          	jalr	-936(ra) # 80003820 <bread>
    80003bd0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003bd2:	40000613          	li	a2,1024
    80003bd6:	4581                	li	a1,0
    80003bd8:	05850513          	addi	a0,a0,88
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	0e2080e7          	jalr	226(ra) # 80000cbe <memset>
  log_write(bp);
    80003be4:	854a                	mv	a0,s2
    80003be6:	00001097          	auipc	ra,0x1
    80003bea:	2fe080e7          	jalr	766(ra) # 80004ee4 <log_write>
  brelse(bp);
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	d60080e7          	jalr	-672(ra) # 80003950 <brelse>
}
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	60e6                	ld	ra,88(sp)
    80003bfc:	6446                	ld	s0,80(sp)
    80003bfe:	64a6                	ld	s1,72(sp)
    80003c00:	6906                	ld	s2,64(sp)
    80003c02:	79e2                	ld	s3,56(sp)
    80003c04:	7a42                	ld	s4,48(sp)
    80003c06:	7aa2                	ld	s5,40(sp)
    80003c08:	7b02                	ld	s6,32(sp)
    80003c0a:	6be2                	ld	s7,24(sp)
    80003c0c:	6c42                	ld	s8,16(sp)
    80003c0e:	6ca2                	ld	s9,8(sp)
    80003c10:	6125                	addi	sp,sp,96
    80003c12:	8082                	ret

0000000080003c14 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c14:	7179                	addi	sp,sp,-48
    80003c16:	f406                	sd	ra,40(sp)
    80003c18:	f022                	sd	s0,32(sp)
    80003c1a:	ec26                	sd	s1,24(sp)
    80003c1c:	e84a                	sd	s2,16(sp)
    80003c1e:	e44e                	sd	s3,8(sp)
    80003c20:	e052                	sd	s4,0(sp)
    80003c22:	1800                	addi	s0,sp,48
    80003c24:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c26:	47ad                	li	a5,11
    80003c28:	04b7fe63          	bgeu	a5,a1,80003c84 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003c2c:	ff45849b          	addiw	s1,a1,-12
    80003c30:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c34:	0ff00793          	li	a5,255
    80003c38:	0ae7e463          	bltu	a5,a4,80003ce0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003c3c:	08052583          	lw	a1,128(a0)
    80003c40:	c5b5                	beqz	a1,80003cac <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003c42:	00092503          	lw	a0,0(s2)
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	bda080e7          	jalr	-1062(ra) # 80003820 <bread>
    80003c4e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c50:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c54:	02049713          	slli	a4,s1,0x20
    80003c58:	01e75593          	srli	a1,a4,0x1e
    80003c5c:	00b784b3          	add	s1,a5,a1
    80003c60:	0004a983          	lw	s3,0(s1)
    80003c64:	04098e63          	beqz	s3,80003cc0 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003c68:	8552                	mv	a0,s4
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	ce6080e7          	jalr	-794(ra) # 80003950 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c72:	854e                	mv	a0,s3
    80003c74:	70a2                	ld	ra,40(sp)
    80003c76:	7402                	ld	s0,32(sp)
    80003c78:	64e2                	ld	s1,24(sp)
    80003c7a:	6942                	ld	s2,16(sp)
    80003c7c:	69a2                	ld	s3,8(sp)
    80003c7e:	6a02                	ld	s4,0(sp)
    80003c80:	6145                	addi	sp,sp,48
    80003c82:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003c84:	02059793          	slli	a5,a1,0x20
    80003c88:	01e7d593          	srli	a1,a5,0x1e
    80003c8c:	00b504b3          	add	s1,a0,a1
    80003c90:	0504a983          	lw	s3,80(s1)
    80003c94:	fc099fe3          	bnez	s3,80003c72 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003c98:	4108                	lw	a0,0(a0)
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	e48080e7          	jalr	-440(ra) # 80003ae2 <balloc>
    80003ca2:	0005099b          	sext.w	s3,a0
    80003ca6:	0534a823          	sw	s3,80(s1)
    80003caa:	b7e1                	j	80003c72 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003cac:	4108                	lw	a0,0(a0)
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	e34080e7          	jalr	-460(ra) # 80003ae2 <balloc>
    80003cb6:	0005059b          	sext.w	a1,a0
    80003cba:	08b92023          	sw	a1,128(s2)
    80003cbe:	b751                	j	80003c42 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003cc0:	00092503          	lw	a0,0(s2)
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	e1e080e7          	jalr	-482(ra) # 80003ae2 <balloc>
    80003ccc:	0005099b          	sext.w	s3,a0
    80003cd0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003cd4:	8552                	mv	a0,s4
    80003cd6:	00001097          	auipc	ra,0x1
    80003cda:	20e080e7          	jalr	526(ra) # 80004ee4 <log_write>
    80003cde:	b769                	j	80003c68 <bmap+0x54>
  panic("bmap: out of range");
    80003ce0:	00006517          	auipc	a0,0x6
    80003ce4:	af850513          	addi	a0,a0,-1288 # 800097d8 <syscalls+0x120>
    80003ce8:	ffffd097          	auipc	ra,0xffffd
    80003cec:	842080e7          	jalr	-1982(ra) # 8000052a <panic>

0000000080003cf0 <iget>:
{
    80003cf0:	7179                	addi	sp,sp,-48
    80003cf2:	f406                	sd	ra,40(sp)
    80003cf4:	f022                	sd	s0,32(sp)
    80003cf6:	ec26                	sd	s1,24(sp)
    80003cf8:	e84a                	sd	s2,16(sp)
    80003cfa:	e44e                	sd	s3,8(sp)
    80003cfc:	e052                	sd	s4,0(sp)
    80003cfe:	1800                	addi	s0,sp,48
    80003d00:	89aa                	mv	s3,a0
    80003d02:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d04:	00036517          	auipc	a0,0x36
    80003d08:	ec450513          	addi	a0,a0,-316 # 80039bc8 <itable>
    80003d0c:	ffffd097          	auipc	ra,0xffffd
    80003d10:	eb6080e7          	jalr	-330(ra) # 80000bc2 <acquire>
  empty = 0;
    80003d14:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d16:	00036497          	auipc	s1,0x36
    80003d1a:	eca48493          	addi	s1,s1,-310 # 80039be0 <itable+0x18>
    80003d1e:	00038697          	auipc	a3,0x38
    80003d22:	95268693          	addi	a3,a3,-1710 # 8003b670 <log>
    80003d26:	a039                	j	80003d34 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d28:	02090b63          	beqz	s2,80003d5e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d2c:	08848493          	addi	s1,s1,136
    80003d30:	02d48a63          	beq	s1,a3,80003d64 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d34:	449c                	lw	a5,8(s1)
    80003d36:	fef059e3          	blez	a5,80003d28 <iget+0x38>
    80003d3a:	4098                	lw	a4,0(s1)
    80003d3c:	ff3716e3          	bne	a4,s3,80003d28 <iget+0x38>
    80003d40:	40d8                	lw	a4,4(s1)
    80003d42:	ff4713e3          	bne	a4,s4,80003d28 <iget+0x38>
      ip->ref++;
    80003d46:	2785                	addiw	a5,a5,1
    80003d48:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003d4a:	00036517          	auipc	a0,0x36
    80003d4e:	e7e50513          	addi	a0,a0,-386 # 80039bc8 <itable>
    80003d52:	ffffd097          	auipc	ra,0xffffd
    80003d56:	f24080e7          	jalr	-220(ra) # 80000c76 <release>
      return ip;
    80003d5a:	8926                	mv	s2,s1
    80003d5c:	a03d                	j	80003d8a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d5e:	f7f9                	bnez	a5,80003d2c <iget+0x3c>
    80003d60:	8926                	mv	s2,s1
    80003d62:	b7e9                	j	80003d2c <iget+0x3c>
  if(empty == 0)
    80003d64:	02090c63          	beqz	s2,80003d9c <iget+0xac>
  ip->dev = dev;
    80003d68:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d6c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d70:	4785                	li	a5,1
    80003d72:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d76:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d7a:	00036517          	auipc	a0,0x36
    80003d7e:	e4e50513          	addi	a0,a0,-434 # 80039bc8 <itable>
    80003d82:	ffffd097          	auipc	ra,0xffffd
    80003d86:	ef4080e7          	jalr	-268(ra) # 80000c76 <release>
}
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	70a2                	ld	ra,40(sp)
    80003d8e:	7402                	ld	s0,32(sp)
    80003d90:	64e2                	ld	s1,24(sp)
    80003d92:	6942                	ld	s2,16(sp)
    80003d94:	69a2                	ld	s3,8(sp)
    80003d96:	6a02                	ld	s4,0(sp)
    80003d98:	6145                	addi	sp,sp,48
    80003d9a:	8082                	ret
    panic("iget: no inodes");
    80003d9c:	00006517          	auipc	a0,0x6
    80003da0:	a5450513          	addi	a0,a0,-1452 # 800097f0 <syscalls+0x138>
    80003da4:	ffffc097          	auipc	ra,0xffffc
    80003da8:	786080e7          	jalr	1926(ra) # 8000052a <panic>

0000000080003dac <fsinit>:
fsinit(int dev) {
    80003dac:	7179                	addi	sp,sp,-48
    80003dae:	f406                	sd	ra,40(sp)
    80003db0:	f022                	sd	s0,32(sp)
    80003db2:	ec26                	sd	s1,24(sp)
    80003db4:	e84a                	sd	s2,16(sp)
    80003db6:	e44e                	sd	s3,8(sp)
    80003db8:	1800                	addi	s0,sp,48
    80003dba:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003dbc:	4585                	li	a1,1
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	a62080e7          	jalr	-1438(ra) # 80003820 <bread>
    80003dc6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003dc8:	00036997          	auipc	s3,0x36
    80003dcc:	de098993          	addi	s3,s3,-544 # 80039ba8 <sb>
    80003dd0:	02000613          	li	a2,32
    80003dd4:	05850593          	addi	a1,a0,88
    80003dd8:	854e                	mv	a0,s3
    80003dda:	ffffd097          	auipc	ra,0xffffd
    80003dde:	f40080e7          	jalr	-192(ra) # 80000d1a <memmove>
  brelse(bp);
    80003de2:	8526                	mv	a0,s1
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	b6c080e7          	jalr	-1172(ra) # 80003950 <brelse>
  if(sb.magic != FSMAGIC)
    80003dec:	0009a703          	lw	a4,0(s3)
    80003df0:	102037b7          	lui	a5,0x10203
    80003df4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003df8:	02f71263          	bne	a4,a5,80003e1c <fsinit+0x70>
  initlog(dev, &sb);
    80003dfc:	00036597          	auipc	a1,0x36
    80003e00:	dac58593          	addi	a1,a1,-596 # 80039ba8 <sb>
    80003e04:	854a                	mv	a0,s2
    80003e06:	00001097          	auipc	ra,0x1
    80003e0a:	e60080e7          	jalr	-416(ra) # 80004c66 <initlog>
}
    80003e0e:	70a2                	ld	ra,40(sp)
    80003e10:	7402                	ld	s0,32(sp)
    80003e12:	64e2                	ld	s1,24(sp)
    80003e14:	6942                	ld	s2,16(sp)
    80003e16:	69a2                	ld	s3,8(sp)
    80003e18:	6145                	addi	sp,sp,48
    80003e1a:	8082                	ret
    panic("invalid file system");
    80003e1c:	00006517          	auipc	a0,0x6
    80003e20:	9e450513          	addi	a0,a0,-1564 # 80009800 <syscalls+0x148>
    80003e24:	ffffc097          	auipc	ra,0xffffc
    80003e28:	706080e7          	jalr	1798(ra) # 8000052a <panic>

0000000080003e2c <iinit>:
{
    80003e2c:	7179                	addi	sp,sp,-48
    80003e2e:	f406                	sd	ra,40(sp)
    80003e30:	f022                	sd	s0,32(sp)
    80003e32:	ec26                	sd	s1,24(sp)
    80003e34:	e84a                	sd	s2,16(sp)
    80003e36:	e44e                	sd	s3,8(sp)
    80003e38:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003e3a:	00006597          	auipc	a1,0x6
    80003e3e:	9de58593          	addi	a1,a1,-1570 # 80009818 <syscalls+0x160>
    80003e42:	00036517          	auipc	a0,0x36
    80003e46:	d8650513          	addi	a0,a0,-634 # 80039bc8 <itable>
    80003e4a:	ffffd097          	auipc	ra,0xffffd
    80003e4e:	ce8080e7          	jalr	-792(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003e52:	00036497          	auipc	s1,0x36
    80003e56:	d9e48493          	addi	s1,s1,-610 # 80039bf0 <itable+0x28>
    80003e5a:	00038997          	auipc	s3,0x38
    80003e5e:	82698993          	addi	s3,s3,-2010 # 8003b680 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003e62:	00006917          	auipc	s2,0x6
    80003e66:	9be90913          	addi	s2,s2,-1602 # 80009820 <syscalls+0x168>
    80003e6a:	85ca                	mv	a1,s2
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	00001097          	auipc	ra,0x1
    80003e72:	15c080e7          	jalr	348(ra) # 80004fca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003e76:	08848493          	addi	s1,s1,136
    80003e7a:	ff3498e3          	bne	s1,s3,80003e6a <iinit+0x3e>
}
    80003e7e:	70a2                	ld	ra,40(sp)
    80003e80:	7402                	ld	s0,32(sp)
    80003e82:	64e2                	ld	s1,24(sp)
    80003e84:	6942                	ld	s2,16(sp)
    80003e86:	69a2                	ld	s3,8(sp)
    80003e88:	6145                	addi	sp,sp,48
    80003e8a:	8082                	ret

0000000080003e8c <ialloc>:
{
    80003e8c:	715d                	addi	sp,sp,-80
    80003e8e:	e486                	sd	ra,72(sp)
    80003e90:	e0a2                	sd	s0,64(sp)
    80003e92:	fc26                	sd	s1,56(sp)
    80003e94:	f84a                	sd	s2,48(sp)
    80003e96:	f44e                	sd	s3,40(sp)
    80003e98:	f052                	sd	s4,32(sp)
    80003e9a:	ec56                	sd	s5,24(sp)
    80003e9c:	e85a                	sd	s6,16(sp)
    80003e9e:	e45e                	sd	s7,8(sp)
    80003ea0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ea2:	00036717          	auipc	a4,0x36
    80003ea6:	d1272703          	lw	a4,-750(a4) # 80039bb4 <sb+0xc>
    80003eaa:	4785                	li	a5,1
    80003eac:	04e7fa63          	bgeu	a5,a4,80003f00 <ialloc+0x74>
    80003eb0:	8aaa                	mv	s5,a0
    80003eb2:	8bae                	mv	s7,a1
    80003eb4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003eb6:	00036a17          	auipc	s4,0x36
    80003eba:	cf2a0a13          	addi	s4,s4,-782 # 80039ba8 <sb>
    80003ebe:	00048b1b          	sext.w	s6,s1
    80003ec2:	0044d793          	srli	a5,s1,0x4
    80003ec6:	018a2583          	lw	a1,24(s4)
    80003eca:	9dbd                	addw	a1,a1,a5
    80003ecc:	8556                	mv	a0,s5
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	952080e7          	jalr	-1710(ra) # 80003820 <bread>
    80003ed6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ed8:	05850993          	addi	s3,a0,88
    80003edc:	00f4f793          	andi	a5,s1,15
    80003ee0:	079a                	slli	a5,a5,0x6
    80003ee2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ee4:	00099783          	lh	a5,0(s3)
    80003ee8:	c785                	beqz	a5,80003f10 <ialloc+0x84>
    brelse(bp);
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	a66080e7          	jalr	-1434(ra) # 80003950 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ef2:	0485                	addi	s1,s1,1
    80003ef4:	00ca2703          	lw	a4,12(s4)
    80003ef8:	0004879b          	sext.w	a5,s1
    80003efc:	fce7e1e3          	bltu	a5,a4,80003ebe <ialloc+0x32>
  panic("ialloc: no inodes");
    80003f00:	00006517          	auipc	a0,0x6
    80003f04:	92850513          	addi	a0,a0,-1752 # 80009828 <syscalls+0x170>
    80003f08:	ffffc097          	auipc	ra,0xffffc
    80003f0c:	622080e7          	jalr	1570(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003f10:	04000613          	li	a2,64
    80003f14:	4581                	li	a1,0
    80003f16:	854e                	mv	a0,s3
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	da6080e7          	jalr	-602(ra) # 80000cbe <memset>
      dip->type = type;
    80003f20:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003f24:	854a                	mv	a0,s2
    80003f26:	00001097          	auipc	ra,0x1
    80003f2a:	fbe080e7          	jalr	-66(ra) # 80004ee4 <log_write>
      brelse(bp);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	a20080e7          	jalr	-1504(ra) # 80003950 <brelse>
      return iget(dev, inum);
    80003f38:	85da                	mv	a1,s6
    80003f3a:	8556                	mv	a0,s5
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	db4080e7          	jalr	-588(ra) # 80003cf0 <iget>
}
    80003f44:	60a6                	ld	ra,72(sp)
    80003f46:	6406                	ld	s0,64(sp)
    80003f48:	74e2                	ld	s1,56(sp)
    80003f4a:	7942                	ld	s2,48(sp)
    80003f4c:	79a2                	ld	s3,40(sp)
    80003f4e:	7a02                	ld	s4,32(sp)
    80003f50:	6ae2                	ld	s5,24(sp)
    80003f52:	6b42                	ld	s6,16(sp)
    80003f54:	6ba2                	ld	s7,8(sp)
    80003f56:	6161                	addi	sp,sp,80
    80003f58:	8082                	ret

0000000080003f5a <iupdate>:
{
    80003f5a:	1101                	addi	sp,sp,-32
    80003f5c:	ec06                	sd	ra,24(sp)
    80003f5e:	e822                	sd	s0,16(sp)
    80003f60:	e426                	sd	s1,8(sp)
    80003f62:	e04a                	sd	s2,0(sp)
    80003f64:	1000                	addi	s0,sp,32
    80003f66:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f68:	415c                	lw	a5,4(a0)
    80003f6a:	0047d79b          	srliw	a5,a5,0x4
    80003f6e:	00036597          	auipc	a1,0x36
    80003f72:	c525a583          	lw	a1,-942(a1) # 80039bc0 <sb+0x18>
    80003f76:	9dbd                	addw	a1,a1,a5
    80003f78:	4108                	lw	a0,0(a0)
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	8a6080e7          	jalr	-1882(ra) # 80003820 <bread>
    80003f82:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f84:	05850793          	addi	a5,a0,88
    80003f88:	40c8                	lw	a0,4(s1)
    80003f8a:	893d                	andi	a0,a0,15
    80003f8c:	051a                	slli	a0,a0,0x6
    80003f8e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003f90:	04449703          	lh	a4,68(s1)
    80003f94:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003f98:	04649703          	lh	a4,70(s1)
    80003f9c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003fa0:	04849703          	lh	a4,72(s1)
    80003fa4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003fa8:	04a49703          	lh	a4,74(s1)
    80003fac:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003fb0:	44f8                	lw	a4,76(s1)
    80003fb2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003fb4:	03400613          	li	a2,52
    80003fb8:	05048593          	addi	a1,s1,80
    80003fbc:	0531                	addi	a0,a0,12
    80003fbe:	ffffd097          	auipc	ra,0xffffd
    80003fc2:	d5c080e7          	jalr	-676(ra) # 80000d1a <memmove>
  log_write(bp);
    80003fc6:	854a                	mv	a0,s2
    80003fc8:	00001097          	auipc	ra,0x1
    80003fcc:	f1c080e7          	jalr	-228(ra) # 80004ee4 <log_write>
  brelse(bp);
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	97e080e7          	jalr	-1666(ra) # 80003950 <brelse>
}
    80003fda:	60e2                	ld	ra,24(sp)
    80003fdc:	6442                	ld	s0,16(sp)
    80003fde:	64a2                	ld	s1,8(sp)
    80003fe0:	6902                	ld	s2,0(sp)
    80003fe2:	6105                	addi	sp,sp,32
    80003fe4:	8082                	ret

0000000080003fe6 <idup>:
{
    80003fe6:	1101                	addi	sp,sp,-32
    80003fe8:	ec06                	sd	ra,24(sp)
    80003fea:	e822                	sd	s0,16(sp)
    80003fec:	e426                	sd	s1,8(sp)
    80003fee:	1000                	addi	s0,sp,32
    80003ff0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ff2:	00036517          	auipc	a0,0x36
    80003ff6:	bd650513          	addi	a0,a0,-1066 # 80039bc8 <itable>
    80003ffa:	ffffd097          	auipc	ra,0xffffd
    80003ffe:	bc8080e7          	jalr	-1080(ra) # 80000bc2 <acquire>
  ip->ref++;
    80004002:	449c                	lw	a5,8(s1)
    80004004:	2785                	addiw	a5,a5,1
    80004006:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004008:	00036517          	auipc	a0,0x36
    8000400c:	bc050513          	addi	a0,a0,-1088 # 80039bc8 <itable>
    80004010:	ffffd097          	auipc	ra,0xffffd
    80004014:	c66080e7          	jalr	-922(ra) # 80000c76 <release>
}
    80004018:	8526                	mv	a0,s1
    8000401a:	60e2                	ld	ra,24(sp)
    8000401c:	6442                	ld	s0,16(sp)
    8000401e:	64a2                	ld	s1,8(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <ilock>:
{
    80004024:	1101                	addi	sp,sp,-32
    80004026:	ec06                	sd	ra,24(sp)
    80004028:	e822                	sd	s0,16(sp)
    8000402a:	e426                	sd	s1,8(sp)
    8000402c:	e04a                	sd	s2,0(sp)
    8000402e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004030:	c115                	beqz	a0,80004054 <ilock+0x30>
    80004032:	84aa                	mv	s1,a0
    80004034:	451c                	lw	a5,8(a0)
    80004036:	00f05f63          	blez	a5,80004054 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000403a:	0541                	addi	a0,a0,16
    8000403c:	00001097          	auipc	ra,0x1
    80004040:	fc8080e7          	jalr	-56(ra) # 80005004 <acquiresleep>
  if(ip->valid == 0){
    80004044:	40bc                	lw	a5,64(s1)
    80004046:	cf99                	beqz	a5,80004064 <ilock+0x40>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	64a2                	ld	s1,8(sp)
    8000404e:	6902                	ld	s2,0(sp)
    80004050:	6105                	addi	sp,sp,32
    80004052:	8082                	ret
    panic("ilock");
    80004054:	00005517          	auipc	a0,0x5
    80004058:	7ec50513          	addi	a0,a0,2028 # 80009840 <syscalls+0x188>
    8000405c:	ffffc097          	auipc	ra,0xffffc
    80004060:	4ce080e7          	jalr	1230(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004064:	40dc                	lw	a5,4(s1)
    80004066:	0047d79b          	srliw	a5,a5,0x4
    8000406a:	00036597          	auipc	a1,0x36
    8000406e:	b565a583          	lw	a1,-1194(a1) # 80039bc0 <sb+0x18>
    80004072:	9dbd                	addw	a1,a1,a5
    80004074:	4088                	lw	a0,0(s1)
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	7aa080e7          	jalr	1962(ra) # 80003820 <bread>
    8000407e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004080:	05850593          	addi	a1,a0,88
    80004084:	40dc                	lw	a5,4(s1)
    80004086:	8bbd                	andi	a5,a5,15
    80004088:	079a                	slli	a5,a5,0x6
    8000408a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000408c:	00059783          	lh	a5,0(a1)
    80004090:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004094:	00259783          	lh	a5,2(a1)
    80004098:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000409c:	00459783          	lh	a5,4(a1)
    800040a0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800040a4:	00659783          	lh	a5,6(a1)
    800040a8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800040ac:	459c                	lw	a5,8(a1)
    800040ae:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800040b0:	03400613          	li	a2,52
    800040b4:	05b1                	addi	a1,a1,12
    800040b6:	05048513          	addi	a0,s1,80
    800040ba:	ffffd097          	auipc	ra,0xffffd
    800040be:	c60080e7          	jalr	-928(ra) # 80000d1a <memmove>
    brelse(bp);
    800040c2:	854a                	mv	a0,s2
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	88c080e7          	jalr	-1908(ra) # 80003950 <brelse>
    ip->valid = 1;
    800040cc:	4785                	li	a5,1
    800040ce:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800040d0:	04449783          	lh	a5,68(s1)
    800040d4:	fbb5                	bnez	a5,80004048 <ilock+0x24>
      panic("ilock: no type");
    800040d6:	00005517          	auipc	a0,0x5
    800040da:	77250513          	addi	a0,a0,1906 # 80009848 <syscalls+0x190>
    800040de:	ffffc097          	auipc	ra,0xffffc
    800040e2:	44c080e7          	jalr	1100(ra) # 8000052a <panic>

00000000800040e6 <iunlock>:
{
    800040e6:	1101                	addi	sp,sp,-32
    800040e8:	ec06                	sd	ra,24(sp)
    800040ea:	e822                	sd	s0,16(sp)
    800040ec:	e426                	sd	s1,8(sp)
    800040ee:	e04a                	sd	s2,0(sp)
    800040f0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800040f2:	c905                	beqz	a0,80004122 <iunlock+0x3c>
    800040f4:	84aa                	mv	s1,a0
    800040f6:	01050913          	addi	s2,a0,16
    800040fa:	854a                	mv	a0,s2
    800040fc:	00001097          	auipc	ra,0x1
    80004100:	fa2080e7          	jalr	-94(ra) # 8000509e <holdingsleep>
    80004104:	cd19                	beqz	a0,80004122 <iunlock+0x3c>
    80004106:	449c                	lw	a5,8(s1)
    80004108:	00f05d63          	blez	a5,80004122 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000410c:	854a                	mv	a0,s2
    8000410e:	00001097          	auipc	ra,0x1
    80004112:	f4c080e7          	jalr	-180(ra) # 8000505a <releasesleep>
}
    80004116:	60e2                	ld	ra,24(sp)
    80004118:	6442                	ld	s0,16(sp)
    8000411a:	64a2                	ld	s1,8(sp)
    8000411c:	6902                	ld	s2,0(sp)
    8000411e:	6105                	addi	sp,sp,32
    80004120:	8082                	ret
    panic("iunlock");
    80004122:	00005517          	auipc	a0,0x5
    80004126:	73650513          	addi	a0,a0,1846 # 80009858 <syscalls+0x1a0>
    8000412a:	ffffc097          	auipc	ra,0xffffc
    8000412e:	400080e7          	jalr	1024(ra) # 8000052a <panic>

0000000080004132 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004132:	7179                	addi	sp,sp,-48
    80004134:	f406                	sd	ra,40(sp)
    80004136:	f022                	sd	s0,32(sp)
    80004138:	ec26                	sd	s1,24(sp)
    8000413a:	e84a                	sd	s2,16(sp)
    8000413c:	e44e                	sd	s3,8(sp)
    8000413e:	e052                	sd	s4,0(sp)
    80004140:	1800                	addi	s0,sp,48
    80004142:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004144:	05050493          	addi	s1,a0,80
    80004148:	08050913          	addi	s2,a0,128
    8000414c:	a021                	j	80004154 <itrunc+0x22>
    8000414e:	0491                	addi	s1,s1,4
    80004150:	01248d63          	beq	s1,s2,8000416a <itrunc+0x38>
    if(ip->addrs[i]){
    80004154:	408c                	lw	a1,0(s1)
    80004156:	dde5                	beqz	a1,8000414e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004158:	0009a503          	lw	a0,0(s3)
    8000415c:	00000097          	auipc	ra,0x0
    80004160:	90a080e7          	jalr	-1782(ra) # 80003a66 <bfree>
      ip->addrs[i] = 0;
    80004164:	0004a023          	sw	zero,0(s1)
    80004168:	b7dd                	j	8000414e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000416a:	0809a583          	lw	a1,128(s3)
    8000416e:	e185                	bnez	a1,8000418e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004170:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004174:	854e                	mv	a0,s3
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	de4080e7          	jalr	-540(ra) # 80003f5a <iupdate>
}
    8000417e:	70a2                	ld	ra,40(sp)
    80004180:	7402                	ld	s0,32(sp)
    80004182:	64e2                	ld	s1,24(sp)
    80004184:	6942                	ld	s2,16(sp)
    80004186:	69a2                	ld	s3,8(sp)
    80004188:	6a02                	ld	s4,0(sp)
    8000418a:	6145                	addi	sp,sp,48
    8000418c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000418e:	0009a503          	lw	a0,0(s3)
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	68e080e7          	jalr	1678(ra) # 80003820 <bread>
    8000419a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000419c:	05850493          	addi	s1,a0,88
    800041a0:	45850913          	addi	s2,a0,1112
    800041a4:	a021                	j	800041ac <itrunc+0x7a>
    800041a6:	0491                	addi	s1,s1,4
    800041a8:	01248b63          	beq	s1,s2,800041be <itrunc+0x8c>
      if(a[j])
    800041ac:	408c                	lw	a1,0(s1)
    800041ae:	dde5                	beqz	a1,800041a6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800041b0:	0009a503          	lw	a0,0(s3)
    800041b4:	00000097          	auipc	ra,0x0
    800041b8:	8b2080e7          	jalr	-1870(ra) # 80003a66 <bfree>
    800041bc:	b7ed                	j	800041a6 <itrunc+0x74>
    brelse(bp);
    800041be:	8552                	mv	a0,s4
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	790080e7          	jalr	1936(ra) # 80003950 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800041c8:	0809a583          	lw	a1,128(s3)
    800041cc:	0009a503          	lw	a0,0(s3)
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	896080e7          	jalr	-1898(ra) # 80003a66 <bfree>
    ip->addrs[NDIRECT] = 0;
    800041d8:	0809a023          	sw	zero,128(s3)
    800041dc:	bf51                	j	80004170 <itrunc+0x3e>

00000000800041de <iput>:
{
    800041de:	1101                	addi	sp,sp,-32
    800041e0:	ec06                	sd	ra,24(sp)
    800041e2:	e822                	sd	s0,16(sp)
    800041e4:	e426                	sd	s1,8(sp)
    800041e6:	e04a                	sd	s2,0(sp)
    800041e8:	1000                	addi	s0,sp,32
    800041ea:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800041ec:	00036517          	auipc	a0,0x36
    800041f0:	9dc50513          	addi	a0,a0,-1572 # 80039bc8 <itable>
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	9ce080e7          	jalr	-1586(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041fc:	4498                	lw	a4,8(s1)
    800041fe:	4785                	li	a5,1
    80004200:	02f70363          	beq	a4,a5,80004226 <iput+0x48>
  ip->ref--;
    80004204:	449c                	lw	a5,8(s1)
    80004206:	37fd                	addiw	a5,a5,-1
    80004208:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000420a:	00036517          	auipc	a0,0x36
    8000420e:	9be50513          	addi	a0,a0,-1602 # 80039bc8 <itable>
    80004212:	ffffd097          	auipc	ra,0xffffd
    80004216:	a64080e7          	jalr	-1436(ra) # 80000c76 <release>
}
    8000421a:	60e2                	ld	ra,24(sp)
    8000421c:	6442                	ld	s0,16(sp)
    8000421e:	64a2                	ld	s1,8(sp)
    80004220:	6902                	ld	s2,0(sp)
    80004222:	6105                	addi	sp,sp,32
    80004224:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004226:	40bc                	lw	a5,64(s1)
    80004228:	dff1                	beqz	a5,80004204 <iput+0x26>
    8000422a:	04a49783          	lh	a5,74(s1)
    8000422e:	fbf9                	bnez	a5,80004204 <iput+0x26>
    acquiresleep(&ip->lock);
    80004230:	01048913          	addi	s2,s1,16
    80004234:	854a                	mv	a0,s2
    80004236:	00001097          	auipc	ra,0x1
    8000423a:	dce080e7          	jalr	-562(ra) # 80005004 <acquiresleep>
    release(&itable.lock);
    8000423e:	00036517          	auipc	a0,0x36
    80004242:	98a50513          	addi	a0,a0,-1654 # 80039bc8 <itable>
    80004246:	ffffd097          	auipc	ra,0xffffd
    8000424a:	a30080e7          	jalr	-1488(ra) # 80000c76 <release>
    itrunc(ip);
    8000424e:	8526                	mv	a0,s1
    80004250:	00000097          	auipc	ra,0x0
    80004254:	ee2080e7          	jalr	-286(ra) # 80004132 <itrunc>
    ip->type = 0;
    80004258:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000425c:	8526                	mv	a0,s1
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	cfc080e7          	jalr	-772(ra) # 80003f5a <iupdate>
    ip->valid = 0;
    80004266:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000426a:	854a                	mv	a0,s2
    8000426c:	00001097          	auipc	ra,0x1
    80004270:	dee080e7          	jalr	-530(ra) # 8000505a <releasesleep>
    acquire(&itable.lock);
    80004274:	00036517          	auipc	a0,0x36
    80004278:	95450513          	addi	a0,a0,-1708 # 80039bc8 <itable>
    8000427c:	ffffd097          	auipc	ra,0xffffd
    80004280:	946080e7          	jalr	-1722(ra) # 80000bc2 <acquire>
    80004284:	b741                	j	80004204 <iput+0x26>

0000000080004286 <iunlockput>:
{
    80004286:	1101                	addi	sp,sp,-32
    80004288:	ec06                	sd	ra,24(sp)
    8000428a:	e822                	sd	s0,16(sp)
    8000428c:	e426                	sd	s1,8(sp)
    8000428e:	1000                	addi	s0,sp,32
    80004290:	84aa                	mv	s1,a0
  iunlock(ip);
    80004292:	00000097          	auipc	ra,0x0
    80004296:	e54080e7          	jalr	-428(ra) # 800040e6 <iunlock>
  iput(ip);
    8000429a:	8526                	mv	a0,s1
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	f42080e7          	jalr	-190(ra) # 800041de <iput>
}
    800042a4:	60e2                	ld	ra,24(sp)
    800042a6:	6442                	ld	s0,16(sp)
    800042a8:	64a2                	ld	s1,8(sp)
    800042aa:	6105                	addi	sp,sp,32
    800042ac:	8082                	ret

00000000800042ae <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800042ae:	1141                	addi	sp,sp,-16
    800042b0:	e422                	sd	s0,8(sp)
    800042b2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800042b4:	411c                	lw	a5,0(a0)
    800042b6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800042b8:	415c                	lw	a5,4(a0)
    800042ba:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800042bc:	04451783          	lh	a5,68(a0)
    800042c0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800042c4:	04a51783          	lh	a5,74(a0)
    800042c8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800042cc:	04c56783          	lwu	a5,76(a0)
    800042d0:	e99c                	sd	a5,16(a1)
}
    800042d2:	6422                	ld	s0,8(sp)
    800042d4:	0141                	addi	sp,sp,16
    800042d6:	8082                	ret

00000000800042d8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042d8:	457c                	lw	a5,76(a0)
    800042da:	0ed7e963          	bltu	a5,a3,800043cc <readi+0xf4>
{
    800042de:	7159                	addi	sp,sp,-112
    800042e0:	f486                	sd	ra,104(sp)
    800042e2:	f0a2                	sd	s0,96(sp)
    800042e4:	eca6                	sd	s1,88(sp)
    800042e6:	e8ca                	sd	s2,80(sp)
    800042e8:	e4ce                	sd	s3,72(sp)
    800042ea:	e0d2                	sd	s4,64(sp)
    800042ec:	fc56                	sd	s5,56(sp)
    800042ee:	f85a                	sd	s6,48(sp)
    800042f0:	f45e                	sd	s7,40(sp)
    800042f2:	f062                	sd	s8,32(sp)
    800042f4:	ec66                	sd	s9,24(sp)
    800042f6:	e86a                	sd	s10,16(sp)
    800042f8:	e46e                	sd	s11,8(sp)
    800042fa:	1880                	addi	s0,sp,112
    800042fc:	8baa                	mv	s7,a0
    800042fe:	8c2e                	mv	s8,a1
    80004300:	8ab2                	mv	s5,a2
    80004302:	84b6                	mv	s1,a3
    80004304:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004306:	9f35                	addw	a4,a4,a3
    return 0;
    80004308:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000430a:	0ad76063          	bltu	a4,a3,800043aa <readi+0xd2>
  if(off + n > ip->size)
    8000430e:	00e7f463          	bgeu	a5,a4,80004316 <readi+0x3e>
    n = ip->size - off;
    80004312:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004316:	0a0b0963          	beqz	s6,800043c8 <readi+0xf0>
    8000431a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000431c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004320:	5cfd                	li	s9,-1
    80004322:	a82d                	j	8000435c <readi+0x84>
    80004324:	020a1d93          	slli	s11,s4,0x20
    80004328:	020ddd93          	srli	s11,s11,0x20
    8000432c:	05890793          	addi	a5,s2,88
    80004330:	86ee                	mv	a3,s11
    80004332:	963e                	add	a2,a2,a5
    80004334:	85d6                	mv	a1,s5
    80004336:	8562                	mv	a0,s8
    80004338:	ffffe097          	auipc	ra,0xffffe
    8000433c:	e9a080e7          	jalr	-358(ra) # 800021d2 <either_copyout>
    80004340:	05950d63          	beq	a0,s9,8000439a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004344:	854a                	mv	a0,s2
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	60a080e7          	jalr	1546(ra) # 80003950 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000434e:	013a09bb          	addw	s3,s4,s3
    80004352:	009a04bb          	addw	s1,s4,s1
    80004356:	9aee                	add	s5,s5,s11
    80004358:	0569f763          	bgeu	s3,s6,800043a6 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000435c:	000ba903          	lw	s2,0(s7) # 1000 <_entry-0x7ffff000>
    80004360:	00a4d59b          	srliw	a1,s1,0xa
    80004364:	855e                	mv	a0,s7
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	8ae080e7          	jalr	-1874(ra) # 80003c14 <bmap>
    8000436e:	0005059b          	sext.w	a1,a0
    80004372:	854a                	mv	a0,s2
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	4ac080e7          	jalr	1196(ra) # 80003820 <bread>
    8000437c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000437e:	3ff4f613          	andi	a2,s1,1023
    80004382:	40cd07bb          	subw	a5,s10,a2
    80004386:	413b073b          	subw	a4,s6,s3
    8000438a:	8a3e                	mv	s4,a5
    8000438c:	2781                	sext.w	a5,a5
    8000438e:	0007069b          	sext.w	a3,a4
    80004392:	f8f6f9e3          	bgeu	a3,a5,80004324 <readi+0x4c>
    80004396:	8a3a                	mv	s4,a4
    80004398:	b771                	j	80004324 <readi+0x4c>
      brelse(bp);
    8000439a:	854a                	mv	a0,s2
    8000439c:	fffff097          	auipc	ra,0xfffff
    800043a0:	5b4080e7          	jalr	1460(ra) # 80003950 <brelse>
      tot = -1;
    800043a4:	59fd                	li	s3,-1
  }
  return tot;
    800043a6:	0009851b          	sext.w	a0,s3
}
    800043aa:	70a6                	ld	ra,104(sp)
    800043ac:	7406                	ld	s0,96(sp)
    800043ae:	64e6                	ld	s1,88(sp)
    800043b0:	6946                	ld	s2,80(sp)
    800043b2:	69a6                	ld	s3,72(sp)
    800043b4:	6a06                	ld	s4,64(sp)
    800043b6:	7ae2                	ld	s5,56(sp)
    800043b8:	7b42                	ld	s6,48(sp)
    800043ba:	7ba2                	ld	s7,40(sp)
    800043bc:	7c02                	ld	s8,32(sp)
    800043be:	6ce2                	ld	s9,24(sp)
    800043c0:	6d42                	ld	s10,16(sp)
    800043c2:	6da2                	ld	s11,8(sp)
    800043c4:	6165                	addi	sp,sp,112
    800043c6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043c8:	89da                	mv	s3,s6
    800043ca:	bff1                	j	800043a6 <readi+0xce>
    return 0;
    800043cc:	4501                	li	a0,0
}
    800043ce:	8082                	ret

00000000800043d0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043d0:	457c                	lw	a5,76(a0)
    800043d2:	10d7e863          	bltu	a5,a3,800044e2 <writei+0x112>
{
    800043d6:	7159                	addi	sp,sp,-112
    800043d8:	f486                	sd	ra,104(sp)
    800043da:	f0a2                	sd	s0,96(sp)
    800043dc:	eca6                	sd	s1,88(sp)
    800043de:	e8ca                	sd	s2,80(sp)
    800043e0:	e4ce                	sd	s3,72(sp)
    800043e2:	e0d2                	sd	s4,64(sp)
    800043e4:	fc56                	sd	s5,56(sp)
    800043e6:	f85a                	sd	s6,48(sp)
    800043e8:	f45e                	sd	s7,40(sp)
    800043ea:	f062                	sd	s8,32(sp)
    800043ec:	ec66                	sd	s9,24(sp)
    800043ee:	e86a                	sd	s10,16(sp)
    800043f0:	e46e                	sd	s11,8(sp)
    800043f2:	1880                	addi	s0,sp,112
    800043f4:	8b2a                	mv	s6,a0
    800043f6:	8c2e                	mv	s8,a1
    800043f8:	8ab2                	mv	s5,a2
    800043fa:	8936                	mv	s2,a3
    800043fc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800043fe:	00e687bb          	addw	a5,a3,a4
    80004402:	0ed7e263          	bltu	a5,a3,800044e6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004406:	00043737          	lui	a4,0x43
    8000440a:	0ef76063          	bltu	a4,a5,800044ea <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000440e:	0c0b8863          	beqz	s7,800044de <writei+0x10e>
    80004412:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004414:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004418:	5cfd                	li	s9,-1
    8000441a:	a091                	j	8000445e <writei+0x8e>
    8000441c:	02099d93          	slli	s11,s3,0x20
    80004420:	020ddd93          	srli	s11,s11,0x20
    80004424:	05848793          	addi	a5,s1,88
    80004428:	86ee                	mv	a3,s11
    8000442a:	8656                	mv	a2,s5
    8000442c:	85e2                	mv	a1,s8
    8000442e:	953e                	add	a0,a0,a5
    80004430:	ffffe097          	auipc	ra,0xffffe
    80004434:	df8080e7          	jalr	-520(ra) # 80002228 <either_copyin>
    80004438:	07950263          	beq	a0,s9,8000449c <writei+0xcc>

      brelse(bp);
      break;
    }
    log_write(bp);
    8000443c:	8526                	mv	a0,s1
    8000443e:	00001097          	auipc	ra,0x1
    80004442:	aa6080e7          	jalr	-1370(ra) # 80004ee4 <log_write>
    brelse(bp);
    80004446:	8526                	mv	a0,s1
    80004448:	fffff097          	auipc	ra,0xfffff
    8000444c:	508080e7          	jalr	1288(ra) # 80003950 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004450:	01498a3b          	addw	s4,s3,s4
    80004454:	0129893b          	addw	s2,s3,s2
    80004458:	9aee                	add	s5,s5,s11
    8000445a:	057a7663          	bgeu	s4,s7,800044a6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000445e:	000b2483          	lw	s1,0(s6)
    80004462:	00a9559b          	srliw	a1,s2,0xa
    80004466:	855a                	mv	a0,s6
    80004468:	fffff097          	auipc	ra,0xfffff
    8000446c:	7ac080e7          	jalr	1964(ra) # 80003c14 <bmap>
    80004470:	0005059b          	sext.w	a1,a0
    80004474:	8526                	mv	a0,s1
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	3aa080e7          	jalr	938(ra) # 80003820 <bread>
    8000447e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004480:	3ff97513          	andi	a0,s2,1023
    80004484:	40ad07bb          	subw	a5,s10,a0
    80004488:	414b873b          	subw	a4,s7,s4
    8000448c:	89be                	mv	s3,a5
    8000448e:	2781                	sext.w	a5,a5
    80004490:	0007069b          	sext.w	a3,a4
    80004494:	f8f6f4e3          	bgeu	a3,a5,8000441c <writei+0x4c>
    80004498:	89ba                	mv	s3,a4
    8000449a:	b749                	j	8000441c <writei+0x4c>
      brelse(bp);
    8000449c:	8526                	mv	a0,s1
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	4b2080e7          	jalr	1202(ra) # 80003950 <brelse>
  }

  if(off > ip->size)
    800044a6:	04cb2783          	lw	a5,76(s6)
    800044aa:	0127f463          	bgeu	a5,s2,800044b2 <writei+0xe2>
    ip->size = off;
    800044ae:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800044b2:	855a                	mv	a0,s6
    800044b4:	00000097          	auipc	ra,0x0
    800044b8:	aa6080e7          	jalr	-1370(ra) # 80003f5a <iupdate>

  return tot;
    800044bc:	000a051b          	sext.w	a0,s4
}
    800044c0:	70a6                	ld	ra,104(sp)
    800044c2:	7406                	ld	s0,96(sp)
    800044c4:	64e6                	ld	s1,88(sp)
    800044c6:	6946                	ld	s2,80(sp)
    800044c8:	69a6                	ld	s3,72(sp)
    800044ca:	6a06                	ld	s4,64(sp)
    800044cc:	7ae2                	ld	s5,56(sp)
    800044ce:	7b42                	ld	s6,48(sp)
    800044d0:	7ba2                	ld	s7,40(sp)
    800044d2:	7c02                	ld	s8,32(sp)
    800044d4:	6ce2                	ld	s9,24(sp)
    800044d6:	6d42                	ld	s10,16(sp)
    800044d8:	6da2                	ld	s11,8(sp)
    800044da:	6165                	addi	sp,sp,112
    800044dc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044de:	8a5e                	mv	s4,s7
    800044e0:	bfc9                	j	800044b2 <writei+0xe2>
    return -1;
    800044e2:	557d                	li	a0,-1
}
    800044e4:	8082                	ret
    return -1;
    800044e6:	557d                	li	a0,-1
    800044e8:	bfe1                	j	800044c0 <writei+0xf0>
    return -1;
    800044ea:	557d                	li	a0,-1
    800044ec:	bfd1                	j	800044c0 <writei+0xf0>

00000000800044ee <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800044ee:	1141                	addi	sp,sp,-16
    800044f0:	e406                	sd	ra,8(sp)
    800044f2:	e022                	sd	s0,0(sp)
    800044f4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800044f6:	4639                	li	a2,14
    800044f8:	ffffd097          	auipc	ra,0xffffd
    800044fc:	89e080e7          	jalr	-1890(ra) # 80000d96 <strncmp>
}
    80004500:	60a2                	ld	ra,8(sp)
    80004502:	6402                	ld	s0,0(sp)
    80004504:	0141                	addi	sp,sp,16
    80004506:	8082                	ret

0000000080004508 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004508:	7139                	addi	sp,sp,-64
    8000450a:	fc06                	sd	ra,56(sp)
    8000450c:	f822                	sd	s0,48(sp)
    8000450e:	f426                	sd	s1,40(sp)
    80004510:	f04a                	sd	s2,32(sp)
    80004512:	ec4e                	sd	s3,24(sp)
    80004514:	e852                	sd	s4,16(sp)
    80004516:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004518:	04451703          	lh	a4,68(a0)
    8000451c:	4785                	li	a5,1
    8000451e:	00f71a63          	bne	a4,a5,80004532 <dirlookup+0x2a>
    80004522:	892a                	mv	s2,a0
    80004524:	89ae                	mv	s3,a1
    80004526:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004528:	457c                	lw	a5,76(a0)
    8000452a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000452c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000452e:	e79d                	bnez	a5,8000455c <dirlookup+0x54>
    80004530:	a8a5                	j	800045a8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004532:	00005517          	auipc	a0,0x5
    80004536:	32e50513          	addi	a0,a0,814 # 80009860 <syscalls+0x1a8>
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	ff0080e7          	jalr	-16(ra) # 8000052a <panic>
      panic("dirlookup read");
    80004542:	00005517          	auipc	a0,0x5
    80004546:	33650513          	addi	a0,a0,822 # 80009878 <syscalls+0x1c0>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	fe0080e7          	jalr	-32(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004552:	24c1                	addiw	s1,s1,16
    80004554:	04c92783          	lw	a5,76(s2)
    80004558:	04f4f763          	bgeu	s1,a5,800045a6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000455c:	4741                	li	a4,16
    8000455e:	86a6                	mv	a3,s1
    80004560:	fc040613          	addi	a2,s0,-64
    80004564:	4581                	li	a1,0
    80004566:	854a                	mv	a0,s2
    80004568:	00000097          	auipc	ra,0x0
    8000456c:	d70080e7          	jalr	-656(ra) # 800042d8 <readi>
    80004570:	47c1                	li	a5,16
    80004572:	fcf518e3          	bne	a0,a5,80004542 <dirlookup+0x3a>
    if(de.inum == 0)
    80004576:	fc045783          	lhu	a5,-64(s0)
    8000457a:	dfe1                	beqz	a5,80004552 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000457c:	fc240593          	addi	a1,s0,-62
    80004580:	854e                	mv	a0,s3
    80004582:	00000097          	auipc	ra,0x0
    80004586:	f6c080e7          	jalr	-148(ra) # 800044ee <namecmp>
    8000458a:	f561                	bnez	a0,80004552 <dirlookup+0x4a>
      if(poff)
    8000458c:	000a0463          	beqz	s4,80004594 <dirlookup+0x8c>
        *poff = off;
    80004590:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004594:	fc045583          	lhu	a1,-64(s0)
    80004598:	00092503          	lw	a0,0(s2)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	754080e7          	jalr	1876(ra) # 80003cf0 <iget>
    800045a4:	a011                	j	800045a8 <dirlookup+0xa0>
  return 0;
    800045a6:	4501                	li	a0,0
}
    800045a8:	70e2                	ld	ra,56(sp)
    800045aa:	7442                	ld	s0,48(sp)
    800045ac:	74a2                	ld	s1,40(sp)
    800045ae:	7902                	ld	s2,32(sp)
    800045b0:	69e2                	ld	s3,24(sp)
    800045b2:	6a42                	ld	s4,16(sp)
    800045b4:	6121                	addi	sp,sp,64
    800045b6:	8082                	ret

00000000800045b8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800045b8:	711d                	addi	sp,sp,-96
    800045ba:	ec86                	sd	ra,88(sp)
    800045bc:	e8a2                	sd	s0,80(sp)
    800045be:	e4a6                	sd	s1,72(sp)
    800045c0:	e0ca                	sd	s2,64(sp)
    800045c2:	fc4e                	sd	s3,56(sp)
    800045c4:	f852                	sd	s4,48(sp)
    800045c6:	f456                	sd	s5,40(sp)
    800045c8:	f05a                	sd	s6,32(sp)
    800045ca:	ec5e                	sd	s7,24(sp)
    800045cc:	e862                	sd	s8,16(sp)
    800045ce:	e466                	sd	s9,8(sp)
    800045d0:	1080                	addi	s0,sp,96
    800045d2:	84aa                	mv	s1,a0
    800045d4:	8aae                	mv	s5,a1
    800045d6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800045d8:	00054703          	lbu	a4,0(a0)
    800045dc:	02f00793          	li	a5,47
    800045e0:	02f70363          	beq	a4,a5,80004606 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800045e4:	ffffd097          	auipc	ra,0xffffd
    800045e8:	584080e7          	jalr	1412(ra) # 80001b68 <myproc>
    800045ec:	15053503          	ld	a0,336(a0)
    800045f0:	00000097          	auipc	ra,0x0
    800045f4:	9f6080e7          	jalr	-1546(ra) # 80003fe6 <idup>
    800045f8:	89aa                	mv	s3,a0
  while(*path == '/')
    800045fa:	02f00913          	li	s2,47
  len = path - s;
    800045fe:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004600:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004602:	4b85                	li	s7,1
    80004604:	a865                	j	800046bc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004606:	4585                	li	a1,1
    80004608:	4505                	li	a0,1
    8000460a:	fffff097          	auipc	ra,0xfffff
    8000460e:	6e6080e7          	jalr	1766(ra) # 80003cf0 <iget>
    80004612:	89aa                	mv	s3,a0
    80004614:	b7dd                	j	800045fa <namex+0x42>
      iunlockput(ip);
    80004616:	854e                	mv	a0,s3
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	c6e080e7          	jalr	-914(ra) # 80004286 <iunlockput>
      return 0;
    80004620:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004622:	854e                	mv	a0,s3
    80004624:	60e6                	ld	ra,88(sp)
    80004626:	6446                	ld	s0,80(sp)
    80004628:	64a6                	ld	s1,72(sp)
    8000462a:	6906                	ld	s2,64(sp)
    8000462c:	79e2                	ld	s3,56(sp)
    8000462e:	7a42                	ld	s4,48(sp)
    80004630:	7aa2                	ld	s5,40(sp)
    80004632:	7b02                	ld	s6,32(sp)
    80004634:	6be2                	ld	s7,24(sp)
    80004636:	6c42                	ld	s8,16(sp)
    80004638:	6ca2                	ld	s9,8(sp)
    8000463a:	6125                	addi	sp,sp,96
    8000463c:	8082                	ret
      iunlock(ip);
    8000463e:	854e                	mv	a0,s3
    80004640:	00000097          	auipc	ra,0x0
    80004644:	aa6080e7          	jalr	-1370(ra) # 800040e6 <iunlock>
      return ip;
    80004648:	bfe9                	j	80004622 <namex+0x6a>
      iunlockput(ip);
    8000464a:	854e                	mv	a0,s3
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	c3a080e7          	jalr	-966(ra) # 80004286 <iunlockput>
      return 0;
    80004654:	89e6                	mv	s3,s9
    80004656:	b7f1                	j	80004622 <namex+0x6a>
  len = path - s;
    80004658:	40b48633          	sub	a2,s1,a1
    8000465c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004660:	099c5463          	bge	s8,s9,800046e8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004664:	4639                	li	a2,14
    80004666:	8552                	mv	a0,s4
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	6b2080e7          	jalr	1714(ra) # 80000d1a <memmove>
  while(*path == '/')
    80004670:	0004c783          	lbu	a5,0(s1)
    80004674:	01279763          	bne	a5,s2,80004682 <namex+0xca>
    path++;
    80004678:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000467a:	0004c783          	lbu	a5,0(s1)
    8000467e:	ff278de3          	beq	a5,s2,80004678 <namex+0xc0>
    ilock(ip);
    80004682:	854e                	mv	a0,s3
    80004684:	00000097          	auipc	ra,0x0
    80004688:	9a0080e7          	jalr	-1632(ra) # 80004024 <ilock>
    if(ip->type != T_DIR){
    8000468c:	04499783          	lh	a5,68(s3)
    80004690:	f97793e3          	bne	a5,s7,80004616 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004694:	000a8563          	beqz	s5,8000469e <namex+0xe6>
    80004698:	0004c783          	lbu	a5,0(s1)
    8000469c:	d3cd                	beqz	a5,8000463e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000469e:	865a                	mv	a2,s6
    800046a0:	85d2                	mv	a1,s4
    800046a2:	854e                	mv	a0,s3
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	e64080e7          	jalr	-412(ra) # 80004508 <dirlookup>
    800046ac:	8caa                	mv	s9,a0
    800046ae:	dd51                	beqz	a0,8000464a <namex+0x92>
    iunlockput(ip);
    800046b0:	854e                	mv	a0,s3
    800046b2:	00000097          	auipc	ra,0x0
    800046b6:	bd4080e7          	jalr	-1068(ra) # 80004286 <iunlockput>
    ip = next;
    800046ba:	89e6                	mv	s3,s9
  while(*path == '/')
    800046bc:	0004c783          	lbu	a5,0(s1)
    800046c0:	05279763          	bne	a5,s2,8000470e <namex+0x156>
    path++;
    800046c4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046c6:	0004c783          	lbu	a5,0(s1)
    800046ca:	ff278de3          	beq	a5,s2,800046c4 <namex+0x10c>
  if(*path == 0)
    800046ce:	c79d                	beqz	a5,800046fc <namex+0x144>
    path++;
    800046d0:	85a6                	mv	a1,s1
  len = path - s;
    800046d2:	8cda                	mv	s9,s6
    800046d4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800046d6:	01278963          	beq	a5,s2,800046e8 <namex+0x130>
    800046da:	dfbd                	beqz	a5,80004658 <namex+0xa0>
    path++;
    800046dc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800046de:	0004c783          	lbu	a5,0(s1)
    800046e2:	ff279ce3          	bne	a5,s2,800046da <namex+0x122>
    800046e6:	bf8d                	j	80004658 <namex+0xa0>
    memmove(name, s, len);
    800046e8:	2601                	sext.w	a2,a2
    800046ea:	8552                	mv	a0,s4
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	62e080e7          	jalr	1582(ra) # 80000d1a <memmove>
    name[len] = 0;
    800046f4:	9cd2                	add	s9,s9,s4
    800046f6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800046fa:	bf9d                	j	80004670 <namex+0xb8>
  if(nameiparent){
    800046fc:	f20a83e3          	beqz	s5,80004622 <namex+0x6a>
    iput(ip);
    80004700:	854e                	mv	a0,s3
    80004702:	00000097          	auipc	ra,0x0
    80004706:	adc080e7          	jalr	-1316(ra) # 800041de <iput>
    return 0;
    8000470a:	4981                	li	s3,0
    8000470c:	bf19                	j	80004622 <namex+0x6a>
  if(*path == 0)
    8000470e:	d7fd                	beqz	a5,800046fc <namex+0x144>
  while(*path != '/' && *path != 0)
    80004710:	0004c783          	lbu	a5,0(s1)
    80004714:	85a6                	mv	a1,s1
    80004716:	b7d1                	j	800046da <namex+0x122>

0000000080004718 <dirlink>:
{
    80004718:	7139                	addi	sp,sp,-64
    8000471a:	fc06                	sd	ra,56(sp)
    8000471c:	f822                	sd	s0,48(sp)
    8000471e:	f426                	sd	s1,40(sp)
    80004720:	f04a                	sd	s2,32(sp)
    80004722:	ec4e                	sd	s3,24(sp)
    80004724:	e852                	sd	s4,16(sp)
    80004726:	0080                	addi	s0,sp,64
    80004728:	892a                	mv	s2,a0
    8000472a:	8a2e                	mv	s4,a1
    8000472c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000472e:	4601                	li	a2,0
    80004730:	00000097          	auipc	ra,0x0
    80004734:	dd8080e7          	jalr	-552(ra) # 80004508 <dirlookup>
    80004738:	e93d                	bnez	a0,800047ae <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000473a:	04c92483          	lw	s1,76(s2)
    8000473e:	c49d                	beqz	s1,8000476c <dirlink+0x54>
    80004740:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004742:	4741                	li	a4,16
    80004744:	86a6                	mv	a3,s1
    80004746:	fc040613          	addi	a2,s0,-64
    8000474a:	4581                	li	a1,0
    8000474c:	854a                	mv	a0,s2
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	b8a080e7          	jalr	-1142(ra) # 800042d8 <readi>
    80004756:	47c1                	li	a5,16
    80004758:	06f51163          	bne	a0,a5,800047ba <dirlink+0xa2>
    if(de.inum == 0)
    8000475c:	fc045783          	lhu	a5,-64(s0)
    80004760:	c791                	beqz	a5,8000476c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004762:	24c1                	addiw	s1,s1,16
    80004764:	04c92783          	lw	a5,76(s2)
    80004768:	fcf4ede3          	bltu	s1,a5,80004742 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000476c:	4639                	li	a2,14
    8000476e:	85d2                	mv	a1,s4
    80004770:	fc240513          	addi	a0,s0,-62
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	65e080e7          	jalr	1630(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    8000477c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004780:	4741                	li	a4,16
    80004782:	86a6                	mv	a3,s1
    80004784:	fc040613          	addi	a2,s0,-64
    80004788:	4581                	li	a1,0
    8000478a:	854a                	mv	a0,s2
    8000478c:	00000097          	auipc	ra,0x0
    80004790:	c44080e7          	jalr	-956(ra) # 800043d0 <writei>
    80004794:	872a                	mv	a4,a0
    80004796:	47c1                	li	a5,16
  return 0;
    80004798:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000479a:	02f71863          	bne	a4,a5,800047ca <dirlink+0xb2>
}
    8000479e:	70e2                	ld	ra,56(sp)
    800047a0:	7442                	ld	s0,48(sp)
    800047a2:	74a2                	ld	s1,40(sp)
    800047a4:	7902                	ld	s2,32(sp)
    800047a6:	69e2                	ld	s3,24(sp)
    800047a8:	6a42                	ld	s4,16(sp)
    800047aa:	6121                	addi	sp,sp,64
    800047ac:	8082                	ret
    iput(ip);
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	a30080e7          	jalr	-1488(ra) # 800041de <iput>
    return -1;
    800047b6:	557d                	li	a0,-1
    800047b8:	b7dd                	j	8000479e <dirlink+0x86>
      panic("dirlink read");
    800047ba:	00005517          	auipc	a0,0x5
    800047be:	0ce50513          	addi	a0,a0,206 # 80009888 <syscalls+0x1d0>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	d68080e7          	jalr	-664(ra) # 8000052a <panic>
    panic("dirlink");
    800047ca:	00005517          	auipc	a0,0x5
    800047ce:	26650513          	addi	a0,a0,614 # 80009a30 <syscalls+0x378>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	d58080e7          	jalr	-680(ra) # 8000052a <panic>

00000000800047da <namei>:

struct inode*
namei(char *path)
{
    800047da:	1101                	addi	sp,sp,-32
    800047dc:	ec06                	sd	ra,24(sp)
    800047de:	e822                	sd	s0,16(sp)
    800047e0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800047e2:	fe040613          	addi	a2,s0,-32
    800047e6:	4581                	li	a1,0
    800047e8:	00000097          	auipc	ra,0x0
    800047ec:	dd0080e7          	jalr	-560(ra) # 800045b8 <namex>
}
    800047f0:	60e2                	ld	ra,24(sp)
    800047f2:	6442                	ld	s0,16(sp)
    800047f4:	6105                	addi	sp,sp,32
    800047f6:	8082                	ret

00000000800047f8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800047f8:	1141                	addi	sp,sp,-16
    800047fa:	e406                	sd	ra,8(sp)
    800047fc:	e022                	sd	s0,0(sp)
    800047fe:	0800                	addi	s0,sp,16
    80004800:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004802:	4585                	li	a1,1
    80004804:	00000097          	auipc	ra,0x0
    80004808:	db4080e7          	jalr	-588(ra) # 800045b8 <namex>
}
    8000480c:	60a2                	ld	ra,8(sp)
    8000480e:	6402                	ld	s0,0(sp)
    80004810:	0141                	addi	sp,sp,16
    80004812:	8082                	ret

0000000080004814 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004814:	1101                	addi	sp,sp,-32
    80004816:	ec22                	sd	s0,24(sp)
    80004818:	1000                	addi	s0,sp,32
    8000481a:	872a                	mv	a4,a0
    8000481c:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    8000481e:	00005797          	auipc	a5,0x5
    80004822:	07a78793          	addi	a5,a5,122 # 80009898 <syscalls+0x1e0>
    80004826:	6394                	ld	a3,0(a5)
    80004828:	fed43023          	sd	a3,-32(s0)
    8000482c:	0087d683          	lhu	a3,8(a5)
    80004830:	fed41423          	sh	a3,-24(s0)
    80004834:	00a7c783          	lbu	a5,10(a5)
    80004838:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000483c:	87ae                	mv	a5,a1
    if(i<0){
    8000483e:	02074b63          	bltz	a4,80004874 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    80004842:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    80004844:	4629                	li	a2,10
        ++p;
    80004846:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    80004848:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    8000484c:	feed                	bnez	a3,80004846 <itoa+0x32>
    *p = '\0';
    8000484e:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    80004852:	4629                	li	a2,10
    80004854:	17fd                	addi	a5,a5,-1
    80004856:	02c766bb          	remw	a3,a4,a2
    8000485a:	ff040593          	addi	a1,s0,-16
    8000485e:	96ae                	add	a3,a3,a1
    80004860:	ff06c683          	lbu	a3,-16(a3)
    80004864:	00d78023          	sb	a3,0(a5)
        i = i/10;
    80004868:	02c7473b          	divw	a4,a4,a2
    }while(i);
    8000486c:	f765                	bnez	a4,80004854 <itoa+0x40>
    return b;
}
    8000486e:	6462                	ld	s0,24(sp)
    80004870:	6105                	addi	sp,sp,32
    80004872:	8082                	ret
        *p++ = '-';
    80004874:	00158793          	addi	a5,a1,1
    80004878:	02d00693          	li	a3,45
    8000487c:	00d58023          	sb	a3,0(a1)
        i *= -1;
    80004880:	40e0073b          	negw	a4,a4
    80004884:	bf7d                	j	80004842 <itoa+0x2e>

0000000080004886 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    80004886:	711d                	addi	sp,sp,-96
    80004888:	ec86                	sd	ra,88(sp)
    8000488a:	e8a2                	sd	s0,80(sp)
    8000488c:	e4a6                	sd	s1,72(sp)
    8000488e:	e0ca                	sd	s2,64(sp)
    80004890:	1080                	addi	s0,sp,96
    80004892:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004894:	4619                	li	a2,6
    80004896:	00005597          	auipc	a1,0x5
    8000489a:	01258593          	addi	a1,a1,18 # 800098a8 <syscalls+0x1f0>
    8000489e:	fd040513          	addi	a0,s0,-48
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	478080e7          	jalr	1144(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800048aa:	fd640593          	addi	a1,s0,-42
    800048ae:	5888                	lw	a0,48(s1)
    800048b0:	00000097          	auipc	ra,0x0
    800048b4:	f64080e7          	jalr	-156(ra) # 80004814 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    800048b8:	1684b503          	ld	a0,360(s1)
    800048bc:	16050763          	beqz	a0,80004a2a <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    800048c0:	00001097          	auipc	ra,0x1
    800048c4:	918080e7          	jalr	-1768(ra) # 800051d8 <fileclose>

  begin_op();
    800048c8:	00000097          	auipc	ra,0x0
    800048cc:	444080e7          	jalr	1092(ra) # 80004d0c <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    800048d0:	fb040593          	addi	a1,s0,-80
    800048d4:	fd040513          	addi	a0,s0,-48
    800048d8:	00000097          	auipc	ra,0x0
    800048dc:	f20080e7          	jalr	-224(ra) # 800047f8 <nameiparent>
    800048e0:	892a                	mv	s2,a0
    800048e2:	cd69                	beqz	a0,800049bc <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	740080e7          	jalr	1856(ra) # 80004024 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800048ec:	00005597          	auipc	a1,0x5
    800048f0:	fc458593          	addi	a1,a1,-60 # 800098b0 <syscalls+0x1f8>
    800048f4:	fb040513          	addi	a0,s0,-80
    800048f8:	00000097          	auipc	ra,0x0
    800048fc:	bf6080e7          	jalr	-1034(ra) # 800044ee <namecmp>
    80004900:	c57d                	beqz	a0,800049ee <removeSwapFile+0x168>
    80004902:	00005597          	auipc	a1,0x5
    80004906:	fb658593          	addi	a1,a1,-74 # 800098b8 <syscalls+0x200>
    8000490a:	fb040513          	addi	a0,s0,-80
    8000490e:	00000097          	auipc	ra,0x0
    80004912:	be0080e7          	jalr	-1056(ra) # 800044ee <namecmp>
    80004916:	cd61                	beqz	a0,800049ee <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80004918:	fac40613          	addi	a2,s0,-84
    8000491c:	fb040593          	addi	a1,s0,-80
    80004920:	854a                	mv	a0,s2
    80004922:	00000097          	auipc	ra,0x0
    80004926:	be6080e7          	jalr	-1050(ra) # 80004508 <dirlookup>
    8000492a:	84aa                	mv	s1,a0
    8000492c:	c169                	beqz	a0,800049ee <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    8000492e:	fffff097          	auipc	ra,0xfffff
    80004932:	6f6080e7          	jalr	1782(ra) # 80004024 <ilock>

  if(ip->nlink < 1)
    80004936:	04a49783          	lh	a5,74(s1)
    8000493a:	08f05763          	blez	a5,800049c8 <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000493e:	04449703          	lh	a4,68(s1)
    80004942:	4785                	li	a5,1
    80004944:	08f70a63          	beq	a4,a5,800049d8 <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80004948:	4641                	li	a2,16
    8000494a:	4581                	li	a1,0
    8000494c:	fc040513          	addi	a0,s0,-64
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	36e080e7          	jalr	878(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004958:	4741                	li	a4,16
    8000495a:	fac42683          	lw	a3,-84(s0)
    8000495e:	fc040613          	addi	a2,s0,-64
    80004962:	4581                	li	a1,0
    80004964:	854a                	mv	a0,s2
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	a6a080e7          	jalr	-1430(ra) # 800043d0 <writei>
    8000496e:	47c1                	li	a5,16
    80004970:	08f51a63          	bne	a0,a5,80004a04 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004974:	04449703          	lh	a4,68(s1)
    80004978:	4785                	li	a5,1
    8000497a:	08f70d63          	beq	a4,a5,80004a14 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    8000497e:	854a                	mv	a0,s2
    80004980:	00000097          	auipc	ra,0x0
    80004984:	906080e7          	jalr	-1786(ra) # 80004286 <iunlockput>

  ip->nlink--;
    80004988:	04a4d783          	lhu	a5,74(s1)
    8000498c:	37fd                	addiw	a5,a5,-1
    8000498e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004992:	8526                	mv	a0,s1
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	5c6080e7          	jalr	1478(ra) # 80003f5a <iupdate>
  iunlockput(ip);
    8000499c:	8526                	mv	a0,s1
    8000499e:	00000097          	auipc	ra,0x0
    800049a2:	8e8080e7          	jalr	-1816(ra) # 80004286 <iunlockput>

  end_op();
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	3e6080e7          	jalr	998(ra) # 80004d8c <end_op>

  return 0;
    800049ae:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    800049b0:	60e6                	ld	ra,88(sp)
    800049b2:	6446                	ld	s0,80(sp)
    800049b4:	64a6                	ld	s1,72(sp)
    800049b6:	6906                	ld	s2,64(sp)
    800049b8:	6125                	addi	sp,sp,96
    800049ba:	8082                	ret
    end_op();
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	3d0080e7          	jalr	976(ra) # 80004d8c <end_op>
    return -1;
    800049c4:	557d                	li	a0,-1
    800049c6:	b7ed                	j	800049b0 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    800049c8:	00005517          	auipc	a0,0x5
    800049cc:	ef850513          	addi	a0,a0,-264 # 800098c0 <syscalls+0x208>
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	b5a080e7          	jalr	-1190(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800049d8:	8526                	mv	a0,s1
    800049da:	00002097          	auipc	ra,0x2
    800049de:	98c080e7          	jalr	-1652(ra) # 80006366 <isdirempty>
    800049e2:	f13d                	bnez	a0,80004948 <removeSwapFile+0xc2>
    iunlockput(ip);
    800049e4:	8526                	mv	a0,s1
    800049e6:	00000097          	auipc	ra,0x0
    800049ea:	8a0080e7          	jalr	-1888(ra) # 80004286 <iunlockput>
    iunlockput(dp);
    800049ee:	854a                	mv	a0,s2
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	896080e7          	jalr	-1898(ra) # 80004286 <iunlockput>
    end_op();
    800049f8:	00000097          	auipc	ra,0x0
    800049fc:	394080e7          	jalr	916(ra) # 80004d8c <end_op>
    return -1;
    80004a00:	557d                	li	a0,-1
    80004a02:	b77d                	j	800049b0 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004a04:	00005517          	auipc	a0,0x5
    80004a08:	ed450513          	addi	a0,a0,-300 # 800098d8 <syscalls+0x220>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	b1e080e7          	jalr	-1250(ra) # 8000052a <panic>
    dp->nlink--;
    80004a14:	04a95783          	lhu	a5,74(s2)
    80004a18:	37fd                	addiw	a5,a5,-1
    80004a1a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004a1e:	854a                	mv	a0,s2
    80004a20:	fffff097          	auipc	ra,0xfffff
    80004a24:	53a080e7          	jalr	1338(ra) # 80003f5a <iupdate>
    80004a28:	bf99                	j	8000497e <removeSwapFile+0xf8>
    return -1;
    80004a2a:	557d                	li	a0,-1
    80004a2c:	b751                	j	800049b0 <removeSwapFile+0x12a>

0000000080004a2e <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004a2e:	7179                	addi	sp,sp,-48
    80004a30:	f406                	sd	ra,40(sp)
    80004a32:	f022                	sd	s0,32(sp)
    80004a34:	ec26                	sd	s1,24(sp)
    80004a36:	e84a                	sd	s2,16(sp)
    80004a38:	1800                	addi	s0,sp,48
    80004a3a:	84aa                	mv	s1,a0

  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004a3c:	4619                	li	a2,6
    80004a3e:	00005597          	auipc	a1,0x5
    80004a42:	e6a58593          	addi	a1,a1,-406 # 800098a8 <syscalls+0x1f0>
    80004a46:	fd040513          	addi	a0,s0,-48
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	2d0080e7          	jalr	720(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004a52:	fd640593          	addi	a1,s0,-42
    80004a56:	5888                	lw	a0,48(s1)
    80004a58:	00000097          	auipc	ra,0x0
    80004a5c:	dbc080e7          	jalr	-580(ra) # 80004814 <itoa>

  begin_op();
    80004a60:	00000097          	auipc	ra,0x0
    80004a64:	2ac080e7          	jalr	684(ra) # 80004d0c <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004a68:	4681                	li	a3,0
    80004a6a:	4601                	li	a2,0
    80004a6c:	4589                	li	a1,2
    80004a6e:	fd040513          	addi	a0,s0,-48
    80004a72:	00002097          	auipc	ra,0x2
    80004a76:	ae8080e7          	jalr	-1304(ra) # 8000655a <create>
    80004a7a:	892a                	mv	s2,a0
  iunlock(in);
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	66a080e7          	jalr	1642(ra) # 800040e6 <iunlock>
  p->swapFile = filealloc();
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	698080e7          	jalr	1688(ra) # 8000511c <filealloc>
    80004a8c:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    80004a90:	cd1d                	beqz	a0,80004ace <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004a92:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004a96:	1684b703          	ld	a4,360(s1)
    80004a9a:	4789                	li	a5,2
    80004a9c:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004a9e:	1684b703          	ld	a4,360(s1)
    80004aa2:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004aa6:	1684b703          	ld	a4,360(s1)
    80004aaa:	4685                	li	a3,1
    80004aac:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004ab0:	1684b703          	ld	a4,360(s1)
    80004ab4:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	2d4080e7          	jalr	724(ra) # 80004d8c <end_op>

    return 0;
}
    80004ac0:	4501                	li	a0,0
    80004ac2:	70a2                	ld	ra,40(sp)
    80004ac4:	7402                	ld	s0,32(sp)
    80004ac6:	64e2                	ld	s1,24(sp)
    80004ac8:	6942                	ld	s2,16(sp)
    80004aca:	6145                	addi	sp,sp,48
    80004acc:	8082                	ret
    panic("no slot for files on /store");
    80004ace:	00005517          	auipc	a0,0x5
    80004ad2:	e1a50513          	addi	a0,a0,-486 # 800098e8 <syscalls+0x230>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	a54080e7          	jalr	-1452(ra) # 8000052a <panic>

0000000080004ade <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004ade:	1141                	addi	sp,sp,-16
    80004ae0:	e406                	sd	ra,8(sp)
    80004ae2:	e022                	sd	s0,0(sp)
    80004ae4:	0800                	addi	s0,sp,16
  // printf("ofri placeOnFile %d\n", placeOnFile);
  p->swapFile->off = placeOnFile;
    80004ae6:	16853783          	ld	a5,360(a0)
    80004aea:	d390                	sw	a2,32(a5)
  // printf("ofri test\n");
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004aec:	8636                	mv	a2,a3
    80004aee:	16853503          	ld	a0,360(a0)
    80004af2:	00001097          	auipc	ra,0x1
    80004af6:	ad8080e7          	jalr	-1320(ra) # 800055ca <kfilewrite>
}
    80004afa:	60a2                	ld	ra,8(sp)
    80004afc:	6402                	ld	s0,0(sp)
    80004afe:	0141                	addi	sp,sp,16
    80004b00:	8082                	ret

0000000080004b02 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004b02:	1141                	addi	sp,sp,-16
    80004b04:	e406                	sd	ra,8(sp)
    80004b06:	e022                	sd	s0,0(sp)
    80004b08:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004b0a:	16853783          	ld	a5,360(a0)
    80004b0e:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004b10:	8636                	mv	a2,a3
    80004b12:	16853503          	ld	a0,360(a0)
    80004b16:	00001097          	auipc	ra,0x1
    80004b1a:	9f2080e7          	jalr	-1550(ra) # 80005508 <kfileread>
    80004b1e:	60a2                	ld	ra,8(sp)
    80004b20:	6402                	ld	s0,0(sp)
    80004b22:	0141                	addi	sp,sp,16
    80004b24:	8082                	ret

0000000080004b26 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004b26:	1101                	addi	sp,sp,-32
    80004b28:	ec06                	sd	ra,24(sp)
    80004b2a:	e822                	sd	s0,16(sp)
    80004b2c:	e426                	sd	s1,8(sp)
    80004b2e:	e04a                	sd	s2,0(sp)
    80004b30:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004b32:	00037917          	auipc	s2,0x37
    80004b36:	b3e90913          	addi	s2,s2,-1218 # 8003b670 <log>
    80004b3a:	01892583          	lw	a1,24(s2)
    80004b3e:	02892503          	lw	a0,40(s2)
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	cde080e7          	jalr	-802(ra) # 80003820 <bread>
    80004b4a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004b4c:	02c92683          	lw	a3,44(s2)
    80004b50:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004b52:	02d05863          	blez	a3,80004b82 <write_head+0x5c>
    80004b56:	00037797          	auipc	a5,0x37
    80004b5a:	b4a78793          	addi	a5,a5,-1206 # 8003b6a0 <log+0x30>
    80004b5e:	05c50713          	addi	a4,a0,92
    80004b62:	36fd                	addiw	a3,a3,-1
    80004b64:	02069613          	slli	a2,a3,0x20
    80004b68:	01e65693          	srli	a3,a2,0x1e
    80004b6c:	00037617          	auipc	a2,0x37
    80004b70:	b3860613          	addi	a2,a2,-1224 # 8003b6a4 <log+0x34>
    80004b74:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004b76:	4390                	lw	a2,0(a5)
    80004b78:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b7a:	0791                	addi	a5,a5,4
    80004b7c:	0711                	addi	a4,a4,4
    80004b7e:	fed79ce3          	bne	a5,a3,80004b76 <write_head+0x50>
  }
  bwrite(buf);
    80004b82:	8526                	mv	a0,s1
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	d8e080e7          	jalr	-626(ra) # 80003912 <bwrite>
  brelse(buf);
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	fffff097          	auipc	ra,0xfffff
    80004b92:	dc2080e7          	jalr	-574(ra) # 80003950 <brelse>
}
    80004b96:	60e2                	ld	ra,24(sp)
    80004b98:	6442                	ld	s0,16(sp)
    80004b9a:	64a2                	ld	s1,8(sp)
    80004b9c:	6902                	ld	s2,0(sp)
    80004b9e:	6105                	addi	sp,sp,32
    80004ba0:	8082                	ret

0000000080004ba2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ba2:	00037797          	auipc	a5,0x37
    80004ba6:	afa7a783          	lw	a5,-1286(a5) # 8003b69c <log+0x2c>
    80004baa:	0af05d63          	blez	a5,80004c64 <install_trans+0xc2>
{
    80004bae:	7139                	addi	sp,sp,-64
    80004bb0:	fc06                	sd	ra,56(sp)
    80004bb2:	f822                	sd	s0,48(sp)
    80004bb4:	f426                	sd	s1,40(sp)
    80004bb6:	f04a                	sd	s2,32(sp)
    80004bb8:	ec4e                	sd	s3,24(sp)
    80004bba:	e852                	sd	s4,16(sp)
    80004bbc:	e456                	sd	s5,8(sp)
    80004bbe:	e05a                	sd	s6,0(sp)
    80004bc0:	0080                	addi	s0,sp,64
    80004bc2:	8b2a                	mv	s6,a0
    80004bc4:	00037a97          	auipc	s5,0x37
    80004bc8:	adca8a93          	addi	s5,s5,-1316 # 8003b6a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bcc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004bce:	00037997          	auipc	s3,0x37
    80004bd2:	aa298993          	addi	s3,s3,-1374 # 8003b670 <log>
    80004bd6:	a00d                	j	80004bf8 <install_trans+0x56>
    brelse(lbuf);
    80004bd8:	854a                	mv	a0,s2
    80004bda:	fffff097          	auipc	ra,0xfffff
    80004bde:	d76080e7          	jalr	-650(ra) # 80003950 <brelse>
    brelse(dbuf);
    80004be2:	8526                	mv	a0,s1
    80004be4:	fffff097          	auipc	ra,0xfffff
    80004be8:	d6c080e7          	jalr	-660(ra) # 80003950 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bec:	2a05                	addiw	s4,s4,1
    80004bee:	0a91                	addi	s5,s5,4
    80004bf0:	02c9a783          	lw	a5,44(s3)
    80004bf4:	04fa5e63          	bge	s4,a5,80004c50 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004bf8:	0189a583          	lw	a1,24(s3)
    80004bfc:	014585bb          	addw	a1,a1,s4
    80004c00:	2585                	addiw	a1,a1,1
    80004c02:	0289a503          	lw	a0,40(s3)
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	c1a080e7          	jalr	-998(ra) # 80003820 <bread>
    80004c0e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004c10:	000aa583          	lw	a1,0(s5)
    80004c14:	0289a503          	lw	a0,40(s3)
    80004c18:	fffff097          	auipc	ra,0xfffff
    80004c1c:	c08080e7          	jalr	-1016(ra) # 80003820 <bread>
    80004c20:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004c22:	40000613          	li	a2,1024
    80004c26:	05890593          	addi	a1,s2,88
    80004c2a:	05850513          	addi	a0,a0,88
    80004c2e:	ffffc097          	auipc	ra,0xffffc
    80004c32:	0ec080e7          	jalr	236(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004c36:	8526                	mv	a0,s1
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	cda080e7          	jalr	-806(ra) # 80003912 <bwrite>
    if(recovering == 0)
    80004c40:	f80b1ce3          	bnez	s6,80004bd8 <install_trans+0x36>
      bunpin(dbuf);
    80004c44:	8526                	mv	a0,s1
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	de4080e7          	jalr	-540(ra) # 80003a2a <bunpin>
    80004c4e:	b769                	j	80004bd8 <install_trans+0x36>
}
    80004c50:	70e2                	ld	ra,56(sp)
    80004c52:	7442                	ld	s0,48(sp)
    80004c54:	74a2                	ld	s1,40(sp)
    80004c56:	7902                	ld	s2,32(sp)
    80004c58:	69e2                	ld	s3,24(sp)
    80004c5a:	6a42                	ld	s4,16(sp)
    80004c5c:	6aa2                	ld	s5,8(sp)
    80004c5e:	6b02                	ld	s6,0(sp)
    80004c60:	6121                	addi	sp,sp,64
    80004c62:	8082                	ret
    80004c64:	8082                	ret

0000000080004c66 <initlog>:
{
    80004c66:	7179                	addi	sp,sp,-48
    80004c68:	f406                	sd	ra,40(sp)
    80004c6a:	f022                	sd	s0,32(sp)
    80004c6c:	ec26                	sd	s1,24(sp)
    80004c6e:	e84a                	sd	s2,16(sp)
    80004c70:	e44e                	sd	s3,8(sp)
    80004c72:	1800                	addi	s0,sp,48
    80004c74:	892a                	mv	s2,a0
    80004c76:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c78:	00037497          	auipc	s1,0x37
    80004c7c:	9f848493          	addi	s1,s1,-1544 # 8003b670 <log>
    80004c80:	00005597          	auipc	a1,0x5
    80004c84:	c8858593          	addi	a1,a1,-888 # 80009908 <syscalls+0x250>
    80004c88:	8526                	mv	a0,s1
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	ea8080e7          	jalr	-344(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004c92:	0149a583          	lw	a1,20(s3)
    80004c96:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004c98:	0109a783          	lw	a5,16(s3)
    80004c9c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004c9e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	b7c080e7          	jalr	-1156(ra) # 80003820 <bread>
  log.lh.n = lh->n;
    80004cac:	4d34                	lw	a3,88(a0)
    80004cae:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004cb0:	02d05663          	blez	a3,80004cdc <initlog+0x76>
    80004cb4:	05c50793          	addi	a5,a0,92
    80004cb8:	00037717          	auipc	a4,0x37
    80004cbc:	9e870713          	addi	a4,a4,-1560 # 8003b6a0 <log+0x30>
    80004cc0:	36fd                	addiw	a3,a3,-1
    80004cc2:	02069613          	slli	a2,a3,0x20
    80004cc6:	01e65693          	srli	a3,a2,0x1e
    80004cca:	06050613          	addi	a2,a0,96
    80004cce:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004cd0:	4390                	lw	a2,0(a5)
    80004cd2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004cd4:	0791                	addi	a5,a5,4
    80004cd6:	0711                	addi	a4,a4,4
    80004cd8:	fed79ce3          	bne	a5,a3,80004cd0 <initlog+0x6a>
  brelse(buf);
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	c74080e7          	jalr	-908(ra) # 80003950 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004ce4:	4505                	li	a0,1
    80004ce6:	00000097          	auipc	ra,0x0
    80004cea:	ebc080e7          	jalr	-324(ra) # 80004ba2 <install_trans>
  log.lh.n = 0;
    80004cee:	00037797          	auipc	a5,0x37
    80004cf2:	9a07a723          	sw	zero,-1618(a5) # 8003b69c <log+0x2c>
  write_head(); // clear the log
    80004cf6:	00000097          	auipc	ra,0x0
    80004cfa:	e30080e7          	jalr	-464(ra) # 80004b26 <write_head>
}
    80004cfe:	70a2                	ld	ra,40(sp)
    80004d00:	7402                	ld	s0,32(sp)
    80004d02:	64e2                	ld	s1,24(sp)
    80004d04:	6942                	ld	s2,16(sp)
    80004d06:	69a2                	ld	s3,8(sp)
    80004d08:	6145                	addi	sp,sp,48
    80004d0a:	8082                	ret

0000000080004d0c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004d0c:	1101                	addi	sp,sp,-32
    80004d0e:	ec06                	sd	ra,24(sp)
    80004d10:	e822                	sd	s0,16(sp)
    80004d12:	e426                	sd	s1,8(sp)
    80004d14:	e04a                	sd	s2,0(sp)
    80004d16:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004d18:	00037517          	auipc	a0,0x37
    80004d1c:	95850513          	addi	a0,a0,-1704 # 8003b670 <log>
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	ea2080e7          	jalr	-350(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004d28:	00037497          	auipc	s1,0x37
    80004d2c:	94848493          	addi	s1,s1,-1720 # 8003b670 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d30:	4979                	li	s2,30
    80004d32:	a039                	j	80004d40 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004d34:	85a6                	mv	a1,s1
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	208080e7          	jalr	520(ra) # 80001f40 <sleep>
    if(log.committing){
    80004d40:	50dc                	lw	a5,36(s1)
    80004d42:	fbed                	bnez	a5,80004d34 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d44:	509c                	lw	a5,32(s1)
    80004d46:	0017871b          	addiw	a4,a5,1
    80004d4a:	0007069b          	sext.w	a3,a4
    80004d4e:	0027179b          	slliw	a5,a4,0x2
    80004d52:	9fb9                	addw	a5,a5,a4
    80004d54:	0017979b          	slliw	a5,a5,0x1
    80004d58:	54d8                	lw	a4,44(s1)
    80004d5a:	9fb9                	addw	a5,a5,a4
    80004d5c:	00f95963          	bge	s2,a5,80004d6e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004d60:	85a6                	mv	a1,s1
    80004d62:	8526                	mv	a0,s1
    80004d64:	ffffd097          	auipc	ra,0xffffd
    80004d68:	1dc080e7          	jalr	476(ra) # 80001f40 <sleep>
    80004d6c:	bfd1                	j	80004d40 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004d6e:	00037517          	auipc	a0,0x37
    80004d72:	90250513          	addi	a0,a0,-1790 # 8003b670 <log>
    80004d76:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	efe080e7          	jalr	-258(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004d80:	60e2                	ld	ra,24(sp)
    80004d82:	6442                	ld	s0,16(sp)
    80004d84:	64a2                	ld	s1,8(sp)
    80004d86:	6902                	ld	s2,0(sp)
    80004d88:	6105                	addi	sp,sp,32
    80004d8a:	8082                	ret

0000000080004d8c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d8c:	7139                	addi	sp,sp,-64
    80004d8e:	fc06                	sd	ra,56(sp)
    80004d90:	f822                	sd	s0,48(sp)
    80004d92:	f426                	sd	s1,40(sp)
    80004d94:	f04a                	sd	s2,32(sp)
    80004d96:	ec4e                	sd	s3,24(sp)
    80004d98:	e852                	sd	s4,16(sp)
    80004d9a:	e456                	sd	s5,8(sp)
    80004d9c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d9e:	00037497          	auipc	s1,0x37
    80004da2:	8d248493          	addi	s1,s1,-1838 # 8003b670 <log>
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	e1a080e7          	jalr	-486(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004db0:	509c                	lw	a5,32(s1)
    80004db2:	37fd                	addiw	a5,a5,-1
    80004db4:	0007891b          	sext.w	s2,a5
    80004db8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004dba:	50dc                	lw	a5,36(s1)
    80004dbc:	e7b9                	bnez	a5,80004e0a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004dbe:	04091e63          	bnez	s2,80004e1a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004dc2:	00037497          	auipc	s1,0x37
    80004dc6:	8ae48493          	addi	s1,s1,-1874 # 8003b670 <log>
    80004dca:	4785                	li	a5,1
    80004dcc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004dce:	8526                	mv	a0,s1
    80004dd0:	ffffc097          	auipc	ra,0xffffc
    80004dd4:	ea6080e7          	jalr	-346(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004dd8:	54dc                	lw	a5,44(s1)
    80004dda:	06f04763          	bgtz	a5,80004e48 <end_op+0xbc>
    acquire(&log.lock);
    80004dde:	00037497          	auipc	s1,0x37
    80004de2:	89248493          	addi	s1,s1,-1902 # 8003b670 <log>
    80004de6:	8526                	mv	a0,s1
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	dda080e7          	jalr	-550(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004df0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ffffd097          	auipc	ra,0xffffd
    80004dfa:	1ae080e7          	jalr	430(ra) # 80001fa4 <wakeup>
    release(&log.lock);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	e76080e7          	jalr	-394(ra) # 80000c76 <release>
}
    80004e08:	a03d                	j	80004e36 <end_op+0xaa>
    panic("log.committing");
    80004e0a:	00005517          	auipc	a0,0x5
    80004e0e:	b0650513          	addi	a0,a0,-1274 # 80009910 <syscalls+0x258>
    80004e12:	ffffb097          	auipc	ra,0xffffb
    80004e16:	718080e7          	jalr	1816(ra) # 8000052a <panic>
    wakeup(&log);
    80004e1a:	00037497          	auipc	s1,0x37
    80004e1e:	85648493          	addi	s1,s1,-1962 # 8003b670 <log>
    80004e22:	8526                	mv	a0,s1
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	180080e7          	jalr	384(ra) # 80001fa4 <wakeup>
  release(&log.lock);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	e48080e7          	jalr	-440(ra) # 80000c76 <release>
}
    80004e36:	70e2                	ld	ra,56(sp)
    80004e38:	7442                	ld	s0,48(sp)
    80004e3a:	74a2                	ld	s1,40(sp)
    80004e3c:	7902                	ld	s2,32(sp)
    80004e3e:	69e2                	ld	s3,24(sp)
    80004e40:	6a42                	ld	s4,16(sp)
    80004e42:	6aa2                	ld	s5,8(sp)
    80004e44:	6121                	addi	sp,sp,64
    80004e46:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e48:	00037a97          	auipc	s5,0x37
    80004e4c:	858a8a93          	addi	s5,s5,-1960 # 8003b6a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004e50:	00037a17          	auipc	s4,0x37
    80004e54:	820a0a13          	addi	s4,s4,-2016 # 8003b670 <log>
    80004e58:	018a2583          	lw	a1,24(s4)
    80004e5c:	012585bb          	addw	a1,a1,s2
    80004e60:	2585                	addiw	a1,a1,1
    80004e62:	028a2503          	lw	a0,40(s4)
    80004e66:	fffff097          	auipc	ra,0xfffff
    80004e6a:	9ba080e7          	jalr	-1606(ra) # 80003820 <bread>
    80004e6e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004e70:	000aa583          	lw	a1,0(s5)
    80004e74:	028a2503          	lw	a0,40(s4)
    80004e78:	fffff097          	auipc	ra,0xfffff
    80004e7c:	9a8080e7          	jalr	-1624(ra) # 80003820 <bread>
    80004e80:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004e82:	40000613          	li	a2,1024
    80004e86:	05850593          	addi	a1,a0,88
    80004e8a:	05848513          	addi	a0,s1,88
    80004e8e:	ffffc097          	auipc	ra,0xffffc
    80004e92:	e8c080e7          	jalr	-372(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004e96:	8526                	mv	a0,s1
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	a7a080e7          	jalr	-1414(ra) # 80003912 <bwrite>
    brelse(from);
    80004ea0:	854e                	mv	a0,s3
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	aae080e7          	jalr	-1362(ra) # 80003950 <brelse>
    brelse(to);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	fffff097          	auipc	ra,0xfffff
    80004eb0:	aa4080e7          	jalr	-1372(ra) # 80003950 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004eb4:	2905                	addiw	s2,s2,1
    80004eb6:	0a91                	addi	s5,s5,4
    80004eb8:	02ca2783          	lw	a5,44(s4)
    80004ebc:	f8f94ee3          	blt	s2,a5,80004e58 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004ec0:	00000097          	auipc	ra,0x0
    80004ec4:	c66080e7          	jalr	-922(ra) # 80004b26 <write_head>
    install_trans(0); // Now install writes to home locations
    80004ec8:	4501                	li	a0,0
    80004eca:	00000097          	auipc	ra,0x0
    80004ece:	cd8080e7          	jalr	-808(ra) # 80004ba2 <install_trans>
    log.lh.n = 0;
    80004ed2:	00036797          	auipc	a5,0x36
    80004ed6:	7c07a523          	sw	zero,1994(a5) # 8003b69c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004eda:	00000097          	auipc	ra,0x0
    80004ede:	c4c080e7          	jalr	-948(ra) # 80004b26 <write_head>
    80004ee2:	bdf5                	j	80004dde <end_op+0x52>

0000000080004ee4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ee4:	1101                	addi	sp,sp,-32
    80004ee6:	ec06                	sd	ra,24(sp)
    80004ee8:	e822                	sd	s0,16(sp)
    80004eea:	e426                	sd	s1,8(sp)
    80004eec:	e04a                	sd	s2,0(sp)
    80004eee:	1000                	addi	s0,sp,32
    80004ef0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004ef2:	00036917          	auipc	s2,0x36
    80004ef6:	77e90913          	addi	s2,s2,1918 # 8003b670 <log>
    80004efa:	854a                	mv	a0,s2
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	cc6080e7          	jalr	-826(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004f04:	02c92603          	lw	a2,44(s2)
    80004f08:	47f5                	li	a5,29
    80004f0a:	06c7c563          	blt	a5,a2,80004f74 <log_write+0x90>
    80004f0e:	00036797          	auipc	a5,0x36
    80004f12:	77e7a783          	lw	a5,1918(a5) # 8003b68c <log+0x1c>
    80004f16:	37fd                	addiw	a5,a5,-1
    80004f18:	04f65e63          	bge	a2,a5,80004f74 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004f1c:	00036797          	auipc	a5,0x36
    80004f20:	7747a783          	lw	a5,1908(a5) # 8003b690 <log+0x20>
    80004f24:	06f05063          	blez	a5,80004f84 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004f28:	4781                	li	a5,0
    80004f2a:	06c05563          	blez	a2,80004f94 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f2e:	44cc                	lw	a1,12(s1)
    80004f30:	00036717          	auipc	a4,0x36
    80004f34:	77070713          	addi	a4,a4,1904 # 8003b6a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004f38:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004f3a:	4314                	lw	a3,0(a4)
    80004f3c:	04b68c63          	beq	a3,a1,80004f94 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004f40:	2785                	addiw	a5,a5,1
    80004f42:	0711                	addi	a4,a4,4
    80004f44:	fef61be3          	bne	a2,a5,80004f3a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004f48:	0621                	addi	a2,a2,8
    80004f4a:	060a                	slli	a2,a2,0x2
    80004f4c:	00036797          	auipc	a5,0x36
    80004f50:	72478793          	addi	a5,a5,1828 # 8003b670 <log>
    80004f54:	963e                	add	a2,a2,a5
    80004f56:	44dc                	lw	a5,12(s1)
    80004f58:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	a92080e7          	jalr	-1390(ra) # 800039ee <bpin>
    log.lh.n++;
    80004f64:	00036717          	auipc	a4,0x36
    80004f68:	70c70713          	addi	a4,a4,1804 # 8003b670 <log>
    80004f6c:	575c                	lw	a5,44(a4)
    80004f6e:	2785                	addiw	a5,a5,1
    80004f70:	d75c                	sw	a5,44(a4)
    80004f72:	a835                	j	80004fae <log_write+0xca>
    panic("too big a transaction");
    80004f74:	00005517          	auipc	a0,0x5
    80004f78:	9ac50513          	addi	a0,a0,-1620 # 80009920 <syscalls+0x268>
    80004f7c:	ffffb097          	auipc	ra,0xffffb
    80004f80:	5ae080e7          	jalr	1454(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    80004f84:	00005517          	auipc	a0,0x5
    80004f88:	9b450513          	addi	a0,a0,-1612 # 80009938 <syscalls+0x280>
    80004f8c:	ffffb097          	auipc	ra,0xffffb
    80004f90:	59e080e7          	jalr	1438(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004f94:	00878713          	addi	a4,a5,8
    80004f98:	00271693          	slli	a3,a4,0x2
    80004f9c:	00036717          	auipc	a4,0x36
    80004fa0:	6d470713          	addi	a4,a4,1748 # 8003b670 <log>
    80004fa4:	9736                	add	a4,a4,a3
    80004fa6:	44d4                	lw	a3,12(s1)
    80004fa8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004faa:	faf608e3          	beq	a2,a5,80004f5a <log_write+0x76>
  }
  release(&log.lock);
    80004fae:	00036517          	auipc	a0,0x36
    80004fb2:	6c250513          	addi	a0,a0,1730 # 8003b670 <log>
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	cc0080e7          	jalr	-832(ra) # 80000c76 <release>
}
    80004fbe:	60e2                	ld	ra,24(sp)
    80004fc0:	6442                	ld	s0,16(sp)
    80004fc2:	64a2                	ld	s1,8(sp)
    80004fc4:	6902                	ld	s2,0(sp)
    80004fc6:	6105                	addi	sp,sp,32
    80004fc8:	8082                	ret

0000000080004fca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004fca:	1101                	addi	sp,sp,-32
    80004fcc:	ec06                	sd	ra,24(sp)
    80004fce:	e822                	sd	s0,16(sp)
    80004fd0:	e426                	sd	s1,8(sp)
    80004fd2:	e04a                	sd	s2,0(sp)
    80004fd4:	1000                	addi	s0,sp,32
    80004fd6:	84aa                	mv	s1,a0
    80004fd8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004fda:	00005597          	auipc	a1,0x5
    80004fde:	97e58593          	addi	a1,a1,-1666 # 80009958 <syscalls+0x2a0>
    80004fe2:	0521                	addi	a0,a0,8
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	b4e080e7          	jalr	-1202(ra) # 80000b32 <initlock>
  lk->name = name;
    80004fec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004ff0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ff4:	0204a423          	sw	zero,40(s1)
}
    80004ff8:	60e2                	ld	ra,24(sp)
    80004ffa:	6442                	ld	s0,16(sp)
    80004ffc:	64a2                	ld	s1,8(sp)
    80004ffe:	6902                	ld	s2,0(sp)
    80005000:	6105                	addi	sp,sp,32
    80005002:	8082                	ret

0000000080005004 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005004:	1101                	addi	sp,sp,-32
    80005006:	ec06                	sd	ra,24(sp)
    80005008:	e822                	sd	s0,16(sp)
    8000500a:	e426                	sd	s1,8(sp)
    8000500c:	e04a                	sd	s2,0(sp)
    8000500e:	1000                	addi	s0,sp,32
    80005010:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005012:	00850913          	addi	s2,a0,8
    80005016:	854a                	mv	a0,s2
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	baa080e7          	jalr	-1110(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80005020:	409c                	lw	a5,0(s1)
    80005022:	cb89                	beqz	a5,80005034 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005024:	85ca                	mv	a1,s2
    80005026:	8526                	mv	a0,s1
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	f18080e7          	jalr	-232(ra) # 80001f40 <sleep>
  while (lk->locked) {
    80005030:	409c                	lw	a5,0(s1)
    80005032:	fbed                	bnez	a5,80005024 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005034:	4785                	li	a5,1
    80005036:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005038:	ffffd097          	auipc	ra,0xffffd
    8000503c:	b30080e7          	jalr	-1232(ra) # 80001b68 <myproc>
    80005040:	591c                	lw	a5,48(a0)
    80005042:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005044:	854a                	mv	a0,s2
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	c30080e7          	jalr	-976(ra) # 80000c76 <release>
}
    8000504e:	60e2                	ld	ra,24(sp)
    80005050:	6442                	ld	s0,16(sp)
    80005052:	64a2                	ld	s1,8(sp)
    80005054:	6902                	ld	s2,0(sp)
    80005056:	6105                	addi	sp,sp,32
    80005058:	8082                	ret

000000008000505a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000505a:	1101                	addi	sp,sp,-32
    8000505c:	ec06                	sd	ra,24(sp)
    8000505e:	e822                	sd	s0,16(sp)
    80005060:	e426                	sd	s1,8(sp)
    80005062:	e04a                	sd	s2,0(sp)
    80005064:	1000                	addi	s0,sp,32
    80005066:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005068:	00850913          	addi	s2,a0,8
    8000506c:	854a                	mv	a0,s2
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	b54080e7          	jalr	-1196(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    80005076:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000507a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000507e:	8526                	mv	a0,s1
    80005080:	ffffd097          	auipc	ra,0xffffd
    80005084:	f24080e7          	jalr	-220(ra) # 80001fa4 <wakeup>
  release(&lk->lk);
    80005088:	854a                	mv	a0,s2
    8000508a:	ffffc097          	auipc	ra,0xffffc
    8000508e:	bec080e7          	jalr	-1044(ra) # 80000c76 <release>
}
    80005092:	60e2                	ld	ra,24(sp)
    80005094:	6442                	ld	s0,16(sp)
    80005096:	64a2                	ld	s1,8(sp)
    80005098:	6902                	ld	s2,0(sp)
    8000509a:	6105                	addi	sp,sp,32
    8000509c:	8082                	ret

000000008000509e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000509e:	7179                	addi	sp,sp,-48
    800050a0:	f406                	sd	ra,40(sp)
    800050a2:	f022                	sd	s0,32(sp)
    800050a4:	ec26                	sd	s1,24(sp)
    800050a6:	e84a                	sd	s2,16(sp)
    800050a8:	e44e                	sd	s3,8(sp)
    800050aa:	1800                	addi	s0,sp,48
    800050ac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800050ae:	00850913          	addi	s2,a0,8
    800050b2:	854a                	mv	a0,s2
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	b0e080e7          	jalr	-1266(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800050bc:	409c                	lw	a5,0(s1)
    800050be:	ef99                	bnez	a5,800050dc <holdingsleep+0x3e>
    800050c0:	4481                	li	s1,0
  release(&lk->lk);
    800050c2:	854a                	mv	a0,s2
    800050c4:	ffffc097          	auipc	ra,0xffffc
    800050c8:	bb2080e7          	jalr	-1102(ra) # 80000c76 <release>
  return r;
}
    800050cc:	8526                	mv	a0,s1
    800050ce:	70a2                	ld	ra,40(sp)
    800050d0:	7402                	ld	s0,32(sp)
    800050d2:	64e2                	ld	s1,24(sp)
    800050d4:	6942                	ld	s2,16(sp)
    800050d6:	69a2                	ld	s3,8(sp)
    800050d8:	6145                	addi	sp,sp,48
    800050da:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800050dc:	0284a983          	lw	s3,40(s1)
    800050e0:	ffffd097          	auipc	ra,0xffffd
    800050e4:	a88080e7          	jalr	-1400(ra) # 80001b68 <myproc>
    800050e8:	5904                	lw	s1,48(a0)
    800050ea:	413484b3          	sub	s1,s1,s3
    800050ee:	0014b493          	seqz	s1,s1
    800050f2:	bfc1                	j	800050c2 <holdingsleep+0x24>

00000000800050f4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800050f4:	1141                	addi	sp,sp,-16
    800050f6:	e406                	sd	ra,8(sp)
    800050f8:	e022                	sd	s0,0(sp)
    800050fa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800050fc:	00005597          	auipc	a1,0x5
    80005100:	86c58593          	addi	a1,a1,-1940 # 80009968 <syscalls+0x2b0>
    80005104:	00036517          	auipc	a0,0x36
    80005108:	6b450513          	addi	a0,a0,1716 # 8003b7b8 <ftable>
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	a26080e7          	jalr	-1498(ra) # 80000b32 <initlock>
}
    80005114:	60a2                	ld	ra,8(sp)
    80005116:	6402                	ld	s0,0(sp)
    80005118:	0141                	addi	sp,sp,16
    8000511a:	8082                	ret

000000008000511c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000511c:	1101                	addi	sp,sp,-32
    8000511e:	ec06                	sd	ra,24(sp)
    80005120:	e822                	sd	s0,16(sp)
    80005122:	e426                	sd	s1,8(sp)
    80005124:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005126:	00036517          	auipc	a0,0x36
    8000512a:	69250513          	addi	a0,a0,1682 # 8003b7b8 <ftable>
    8000512e:	ffffc097          	auipc	ra,0xffffc
    80005132:	a94080e7          	jalr	-1388(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005136:	00036497          	auipc	s1,0x36
    8000513a:	69a48493          	addi	s1,s1,1690 # 8003b7d0 <ftable+0x18>
    8000513e:	00037717          	auipc	a4,0x37
    80005142:	63270713          	addi	a4,a4,1586 # 8003c770 <ftable+0xfb8>
    if(f->ref == 0){
    80005146:	40dc                	lw	a5,4(s1)
    80005148:	cf99                	beqz	a5,80005166 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000514a:	02848493          	addi	s1,s1,40
    8000514e:	fee49ce3          	bne	s1,a4,80005146 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005152:	00036517          	auipc	a0,0x36
    80005156:	66650513          	addi	a0,a0,1638 # 8003b7b8 <ftable>
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	b1c080e7          	jalr	-1252(ra) # 80000c76 <release>
  return 0;
    80005162:	4481                	li	s1,0
    80005164:	a819                	j	8000517a <filealloc+0x5e>
      f->ref = 1;
    80005166:	4785                	li	a5,1
    80005168:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000516a:	00036517          	auipc	a0,0x36
    8000516e:	64e50513          	addi	a0,a0,1614 # 8003b7b8 <ftable>
    80005172:	ffffc097          	auipc	ra,0xffffc
    80005176:	b04080e7          	jalr	-1276(ra) # 80000c76 <release>
}
    8000517a:	8526                	mv	a0,s1
    8000517c:	60e2                	ld	ra,24(sp)
    8000517e:	6442                	ld	s0,16(sp)
    80005180:	64a2                	ld	s1,8(sp)
    80005182:	6105                	addi	sp,sp,32
    80005184:	8082                	ret

0000000080005186 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005186:	1101                	addi	sp,sp,-32
    80005188:	ec06                	sd	ra,24(sp)
    8000518a:	e822                	sd	s0,16(sp)
    8000518c:	e426                	sd	s1,8(sp)
    8000518e:	1000                	addi	s0,sp,32
    80005190:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005192:	00036517          	auipc	a0,0x36
    80005196:	62650513          	addi	a0,a0,1574 # 8003b7b8 <ftable>
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	a28080e7          	jalr	-1496(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800051a2:	40dc                	lw	a5,4(s1)
    800051a4:	02f05263          	blez	a5,800051c8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800051a8:	2785                	addiw	a5,a5,1
    800051aa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800051ac:	00036517          	auipc	a0,0x36
    800051b0:	60c50513          	addi	a0,a0,1548 # 8003b7b8 <ftable>
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	ac2080e7          	jalr	-1342(ra) # 80000c76 <release>
  return f;
}
    800051bc:	8526                	mv	a0,s1
    800051be:	60e2                	ld	ra,24(sp)
    800051c0:	6442                	ld	s0,16(sp)
    800051c2:	64a2                	ld	s1,8(sp)
    800051c4:	6105                	addi	sp,sp,32
    800051c6:	8082                	ret
    panic("filedup");
    800051c8:	00004517          	auipc	a0,0x4
    800051cc:	7a850513          	addi	a0,a0,1960 # 80009970 <syscalls+0x2b8>
    800051d0:	ffffb097          	auipc	ra,0xffffb
    800051d4:	35a080e7          	jalr	858(ra) # 8000052a <panic>

00000000800051d8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800051d8:	7139                	addi	sp,sp,-64
    800051da:	fc06                	sd	ra,56(sp)
    800051dc:	f822                	sd	s0,48(sp)
    800051de:	f426                	sd	s1,40(sp)
    800051e0:	f04a                	sd	s2,32(sp)
    800051e2:	ec4e                	sd	s3,24(sp)
    800051e4:	e852                	sd	s4,16(sp)
    800051e6:	e456                	sd	s5,8(sp)
    800051e8:	0080                	addi	s0,sp,64
    800051ea:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800051ec:	00036517          	auipc	a0,0x36
    800051f0:	5cc50513          	addi	a0,a0,1484 # 8003b7b8 <ftable>
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	9ce080e7          	jalr	-1586(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    800051fc:	40dc                	lw	a5,4(s1)
    800051fe:	06f05163          	blez	a5,80005260 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005202:	37fd                	addiw	a5,a5,-1
    80005204:	0007871b          	sext.w	a4,a5
    80005208:	c0dc                	sw	a5,4(s1)
    8000520a:	06e04363          	bgtz	a4,80005270 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000520e:	0004a903          	lw	s2,0(s1)
    80005212:	0094ca83          	lbu	s5,9(s1)
    80005216:	0104ba03          	ld	s4,16(s1)
    8000521a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000521e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005222:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005226:	00036517          	auipc	a0,0x36
    8000522a:	59250513          	addi	a0,a0,1426 # 8003b7b8 <ftable>
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	a48080e7          	jalr	-1464(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80005236:	4785                	li	a5,1
    80005238:	04f90d63          	beq	s2,a5,80005292 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000523c:	3979                	addiw	s2,s2,-2
    8000523e:	4785                	li	a5,1
    80005240:	0527e063          	bltu	a5,s2,80005280 <fileclose+0xa8>
    begin_op();
    80005244:	00000097          	auipc	ra,0x0
    80005248:	ac8080e7          	jalr	-1336(ra) # 80004d0c <begin_op>
    iput(ff.ip);
    8000524c:	854e                	mv	a0,s3
    8000524e:	fffff097          	auipc	ra,0xfffff
    80005252:	f90080e7          	jalr	-112(ra) # 800041de <iput>
    end_op();
    80005256:	00000097          	auipc	ra,0x0
    8000525a:	b36080e7          	jalr	-1226(ra) # 80004d8c <end_op>
    8000525e:	a00d                	j	80005280 <fileclose+0xa8>
    panic("fileclose");
    80005260:	00004517          	auipc	a0,0x4
    80005264:	71850513          	addi	a0,a0,1816 # 80009978 <syscalls+0x2c0>
    80005268:	ffffb097          	auipc	ra,0xffffb
    8000526c:	2c2080e7          	jalr	706(ra) # 8000052a <panic>
    release(&ftable.lock);
    80005270:	00036517          	auipc	a0,0x36
    80005274:	54850513          	addi	a0,a0,1352 # 8003b7b8 <ftable>
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	9fe080e7          	jalr	-1538(ra) # 80000c76 <release>
  }
}
    80005280:	70e2                	ld	ra,56(sp)
    80005282:	7442                	ld	s0,48(sp)
    80005284:	74a2                	ld	s1,40(sp)
    80005286:	7902                	ld	s2,32(sp)
    80005288:	69e2                	ld	s3,24(sp)
    8000528a:	6a42                	ld	s4,16(sp)
    8000528c:	6aa2                	ld	s5,8(sp)
    8000528e:	6121                	addi	sp,sp,64
    80005290:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005292:	85d6                	mv	a1,s5
    80005294:	8552                	mv	a0,s4
    80005296:	00000097          	auipc	ra,0x0
    8000529a:	542080e7          	jalr	1346(ra) # 800057d8 <pipeclose>
    8000529e:	b7cd                	j	80005280 <fileclose+0xa8>

00000000800052a0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800052a0:	715d                	addi	sp,sp,-80
    800052a2:	e486                	sd	ra,72(sp)
    800052a4:	e0a2                	sd	s0,64(sp)
    800052a6:	fc26                	sd	s1,56(sp)
    800052a8:	f84a                	sd	s2,48(sp)
    800052aa:	f44e                	sd	s3,40(sp)
    800052ac:	0880                	addi	s0,sp,80
    800052ae:	84aa                	mv	s1,a0
    800052b0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800052b2:	ffffd097          	auipc	ra,0xffffd
    800052b6:	8b6080e7          	jalr	-1866(ra) # 80001b68 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800052ba:	409c                	lw	a5,0(s1)
    800052bc:	37f9                	addiw	a5,a5,-2
    800052be:	4705                	li	a4,1
    800052c0:	04f76763          	bltu	a4,a5,8000530e <filestat+0x6e>
    800052c4:	892a                	mv	s2,a0
    ilock(f->ip);
    800052c6:	6c88                	ld	a0,24(s1)
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	d5c080e7          	jalr	-676(ra) # 80004024 <ilock>
    stati(f->ip, &st);
    800052d0:	fb840593          	addi	a1,s0,-72
    800052d4:	6c88                	ld	a0,24(s1)
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	fd8080e7          	jalr	-40(ra) # 800042ae <stati>
    iunlock(f->ip);
    800052de:	6c88                	ld	a0,24(s1)
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	e06080e7          	jalr	-506(ra) # 800040e6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800052e8:	46e1                	li	a3,24
    800052ea:	fb840613          	addi	a2,s0,-72
    800052ee:	85ce                	mv	a1,s3
    800052f0:	05093503          	ld	a0,80(s2)
    800052f4:	ffffc097          	auipc	ra,0xffffc
    800052f8:	534080e7          	jalr	1332(ra) # 80001828 <copyout>
    800052fc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005300:	60a6                	ld	ra,72(sp)
    80005302:	6406                	ld	s0,64(sp)
    80005304:	74e2                	ld	s1,56(sp)
    80005306:	7942                	ld	s2,48(sp)
    80005308:	79a2                	ld	s3,40(sp)
    8000530a:	6161                	addi	sp,sp,80
    8000530c:	8082                	ret
  return -1;
    8000530e:	557d                	li	a0,-1
    80005310:	bfc5                	j	80005300 <filestat+0x60>

0000000080005312 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005312:	7179                	addi	sp,sp,-48
    80005314:	f406                	sd	ra,40(sp)
    80005316:	f022                	sd	s0,32(sp)
    80005318:	ec26                	sd	s1,24(sp)
    8000531a:	e84a                	sd	s2,16(sp)
    8000531c:	e44e                	sd	s3,8(sp)
    8000531e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005320:	00854783          	lbu	a5,8(a0)
    80005324:	c3d5                	beqz	a5,800053c8 <fileread+0xb6>
    80005326:	84aa                	mv	s1,a0
    80005328:	89ae                	mv	s3,a1
    8000532a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000532c:	411c                	lw	a5,0(a0)
    8000532e:	4705                	li	a4,1
    80005330:	04e78963          	beq	a5,a4,80005382 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005334:	470d                	li	a4,3
    80005336:	04e78d63          	beq	a5,a4,80005390 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000533a:	4709                	li	a4,2
    8000533c:	06e79e63          	bne	a5,a4,800053b8 <fileread+0xa6>
    ilock(f->ip);
    80005340:	6d08                	ld	a0,24(a0)
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	ce2080e7          	jalr	-798(ra) # 80004024 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000534a:	874a                	mv	a4,s2
    8000534c:	5094                	lw	a3,32(s1)
    8000534e:	864e                	mv	a2,s3
    80005350:	4585                	li	a1,1
    80005352:	6c88                	ld	a0,24(s1)
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	f84080e7          	jalr	-124(ra) # 800042d8 <readi>
    8000535c:	892a                	mv	s2,a0
    8000535e:	00a05563          	blez	a0,80005368 <fileread+0x56>
      f->off += r;
    80005362:	509c                	lw	a5,32(s1)
    80005364:	9fa9                	addw	a5,a5,a0
    80005366:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005368:	6c88                	ld	a0,24(s1)
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	d7c080e7          	jalr	-644(ra) # 800040e6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005372:	854a                	mv	a0,s2
    80005374:	70a2                	ld	ra,40(sp)
    80005376:	7402                	ld	s0,32(sp)
    80005378:	64e2                	ld	s1,24(sp)
    8000537a:	6942                	ld	s2,16(sp)
    8000537c:	69a2                	ld	s3,8(sp)
    8000537e:	6145                	addi	sp,sp,48
    80005380:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005382:	6908                	ld	a0,16(a0)
    80005384:	00000097          	auipc	ra,0x0
    80005388:	5b6080e7          	jalr	1462(ra) # 8000593a <piperead>
    8000538c:	892a                	mv	s2,a0
    8000538e:	b7d5                	j	80005372 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005390:	02451783          	lh	a5,36(a0)
    80005394:	03079693          	slli	a3,a5,0x30
    80005398:	92c1                	srli	a3,a3,0x30
    8000539a:	4725                	li	a4,9
    8000539c:	02d76863          	bltu	a4,a3,800053cc <fileread+0xba>
    800053a0:	0792                	slli	a5,a5,0x4
    800053a2:	00036717          	auipc	a4,0x36
    800053a6:	37670713          	addi	a4,a4,886 # 8003b718 <devsw>
    800053aa:	97ba                	add	a5,a5,a4
    800053ac:	639c                	ld	a5,0(a5)
    800053ae:	c38d                	beqz	a5,800053d0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800053b0:	4505                	li	a0,1
    800053b2:	9782                	jalr	a5
    800053b4:	892a                	mv	s2,a0
    800053b6:	bf75                	j	80005372 <fileread+0x60>
    panic("fileread");
    800053b8:	00004517          	auipc	a0,0x4
    800053bc:	5d050513          	addi	a0,a0,1488 # 80009988 <syscalls+0x2d0>
    800053c0:	ffffb097          	auipc	ra,0xffffb
    800053c4:	16a080e7          	jalr	362(ra) # 8000052a <panic>
    return -1;
    800053c8:	597d                	li	s2,-1
    800053ca:	b765                	j	80005372 <fileread+0x60>
      return -1;
    800053cc:	597d                	li	s2,-1
    800053ce:	b755                	j	80005372 <fileread+0x60>
    800053d0:	597d                	li	s2,-1
    800053d2:	b745                	j	80005372 <fileread+0x60>

00000000800053d4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800053d4:	715d                	addi	sp,sp,-80
    800053d6:	e486                	sd	ra,72(sp)
    800053d8:	e0a2                	sd	s0,64(sp)
    800053da:	fc26                	sd	s1,56(sp)
    800053dc:	f84a                	sd	s2,48(sp)
    800053de:	f44e                	sd	s3,40(sp)
    800053e0:	f052                	sd	s4,32(sp)
    800053e2:	ec56                	sd	s5,24(sp)
    800053e4:	e85a                	sd	s6,16(sp)
    800053e6:	e45e                	sd	s7,8(sp)
    800053e8:	e062                	sd	s8,0(sp)
    800053ea:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800053ec:	00954783          	lbu	a5,9(a0)
    800053f0:	10078663          	beqz	a5,800054fc <filewrite+0x128>
    800053f4:	892a                	mv	s2,a0
    800053f6:	8aae                	mv	s5,a1
    800053f8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800053fa:	411c                	lw	a5,0(a0)
    800053fc:	4705                	li	a4,1
    800053fe:	02e78263          	beq	a5,a4,80005422 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005402:	470d                	li	a4,3
    80005404:	02e78663          	beq	a5,a4,80005430 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005408:	4709                	li	a4,2
    8000540a:	0ee79163          	bne	a5,a4,800054ec <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000540e:	0ac05d63          	blez	a2,800054c8 <filewrite+0xf4>
    int i = 0;
    80005412:	4981                	li	s3,0
    80005414:	6b05                	lui	s6,0x1
    80005416:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000541a:	6b85                	lui	s7,0x1
    8000541c:	c00b8b9b          	addiw	s7,s7,-1024
    80005420:	a861                	j	800054b8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005422:	6908                	ld	a0,16(a0)
    80005424:	00000097          	auipc	ra,0x0
    80005428:	424080e7          	jalr	1060(ra) # 80005848 <pipewrite>
    8000542c:	8a2a                	mv	s4,a0
    8000542e:	a045                	j	800054ce <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005430:	02451783          	lh	a5,36(a0)
    80005434:	03079693          	slli	a3,a5,0x30
    80005438:	92c1                	srli	a3,a3,0x30
    8000543a:	4725                	li	a4,9
    8000543c:	0cd76263          	bltu	a4,a3,80005500 <filewrite+0x12c>
    80005440:	0792                	slli	a5,a5,0x4
    80005442:	00036717          	auipc	a4,0x36
    80005446:	2d670713          	addi	a4,a4,726 # 8003b718 <devsw>
    8000544a:	97ba                	add	a5,a5,a4
    8000544c:	679c                	ld	a5,8(a5)
    8000544e:	cbdd                	beqz	a5,80005504 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005450:	4505                	li	a0,1
    80005452:	9782                	jalr	a5
    80005454:	8a2a                	mv	s4,a0
    80005456:	a8a5                	j	800054ce <filewrite+0xfa>
    80005458:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	8b0080e7          	jalr	-1872(ra) # 80004d0c <begin_op>
      ilock(f->ip);
    80005464:	01893503          	ld	a0,24(s2)
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	bbc080e7          	jalr	-1092(ra) # 80004024 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005470:	8762                	mv	a4,s8
    80005472:	02092683          	lw	a3,32(s2)
    80005476:	01598633          	add	a2,s3,s5
    8000547a:	4585                	li	a1,1
    8000547c:	01893503          	ld	a0,24(s2)
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	f50080e7          	jalr	-176(ra) # 800043d0 <writei>
    80005488:	84aa                	mv	s1,a0
    8000548a:	00a05763          	blez	a0,80005498 <filewrite+0xc4>
        f->off += r;
    8000548e:	02092783          	lw	a5,32(s2)
    80005492:	9fa9                	addw	a5,a5,a0
    80005494:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005498:	01893503          	ld	a0,24(s2)
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	c4a080e7          	jalr	-950(ra) # 800040e6 <iunlock>
      end_op();
    800054a4:	00000097          	auipc	ra,0x0
    800054a8:	8e8080e7          	jalr	-1816(ra) # 80004d8c <end_op>

      if(r != n1){
    800054ac:	009c1f63          	bne	s8,s1,800054ca <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800054b0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800054b4:	0149db63          	bge	s3,s4,800054ca <filewrite+0xf6>
      int n1 = n - i;
    800054b8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800054bc:	84be                	mv	s1,a5
    800054be:	2781                	sext.w	a5,a5
    800054c0:	f8fb5ce3          	bge	s6,a5,80005458 <filewrite+0x84>
    800054c4:	84de                	mv	s1,s7
    800054c6:	bf49                	j	80005458 <filewrite+0x84>
    int i = 0;
    800054c8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800054ca:	013a1f63          	bne	s4,s3,800054e8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800054ce:	8552                	mv	a0,s4
    800054d0:	60a6                	ld	ra,72(sp)
    800054d2:	6406                	ld	s0,64(sp)
    800054d4:	74e2                	ld	s1,56(sp)
    800054d6:	7942                	ld	s2,48(sp)
    800054d8:	79a2                	ld	s3,40(sp)
    800054da:	7a02                	ld	s4,32(sp)
    800054dc:	6ae2                	ld	s5,24(sp)
    800054de:	6b42                	ld	s6,16(sp)
    800054e0:	6ba2                	ld	s7,8(sp)
    800054e2:	6c02                	ld	s8,0(sp)
    800054e4:	6161                	addi	sp,sp,80
    800054e6:	8082                	ret
    ret = (i == n ? n : -1);
    800054e8:	5a7d                	li	s4,-1
    800054ea:	b7d5                	j	800054ce <filewrite+0xfa>
    panic("filewrite");
    800054ec:	00004517          	auipc	a0,0x4
    800054f0:	4ac50513          	addi	a0,a0,1196 # 80009998 <syscalls+0x2e0>
    800054f4:	ffffb097          	auipc	ra,0xffffb
    800054f8:	036080e7          	jalr	54(ra) # 8000052a <panic>
    return -1;
    800054fc:	5a7d                	li	s4,-1
    800054fe:	bfc1                	j	800054ce <filewrite+0xfa>
      return -1;
    80005500:	5a7d                	li	s4,-1
    80005502:	b7f1                	j	800054ce <filewrite+0xfa>
    80005504:	5a7d                	li	s4,-1
    80005506:	b7e1                	j	800054ce <filewrite+0xfa>

0000000080005508 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    80005508:	7179                	addi	sp,sp,-48
    8000550a:	f406                	sd	ra,40(sp)
    8000550c:	f022                	sd	s0,32(sp)
    8000550e:	ec26                	sd	s1,24(sp)
    80005510:	e84a                	sd	s2,16(sp)
    80005512:	e44e                	sd	s3,8(sp)
    80005514:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005516:	00854783          	lbu	a5,8(a0)
    8000551a:	c3d5                	beqz	a5,800055be <kfileread+0xb6>
    8000551c:	84aa                	mv	s1,a0
    8000551e:	89ae                	mv	s3,a1
    80005520:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005522:	411c                	lw	a5,0(a0)
    80005524:	4705                	li	a4,1
    80005526:	04e78963          	beq	a5,a4,80005578 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000552a:	470d                	li	a4,3
    8000552c:	04e78d63          	beq	a5,a4,80005586 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005530:	4709                	li	a4,2
    80005532:	06e79e63          	bne	a5,a4,800055ae <kfileread+0xa6>
    ilock(f->ip);
    80005536:	6d08                	ld	a0,24(a0)
    80005538:	fffff097          	auipc	ra,0xfffff
    8000553c:	aec080e7          	jalr	-1300(ra) # 80004024 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80005540:	874a                	mv	a4,s2
    80005542:	5094                	lw	a3,32(s1)
    80005544:	864e                	mv	a2,s3
    80005546:	4581                	li	a1,0
    80005548:	6c88                	ld	a0,24(s1)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	d8e080e7          	jalr	-626(ra) # 800042d8 <readi>
    80005552:	892a                	mv	s2,a0
    80005554:	00a05563          	blez	a0,8000555e <kfileread+0x56>
      f->off += r;
    80005558:	509c                	lw	a5,32(s1)
    8000555a:	9fa9                	addw	a5,a5,a0
    8000555c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000555e:	6c88                	ld	a0,24(s1)
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	b86080e7          	jalr	-1146(ra) # 800040e6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005568:	854a                	mv	a0,s2
    8000556a:	70a2                	ld	ra,40(sp)
    8000556c:	7402                	ld	s0,32(sp)
    8000556e:	64e2                	ld	s1,24(sp)
    80005570:	6942                	ld	s2,16(sp)
    80005572:	69a2                	ld	s3,8(sp)
    80005574:	6145                	addi	sp,sp,48
    80005576:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005578:	6908                	ld	a0,16(a0)
    8000557a:	00000097          	auipc	ra,0x0
    8000557e:	3c0080e7          	jalr	960(ra) # 8000593a <piperead>
    80005582:	892a                	mv	s2,a0
    80005584:	b7d5                	j	80005568 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005586:	02451783          	lh	a5,36(a0)
    8000558a:	03079693          	slli	a3,a5,0x30
    8000558e:	92c1                	srli	a3,a3,0x30
    80005590:	4725                	li	a4,9
    80005592:	02d76863          	bltu	a4,a3,800055c2 <kfileread+0xba>
    80005596:	0792                	slli	a5,a5,0x4
    80005598:	00036717          	auipc	a4,0x36
    8000559c:	18070713          	addi	a4,a4,384 # 8003b718 <devsw>
    800055a0:	97ba                	add	a5,a5,a4
    800055a2:	639c                	ld	a5,0(a5)
    800055a4:	c38d                	beqz	a5,800055c6 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800055a6:	4505                	li	a0,1
    800055a8:	9782                	jalr	a5
    800055aa:	892a                	mv	s2,a0
    800055ac:	bf75                	j	80005568 <kfileread+0x60>
    panic("fileread");
    800055ae:	00004517          	auipc	a0,0x4
    800055b2:	3da50513          	addi	a0,a0,986 # 80009988 <syscalls+0x2d0>
    800055b6:	ffffb097          	auipc	ra,0xffffb
    800055ba:	f74080e7          	jalr	-140(ra) # 8000052a <panic>
    return -1;
    800055be:	597d                	li	s2,-1
    800055c0:	b765                	j	80005568 <kfileread+0x60>
      return -1;
    800055c2:	597d                	li	s2,-1
    800055c4:	b755                	j	80005568 <kfileread+0x60>
    800055c6:	597d                	li	s2,-1
    800055c8:	b745                	j	80005568 <kfileread+0x60>

00000000800055ca <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    800055ca:	715d                	addi	sp,sp,-80
    800055cc:	e486                	sd	ra,72(sp)
    800055ce:	e0a2                	sd	s0,64(sp)
    800055d0:	fc26                	sd	s1,56(sp)
    800055d2:	f84a                	sd	s2,48(sp)
    800055d4:	f44e                	sd	s3,40(sp)
    800055d6:	f052                	sd	s4,32(sp)
    800055d8:	ec56                	sd	s5,24(sp)
    800055da:	e85a                	sd	s6,16(sp)
    800055dc:	e45e                	sd	s7,8(sp)
    800055de:	e062                	sd	s8,0(sp)
    800055e0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800055e2:	00954783          	lbu	a5,9(a0)
    800055e6:	10078663          	beqz	a5,800056f2 <kfilewrite+0x128>
    800055ea:	892a                	mv	s2,a0
    800055ec:	8aae                	mv	s5,a1
    800055ee:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800055f0:	411c                	lw	a5,0(a0)
    800055f2:	4705                	li	a4,1
    800055f4:	02e78263          	beq	a5,a4,80005618 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);

  } else if(f->type == FD_DEVICE){
    800055f8:	470d                	li	a4,3
    800055fa:	02e78663          	beq	a5,a4,80005626 <kfilewrite+0x5c>

    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;

    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800055fe:	4709                	li	a4,2
    80005600:	0ee79163          	bne	a5,a4,800056e2 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005604:	0ac05d63          	blez	a2,800056be <kfilewrite+0xf4>
    int i = 0;
    80005608:	4981                	li	s3,0
    8000560a:	6b05                	lui	s6,0x1
    8000560c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005610:	6b85                	lui	s7,0x1
    80005612:	c00b8b9b          	addiw	s7,s7,-1024
    80005616:	a861                	j	800056ae <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005618:	6908                	ld	a0,16(a0)
    8000561a:	00000097          	auipc	ra,0x0
    8000561e:	22e080e7          	jalr	558(ra) # 80005848 <pipewrite>
    80005622:	8a2a                	mv	s4,a0
    80005624:	a045                	j	800056c4 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005626:	02451783          	lh	a5,36(a0)
    8000562a:	03079693          	slli	a3,a5,0x30
    8000562e:	92c1                	srli	a3,a3,0x30
    80005630:	4725                	li	a4,9
    80005632:	0cd76263          	bltu	a4,a3,800056f6 <kfilewrite+0x12c>
    80005636:	0792                	slli	a5,a5,0x4
    80005638:	00036717          	auipc	a4,0x36
    8000563c:	0e070713          	addi	a4,a4,224 # 8003b718 <devsw>
    80005640:	97ba                	add	a5,a5,a4
    80005642:	679c                	ld	a5,8(a5)
    80005644:	cbdd                	beqz	a5,800056fa <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005646:	4505                	li	a0,1
    80005648:	9782                	jalr	a5
    8000564a:	8a2a                	mv	s4,a0
    8000564c:	a8a5                	j	800056c4 <kfilewrite+0xfa>
    8000564e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	6ba080e7          	jalr	1722(ra) # 80004d0c <begin_op>
      ilock(f->ip);
    8000565a:	01893503          	ld	a0,24(s2)
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	9c6080e7          	jalr	-1594(ra) # 80004024 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80005666:	8762                	mv	a4,s8
    80005668:	02092683          	lw	a3,32(s2)
    8000566c:	01598633          	add	a2,s3,s5
    80005670:	4581                	li	a1,0
    80005672:	01893503          	ld	a0,24(s2)
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	d5a080e7          	jalr	-678(ra) # 800043d0 <writei>
    8000567e:	84aa                	mv	s1,a0
    80005680:	00a05763          	blez	a0,8000568e <kfilewrite+0xc4>
        f->off += r;
    80005684:	02092783          	lw	a5,32(s2)
    80005688:	9fa9                	addw	a5,a5,a0
    8000568a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000568e:	01893503          	ld	a0,24(s2)
    80005692:	fffff097          	auipc	ra,0xfffff
    80005696:	a54080e7          	jalr	-1452(ra) # 800040e6 <iunlock>
      end_op();
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	6f2080e7          	jalr	1778(ra) # 80004d8c <end_op>

      if(r != n1){
    800056a2:	009c1f63          	bne	s8,s1,800056c0 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800056a6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800056aa:	0149db63          	bge	s3,s4,800056c0 <kfilewrite+0xf6>
      int n1 = n - i;
    800056ae:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800056b2:	84be                	mv	s1,a5
    800056b4:	2781                	sext.w	a5,a5
    800056b6:	f8fb5ce3          	bge	s6,a5,8000564e <kfilewrite+0x84>
    800056ba:	84de                	mv	s1,s7
    800056bc:	bf49                	j	8000564e <kfilewrite+0x84>
    int i = 0;
    800056be:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800056c0:	013a1f63          	bne	s4,s3,800056de <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    800056c4:	8552                	mv	a0,s4
    800056c6:	60a6                	ld	ra,72(sp)
    800056c8:	6406                	ld	s0,64(sp)
    800056ca:	74e2                	ld	s1,56(sp)
    800056cc:	7942                	ld	s2,48(sp)
    800056ce:	79a2                	ld	s3,40(sp)
    800056d0:	7a02                	ld	s4,32(sp)
    800056d2:	6ae2                	ld	s5,24(sp)
    800056d4:	6b42                	ld	s6,16(sp)
    800056d6:	6ba2                	ld	s7,8(sp)
    800056d8:	6c02                	ld	s8,0(sp)
    800056da:	6161                	addi	sp,sp,80
    800056dc:	8082                	ret
    ret = (i == n ? n : -1);
    800056de:	5a7d                	li	s4,-1
    800056e0:	b7d5                	j	800056c4 <kfilewrite+0xfa>
    panic("filewrite");
    800056e2:	00004517          	auipc	a0,0x4
    800056e6:	2b650513          	addi	a0,a0,694 # 80009998 <syscalls+0x2e0>
    800056ea:	ffffb097          	auipc	ra,0xffffb
    800056ee:	e40080e7          	jalr	-448(ra) # 8000052a <panic>
    return -1;
    800056f2:	5a7d                	li	s4,-1
    800056f4:	bfc1                	j	800056c4 <kfilewrite+0xfa>
      return -1;
    800056f6:	5a7d                	li	s4,-1
    800056f8:	b7f1                	j	800056c4 <kfilewrite+0xfa>
    800056fa:	5a7d                	li	s4,-1
    800056fc:	b7e1                	j	800056c4 <kfilewrite+0xfa>

00000000800056fe <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800056fe:	7179                	addi	sp,sp,-48
    80005700:	f406                	sd	ra,40(sp)
    80005702:	f022                	sd	s0,32(sp)
    80005704:	ec26                	sd	s1,24(sp)
    80005706:	e84a                	sd	s2,16(sp)
    80005708:	e44e                	sd	s3,8(sp)
    8000570a:	e052                	sd	s4,0(sp)
    8000570c:	1800                	addi	s0,sp,48
    8000570e:	84aa                	mv	s1,a0
    80005710:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005712:	0005b023          	sd	zero,0(a1)
    80005716:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000571a:	00000097          	auipc	ra,0x0
    8000571e:	a02080e7          	jalr	-1534(ra) # 8000511c <filealloc>
    80005722:	e088                	sd	a0,0(s1)
    80005724:	c551                	beqz	a0,800057b0 <pipealloc+0xb2>
    80005726:	00000097          	auipc	ra,0x0
    8000572a:	9f6080e7          	jalr	-1546(ra) # 8000511c <filealloc>
    8000572e:	00aa3023          	sd	a0,0(s4)
    80005732:	c92d                	beqz	a0,800057a4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005734:	ffffb097          	auipc	ra,0xffffb
    80005738:	39e080e7          	jalr	926(ra) # 80000ad2 <kalloc>
    8000573c:	892a                	mv	s2,a0
    8000573e:	c125                	beqz	a0,8000579e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005740:	4985                	li	s3,1
    80005742:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005746:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000574a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000574e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005752:	00004597          	auipc	a1,0x4
    80005756:	25658593          	addi	a1,a1,598 # 800099a8 <syscalls+0x2f0>
    8000575a:	ffffb097          	auipc	ra,0xffffb
    8000575e:	3d8080e7          	jalr	984(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80005762:	609c                	ld	a5,0(s1)
    80005764:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005768:	609c                	ld	a5,0(s1)
    8000576a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000576e:	609c                	ld	a5,0(s1)
    80005770:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005774:	609c                	ld	a5,0(s1)
    80005776:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000577a:	000a3783          	ld	a5,0(s4)
    8000577e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005782:	000a3783          	ld	a5,0(s4)
    80005786:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000578a:	000a3783          	ld	a5,0(s4)
    8000578e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005792:	000a3783          	ld	a5,0(s4)
    80005796:	0127b823          	sd	s2,16(a5)
  return 0;
    8000579a:	4501                	li	a0,0
    8000579c:	a025                	j	800057c4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000579e:	6088                	ld	a0,0(s1)
    800057a0:	e501                	bnez	a0,800057a8 <pipealloc+0xaa>
    800057a2:	a039                	j	800057b0 <pipealloc+0xb2>
    800057a4:	6088                	ld	a0,0(s1)
    800057a6:	c51d                	beqz	a0,800057d4 <pipealloc+0xd6>
    fileclose(*f0);
    800057a8:	00000097          	auipc	ra,0x0
    800057ac:	a30080e7          	jalr	-1488(ra) # 800051d8 <fileclose>
  if(*f1)
    800057b0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800057b4:	557d                	li	a0,-1
  if(*f1)
    800057b6:	c799                	beqz	a5,800057c4 <pipealloc+0xc6>
    fileclose(*f1);
    800057b8:	853e                	mv	a0,a5
    800057ba:	00000097          	auipc	ra,0x0
    800057be:	a1e080e7          	jalr	-1506(ra) # 800051d8 <fileclose>
  return -1;
    800057c2:	557d                	li	a0,-1
}
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	64e2                	ld	s1,24(sp)
    800057ca:	6942                	ld	s2,16(sp)
    800057cc:	69a2                	ld	s3,8(sp)
    800057ce:	6a02                	ld	s4,0(sp)
    800057d0:	6145                	addi	sp,sp,48
    800057d2:	8082                	ret
  return -1;
    800057d4:	557d                	li	a0,-1
    800057d6:	b7fd                	j	800057c4 <pipealloc+0xc6>

00000000800057d8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800057d8:	1101                	addi	sp,sp,-32
    800057da:	ec06                	sd	ra,24(sp)
    800057dc:	e822                	sd	s0,16(sp)
    800057de:	e426                	sd	s1,8(sp)
    800057e0:	e04a                	sd	s2,0(sp)
    800057e2:	1000                	addi	s0,sp,32
    800057e4:	84aa                	mv	s1,a0
    800057e6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800057e8:	ffffb097          	auipc	ra,0xffffb
    800057ec:	3da080e7          	jalr	986(ra) # 80000bc2 <acquire>
  if(writable){
    800057f0:	02090d63          	beqz	s2,8000582a <pipeclose+0x52>
    pi->writeopen = 0;
    800057f4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800057f8:	21848513          	addi	a0,s1,536
    800057fc:	ffffc097          	auipc	ra,0xffffc
    80005800:	7a8080e7          	jalr	1960(ra) # 80001fa4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005804:	2204b783          	ld	a5,544(s1)
    80005808:	eb95                	bnez	a5,8000583c <pipeclose+0x64>
    release(&pi->lock);
    8000580a:	8526                	mv	a0,s1
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	46a080e7          	jalr	1130(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005814:	8526                	mv	a0,s1
    80005816:	ffffb097          	auipc	ra,0xffffb
    8000581a:	1c0080e7          	jalr	448(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    8000581e:	60e2                	ld	ra,24(sp)
    80005820:	6442                	ld	s0,16(sp)
    80005822:	64a2                	ld	s1,8(sp)
    80005824:	6902                	ld	s2,0(sp)
    80005826:	6105                	addi	sp,sp,32
    80005828:	8082                	ret
    pi->readopen = 0;
    8000582a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000582e:	21c48513          	addi	a0,s1,540
    80005832:	ffffc097          	auipc	ra,0xffffc
    80005836:	772080e7          	jalr	1906(ra) # 80001fa4 <wakeup>
    8000583a:	b7e9                	j	80005804 <pipeclose+0x2c>
    release(&pi->lock);
    8000583c:	8526                	mv	a0,s1
    8000583e:	ffffb097          	auipc	ra,0xffffb
    80005842:	438080e7          	jalr	1080(ra) # 80000c76 <release>
}
    80005846:	bfe1                	j	8000581e <pipeclose+0x46>

0000000080005848 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005848:	711d                	addi	sp,sp,-96
    8000584a:	ec86                	sd	ra,88(sp)
    8000584c:	e8a2                	sd	s0,80(sp)
    8000584e:	e4a6                	sd	s1,72(sp)
    80005850:	e0ca                	sd	s2,64(sp)
    80005852:	fc4e                	sd	s3,56(sp)
    80005854:	f852                	sd	s4,48(sp)
    80005856:	f456                	sd	s5,40(sp)
    80005858:	f05a                	sd	s6,32(sp)
    8000585a:	ec5e                	sd	s7,24(sp)
    8000585c:	e862                	sd	s8,16(sp)
    8000585e:	1080                	addi	s0,sp,96
    80005860:	84aa                	mv	s1,a0
    80005862:	8aae                	mv	s5,a1
    80005864:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005866:	ffffc097          	auipc	ra,0xffffc
    8000586a:	302080e7          	jalr	770(ra) # 80001b68 <myproc>
    8000586e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005870:	8526                	mv	a0,s1
    80005872:	ffffb097          	auipc	ra,0xffffb
    80005876:	350080e7          	jalr	848(ra) # 80000bc2 <acquire>
  while(i < n){
    8000587a:	0b405363          	blez	s4,80005920 <pipewrite+0xd8>
  int i = 0;
    8000587e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005880:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005882:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005886:	21c48b93          	addi	s7,s1,540
    8000588a:	a089                	j	800058cc <pipewrite+0x84>
      release(&pi->lock);
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffb097          	auipc	ra,0xffffb
    80005892:	3e8080e7          	jalr	1000(ra) # 80000c76 <release>
      return -1;
    80005896:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005898:	854a                	mv	a0,s2
    8000589a:	60e6                	ld	ra,88(sp)
    8000589c:	6446                	ld	s0,80(sp)
    8000589e:	64a6                	ld	s1,72(sp)
    800058a0:	6906                	ld	s2,64(sp)
    800058a2:	79e2                	ld	s3,56(sp)
    800058a4:	7a42                	ld	s4,48(sp)
    800058a6:	7aa2                	ld	s5,40(sp)
    800058a8:	7b02                	ld	s6,32(sp)
    800058aa:	6be2                	ld	s7,24(sp)
    800058ac:	6c42                	ld	s8,16(sp)
    800058ae:	6125                	addi	sp,sp,96
    800058b0:	8082                	ret
      wakeup(&pi->nread);
    800058b2:	8562                	mv	a0,s8
    800058b4:	ffffc097          	auipc	ra,0xffffc
    800058b8:	6f0080e7          	jalr	1776(ra) # 80001fa4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800058bc:	85a6                	mv	a1,s1
    800058be:	855e                	mv	a0,s7
    800058c0:	ffffc097          	auipc	ra,0xffffc
    800058c4:	680080e7          	jalr	1664(ra) # 80001f40 <sleep>
  while(i < n){
    800058c8:	05495d63          	bge	s2,s4,80005922 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800058cc:	2204a783          	lw	a5,544(s1)
    800058d0:	dfd5                	beqz	a5,8000588c <pipewrite+0x44>
    800058d2:	0289a783          	lw	a5,40(s3)
    800058d6:	fbdd                	bnez	a5,8000588c <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800058d8:	2184a783          	lw	a5,536(s1)
    800058dc:	21c4a703          	lw	a4,540(s1)
    800058e0:	2007879b          	addiw	a5,a5,512
    800058e4:	fcf707e3          	beq	a4,a5,800058b2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800058e8:	4685                	li	a3,1
    800058ea:	01590633          	add	a2,s2,s5
    800058ee:	faf40593          	addi	a1,s0,-81
    800058f2:	0509b503          	ld	a0,80(s3)
    800058f6:	ffffc097          	auipc	ra,0xffffc
    800058fa:	fbe080e7          	jalr	-66(ra) # 800018b4 <copyin>
    800058fe:	03650263          	beq	a0,s6,80005922 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005902:	21c4a783          	lw	a5,540(s1)
    80005906:	0017871b          	addiw	a4,a5,1
    8000590a:	20e4ae23          	sw	a4,540(s1)
    8000590e:	1ff7f793          	andi	a5,a5,511
    80005912:	97a6                	add	a5,a5,s1
    80005914:	faf44703          	lbu	a4,-81(s0)
    80005918:	00e78c23          	sb	a4,24(a5)
      i++;
    8000591c:	2905                	addiw	s2,s2,1
    8000591e:	b76d                	j	800058c8 <pipewrite+0x80>
  int i = 0;
    80005920:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005922:	21848513          	addi	a0,s1,536
    80005926:	ffffc097          	auipc	ra,0xffffc
    8000592a:	67e080e7          	jalr	1662(ra) # 80001fa4 <wakeup>
  release(&pi->lock);
    8000592e:	8526                	mv	a0,s1
    80005930:	ffffb097          	auipc	ra,0xffffb
    80005934:	346080e7          	jalr	838(ra) # 80000c76 <release>
  return i;
    80005938:	b785                	j	80005898 <pipewrite+0x50>

000000008000593a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000593a:	715d                	addi	sp,sp,-80
    8000593c:	e486                	sd	ra,72(sp)
    8000593e:	e0a2                	sd	s0,64(sp)
    80005940:	fc26                	sd	s1,56(sp)
    80005942:	f84a                	sd	s2,48(sp)
    80005944:	f44e                	sd	s3,40(sp)
    80005946:	f052                	sd	s4,32(sp)
    80005948:	ec56                	sd	s5,24(sp)
    8000594a:	e85a                	sd	s6,16(sp)
    8000594c:	0880                	addi	s0,sp,80
    8000594e:	84aa                	mv	s1,a0
    80005950:	892e                	mv	s2,a1
    80005952:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005954:	ffffc097          	auipc	ra,0xffffc
    80005958:	214080e7          	jalr	532(ra) # 80001b68 <myproc>
    8000595c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffb097          	auipc	ra,0xffffb
    80005964:	262080e7          	jalr	610(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005968:	2184a703          	lw	a4,536(s1)
    8000596c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005970:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005974:	02f71463          	bne	a4,a5,8000599c <piperead+0x62>
    80005978:	2244a783          	lw	a5,548(s1)
    8000597c:	c385                	beqz	a5,8000599c <piperead+0x62>
    if(pr->killed){
    8000597e:	028a2783          	lw	a5,40(s4)
    80005982:	ebc1                	bnez	a5,80005a12 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005984:	85a6                	mv	a1,s1
    80005986:	854e                	mv	a0,s3
    80005988:	ffffc097          	auipc	ra,0xffffc
    8000598c:	5b8080e7          	jalr	1464(ra) # 80001f40 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005990:	2184a703          	lw	a4,536(s1)
    80005994:	21c4a783          	lw	a5,540(s1)
    80005998:	fef700e3          	beq	a4,a5,80005978 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000599c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000599e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059a0:	05505363          	blez	s5,800059e6 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800059a4:	2184a783          	lw	a5,536(s1)
    800059a8:	21c4a703          	lw	a4,540(s1)
    800059ac:	02f70d63          	beq	a4,a5,800059e6 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800059b0:	0017871b          	addiw	a4,a5,1
    800059b4:	20e4ac23          	sw	a4,536(s1)
    800059b8:	1ff7f793          	andi	a5,a5,511
    800059bc:	97a6                	add	a5,a5,s1
    800059be:	0187c783          	lbu	a5,24(a5)
    800059c2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059c6:	4685                	li	a3,1
    800059c8:	fbf40613          	addi	a2,s0,-65
    800059cc:	85ca                	mv	a1,s2
    800059ce:	050a3503          	ld	a0,80(s4)
    800059d2:	ffffc097          	auipc	ra,0xffffc
    800059d6:	e56080e7          	jalr	-426(ra) # 80001828 <copyout>
    800059da:	01650663          	beq	a0,s6,800059e6 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059de:	2985                	addiw	s3,s3,1
    800059e0:	0905                	addi	s2,s2,1
    800059e2:	fd3a91e3          	bne	s5,s3,800059a4 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800059e6:	21c48513          	addi	a0,s1,540
    800059ea:	ffffc097          	auipc	ra,0xffffc
    800059ee:	5ba080e7          	jalr	1466(ra) # 80001fa4 <wakeup>
  release(&pi->lock);
    800059f2:	8526                	mv	a0,s1
    800059f4:	ffffb097          	auipc	ra,0xffffb
    800059f8:	282080e7          	jalr	642(ra) # 80000c76 <release>
  return i;
}
    800059fc:	854e                	mv	a0,s3
    800059fe:	60a6                	ld	ra,72(sp)
    80005a00:	6406                	ld	s0,64(sp)
    80005a02:	74e2                	ld	s1,56(sp)
    80005a04:	7942                	ld	s2,48(sp)
    80005a06:	79a2                	ld	s3,40(sp)
    80005a08:	7a02                	ld	s4,32(sp)
    80005a0a:	6ae2                	ld	s5,24(sp)
    80005a0c:	6b42                	ld	s6,16(sp)
    80005a0e:	6161                	addi	sp,sp,80
    80005a10:	8082                	ret
      release(&pi->lock);
    80005a12:	8526                	mv	a0,s1
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	262080e7          	jalr	610(ra) # 80000c76 <release>
      return -1;
    80005a1c:	59fd                	li	s3,-1
    80005a1e:	bff9                	j	800059fc <piperead+0xc2>

0000000080005a20 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005a20:	7119                	addi	sp,sp,-128
    80005a22:	fc86                	sd	ra,120(sp)
    80005a24:	f8a2                	sd	s0,112(sp)
    80005a26:	f4a6                	sd	s1,104(sp)
    80005a28:	f0ca                	sd	s2,96(sp)
    80005a2a:	ecce                	sd	s3,88(sp)
    80005a2c:	e8d2                	sd	s4,80(sp)
    80005a2e:	e4d6                	sd	s5,72(sp)
    80005a30:	e0da                	sd	s6,64(sp)
    80005a32:	fc5e                	sd	s7,56(sp)
    80005a34:	f862                	sd	s8,48(sp)
    80005a36:	f466                	sd	s9,40(sp)
    80005a38:	f06a                	sd	s10,32(sp)
    80005a3a:	ec6e                	sd	s11,24(sp)
    80005a3c:	0100                	addi	s0,sp,128
    80005a3e:	81010113          	addi	sp,sp,-2032
    80005a42:	74fd                	lui	s1,0xfffff
    80005a44:	7a848793          	addi	a5,s1,1960 # fffffffffffff7a8 <end+0xffffffff7ffbf7a8>
    80005a48:	97a2                	add	a5,a5,s0
    80005a4a:	e388                	sd	a0,0(a5)
    80005a4c:	7b048793          	addi	a5,s1,1968
    80005a50:	97a2                	add	a5,a5,s0
    80005a52:	e38c                	sd	a1,0(a5)
  printf("hello from exec! path: %s\n", path);
    80005a54:	85aa                	mv	a1,a0
    80005a56:	00004517          	auipc	a0,0x4
    80005a5a:	f5a50513          	addi	a0,a0,-166 # 800099b0 <syscalls+0x2f8>
    80005a5e:	ffffb097          	auipc	ra,0xffffb
    80005a62:	b16080e7          	jalr	-1258(ra) # 80000574 <printf>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005a66:	ffffc097          	auipc	ra,0xffffc
    80005a6a:	102080e7          	jalr	258(ra) # 80001b68 <myproc>
    80005a6e:	7c048793          	addi	a5,s1,1984
    80005a72:	97a2                	add	a5,a5,s0
    80005a74:	e388                	sd	a0,0(a5)
  //and clear the pages in arrays (we want theme cleared because the child process
  //doing exec doesn't need the memory from daddy)
  #ifndef NONE
  struct page_struct old_ram[MAX_PSYC_PAGES];
  struct page_struct old_swap[MAX_SWAP_PAGES];
  if (p->pid > 2){
    80005a76:	5918                	lw	a4,48(a0)
    80005a78:	4789                	li	a5,2
    80005a7a:	06e7d863          	bge	a5,a4,80005aea <exec+0xca>
    80005a7e:	b1040913          	addi	s2,s0,-1264
    80005a82:	4a050493          	addi	s1,a0,1184
    80005a86:	e1040a13          	addi	s4,s0,-496
    for(int i=0; i<MAX_PSYC_PAGES; i++){
      memmove((void *)&old_ram[i], (void *)&p->files_in_physicalmem[i], sizeof(struct page_struct));
      // memmove((void *)&old_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));

      p->files_in_physicalmem[i].isAvailable = 1;
    80005a8a:	4985                	li	s3,1
      memmove((void *)&old_ram[i], (void *)&p->files_in_physicalmem[i], sizeof(struct page_struct));
    80005a8c:	03000613          	li	a2,48
    80005a90:	85a6                	mv	a1,s1
    80005a92:	854a                	mv	a0,s2
    80005a94:	ffffb097          	auipc	ra,0xffffb
    80005a98:	286080e7          	jalr	646(ra) # 80000d1a <memmove>
      p->files_in_physicalmem[i].isAvailable = 1;
    80005a9c:	0134a023          	sw	s3,0(s1)
    for(int i=0; i<MAX_PSYC_PAGES; i++){
    80005aa0:	03090913          	addi	s2,s2,48
    80005aa4:	03048493          	addi	s1,s1,48
    80005aa8:	ff4912e3          	bne	s2,s4,80005a8c <exec+0x6c>
    80005aac:	77fd                	lui	a5,0xfffff
    80005aae:	7e078793          	addi	a5,a5,2016 # fffffffffffff7e0 <end+0xffffffff7ffbf7e0>
    80005ab2:	00f40933          	add	s2,s0,a5
    80005ab6:	77fd                	lui	a5,0xfffff
    80005ab8:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005abc:	97a2                	add	a5,a5,s0
    80005abe:	639c                	ld	a5,0(a5)
    80005ac0:	17078493          	addi	s1,a5,368
    80005ac4:	b1040a13          	addi	s4,s0,-1264
      // p->files_in_swap[i].isAvailable = 1;
      // p->files_in_swap[i].va = -1;
    }
    for(int i=0; i<MAX_SWAP_PAGES; i++){
      memmove((void *)&old_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
      p->files_in_swap[i].isAvailable = 1;
    80005ac8:	4985                	li	s3,1
      memmove((void *)&old_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
    80005aca:	03000613          	li	a2,48
    80005ace:	85a6                	mv	a1,s1
    80005ad0:	854a                	mv	a0,s2
    80005ad2:	ffffb097          	auipc	ra,0xffffb
    80005ad6:	248080e7          	jalr	584(ra) # 80000d1a <memmove>
      p->files_in_swap[i].isAvailable = 1;
    80005ada:	0134a023          	sw	s3,0(s1)
    for(int i=0; i<MAX_SWAP_PAGES; i++){
    80005ade:	03090913          	addi	s2,s2,48
    80005ae2:	03048493          	addi	s1,s1,48
    80005ae6:	ff4912e3          	bne	s2,s4,80005aca <exec+0xaa>
    }
  }
  //backup and zerofy page counters
  int backup_num_of_ram_pages = p->num_of_pages_in_phys;
    80005aea:	74fd                	lui	s1,0xfffff
    80005aec:	7c048793          	addi	a5,s1,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005af0:	97a2                	add	a5,a5,s0
    80005af2:	639c                	ld	a5,0(a5)
    80005af4:	7a47a703          	lw	a4,1956(a5)
    80005af8:	7a048693          	addi	a3,s1,1952
    80005afc:	96a2                	add	a3,a3,s0
    80005afe:	e298                	sd	a4,0(a3)
  int backup_num_of_pages = p->num_of_pages;
    80005b00:	7a07a703          	lw	a4,1952(a5)
    80005b04:	79848693          	addi	a3,s1,1944
    80005b08:	96a2                	add	a3,a3,s0
    80005b0a:	e298                	sd	a4,0(a3)
  p->num_of_pages = 0;
    80005b0c:	7a07a023          	sw	zero,1952(a5)
  p->num_of_pages_in_phys = 0;
    80005b10:	7a07a223          	sw	zero,1956(a5)

  #endif

  begin_op();
    80005b14:	fffff097          	auipc	ra,0xfffff
    80005b18:	1f8080e7          	jalr	504(ra) # 80004d0c <begin_op>

  if((ip = namei(path)) == 0){
    80005b1c:	7a848793          	addi	a5,s1,1960
    80005b20:	97a2                	add	a5,a5,s0
    80005b22:	6388                	ld	a0,0(a5)
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	cb6080e7          	jalr	-842(ra) # 800047da <namei>
    80005b2c:	8aaa                	mv	s5,a0
    80005b2e:	cd2d                	beqz	a0,80005ba8 <exec+0x188>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	4f4080e7          	jalr	1268(ra) # 80004024 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005b38:	04000713          	li	a4,64
    80005b3c:	4681                	li	a3,0
    80005b3e:	e4840613          	addi	a2,s0,-440
    80005b42:	4581                	li	a1,0
    80005b44:	8556                	mv	a0,s5
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	792080e7          	jalr	1938(ra) # 800042d8 <readi>
    80005b4e:	04000793          	li	a5,64
    80005b52:	2af51463          	bne	a0,a5,80005dfa <exec+0x3da>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005b56:	e4842703          	lw	a4,-440(s0)
    80005b5a:	464c47b7          	lui	a5,0x464c4
    80005b5e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005b62:	28f71c63          	bne	a4,a5,80005dfa <exec+0x3da>
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    80005b66:	797d                	lui	s2,0xfffff
    80005b68:	7c090793          	addi	a5,s2,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005b6c:	97a2                	add	a5,a5,s0
    80005b6e:	6388                	ld	a0,0(a5)
    80005b70:	ffffc097          	auipc	ra,0xffffc
    80005b74:	0bc080e7          	jalr	188(ra) # 80001c2c <proc_pagetable>
    80005b78:	8b2a                	mv	s6,a0
    80005b7a:	28050063          	beqz	a0,80005dfa <exec+0x3da>
    goto bad;

  // Load program into memory. allocate ELF stuff
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b7e:	e6842783          	lw	a5,-408(s0)
    80005b82:	e8045703          	lhu	a4,-384(s0)
    80005b86:	c349                	beqz	a4,80005c08 <exec+0x1e8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005b88:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b8a:	7d890713          	addi	a4,s2,2008
    80005b8e:	9722                	add	a4,a4,s0
    80005b90:	00073023          	sd	zero,0(a4)
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    sz = sz1;
    if(ph.vaddr % PGSIZE != 0)
    80005b94:	6a05                	lui	s4,0x1
    80005b96:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005b9a:	7b890693          	addi	a3,s2,1976
    80005b9e:	96a2                	add	a3,a3,s0
    80005ba0:	e298                	sd	a4,0(a3)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005ba2:	6d85                	lui	s11,0x1
    80005ba4:	7d7d                	lui	s10,0xfffff
    80005ba6:	ae41                	j	80005f36 <exec+0x516>
    end_op();
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	1e4080e7          	jalr	484(ra) # 80004d8c <end_op>
    return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	a4e5                	j	80005e9a <exec+0x47a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005bb4:	00004517          	auipc	a0,0x4
    80005bb8:	e1c50513          	addi	a0,a0,-484 # 800099d0 <syscalls+0x318>
    80005bbc:	ffffb097          	auipc	ra,0xffffb
    80005bc0:	96e080e7          	jalr	-1682(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005bc4:	874a                	mv	a4,s2
    80005bc6:	009c86bb          	addw	a3,s9,s1
    80005bca:	4581                	li	a1,0
    80005bcc:	8556                	mv	a0,s5
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	70a080e7          	jalr	1802(ra) # 800042d8 <readi>
    80005bd6:	2501                	sext.w	a0,a0
    80005bd8:	20a91563          	bne	s2,a0,80005de2 <exec+0x3c2>
  for(i = 0; i < sz; i += PGSIZE){
    80005bdc:	009d84bb          	addw	s1,s11,s1
    80005be0:	013d09bb          	addw	s3,s10,s3
    80005be4:	3174ff63          	bgeu	s1,s7,80005f02 <exec+0x4e2>
    pa = walkaddr(pagetable, va + i);
    80005be8:	02049593          	slli	a1,s1,0x20
    80005bec:	9181                	srli	a1,a1,0x20
    80005bee:	95e2                	add	a1,a1,s8
    80005bf0:	855a                	mv	a0,s6
    80005bf2:	ffffb097          	auipc	ra,0xffffb
    80005bf6:	46e080e7          	jalr	1134(ra) # 80001060 <walkaddr>
    80005bfa:	862a                	mv	a2,a0
    if(pa == 0)
    80005bfc:	dd45                	beqz	a0,80005bb4 <exec+0x194>
      n = PGSIZE;
    80005bfe:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005c00:	fd49f2e3          	bgeu	s3,s4,80005bc4 <exec+0x1a4>
      n = sz - i;
    80005c04:	894e                	mv	s2,s3
    80005c06:	bf7d                	j	80005bc4 <exec+0x1a4>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005c08:	4481                	li	s1,0
  iunlockput(ip);
    80005c0a:	8556                	mv	a0,s5
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	67a080e7          	jalr	1658(ra) # 80004286 <iunlockput>
  end_op();
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	178080e7          	jalr	376(ra) # 80004d8c <end_op>
  p = myproc();
    80005c1c:	ffffc097          	auipc	ra,0xffffc
    80005c20:	f4c080e7          	jalr	-180(ra) # 80001b68 <myproc>
    80005c24:	797d                	lui	s2,0xfffff
    80005c26:	7c090713          	addi	a4,s2,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005c2a:	9722                	add	a4,a4,s0
    80005c2c:	e308                	sd	a0,0(a4)
  uint64 oldsz = p->sz;
    80005c2e:	04853c03          	ld	s8,72(a0)
  sz = PGROUNDUP(sz);
    80005c32:	6785                	lui	a5,0x1
    80005c34:	17fd                	addi	a5,a5,-1
    80005c36:	94be                	add	s1,s1,a5
    80005c38:	77fd                	lui	a5,0xfffff
    80005c3a:	8cfd                	and	s1,s1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005c3c:	6609                	lui	a2,0x2
    80005c3e:	9626                	add	a2,a2,s1
    80005c40:	85a6                	mv	a1,s1
    80005c42:	855a                	mv	a0,s6
    80005c44:	ffffc097          	auipc	ra,0xffffc
    80005c48:	8de080e7          	jalr	-1826(ra) # 80001522 <uvmalloc>
    80005c4c:	7c890713          	addi	a4,s2,1992
    80005c50:	9722                	add	a4,a4,s0
    80005c52:	e308                	sd	a0,0(a4)
    80005c54:	28050663          	beqz	a0,80005ee0 <exec+0x4c0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005c58:	75f9                	lui	a1,0xffffe
    80005c5a:	84aa                	mv	s1,a0
    80005c5c:	95aa                	add	a1,a1,a0
    80005c5e:	855a                	mv	a0,s6
    80005c60:	ffffc097          	auipc	ra,0xffffc
    80005c64:	b96080e7          	jalr	-1130(ra) # 800017f6 <uvmclear>
  stackbase = sp - PGSIZE;
    80005c68:	7afd                	lui	s5,0xfffff
    80005c6a:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80005c6c:	7b090793          	addi	a5,s2,1968
    80005c70:	97a2                	add	a5,a5,s0
    80005c72:	639c                	ld	a5,0(a5)
    80005c74:	6388                	ld	a0,0(a5)
    80005c76:	c925                	beqz	a0,80005ce6 <exec+0x2c6>
    80005c78:	e8840913          	addi	s2,s0,-376
    80005c7c:	f8840b93          	addi	s7,s0,-120
    80005c80:	4981                	li	s3,0
    sp -= strlen(argv[argc]) + 1;
    80005c82:	ffffb097          	auipc	ra,0xffffb
    80005c86:	1c0080e7          	jalr	448(ra) # 80000e42 <strlen>
    80005c8a:	2505                	addiw	a0,a0,1
    80005c8c:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c8e:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80005c90:	2554ef63          	bltu	s1,s5,80005eee <exec+0x4ce>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c94:	7d7d                	lui	s10,0xfffff
    80005c96:	7b0d0793          	addi	a5,s10,1968 # fffffffffffff7b0 <end+0xffffffff7ffbf7b0>
    80005c9a:	97a2                	add	a5,a5,s0
    80005c9c:	0007bc83          	ld	s9,0(a5) # fffffffffffff000 <end+0xffffffff7ffbf000>
    80005ca0:	000cba03          	ld	s4,0(s9)
    80005ca4:	8552                	mv	a0,s4
    80005ca6:	ffffb097          	auipc	ra,0xffffb
    80005caa:	19c080e7          	jalr	412(ra) # 80000e42 <strlen>
    80005cae:	0015069b          	addiw	a3,a0,1
    80005cb2:	8652                	mv	a2,s4
    80005cb4:	85a6                	mv	a1,s1
    80005cb6:	855a                	mv	a0,s6
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	b70080e7          	jalr	-1168(ra) # 80001828 <copyout>
    80005cc0:	22054963          	bltz	a0,80005ef2 <exec+0x4d2>
    ustack[argc] = sp;
    80005cc4:	00993023          	sd	s1,0(s2)
  for(argc = 0; argv[argc]; argc++) {
    80005cc8:	0985                	addi	s3,s3,1
    80005cca:	008c8793          	addi	a5,s9,8
    80005cce:	7b0d0713          	addi	a4,s10,1968
    80005cd2:	9722                	add	a4,a4,s0
    80005cd4:	e31c                	sd	a5,0(a4)
    80005cd6:	008cb503          	ld	a0,8(s9)
    80005cda:	cd01                	beqz	a0,80005cf2 <exec+0x2d2>
    if(argc >= MAXARG)
    80005cdc:	0921                	addi	s2,s2,8
    80005cde:	fb7912e3          	bne	s2,s7,80005c82 <exec+0x262>
  ip = 0;
    80005ce2:	4a81                	li	s5,0
    80005ce4:	a8fd                	j	80005de2 <exec+0x3c2>
  sp = sz;
    80005ce6:	77fd                	lui	a5,0xfffff
    80005ce8:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005cec:	97a2                	add	a5,a5,s0
    80005cee:	6384                	ld	s1,0(a5)
  for(argc = 0; argv[argc]; argc++) {
    80005cf0:	4981                	li	s3,0
  ustack[argc] = 0;
    80005cf2:	00399793          	slli	a5,s3,0x3
    80005cf6:	f9040713          	addi	a4,s0,-112
    80005cfa:	97ba                	add	a5,a5,a4
    80005cfc:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005d00:	00198693          	addi	a3,s3,1
    80005d04:	068e                	slli	a3,a3,0x3
    80005d06:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005d08:	98c1                	andi	s1,s1,-16
  if(sp < stackbase)
    80005d0a:	1f54e663          	bltu	s1,s5,80005ef6 <exec+0x4d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005d0e:	e8840613          	addi	a2,s0,-376
    80005d12:	85a6                	mv	a1,s1
    80005d14:	855a                	mv	a0,s6
    80005d16:	ffffc097          	auipc	ra,0xffffc
    80005d1a:	b12080e7          	jalr	-1262(ra) # 80001828 <copyout>
    80005d1e:	1c054e63          	bltz	a0,80005efa <exec+0x4da>
  p->trapframe->a1 = sp;
    80005d22:	777d                	lui	a4,0xfffff
    80005d24:	7c070793          	addi	a5,a4,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005d28:	97a2                	add	a5,a5,s0
    80005d2a:	639c                	ld	a5,0(a5)
    80005d2c:	6fbc                	ld	a5,88(a5)
    80005d2e:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    80005d30:	7a870793          	addi	a5,a4,1960
    80005d34:	97a2                	add	a5,a5,s0
    80005d36:	639c                	ld	a5,0(a5)
    80005d38:	0007c703          	lbu	a4,0(a5)
    80005d3c:	c30d                	beqz	a4,80005d5e <exec+0x33e>
    80005d3e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005d40:	02f00693          	li	a3,47
    80005d44:	a029                	j	80005d4e <exec+0x32e>
  for(last=s=path; *s; s++)
    80005d46:	0785                	addi	a5,a5,1
    80005d48:	fff7c703          	lbu	a4,-1(a5)
    80005d4c:	cb09                	beqz	a4,80005d5e <exec+0x33e>
    if(*s == '/')
    80005d4e:	fed71ce3          	bne	a4,a3,80005d46 <exec+0x326>
      last = s+1;
    80005d52:	777d                	lui	a4,0xfffff
    80005d54:	7a870713          	addi	a4,a4,1960 # fffffffffffff7a8 <end+0xffffffff7ffbf7a8>
    80005d58:	9722                	add	a4,a4,s0
    80005d5a:	e31c                	sd	a5,0(a4)
    80005d5c:	b7ed                	j	80005d46 <exec+0x326>
  safestrcpy(p->name, last, sizeof(p->name));
    80005d5e:	4641                	li	a2,16
    80005d60:	777d                	lui	a4,0xfffff
    80005d62:	7a870793          	addi	a5,a4,1960 # fffffffffffff7a8 <end+0xffffffff7ffbf7a8>
    80005d66:	97a2                	add	a5,a5,s0
    80005d68:	638c                	ld	a1,0(a5)
    80005d6a:	7c070793          	addi	a5,a4,1984
    80005d6e:	97a2                	add	a5,a5,s0
    80005d70:	0007b903          	ld	s2,0(a5)
    80005d74:	15890513          	addi	a0,s2,344
    80005d78:	ffffb097          	auipc	ra,0xffffb
    80005d7c:	098080e7          	jalr	152(ra) # 80000e10 <safestrcpy>
  if (p->pid > 2){
    80005d80:	03092703          	lw	a4,48(s2)
    80005d84:	4789                	li	a5,2
    80005d86:	00e7de63          	bge	a5,a4,80005da2 <exec+0x382>
    if(removeSwapFile(p) < 0)
    80005d8a:	854a                	mv	a0,s2
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	afa080e7          	jalr	-1286(ra) # 80004886 <removeSwapFile>
    80005d94:	16054563          	bltz	a0,80005efe <exec+0x4de>
    createSwapFile(p);
    80005d98:	854a                	mv	a0,s2
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	c94080e7          	jalr	-876(ra) # 80004a2e <createSwapFile>
  oldpagetable = p->pagetable;
    80005da2:	777d                	lui	a4,0xfffff
    80005da4:	7c070793          	addi	a5,a4,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005da8:	97a2                	add	a5,a5,s0
    80005daa:	6394                	ld	a3,0(a5)
    80005dac:	6aa8                	ld	a0,80(a3)
  p->pagetable = pagetable;
    80005dae:	0566b823          	sd	s6,80(a3)
  p->sz = sz;
    80005db2:	7c870713          	addi	a4,a4,1992
    80005db6:	9722                	add	a4,a4,s0
    80005db8:	6318                	ld	a4,0(a4)
    80005dba:	e6b8                	sd	a4,72(a3)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005dbc:	6ebc                	ld	a5,88(a3)
    80005dbe:	e6043703          	ld	a4,-416(s0)
    80005dc2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005dc4:	6ebc                	ld	a5,88(a3)
    80005dc6:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005dc8:	85e2                	mv	a1,s8
    80005dca:	ffffc097          	auipc	ra,0xffffc
    80005dce:	efe080e7          	jalr	-258(ra) # 80001cc8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005dd2:	0009851b          	sext.w	a0,s3
    80005dd6:	a0d1                	j	80005e9a <exec+0x47a>
    80005dd8:	77fd                	lui	a5,0xfffff
    80005dda:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005dde:	97a2                	add	a5,a5,s0
    80005de0:	e384                	sd	s1,0(a5)
    proc_freepagetable(pagetable, sz);
    80005de2:	77fd                	lui	a5,0xfffff
    80005de4:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005de8:	97a2                	add	a5,a5,s0
    80005dea:	638c                	ld	a1,0(a5)
    80005dec:	855a                	mv	a0,s6
    80005dee:	ffffc097          	auipc	ra,0xffffc
    80005df2:	eda080e7          	jalr	-294(ra) # 80001cc8 <proc_freepagetable>
  if(ip){
    80005df6:	000a8b63          	beqz	s5,80005e0c <exec+0x3ec>
    iunlockput(ip);
    80005dfa:	8556                	mv	a0,s5
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	48a080e7          	jalr	1162(ra) # 80004286 <iunlockput>
    end_op();
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	f88080e7          	jalr	-120(ra) # 80004d8c <end_op>
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    80005e0c:	77fd                	lui	a5,0xfffff
    80005e0e:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005e12:	97a2                	add	a5,a5,s0
    80005e14:	639c                	ld	a5,0(a5)
    80005e16:	4a078913          	addi	s2,a5,1184
    80005e1a:	b1040493          	addi	s1,s0,-1264
    80005e1e:	e1040993          	addi	s3,s0,-496
    memmove((void *)&p->files_in_physicalmem[i], (void *)&old_ram[i], sizeof(struct page_struct));
    80005e22:	03000613          	li	a2,48
    80005e26:	85a6                	mv	a1,s1
    80005e28:	854a                	mv	a0,s2
    80005e2a:	ffffb097          	auipc	ra,0xffffb
    80005e2e:	ef0080e7          	jalr	-272(ra) # 80000d1a <memmove>
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    80005e32:	03090913          	addi	s2,s2,48
    80005e36:	03048493          	addi	s1,s1,48
    80005e3a:	ff3494e3          	bne	s1,s3,80005e22 <exec+0x402>
    80005e3e:	77fd                	lui	a5,0xfffff
    80005e40:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005e44:	97a2                	add	a5,a5,s0
    80005e46:	639c                	ld	a5,0(a5)
    80005e48:	17078913          	addi	s2,a5,368
    80005e4c:	77fd                	lui	a5,0xfffff
    80005e4e:	7e078793          	addi	a5,a5,2016 # fffffffffffff7e0 <end+0xffffffff7ffbf7e0>
    80005e52:	00f404b3          	add	s1,s0,a5
    80005e56:	b1040993          	addi	s3,s0,-1264
    memmove((void *)&p->files_in_swap[i], (void *)&old_swap[i], sizeof(struct page_struct));
    80005e5a:	03000613          	li	a2,48
    80005e5e:	85a6                	mv	a1,s1
    80005e60:	854a                	mv	a0,s2
    80005e62:	ffffb097          	auipc	ra,0xffffb
    80005e66:	eb8080e7          	jalr	-328(ra) # 80000d1a <memmove>
  for(int i=0; i<MAX_SWAP_PAGES; i++){
    80005e6a:	03090913          	addi	s2,s2,48
    80005e6e:	03048493          	addi	s1,s1,48
    80005e72:	ff3494e3          	bne	s1,s3,80005e5a <exec+0x43a>
  p->num_of_pages_in_phys = backup_num_of_ram_pages;
    80005e76:	76fd                	lui	a3,0xfffff
    80005e78:	7c068793          	addi	a5,a3,1984 # fffffffffffff7c0 <end+0xffffffff7ffbf7c0>
    80005e7c:	97a2                	add	a5,a5,s0
    80005e7e:	639c                	ld	a5,0(a5)
    80005e80:	7a068713          	addi	a4,a3,1952
    80005e84:	9722                	add	a4,a4,s0
    80005e86:	6318                	ld	a4,0(a4)
    80005e88:	7ae7a223          	sw	a4,1956(a5)
  p->num_of_pages = backup_num_of_pages;
    80005e8c:	79868713          	addi	a4,a3,1944
    80005e90:	9722                	add	a4,a4,s0
    80005e92:	6318                	ld	a4,0(a4)
    80005e94:	7ae7a023          	sw	a4,1952(a5)
  return -1;
    80005e98:	557d                	li	a0,-1
}
    80005e9a:	7f010113          	addi	sp,sp,2032
    80005e9e:	70e6                	ld	ra,120(sp)
    80005ea0:	7446                	ld	s0,112(sp)
    80005ea2:	74a6                	ld	s1,104(sp)
    80005ea4:	7906                	ld	s2,96(sp)
    80005ea6:	69e6                	ld	s3,88(sp)
    80005ea8:	6a46                	ld	s4,80(sp)
    80005eaa:	6aa6                	ld	s5,72(sp)
    80005eac:	6b06                	ld	s6,64(sp)
    80005eae:	7be2                	ld	s7,56(sp)
    80005eb0:	7c42                	ld	s8,48(sp)
    80005eb2:	7ca2                	ld	s9,40(sp)
    80005eb4:	7d02                	ld	s10,32(sp)
    80005eb6:	6de2                	ld	s11,24(sp)
    80005eb8:	6109                	addi	sp,sp,128
    80005eba:	8082                	ret
    80005ebc:	77fd                	lui	a5,0xfffff
    80005ebe:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005ec2:	97a2                	add	a5,a5,s0
    80005ec4:	e384                	sd	s1,0(a5)
    80005ec6:	bf31                	j	80005de2 <exec+0x3c2>
    80005ec8:	77fd                	lui	a5,0xfffff
    80005eca:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005ece:	97a2                	add	a5,a5,s0
    80005ed0:	e384                	sd	s1,0(a5)
    80005ed2:	bf01                	j	80005de2 <exec+0x3c2>
    80005ed4:	77fd                	lui	a5,0xfffff
    80005ed6:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005eda:	97a2                	add	a5,a5,s0
    80005edc:	e384                	sd	s1,0(a5)
    80005ede:	b711                	j	80005de2 <exec+0x3c2>
  sz = PGROUNDUP(sz);
    80005ee0:	77fd                	lui	a5,0xfffff
    80005ee2:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005ee6:	97a2                	add	a5,a5,s0
    80005ee8:	e384                	sd	s1,0(a5)
  ip = 0;
    80005eea:	4a81                	li	s5,0
    80005eec:	bddd                	j	80005de2 <exec+0x3c2>
    80005eee:	4a81                	li	s5,0
    80005ef0:	bdcd                	j	80005de2 <exec+0x3c2>
    80005ef2:	4a81                	li	s5,0
    80005ef4:	b5fd                	j	80005de2 <exec+0x3c2>
    80005ef6:	4a81                	li	s5,0
    80005ef8:	b5ed                	j	80005de2 <exec+0x3c2>
    80005efa:	4a81                	li	s5,0
    80005efc:	b5dd                	j	80005de2 <exec+0x3c2>
    80005efe:	4a81                	li	s5,0
    80005f00:	b5cd                	j	80005de2 <exec+0x3c2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005f02:	77fd                	lui	a5,0xfffff
    80005f04:	7c878793          	addi	a5,a5,1992 # fffffffffffff7c8 <end+0xffffffff7ffbf7c8>
    80005f08:	97a2                	add	a5,a5,s0
    80005f0a:	6384                	ld	s1,0(a5)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005f0c:	777d                	lui	a4,0xfffff
    80005f0e:	7d870793          	addi	a5,a4,2008 # fffffffffffff7d8 <end+0xffffffff7ffbf7d8>
    80005f12:	97a2                	add	a5,a5,s0
    80005f14:	639c                	ld	a5,0(a5)
    80005f16:	0017869b          	addiw	a3,a5,1
    80005f1a:	7d870793          	addi	a5,a4,2008
    80005f1e:	97a2                	add	a5,a5,s0
    80005f20:	e394                	sd	a3,0(a5)
    80005f22:	7d070793          	addi	a5,a4,2000
    80005f26:	97a2                	add	a5,a5,s0
    80005f28:	639c                	ld	a5,0(a5)
    80005f2a:	0387879b          	addiw	a5,a5,56
    80005f2e:	e8045703          	lhu	a4,-384(s0)
    80005f32:	cce6dce3          	bge	a3,a4,80005c0a <exec+0x1ea>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005f36:	2781                	sext.w	a5,a5
    80005f38:	797d                	lui	s2,0xfffff
    80005f3a:	7d090713          	addi	a4,s2,2000 # fffffffffffff7d0 <end+0xffffffff7ffbf7d0>
    80005f3e:	9722                	add	a4,a4,s0
    80005f40:	e31c                	sd	a5,0(a4)
    80005f42:	03800713          	li	a4,56
    80005f46:	86be                	mv	a3,a5
    80005f48:	e1040613          	addi	a2,s0,-496
    80005f4c:	4581                	li	a1,0
    80005f4e:	8556                	mv	a0,s5
    80005f50:	ffffe097          	auipc	ra,0xffffe
    80005f54:	388080e7          	jalr	904(ra) # 800042d8 <readi>
    80005f58:	03800793          	li	a5,56
    80005f5c:	e6f51ee3          	bne	a0,a5,80005dd8 <exec+0x3b8>
    if(ph.type != ELF_PROG_LOAD)
    80005f60:	e1042783          	lw	a5,-496(s0)
    80005f64:	4705                	li	a4,1
    80005f66:	fae793e3          	bne	a5,a4,80005f0c <exec+0x4ec>
    if(ph.memsz < ph.filesz)
    80005f6a:	e3843603          	ld	a2,-456(s0)
    80005f6e:	e3043783          	ld	a5,-464(s0)
    80005f72:	f4f665e3          	bltu	a2,a5,80005ebc <exec+0x49c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005f76:	e2043783          	ld	a5,-480(s0)
    80005f7a:	963e                	add	a2,a2,a5
    80005f7c:	f4f666e3          	bltu	a2,a5,80005ec8 <exec+0x4a8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005f80:	85a6                	mv	a1,s1
    80005f82:	855a                	mv	a0,s6
    80005f84:	ffffb097          	auipc	ra,0xffffb
    80005f88:	59e080e7          	jalr	1438(ra) # 80001522 <uvmalloc>
    80005f8c:	7c890713          	addi	a4,s2,1992
    80005f90:	9722                	add	a4,a4,s0
    80005f92:	e308                	sd	a0,0(a4)
    80005f94:	d121                	beqz	a0,80005ed4 <exec+0x4b4>
    if(ph.vaddr % PGSIZE != 0)
    80005f96:	e2043c03          	ld	s8,-480(s0)
    80005f9a:	7b890793          	addi	a5,s2,1976
    80005f9e:	97a2                	add	a5,a5,s0
    80005fa0:	639c                	ld	a5,0(a5)
    80005fa2:	00fc77b3          	and	a5,s8,a5
    80005fa6:	e2079ee3          	bnez	a5,80005de2 <exec+0x3c2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005faa:	e1842c83          	lw	s9,-488(s0)
    80005fae:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005fb2:	f40b88e3          	beqz	s7,80005f02 <exec+0x4e2>
    80005fb6:	89de                	mv	s3,s7
    80005fb8:	4481                	li	s1,0
    80005fba:	b13d                	j	80005be8 <exec+0x1c8>

0000000080005fbc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005fbc:	7179                	addi	sp,sp,-48
    80005fbe:	f406                	sd	ra,40(sp)
    80005fc0:	f022                	sd	s0,32(sp)
    80005fc2:	ec26                	sd	s1,24(sp)
    80005fc4:	e84a                	sd	s2,16(sp)
    80005fc6:	1800                	addi	s0,sp,48
    80005fc8:	892e                	mv	s2,a1
    80005fca:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005fcc:	fdc40593          	addi	a1,s0,-36
    80005fd0:	ffffd097          	auipc	ra,0xffffd
    80005fd4:	4ca080e7          	jalr	1226(ra) # 8000349a <argint>
    80005fd8:	04054063          	bltz	a0,80006018 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005fdc:	fdc42703          	lw	a4,-36(s0)
    80005fe0:	47bd                	li	a5,15
    80005fe2:	02e7ed63          	bltu	a5,a4,8000601c <argfd+0x60>
    80005fe6:	ffffc097          	auipc	ra,0xffffc
    80005fea:	b82080e7          	jalr	-1150(ra) # 80001b68 <myproc>
    80005fee:	fdc42703          	lw	a4,-36(s0)
    80005ff2:	01a70793          	addi	a5,a4,26
    80005ff6:	078e                	slli	a5,a5,0x3
    80005ff8:	953e                	add	a0,a0,a5
    80005ffa:	611c                	ld	a5,0(a0)
    80005ffc:	c395                	beqz	a5,80006020 <argfd+0x64>
    return -1;
  if(pfd)
    80005ffe:	00090463          	beqz	s2,80006006 <argfd+0x4a>
    *pfd = fd;
    80006002:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006006:	4501                	li	a0,0
  if(pf)
    80006008:	c091                	beqz	s1,8000600c <argfd+0x50>
    *pf = f;
    8000600a:	e09c                	sd	a5,0(s1)
}
    8000600c:	70a2                	ld	ra,40(sp)
    8000600e:	7402                	ld	s0,32(sp)
    80006010:	64e2                	ld	s1,24(sp)
    80006012:	6942                	ld	s2,16(sp)
    80006014:	6145                	addi	sp,sp,48
    80006016:	8082                	ret
    return -1;
    80006018:	557d                	li	a0,-1
    8000601a:	bfcd                	j	8000600c <argfd+0x50>
    return -1;
    8000601c:	557d                	li	a0,-1
    8000601e:	b7fd                	j	8000600c <argfd+0x50>
    80006020:	557d                	li	a0,-1
    80006022:	b7ed                	j	8000600c <argfd+0x50>

0000000080006024 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006024:	1101                	addi	sp,sp,-32
    80006026:	ec06                	sd	ra,24(sp)
    80006028:	e822                	sd	s0,16(sp)
    8000602a:	e426                	sd	s1,8(sp)
    8000602c:	1000                	addi	s0,sp,32
    8000602e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80006030:	ffffc097          	auipc	ra,0xffffc
    80006034:	b38080e7          	jalr	-1224(ra) # 80001b68 <myproc>
    80006038:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000603a:	0d050793          	addi	a5,a0,208
    8000603e:	4501                	li	a0,0
    80006040:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80006042:	6398                	ld	a4,0(a5)
    80006044:	cb19                	beqz	a4,8000605a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006046:	2505                	addiw	a0,a0,1
    80006048:	07a1                	addi	a5,a5,8
    8000604a:	fed51ce3          	bne	a0,a3,80006042 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000604e:	557d                	li	a0,-1
}
    80006050:	60e2                	ld	ra,24(sp)
    80006052:	6442                	ld	s0,16(sp)
    80006054:	64a2                	ld	s1,8(sp)
    80006056:	6105                	addi	sp,sp,32
    80006058:	8082                	ret
      p->ofile[fd] = f;
    8000605a:	01a50793          	addi	a5,a0,26
    8000605e:	078e                	slli	a5,a5,0x3
    80006060:	963e                	add	a2,a2,a5
    80006062:	e204                	sd	s1,0(a2)
      return fd;
    80006064:	b7f5                	j	80006050 <fdalloc+0x2c>

0000000080006066 <sys_dup>:

uint64
sys_dup(void)
{
    80006066:	7179                	addi	sp,sp,-48
    80006068:	f406                	sd	ra,40(sp)
    8000606a:	f022                	sd	s0,32(sp)
    8000606c:	ec26                	sd	s1,24(sp)
    8000606e:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80006070:	fd840613          	addi	a2,s0,-40
    80006074:	4581                	li	a1,0
    80006076:	4501                	li	a0,0
    80006078:	00000097          	auipc	ra,0x0
    8000607c:	f44080e7          	jalr	-188(ra) # 80005fbc <argfd>
    return -1;
    80006080:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006082:	02054363          	bltz	a0,800060a8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006086:	fd843503          	ld	a0,-40(s0)
    8000608a:	00000097          	auipc	ra,0x0
    8000608e:	f9a080e7          	jalr	-102(ra) # 80006024 <fdalloc>
    80006092:	84aa                	mv	s1,a0
    return -1;
    80006094:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006096:	00054963          	bltz	a0,800060a8 <sys_dup+0x42>
  filedup(f);
    8000609a:	fd843503          	ld	a0,-40(s0)
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	0e8080e7          	jalr	232(ra) # 80005186 <filedup>
  return fd;
    800060a6:	87a6                	mv	a5,s1
}
    800060a8:	853e                	mv	a0,a5
    800060aa:	70a2                	ld	ra,40(sp)
    800060ac:	7402                	ld	s0,32(sp)
    800060ae:	64e2                	ld	s1,24(sp)
    800060b0:	6145                	addi	sp,sp,48
    800060b2:	8082                	ret

00000000800060b4 <sys_read>:

uint64
sys_read(void)
{
    800060b4:	7179                	addi	sp,sp,-48
    800060b6:	f406                	sd	ra,40(sp)
    800060b8:	f022                	sd	s0,32(sp)
    800060ba:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060bc:	fe840613          	addi	a2,s0,-24
    800060c0:	4581                	li	a1,0
    800060c2:	4501                	li	a0,0
    800060c4:	00000097          	auipc	ra,0x0
    800060c8:	ef8080e7          	jalr	-264(ra) # 80005fbc <argfd>
    return -1;
    800060cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060ce:	04054163          	bltz	a0,80006110 <sys_read+0x5c>
    800060d2:	fe440593          	addi	a1,s0,-28
    800060d6:	4509                	li	a0,2
    800060d8:	ffffd097          	auipc	ra,0xffffd
    800060dc:	3c2080e7          	jalr	962(ra) # 8000349a <argint>
    return -1;
    800060e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060e2:	02054763          	bltz	a0,80006110 <sys_read+0x5c>
    800060e6:	fd840593          	addi	a1,s0,-40
    800060ea:	4505                	li	a0,1
    800060ec:	ffffd097          	auipc	ra,0xffffd
    800060f0:	3d0080e7          	jalr	976(ra) # 800034bc <argaddr>
    return -1;
    800060f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060f6:	00054d63          	bltz	a0,80006110 <sys_read+0x5c>
  return fileread(f, p, n);
    800060fa:	fe442603          	lw	a2,-28(s0)
    800060fe:	fd843583          	ld	a1,-40(s0)
    80006102:	fe843503          	ld	a0,-24(s0)
    80006106:	fffff097          	auipc	ra,0xfffff
    8000610a:	20c080e7          	jalr	524(ra) # 80005312 <fileread>
    8000610e:	87aa                	mv	a5,a0
}
    80006110:	853e                	mv	a0,a5
    80006112:	70a2                	ld	ra,40(sp)
    80006114:	7402                	ld	s0,32(sp)
    80006116:	6145                	addi	sp,sp,48
    80006118:	8082                	ret

000000008000611a <sys_write>:

uint64
sys_write(void)
{
    8000611a:	7179                	addi	sp,sp,-48
    8000611c:	f406                	sd	ra,40(sp)
    8000611e:	f022                	sd	s0,32(sp)
    80006120:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006122:	fe840613          	addi	a2,s0,-24
    80006126:	4581                	li	a1,0
    80006128:	4501                	li	a0,0
    8000612a:	00000097          	auipc	ra,0x0
    8000612e:	e92080e7          	jalr	-366(ra) # 80005fbc <argfd>
    return -1;
    80006132:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006134:	04054163          	bltz	a0,80006176 <sys_write+0x5c>
    80006138:	fe440593          	addi	a1,s0,-28
    8000613c:	4509                	li	a0,2
    8000613e:	ffffd097          	auipc	ra,0xffffd
    80006142:	35c080e7          	jalr	860(ra) # 8000349a <argint>
    return -1;
    80006146:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006148:	02054763          	bltz	a0,80006176 <sys_write+0x5c>
    8000614c:	fd840593          	addi	a1,s0,-40
    80006150:	4505                	li	a0,1
    80006152:	ffffd097          	auipc	ra,0xffffd
    80006156:	36a080e7          	jalr	874(ra) # 800034bc <argaddr>
    return -1;
    8000615a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000615c:	00054d63          	bltz	a0,80006176 <sys_write+0x5c>

  return filewrite(f, p, n);
    80006160:	fe442603          	lw	a2,-28(s0)
    80006164:	fd843583          	ld	a1,-40(s0)
    80006168:	fe843503          	ld	a0,-24(s0)
    8000616c:	fffff097          	auipc	ra,0xfffff
    80006170:	268080e7          	jalr	616(ra) # 800053d4 <filewrite>
    80006174:	87aa                	mv	a5,a0
}
    80006176:	853e                	mv	a0,a5
    80006178:	70a2                	ld	ra,40(sp)
    8000617a:	7402                	ld	s0,32(sp)
    8000617c:	6145                	addi	sp,sp,48
    8000617e:	8082                	ret

0000000080006180 <sys_close>:

uint64
sys_close(void)
{
    80006180:	1101                	addi	sp,sp,-32
    80006182:	ec06                	sd	ra,24(sp)
    80006184:	e822                	sd	s0,16(sp)
    80006186:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80006188:	fe040613          	addi	a2,s0,-32
    8000618c:	fec40593          	addi	a1,s0,-20
    80006190:	4501                	li	a0,0
    80006192:	00000097          	auipc	ra,0x0
    80006196:	e2a080e7          	jalr	-470(ra) # 80005fbc <argfd>
    return -1;
    8000619a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000619c:	02054463          	bltz	a0,800061c4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800061a0:	ffffc097          	auipc	ra,0xffffc
    800061a4:	9c8080e7          	jalr	-1592(ra) # 80001b68 <myproc>
    800061a8:	fec42783          	lw	a5,-20(s0)
    800061ac:	07e9                	addi	a5,a5,26
    800061ae:	078e                	slli	a5,a5,0x3
    800061b0:	97aa                	add	a5,a5,a0
    800061b2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800061b6:	fe043503          	ld	a0,-32(s0)
    800061ba:	fffff097          	auipc	ra,0xfffff
    800061be:	01e080e7          	jalr	30(ra) # 800051d8 <fileclose>
  return 0;
    800061c2:	4781                	li	a5,0
}
    800061c4:	853e                	mv	a0,a5
    800061c6:	60e2                	ld	ra,24(sp)
    800061c8:	6442                	ld	s0,16(sp)
    800061ca:	6105                	addi	sp,sp,32
    800061cc:	8082                	ret

00000000800061ce <sys_fstat>:

uint64
sys_fstat(void)
{
    800061ce:	1101                	addi	sp,sp,-32
    800061d0:	ec06                	sd	ra,24(sp)
    800061d2:	e822                	sd	s0,16(sp)
    800061d4:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061d6:	fe840613          	addi	a2,s0,-24
    800061da:	4581                	li	a1,0
    800061dc:	4501                	li	a0,0
    800061de:	00000097          	auipc	ra,0x0
    800061e2:	dde080e7          	jalr	-546(ra) # 80005fbc <argfd>
    return -1;
    800061e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061e8:	02054563          	bltz	a0,80006212 <sys_fstat+0x44>
    800061ec:	fe040593          	addi	a1,s0,-32
    800061f0:	4505                	li	a0,1
    800061f2:	ffffd097          	auipc	ra,0xffffd
    800061f6:	2ca080e7          	jalr	714(ra) # 800034bc <argaddr>
    return -1;
    800061fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061fc:	00054b63          	bltz	a0,80006212 <sys_fstat+0x44>
  return filestat(f, st);
    80006200:	fe043583          	ld	a1,-32(s0)
    80006204:	fe843503          	ld	a0,-24(s0)
    80006208:	fffff097          	auipc	ra,0xfffff
    8000620c:	098080e7          	jalr	152(ra) # 800052a0 <filestat>
    80006210:	87aa                	mv	a5,a0
}
    80006212:	853e                	mv	a0,a5
    80006214:	60e2                	ld	ra,24(sp)
    80006216:	6442                	ld	s0,16(sp)
    80006218:	6105                	addi	sp,sp,32
    8000621a:	8082                	ret

000000008000621c <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    8000621c:	7169                	addi	sp,sp,-304
    8000621e:	f606                	sd	ra,296(sp)
    80006220:	f222                	sd	s0,288(sp)
    80006222:	ee26                	sd	s1,280(sp)
    80006224:	ea4a                	sd	s2,272(sp)
    80006226:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006228:	08000613          	li	a2,128
    8000622c:	ed040593          	addi	a1,s0,-304
    80006230:	4501                	li	a0,0
    80006232:	ffffd097          	auipc	ra,0xffffd
    80006236:	2ac080e7          	jalr	684(ra) # 800034de <argstr>
    return -1;
    8000623a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000623c:	10054e63          	bltz	a0,80006358 <sys_link+0x13c>
    80006240:	08000613          	li	a2,128
    80006244:	f5040593          	addi	a1,s0,-176
    80006248:	4505                	li	a0,1
    8000624a:	ffffd097          	auipc	ra,0xffffd
    8000624e:	294080e7          	jalr	660(ra) # 800034de <argstr>
    return -1;
    80006252:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006254:	10054263          	bltz	a0,80006358 <sys_link+0x13c>

  begin_op();
    80006258:	fffff097          	auipc	ra,0xfffff
    8000625c:	ab4080e7          	jalr	-1356(ra) # 80004d0c <begin_op>
  if((ip = namei(old)) == 0){
    80006260:	ed040513          	addi	a0,s0,-304
    80006264:	ffffe097          	auipc	ra,0xffffe
    80006268:	576080e7          	jalr	1398(ra) # 800047da <namei>
    8000626c:	84aa                	mv	s1,a0
    8000626e:	c551                	beqz	a0,800062fa <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    80006270:	ffffe097          	auipc	ra,0xffffe
    80006274:	db4080e7          	jalr	-588(ra) # 80004024 <ilock>
  if(ip->type == T_DIR){
    80006278:	04449703          	lh	a4,68(s1)
    8000627c:	4785                	li	a5,1
    8000627e:	08f70463          	beq	a4,a5,80006306 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006282:	04a4d783          	lhu	a5,74(s1)
    80006286:	2785                	addiw	a5,a5,1
    80006288:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000628c:	8526                	mv	a0,s1
    8000628e:	ffffe097          	auipc	ra,0xffffe
    80006292:	ccc080e7          	jalr	-820(ra) # 80003f5a <iupdate>
  iunlock(ip);
    80006296:	8526                	mv	a0,s1
    80006298:	ffffe097          	auipc	ra,0xffffe
    8000629c:	e4e080e7          	jalr	-434(ra) # 800040e6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    800062a0:	fd040593          	addi	a1,s0,-48
    800062a4:	f5040513          	addi	a0,s0,-176
    800062a8:	ffffe097          	auipc	ra,0xffffe
    800062ac:	550080e7          	jalr	1360(ra) # 800047f8 <nameiparent>
    800062b0:	892a                	mv	s2,a0
    800062b2:	c935                	beqz	a0,80006326 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    800062b4:	ffffe097          	auipc	ra,0xffffe
    800062b8:	d70080e7          	jalr	-656(ra) # 80004024 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800062bc:	00092703          	lw	a4,0(s2)
    800062c0:	409c                	lw	a5,0(s1)
    800062c2:	04f71d63          	bne	a4,a5,8000631c <sys_link+0x100>
    800062c6:	40d0                	lw	a2,4(s1)
    800062c8:	fd040593          	addi	a1,s0,-48
    800062cc:	854a                	mv	a0,s2
    800062ce:	ffffe097          	auipc	ra,0xffffe
    800062d2:	44a080e7          	jalr	1098(ra) # 80004718 <dirlink>
    800062d6:	04054363          	bltz	a0,8000631c <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800062da:	854a                	mv	a0,s2
    800062dc:	ffffe097          	auipc	ra,0xffffe
    800062e0:	faa080e7          	jalr	-86(ra) # 80004286 <iunlockput>
  iput(ip);
    800062e4:	8526                	mv	a0,s1
    800062e6:	ffffe097          	auipc	ra,0xffffe
    800062ea:	ef8080e7          	jalr	-264(ra) # 800041de <iput>

  end_op();
    800062ee:	fffff097          	auipc	ra,0xfffff
    800062f2:	a9e080e7          	jalr	-1378(ra) # 80004d8c <end_op>

  return 0;
    800062f6:	4781                	li	a5,0
    800062f8:	a085                	j	80006358 <sys_link+0x13c>
    end_op();
    800062fa:	fffff097          	auipc	ra,0xfffff
    800062fe:	a92080e7          	jalr	-1390(ra) # 80004d8c <end_op>
    return -1;
    80006302:	57fd                	li	a5,-1
    80006304:	a891                	j	80006358 <sys_link+0x13c>
    iunlockput(ip);
    80006306:	8526                	mv	a0,s1
    80006308:	ffffe097          	auipc	ra,0xffffe
    8000630c:	f7e080e7          	jalr	-130(ra) # 80004286 <iunlockput>
    end_op();
    80006310:	fffff097          	auipc	ra,0xfffff
    80006314:	a7c080e7          	jalr	-1412(ra) # 80004d8c <end_op>
    return -1;
    80006318:	57fd                	li	a5,-1
    8000631a:	a83d                	j	80006358 <sys_link+0x13c>
    iunlockput(dp);
    8000631c:	854a                	mv	a0,s2
    8000631e:	ffffe097          	auipc	ra,0xffffe
    80006322:	f68080e7          	jalr	-152(ra) # 80004286 <iunlockput>

bad:
  ilock(ip);
    80006326:	8526                	mv	a0,s1
    80006328:	ffffe097          	auipc	ra,0xffffe
    8000632c:	cfc080e7          	jalr	-772(ra) # 80004024 <ilock>
  ip->nlink--;
    80006330:	04a4d783          	lhu	a5,74(s1)
    80006334:	37fd                	addiw	a5,a5,-1
    80006336:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000633a:	8526                	mv	a0,s1
    8000633c:	ffffe097          	auipc	ra,0xffffe
    80006340:	c1e080e7          	jalr	-994(ra) # 80003f5a <iupdate>
  iunlockput(ip);
    80006344:	8526                	mv	a0,s1
    80006346:	ffffe097          	auipc	ra,0xffffe
    8000634a:	f40080e7          	jalr	-192(ra) # 80004286 <iunlockput>
  end_op();
    8000634e:	fffff097          	auipc	ra,0xfffff
    80006352:	a3e080e7          	jalr	-1474(ra) # 80004d8c <end_op>
  return -1;
    80006356:	57fd                	li	a5,-1
}
    80006358:	853e                	mv	a0,a5
    8000635a:	70b2                	ld	ra,296(sp)
    8000635c:	7412                	ld	s0,288(sp)
    8000635e:	64f2                	ld	s1,280(sp)
    80006360:	6952                	ld	s2,272(sp)
    80006362:	6155                	addi	sp,sp,304
    80006364:	8082                	ret

0000000080006366 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006366:	4578                	lw	a4,76(a0)
    80006368:	02000793          	li	a5,32
    8000636c:	04e7fa63          	bgeu	a5,a4,800063c0 <isdirempty+0x5a>
{
    80006370:	7179                	addi	sp,sp,-48
    80006372:	f406                	sd	ra,40(sp)
    80006374:	f022                	sd	s0,32(sp)
    80006376:	ec26                	sd	s1,24(sp)
    80006378:	e84a                	sd	s2,16(sp)
    8000637a:	1800                	addi	s0,sp,48
    8000637c:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000637e:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006382:	4741                	li	a4,16
    80006384:	86a6                	mv	a3,s1
    80006386:	fd040613          	addi	a2,s0,-48
    8000638a:	4581                	li	a1,0
    8000638c:	854a                	mv	a0,s2
    8000638e:	ffffe097          	auipc	ra,0xffffe
    80006392:	f4a080e7          	jalr	-182(ra) # 800042d8 <readi>
    80006396:	47c1                	li	a5,16
    80006398:	00f51c63          	bne	a0,a5,800063b0 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    8000639c:	fd045783          	lhu	a5,-48(s0)
    800063a0:	e395                	bnez	a5,800063c4 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800063a2:	24c1                	addiw	s1,s1,16
    800063a4:	04c92783          	lw	a5,76(s2)
    800063a8:	fcf4ede3          	bltu	s1,a5,80006382 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    800063ac:	4505                	li	a0,1
    800063ae:	a821                	j	800063c6 <isdirempty+0x60>
      panic("isdirempty: readi");
    800063b0:	00003517          	auipc	a0,0x3
    800063b4:	64050513          	addi	a0,a0,1600 # 800099f0 <syscalls+0x338>
    800063b8:	ffffa097          	auipc	ra,0xffffa
    800063bc:	172080e7          	jalr	370(ra) # 8000052a <panic>
  return 1;
    800063c0:	4505                	li	a0,1
}
    800063c2:	8082                	ret
      return 0;
    800063c4:	4501                	li	a0,0
}
    800063c6:	70a2                	ld	ra,40(sp)
    800063c8:	7402                	ld	s0,32(sp)
    800063ca:	64e2                	ld	s1,24(sp)
    800063cc:	6942                	ld	s2,16(sp)
    800063ce:	6145                	addi	sp,sp,48
    800063d0:	8082                	ret

00000000800063d2 <sys_unlink>:

uint64
sys_unlink(void)
{
    800063d2:	7155                	addi	sp,sp,-208
    800063d4:	e586                	sd	ra,200(sp)
    800063d6:	e1a2                	sd	s0,192(sp)
    800063d8:	fd26                	sd	s1,184(sp)
    800063da:	f94a                	sd	s2,176(sp)
    800063dc:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800063de:	08000613          	li	a2,128
    800063e2:	f4040593          	addi	a1,s0,-192
    800063e6:	4501                	li	a0,0
    800063e8:	ffffd097          	auipc	ra,0xffffd
    800063ec:	0f6080e7          	jalr	246(ra) # 800034de <argstr>
    800063f0:	16054363          	bltz	a0,80006556 <sys_unlink+0x184>
    return -1;

  begin_op();
    800063f4:	fffff097          	auipc	ra,0xfffff
    800063f8:	918080e7          	jalr	-1768(ra) # 80004d0c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800063fc:	fc040593          	addi	a1,s0,-64
    80006400:	f4040513          	addi	a0,s0,-192
    80006404:	ffffe097          	auipc	ra,0xffffe
    80006408:	3f4080e7          	jalr	1012(ra) # 800047f8 <nameiparent>
    8000640c:	84aa                	mv	s1,a0
    8000640e:	c961                	beqz	a0,800064de <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    80006410:	ffffe097          	auipc	ra,0xffffe
    80006414:	c14080e7          	jalr	-1004(ra) # 80004024 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006418:	00003597          	auipc	a1,0x3
    8000641c:	49858593          	addi	a1,a1,1176 # 800098b0 <syscalls+0x1f8>
    80006420:	fc040513          	addi	a0,s0,-64
    80006424:	ffffe097          	auipc	ra,0xffffe
    80006428:	0ca080e7          	jalr	202(ra) # 800044ee <namecmp>
    8000642c:	c175                	beqz	a0,80006510 <sys_unlink+0x13e>
    8000642e:	00003597          	auipc	a1,0x3
    80006432:	48a58593          	addi	a1,a1,1162 # 800098b8 <syscalls+0x200>
    80006436:	fc040513          	addi	a0,s0,-64
    8000643a:	ffffe097          	auipc	ra,0xffffe
    8000643e:	0b4080e7          	jalr	180(ra) # 800044ee <namecmp>
    80006442:	c579                	beqz	a0,80006510 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006444:	f3c40613          	addi	a2,s0,-196
    80006448:	fc040593          	addi	a1,s0,-64
    8000644c:	8526                	mv	a0,s1
    8000644e:	ffffe097          	auipc	ra,0xffffe
    80006452:	0ba080e7          	jalr	186(ra) # 80004508 <dirlookup>
    80006456:	892a                	mv	s2,a0
    80006458:	cd45                	beqz	a0,80006510 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    8000645a:	ffffe097          	auipc	ra,0xffffe
    8000645e:	bca080e7          	jalr	-1078(ra) # 80004024 <ilock>

  if(ip->nlink < 1)
    80006462:	04a91783          	lh	a5,74(s2)
    80006466:	08f05263          	blez	a5,800064ea <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000646a:	04491703          	lh	a4,68(s2)
    8000646e:	4785                	li	a5,1
    80006470:	08f70563          	beq	a4,a5,800064fa <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006474:	4641                	li	a2,16
    80006476:	4581                	li	a1,0
    80006478:	fd040513          	addi	a0,s0,-48
    8000647c:	ffffb097          	auipc	ra,0xffffb
    80006480:	842080e7          	jalr	-1982(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006484:	4741                	li	a4,16
    80006486:	f3c42683          	lw	a3,-196(s0)
    8000648a:	fd040613          	addi	a2,s0,-48
    8000648e:	4581                	li	a1,0
    80006490:	8526                	mv	a0,s1
    80006492:	ffffe097          	auipc	ra,0xffffe
    80006496:	f3e080e7          	jalr	-194(ra) # 800043d0 <writei>
    8000649a:	47c1                	li	a5,16
    8000649c:	08f51a63          	bne	a0,a5,80006530 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800064a0:	04491703          	lh	a4,68(s2)
    800064a4:	4785                	li	a5,1
    800064a6:	08f70d63          	beq	a4,a5,80006540 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800064aa:	8526                	mv	a0,s1
    800064ac:	ffffe097          	auipc	ra,0xffffe
    800064b0:	dda080e7          	jalr	-550(ra) # 80004286 <iunlockput>

  ip->nlink--;
    800064b4:	04a95783          	lhu	a5,74(s2)
    800064b8:	37fd                	addiw	a5,a5,-1
    800064ba:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800064be:	854a                	mv	a0,s2
    800064c0:	ffffe097          	auipc	ra,0xffffe
    800064c4:	a9a080e7          	jalr	-1382(ra) # 80003f5a <iupdate>
  iunlockput(ip);
    800064c8:	854a                	mv	a0,s2
    800064ca:	ffffe097          	auipc	ra,0xffffe
    800064ce:	dbc080e7          	jalr	-580(ra) # 80004286 <iunlockput>

  end_op();
    800064d2:	fffff097          	auipc	ra,0xfffff
    800064d6:	8ba080e7          	jalr	-1862(ra) # 80004d8c <end_op>

  return 0;
    800064da:	4501                	li	a0,0
    800064dc:	a0a1                	j	80006524 <sys_unlink+0x152>
    end_op();
    800064de:	fffff097          	auipc	ra,0xfffff
    800064e2:	8ae080e7          	jalr	-1874(ra) # 80004d8c <end_op>
    return -1;
    800064e6:	557d                	li	a0,-1
    800064e8:	a835                	j	80006524 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800064ea:	00003517          	auipc	a0,0x3
    800064ee:	3d650513          	addi	a0,a0,982 # 800098c0 <syscalls+0x208>
    800064f2:	ffffa097          	auipc	ra,0xffffa
    800064f6:	038080e7          	jalr	56(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800064fa:	854a                	mv	a0,s2
    800064fc:	00000097          	auipc	ra,0x0
    80006500:	e6a080e7          	jalr	-406(ra) # 80006366 <isdirempty>
    80006504:	f925                	bnez	a0,80006474 <sys_unlink+0xa2>
    iunlockput(ip);
    80006506:	854a                	mv	a0,s2
    80006508:	ffffe097          	auipc	ra,0xffffe
    8000650c:	d7e080e7          	jalr	-642(ra) # 80004286 <iunlockput>

bad:
  iunlockput(dp);
    80006510:	8526                	mv	a0,s1
    80006512:	ffffe097          	auipc	ra,0xffffe
    80006516:	d74080e7          	jalr	-652(ra) # 80004286 <iunlockput>
  end_op();
    8000651a:	fffff097          	auipc	ra,0xfffff
    8000651e:	872080e7          	jalr	-1934(ra) # 80004d8c <end_op>
  return -1;
    80006522:	557d                	li	a0,-1
}
    80006524:	60ae                	ld	ra,200(sp)
    80006526:	640e                	ld	s0,192(sp)
    80006528:	74ea                	ld	s1,184(sp)
    8000652a:	794a                	ld	s2,176(sp)
    8000652c:	6169                	addi	sp,sp,208
    8000652e:	8082                	ret
    panic("unlink: writei");
    80006530:	00003517          	auipc	a0,0x3
    80006534:	3a850513          	addi	a0,a0,936 # 800098d8 <syscalls+0x220>
    80006538:	ffffa097          	auipc	ra,0xffffa
    8000653c:	ff2080e7          	jalr	-14(ra) # 8000052a <panic>
    dp->nlink--;
    80006540:	04a4d783          	lhu	a5,74(s1)
    80006544:	37fd                	addiw	a5,a5,-1
    80006546:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000654a:	8526                	mv	a0,s1
    8000654c:	ffffe097          	auipc	ra,0xffffe
    80006550:	a0e080e7          	jalr	-1522(ra) # 80003f5a <iupdate>
    80006554:	bf99                	j	800064aa <sys_unlink+0xd8>
    return -1;
    80006556:	557d                	li	a0,-1
    80006558:	b7f1                	j	80006524 <sys_unlink+0x152>

000000008000655a <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    8000655a:	715d                	addi	sp,sp,-80
    8000655c:	e486                	sd	ra,72(sp)
    8000655e:	e0a2                	sd	s0,64(sp)
    80006560:	fc26                	sd	s1,56(sp)
    80006562:	f84a                	sd	s2,48(sp)
    80006564:	f44e                	sd	s3,40(sp)
    80006566:	f052                	sd	s4,32(sp)
    80006568:	ec56                	sd	s5,24(sp)
    8000656a:	0880                	addi	s0,sp,80
    8000656c:	89ae                	mv	s3,a1
    8000656e:	8ab2                	mv	s5,a2
    80006570:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006572:	fb040593          	addi	a1,s0,-80
    80006576:	ffffe097          	auipc	ra,0xffffe
    8000657a:	282080e7          	jalr	642(ra) # 800047f8 <nameiparent>
    8000657e:	892a                	mv	s2,a0
    80006580:	12050e63          	beqz	a0,800066bc <create+0x162>
    return 0;

  ilock(dp);
    80006584:	ffffe097          	auipc	ra,0xffffe
    80006588:	aa0080e7          	jalr	-1376(ra) # 80004024 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000658c:	4601                	li	a2,0
    8000658e:	fb040593          	addi	a1,s0,-80
    80006592:	854a                	mv	a0,s2
    80006594:	ffffe097          	auipc	ra,0xffffe
    80006598:	f74080e7          	jalr	-140(ra) # 80004508 <dirlookup>
    8000659c:	84aa                	mv	s1,a0
    8000659e:	c921                	beqz	a0,800065ee <create+0x94>
    iunlockput(dp);
    800065a0:	854a                	mv	a0,s2
    800065a2:	ffffe097          	auipc	ra,0xffffe
    800065a6:	ce4080e7          	jalr	-796(ra) # 80004286 <iunlockput>
    ilock(ip);
    800065aa:	8526                	mv	a0,s1
    800065ac:	ffffe097          	auipc	ra,0xffffe
    800065b0:	a78080e7          	jalr	-1416(ra) # 80004024 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800065b4:	2981                	sext.w	s3,s3
    800065b6:	4789                	li	a5,2
    800065b8:	02f99463          	bne	s3,a5,800065e0 <create+0x86>
    800065bc:	0444d783          	lhu	a5,68(s1)
    800065c0:	37f9                	addiw	a5,a5,-2
    800065c2:	17c2                	slli	a5,a5,0x30
    800065c4:	93c1                	srli	a5,a5,0x30
    800065c6:	4705                	li	a4,1
    800065c8:	00f76c63          	bltu	a4,a5,800065e0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800065cc:	8526                	mv	a0,s1
    800065ce:	60a6                	ld	ra,72(sp)
    800065d0:	6406                	ld	s0,64(sp)
    800065d2:	74e2                	ld	s1,56(sp)
    800065d4:	7942                	ld	s2,48(sp)
    800065d6:	79a2                	ld	s3,40(sp)
    800065d8:	7a02                	ld	s4,32(sp)
    800065da:	6ae2                	ld	s5,24(sp)
    800065dc:	6161                	addi	sp,sp,80
    800065de:	8082                	ret
    iunlockput(ip);
    800065e0:	8526                	mv	a0,s1
    800065e2:	ffffe097          	auipc	ra,0xffffe
    800065e6:	ca4080e7          	jalr	-860(ra) # 80004286 <iunlockput>
    return 0;
    800065ea:	4481                	li	s1,0
    800065ec:	b7c5                	j	800065cc <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800065ee:	85ce                	mv	a1,s3
    800065f0:	00092503          	lw	a0,0(s2)
    800065f4:	ffffe097          	auipc	ra,0xffffe
    800065f8:	898080e7          	jalr	-1896(ra) # 80003e8c <ialloc>
    800065fc:	84aa                	mv	s1,a0
    800065fe:	c521                	beqz	a0,80006646 <create+0xec>
  ilock(ip);
    80006600:	ffffe097          	auipc	ra,0xffffe
    80006604:	a24080e7          	jalr	-1500(ra) # 80004024 <ilock>
  ip->major = major;
    80006608:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000660c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006610:	4a05                	li	s4,1
    80006612:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006616:	8526                	mv	a0,s1
    80006618:	ffffe097          	auipc	ra,0xffffe
    8000661c:	942080e7          	jalr	-1726(ra) # 80003f5a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006620:	2981                	sext.w	s3,s3
    80006622:	03498a63          	beq	s3,s4,80006656 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006626:	40d0                	lw	a2,4(s1)
    80006628:	fb040593          	addi	a1,s0,-80
    8000662c:	854a                	mv	a0,s2
    8000662e:	ffffe097          	auipc	ra,0xffffe
    80006632:	0ea080e7          	jalr	234(ra) # 80004718 <dirlink>
    80006636:	06054b63          	bltz	a0,800066ac <create+0x152>
  iunlockput(dp);
    8000663a:	854a                	mv	a0,s2
    8000663c:	ffffe097          	auipc	ra,0xffffe
    80006640:	c4a080e7          	jalr	-950(ra) # 80004286 <iunlockput>
  return ip;
    80006644:	b761                	j	800065cc <create+0x72>
    panic("create: ialloc");
    80006646:	00003517          	auipc	a0,0x3
    8000664a:	3c250513          	addi	a0,a0,962 # 80009a08 <syscalls+0x350>
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	edc080e7          	jalr	-292(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006656:	04a95783          	lhu	a5,74(s2)
    8000665a:	2785                	addiw	a5,a5,1
    8000665c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006660:	854a                	mv	a0,s2
    80006662:	ffffe097          	auipc	ra,0xffffe
    80006666:	8f8080e7          	jalr	-1800(ra) # 80003f5a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000666a:	40d0                	lw	a2,4(s1)
    8000666c:	00003597          	auipc	a1,0x3
    80006670:	24458593          	addi	a1,a1,580 # 800098b0 <syscalls+0x1f8>
    80006674:	8526                	mv	a0,s1
    80006676:	ffffe097          	auipc	ra,0xffffe
    8000667a:	0a2080e7          	jalr	162(ra) # 80004718 <dirlink>
    8000667e:	00054f63          	bltz	a0,8000669c <create+0x142>
    80006682:	00492603          	lw	a2,4(s2)
    80006686:	00003597          	auipc	a1,0x3
    8000668a:	23258593          	addi	a1,a1,562 # 800098b8 <syscalls+0x200>
    8000668e:	8526                	mv	a0,s1
    80006690:	ffffe097          	auipc	ra,0xffffe
    80006694:	088080e7          	jalr	136(ra) # 80004718 <dirlink>
    80006698:	f80557e3          	bgez	a0,80006626 <create+0xcc>
      panic("create dots");
    8000669c:	00003517          	auipc	a0,0x3
    800066a0:	37c50513          	addi	a0,a0,892 # 80009a18 <syscalls+0x360>
    800066a4:	ffffa097          	auipc	ra,0xffffa
    800066a8:	e86080e7          	jalr	-378(ra) # 8000052a <panic>
    panic("create: dirlink");
    800066ac:	00003517          	auipc	a0,0x3
    800066b0:	37c50513          	addi	a0,a0,892 # 80009a28 <syscalls+0x370>
    800066b4:	ffffa097          	auipc	ra,0xffffa
    800066b8:	e76080e7          	jalr	-394(ra) # 8000052a <panic>
    return 0;
    800066bc:	84aa                	mv	s1,a0
    800066be:	b739                	j	800065cc <create+0x72>

00000000800066c0 <sys_open>:

uint64
sys_open(void)
{
    800066c0:	7131                	addi	sp,sp,-192
    800066c2:	fd06                	sd	ra,184(sp)
    800066c4:	f922                	sd	s0,176(sp)
    800066c6:	f526                	sd	s1,168(sp)
    800066c8:	f14a                	sd	s2,160(sp)
    800066ca:	ed4e                	sd	s3,152(sp)
    800066cc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800066ce:	08000613          	li	a2,128
    800066d2:	f5040593          	addi	a1,s0,-176
    800066d6:	4501                	li	a0,0
    800066d8:	ffffd097          	auipc	ra,0xffffd
    800066dc:	e06080e7          	jalr	-506(ra) # 800034de <argstr>
    return -1;
    800066e0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800066e2:	0c054163          	bltz	a0,800067a4 <sys_open+0xe4>
    800066e6:	f4c40593          	addi	a1,s0,-180
    800066ea:	4505                	li	a0,1
    800066ec:	ffffd097          	auipc	ra,0xffffd
    800066f0:	dae080e7          	jalr	-594(ra) # 8000349a <argint>
    800066f4:	0a054863          	bltz	a0,800067a4 <sys_open+0xe4>

  begin_op();
    800066f8:	ffffe097          	auipc	ra,0xffffe
    800066fc:	614080e7          	jalr	1556(ra) # 80004d0c <begin_op>

  if(omode & O_CREATE){
    80006700:	f4c42783          	lw	a5,-180(s0)
    80006704:	2007f793          	andi	a5,a5,512
    80006708:	cbdd                	beqz	a5,800067be <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000670a:	4681                	li	a3,0
    8000670c:	4601                	li	a2,0
    8000670e:	4589                	li	a1,2
    80006710:	f5040513          	addi	a0,s0,-176
    80006714:	00000097          	auipc	ra,0x0
    80006718:	e46080e7          	jalr	-442(ra) # 8000655a <create>
    8000671c:	892a                	mv	s2,a0
    if(ip == 0){
    8000671e:	c959                	beqz	a0,800067b4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006720:	04491703          	lh	a4,68(s2)
    80006724:	478d                	li	a5,3
    80006726:	00f71763          	bne	a4,a5,80006734 <sys_open+0x74>
    8000672a:	04695703          	lhu	a4,70(s2)
    8000672e:	47a5                	li	a5,9
    80006730:	0ce7ec63          	bltu	a5,a4,80006808 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006734:	fffff097          	auipc	ra,0xfffff
    80006738:	9e8080e7          	jalr	-1560(ra) # 8000511c <filealloc>
    8000673c:	89aa                	mv	s3,a0
    8000673e:	10050263          	beqz	a0,80006842 <sys_open+0x182>
    80006742:	00000097          	auipc	ra,0x0
    80006746:	8e2080e7          	jalr	-1822(ra) # 80006024 <fdalloc>
    8000674a:	84aa                	mv	s1,a0
    8000674c:	0e054663          	bltz	a0,80006838 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006750:	04491703          	lh	a4,68(s2)
    80006754:	478d                	li	a5,3
    80006756:	0cf70463          	beq	a4,a5,8000681e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000675a:	4789                	li	a5,2
    8000675c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006760:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006764:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006768:	f4c42783          	lw	a5,-180(s0)
    8000676c:	0017c713          	xori	a4,a5,1
    80006770:	8b05                	andi	a4,a4,1
    80006772:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006776:	0037f713          	andi	a4,a5,3
    8000677a:	00e03733          	snez	a4,a4
    8000677e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006782:	4007f793          	andi	a5,a5,1024
    80006786:	c791                	beqz	a5,80006792 <sys_open+0xd2>
    80006788:	04491703          	lh	a4,68(s2)
    8000678c:	4789                	li	a5,2
    8000678e:	08f70f63          	beq	a4,a5,8000682c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006792:	854a                	mv	a0,s2
    80006794:	ffffe097          	auipc	ra,0xffffe
    80006798:	952080e7          	jalr	-1710(ra) # 800040e6 <iunlock>
  end_op();
    8000679c:	ffffe097          	auipc	ra,0xffffe
    800067a0:	5f0080e7          	jalr	1520(ra) # 80004d8c <end_op>

  return fd;
}
    800067a4:	8526                	mv	a0,s1
    800067a6:	70ea                	ld	ra,184(sp)
    800067a8:	744a                	ld	s0,176(sp)
    800067aa:	74aa                	ld	s1,168(sp)
    800067ac:	790a                	ld	s2,160(sp)
    800067ae:	69ea                	ld	s3,152(sp)
    800067b0:	6129                	addi	sp,sp,192
    800067b2:	8082                	ret
      end_op();
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	5d8080e7          	jalr	1496(ra) # 80004d8c <end_op>
      return -1;
    800067bc:	b7e5                	j	800067a4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800067be:	f5040513          	addi	a0,s0,-176
    800067c2:	ffffe097          	auipc	ra,0xffffe
    800067c6:	018080e7          	jalr	24(ra) # 800047da <namei>
    800067ca:	892a                	mv	s2,a0
    800067cc:	c905                	beqz	a0,800067fc <sys_open+0x13c>
    ilock(ip);
    800067ce:	ffffe097          	auipc	ra,0xffffe
    800067d2:	856080e7          	jalr	-1962(ra) # 80004024 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800067d6:	04491703          	lh	a4,68(s2)
    800067da:	4785                	li	a5,1
    800067dc:	f4f712e3          	bne	a4,a5,80006720 <sys_open+0x60>
    800067e0:	f4c42783          	lw	a5,-180(s0)
    800067e4:	dba1                	beqz	a5,80006734 <sys_open+0x74>
      iunlockput(ip);
    800067e6:	854a                	mv	a0,s2
    800067e8:	ffffe097          	auipc	ra,0xffffe
    800067ec:	a9e080e7          	jalr	-1378(ra) # 80004286 <iunlockput>
      end_op();
    800067f0:	ffffe097          	auipc	ra,0xffffe
    800067f4:	59c080e7          	jalr	1436(ra) # 80004d8c <end_op>
      return -1;
    800067f8:	54fd                	li	s1,-1
    800067fa:	b76d                	j	800067a4 <sys_open+0xe4>
      end_op();
    800067fc:	ffffe097          	auipc	ra,0xffffe
    80006800:	590080e7          	jalr	1424(ra) # 80004d8c <end_op>
      return -1;
    80006804:	54fd                	li	s1,-1
    80006806:	bf79                	j	800067a4 <sys_open+0xe4>
    iunlockput(ip);
    80006808:	854a                	mv	a0,s2
    8000680a:	ffffe097          	auipc	ra,0xffffe
    8000680e:	a7c080e7          	jalr	-1412(ra) # 80004286 <iunlockput>
    end_op();
    80006812:	ffffe097          	auipc	ra,0xffffe
    80006816:	57a080e7          	jalr	1402(ra) # 80004d8c <end_op>
    return -1;
    8000681a:	54fd                	li	s1,-1
    8000681c:	b761                	j	800067a4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000681e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006822:	04691783          	lh	a5,70(s2)
    80006826:	02f99223          	sh	a5,36(s3)
    8000682a:	bf2d                	j	80006764 <sys_open+0xa4>
    itrunc(ip);
    8000682c:	854a                	mv	a0,s2
    8000682e:	ffffe097          	auipc	ra,0xffffe
    80006832:	904080e7          	jalr	-1788(ra) # 80004132 <itrunc>
    80006836:	bfb1                	j	80006792 <sys_open+0xd2>
      fileclose(f);
    80006838:	854e                	mv	a0,s3
    8000683a:	fffff097          	auipc	ra,0xfffff
    8000683e:	99e080e7          	jalr	-1634(ra) # 800051d8 <fileclose>
    iunlockput(ip);
    80006842:	854a                	mv	a0,s2
    80006844:	ffffe097          	auipc	ra,0xffffe
    80006848:	a42080e7          	jalr	-1470(ra) # 80004286 <iunlockput>
    end_op();
    8000684c:	ffffe097          	auipc	ra,0xffffe
    80006850:	540080e7          	jalr	1344(ra) # 80004d8c <end_op>
    return -1;
    80006854:	54fd                	li	s1,-1
    80006856:	b7b9                	j	800067a4 <sys_open+0xe4>

0000000080006858 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006858:	7175                	addi	sp,sp,-144
    8000685a:	e506                	sd	ra,136(sp)
    8000685c:	e122                	sd	s0,128(sp)
    8000685e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006860:	ffffe097          	auipc	ra,0xffffe
    80006864:	4ac080e7          	jalr	1196(ra) # 80004d0c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006868:	08000613          	li	a2,128
    8000686c:	f7040593          	addi	a1,s0,-144
    80006870:	4501                	li	a0,0
    80006872:	ffffd097          	auipc	ra,0xffffd
    80006876:	c6c080e7          	jalr	-916(ra) # 800034de <argstr>
    8000687a:	02054963          	bltz	a0,800068ac <sys_mkdir+0x54>
    8000687e:	4681                	li	a3,0
    80006880:	4601                	li	a2,0
    80006882:	4585                	li	a1,1
    80006884:	f7040513          	addi	a0,s0,-144
    80006888:	00000097          	auipc	ra,0x0
    8000688c:	cd2080e7          	jalr	-814(ra) # 8000655a <create>
    80006890:	cd11                	beqz	a0,800068ac <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006892:	ffffe097          	auipc	ra,0xffffe
    80006896:	9f4080e7          	jalr	-1548(ra) # 80004286 <iunlockput>
  end_op();
    8000689a:	ffffe097          	auipc	ra,0xffffe
    8000689e:	4f2080e7          	jalr	1266(ra) # 80004d8c <end_op>
  return 0;
    800068a2:	4501                	li	a0,0
}
    800068a4:	60aa                	ld	ra,136(sp)
    800068a6:	640a                	ld	s0,128(sp)
    800068a8:	6149                	addi	sp,sp,144
    800068aa:	8082                	ret
    end_op();
    800068ac:	ffffe097          	auipc	ra,0xffffe
    800068b0:	4e0080e7          	jalr	1248(ra) # 80004d8c <end_op>
    return -1;
    800068b4:	557d                	li	a0,-1
    800068b6:	b7fd                	j	800068a4 <sys_mkdir+0x4c>

00000000800068b8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800068b8:	7135                	addi	sp,sp,-160
    800068ba:	ed06                	sd	ra,152(sp)
    800068bc:	e922                	sd	s0,144(sp)
    800068be:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800068c0:	ffffe097          	auipc	ra,0xffffe
    800068c4:	44c080e7          	jalr	1100(ra) # 80004d0c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800068c8:	08000613          	li	a2,128
    800068cc:	f7040593          	addi	a1,s0,-144
    800068d0:	4501                	li	a0,0
    800068d2:	ffffd097          	auipc	ra,0xffffd
    800068d6:	c0c080e7          	jalr	-1012(ra) # 800034de <argstr>
    800068da:	04054a63          	bltz	a0,8000692e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800068de:	f6c40593          	addi	a1,s0,-148
    800068e2:	4505                	li	a0,1
    800068e4:	ffffd097          	auipc	ra,0xffffd
    800068e8:	bb6080e7          	jalr	-1098(ra) # 8000349a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800068ec:	04054163          	bltz	a0,8000692e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800068f0:	f6840593          	addi	a1,s0,-152
    800068f4:	4509                	li	a0,2
    800068f6:	ffffd097          	auipc	ra,0xffffd
    800068fa:	ba4080e7          	jalr	-1116(ra) # 8000349a <argint>
     argint(1, &major) < 0 ||
    800068fe:	02054863          	bltz	a0,8000692e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006902:	f6841683          	lh	a3,-152(s0)
    80006906:	f6c41603          	lh	a2,-148(s0)
    8000690a:	458d                	li	a1,3
    8000690c:	f7040513          	addi	a0,s0,-144
    80006910:	00000097          	auipc	ra,0x0
    80006914:	c4a080e7          	jalr	-950(ra) # 8000655a <create>
     argint(2, &minor) < 0 ||
    80006918:	c919                	beqz	a0,8000692e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000691a:	ffffe097          	auipc	ra,0xffffe
    8000691e:	96c080e7          	jalr	-1684(ra) # 80004286 <iunlockput>
  end_op();
    80006922:	ffffe097          	auipc	ra,0xffffe
    80006926:	46a080e7          	jalr	1130(ra) # 80004d8c <end_op>
  return 0;
    8000692a:	4501                	li	a0,0
    8000692c:	a031                	j	80006938 <sys_mknod+0x80>
    end_op();
    8000692e:	ffffe097          	auipc	ra,0xffffe
    80006932:	45e080e7          	jalr	1118(ra) # 80004d8c <end_op>
    return -1;
    80006936:	557d                	li	a0,-1
}
    80006938:	60ea                	ld	ra,152(sp)
    8000693a:	644a                	ld	s0,144(sp)
    8000693c:	610d                	addi	sp,sp,160
    8000693e:	8082                	ret

0000000080006940 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006940:	7135                	addi	sp,sp,-160
    80006942:	ed06                	sd	ra,152(sp)
    80006944:	e922                	sd	s0,144(sp)
    80006946:	e526                	sd	s1,136(sp)
    80006948:	e14a                	sd	s2,128(sp)
    8000694a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000694c:	ffffb097          	auipc	ra,0xffffb
    80006950:	21c080e7          	jalr	540(ra) # 80001b68 <myproc>
    80006954:	892a                	mv	s2,a0
  
  begin_op();
    80006956:	ffffe097          	auipc	ra,0xffffe
    8000695a:	3b6080e7          	jalr	950(ra) # 80004d0c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000695e:	08000613          	li	a2,128
    80006962:	f6040593          	addi	a1,s0,-160
    80006966:	4501                	li	a0,0
    80006968:	ffffd097          	auipc	ra,0xffffd
    8000696c:	b76080e7          	jalr	-1162(ra) # 800034de <argstr>
    80006970:	04054b63          	bltz	a0,800069c6 <sys_chdir+0x86>
    80006974:	f6040513          	addi	a0,s0,-160
    80006978:	ffffe097          	auipc	ra,0xffffe
    8000697c:	e62080e7          	jalr	-414(ra) # 800047da <namei>
    80006980:	84aa                	mv	s1,a0
    80006982:	c131                	beqz	a0,800069c6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006984:	ffffd097          	auipc	ra,0xffffd
    80006988:	6a0080e7          	jalr	1696(ra) # 80004024 <ilock>
  if(ip->type != T_DIR){
    8000698c:	04449703          	lh	a4,68(s1)
    80006990:	4785                	li	a5,1
    80006992:	04f71063          	bne	a4,a5,800069d2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006996:	8526                	mv	a0,s1
    80006998:	ffffd097          	auipc	ra,0xffffd
    8000699c:	74e080e7          	jalr	1870(ra) # 800040e6 <iunlock>
  iput(p->cwd);
    800069a0:	15093503          	ld	a0,336(s2)
    800069a4:	ffffe097          	auipc	ra,0xffffe
    800069a8:	83a080e7          	jalr	-1990(ra) # 800041de <iput>
  end_op();
    800069ac:	ffffe097          	auipc	ra,0xffffe
    800069b0:	3e0080e7          	jalr	992(ra) # 80004d8c <end_op>
  p->cwd = ip;
    800069b4:	14993823          	sd	s1,336(s2)
  return 0;
    800069b8:	4501                	li	a0,0
}
    800069ba:	60ea                	ld	ra,152(sp)
    800069bc:	644a                	ld	s0,144(sp)
    800069be:	64aa                	ld	s1,136(sp)
    800069c0:	690a                	ld	s2,128(sp)
    800069c2:	610d                	addi	sp,sp,160
    800069c4:	8082                	ret
    end_op();
    800069c6:	ffffe097          	auipc	ra,0xffffe
    800069ca:	3c6080e7          	jalr	966(ra) # 80004d8c <end_op>
    return -1;
    800069ce:	557d                	li	a0,-1
    800069d0:	b7ed                	j	800069ba <sys_chdir+0x7a>
    iunlockput(ip);
    800069d2:	8526                	mv	a0,s1
    800069d4:	ffffe097          	auipc	ra,0xffffe
    800069d8:	8b2080e7          	jalr	-1870(ra) # 80004286 <iunlockput>
    end_op();
    800069dc:	ffffe097          	auipc	ra,0xffffe
    800069e0:	3b0080e7          	jalr	944(ra) # 80004d8c <end_op>
    return -1;
    800069e4:	557d                	li	a0,-1
    800069e6:	bfd1                	j	800069ba <sys_chdir+0x7a>

00000000800069e8 <sys_exec>:

uint64
sys_exec(void)
{
    800069e8:	7145                	addi	sp,sp,-464
    800069ea:	e786                	sd	ra,456(sp)
    800069ec:	e3a2                	sd	s0,448(sp)
    800069ee:	ff26                	sd	s1,440(sp)
    800069f0:	fb4a                	sd	s2,432(sp)
    800069f2:	f74e                	sd	s3,424(sp)
    800069f4:	f352                	sd	s4,416(sp)
    800069f6:	ef56                	sd	s5,408(sp)
    800069f8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800069fa:	08000613          	li	a2,128
    800069fe:	f4040593          	addi	a1,s0,-192
    80006a02:	4501                	li	a0,0
    80006a04:	ffffd097          	auipc	ra,0xffffd
    80006a08:	ada080e7          	jalr	-1318(ra) # 800034de <argstr>
    return -1;
    80006a0c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006a0e:	0c054a63          	bltz	a0,80006ae2 <sys_exec+0xfa>
    80006a12:	e3840593          	addi	a1,s0,-456
    80006a16:	4505                	li	a0,1
    80006a18:	ffffd097          	auipc	ra,0xffffd
    80006a1c:	aa4080e7          	jalr	-1372(ra) # 800034bc <argaddr>
    80006a20:	0c054163          	bltz	a0,80006ae2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006a24:	10000613          	li	a2,256
    80006a28:	4581                	li	a1,0
    80006a2a:	e4040513          	addi	a0,s0,-448
    80006a2e:	ffffa097          	auipc	ra,0xffffa
    80006a32:	290080e7          	jalr	656(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006a36:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006a3a:	89a6                	mv	s3,s1
    80006a3c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006a3e:	02000a13          	li	s4,32
    80006a42:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006a46:	00391793          	slli	a5,s2,0x3
    80006a4a:	e3040593          	addi	a1,s0,-464
    80006a4e:	e3843503          	ld	a0,-456(s0)
    80006a52:	953e                	add	a0,a0,a5
    80006a54:	ffffd097          	auipc	ra,0xffffd
    80006a58:	9ac080e7          	jalr	-1620(ra) # 80003400 <fetchaddr>
    80006a5c:	02054a63          	bltz	a0,80006a90 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006a60:	e3043783          	ld	a5,-464(s0)
    80006a64:	c3b9                	beqz	a5,80006aaa <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006a66:	ffffa097          	auipc	ra,0xffffa
    80006a6a:	06c080e7          	jalr	108(ra) # 80000ad2 <kalloc>
    80006a6e:	85aa                	mv	a1,a0
    80006a70:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006a74:	cd11                	beqz	a0,80006a90 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006a76:	6605                	lui	a2,0x1
    80006a78:	e3043503          	ld	a0,-464(s0)
    80006a7c:	ffffd097          	auipc	ra,0xffffd
    80006a80:	9d6080e7          	jalr	-1578(ra) # 80003452 <fetchstr>
    80006a84:	00054663          	bltz	a0,80006a90 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006a88:	0905                	addi	s2,s2,1
    80006a8a:	09a1                	addi	s3,s3,8
    80006a8c:	fb491be3          	bne	s2,s4,80006a42 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006a90:	10048913          	addi	s2,s1,256
    80006a94:	6088                	ld	a0,0(s1)
    80006a96:	c529                	beqz	a0,80006ae0 <sys_exec+0xf8>
    kfree(argv[i]);
    80006a98:	ffffa097          	auipc	ra,0xffffa
    80006a9c:	f3e080e7          	jalr	-194(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006aa0:	04a1                	addi	s1,s1,8
    80006aa2:	ff2499e3          	bne	s1,s2,80006a94 <sys_exec+0xac>
  return -1;
    80006aa6:	597d                	li	s2,-1
    80006aa8:	a82d                	j	80006ae2 <sys_exec+0xfa>
      argv[i] = 0;
    80006aaa:	0a8e                	slli	s5,s5,0x3
    80006aac:	fc040793          	addi	a5,s0,-64
    80006ab0:	9abe                	add	s5,s5,a5
    80006ab2:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffbee80>
  int ret = exec(path, argv);
    80006ab6:	e4040593          	addi	a1,s0,-448
    80006aba:	f4040513          	addi	a0,s0,-192
    80006abe:	fffff097          	auipc	ra,0xfffff
    80006ac2:	f62080e7          	jalr	-158(ra) # 80005a20 <exec>
    80006ac6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ac8:	10048993          	addi	s3,s1,256
    80006acc:	6088                	ld	a0,0(s1)
    80006ace:	c911                	beqz	a0,80006ae2 <sys_exec+0xfa>
    kfree(argv[i]);
    80006ad0:	ffffa097          	auipc	ra,0xffffa
    80006ad4:	f06080e7          	jalr	-250(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ad8:	04a1                	addi	s1,s1,8
    80006ada:	ff3499e3          	bne	s1,s3,80006acc <sys_exec+0xe4>
    80006ade:	a011                	j	80006ae2 <sys_exec+0xfa>
  return -1;
    80006ae0:	597d                	li	s2,-1
}
    80006ae2:	854a                	mv	a0,s2
    80006ae4:	60be                	ld	ra,456(sp)
    80006ae6:	641e                	ld	s0,448(sp)
    80006ae8:	74fa                	ld	s1,440(sp)
    80006aea:	795a                	ld	s2,432(sp)
    80006aec:	79ba                	ld	s3,424(sp)
    80006aee:	7a1a                	ld	s4,416(sp)
    80006af0:	6afa                	ld	s5,408(sp)
    80006af2:	6179                	addi	sp,sp,464
    80006af4:	8082                	ret

0000000080006af6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006af6:	7139                	addi	sp,sp,-64
    80006af8:	fc06                	sd	ra,56(sp)
    80006afa:	f822                	sd	s0,48(sp)
    80006afc:	f426                	sd	s1,40(sp)
    80006afe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006b00:	ffffb097          	auipc	ra,0xffffb
    80006b04:	068080e7          	jalr	104(ra) # 80001b68 <myproc>
    80006b08:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006b0a:	fd840593          	addi	a1,s0,-40
    80006b0e:	4501                	li	a0,0
    80006b10:	ffffd097          	auipc	ra,0xffffd
    80006b14:	9ac080e7          	jalr	-1620(ra) # 800034bc <argaddr>
    return -1;
    80006b18:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006b1a:	0e054063          	bltz	a0,80006bfa <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006b1e:	fc840593          	addi	a1,s0,-56
    80006b22:	fd040513          	addi	a0,s0,-48
    80006b26:	fffff097          	auipc	ra,0xfffff
    80006b2a:	bd8080e7          	jalr	-1064(ra) # 800056fe <pipealloc>
    return -1;
    80006b2e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006b30:	0c054563          	bltz	a0,80006bfa <sys_pipe+0x104>
  fd0 = -1;
    80006b34:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006b38:	fd043503          	ld	a0,-48(s0)
    80006b3c:	fffff097          	auipc	ra,0xfffff
    80006b40:	4e8080e7          	jalr	1256(ra) # 80006024 <fdalloc>
    80006b44:	fca42223          	sw	a0,-60(s0)
    80006b48:	08054c63          	bltz	a0,80006be0 <sys_pipe+0xea>
    80006b4c:	fc843503          	ld	a0,-56(s0)
    80006b50:	fffff097          	auipc	ra,0xfffff
    80006b54:	4d4080e7          	jalr	1236(ra) # 80006024 <fdalloc>
    80006b58:	fca42023          	sw	a0,-64(s0)
    80006b5c:	06054863          	bltz	a0,80006bcc <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006b60:	4691                	li	a3,4
    80006b62:	fc440613          	addi	a2,s0,-60
    80006b66:	fd843583          	ld	a1,-40(s0)
    80006b6a:	68a8                	ld	a0,80(s1)
    80006b6c:	ffffb097          	auipc	ra,0xffffb
    80006b70:	cbc080e7          	jalr	-836(ra) # 80001828 <copyout>
    80006b74:	02054063          	bltz	a0,80006b94 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006b78:	4691                	li	a3,4
    80006b7a:	fc040613          	addi	a2,s0,-64
    80006b7e:	fd843583          	ld	a1,-40(s0)
    80006b82:	0591                	addi	a1,a1,4
    80006b84:	68a8                	ld	a0,80(s1)
    80006b86:	ffffb097          	auipc	ra,0xffffb
    80006b8a:	ca2080e7          	jalr	-862(ra) # 80001828 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006b8e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006b90:	06055563          	bgez	a0,80006bfa <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006b94:	fc442783          	lw	a5,-60(s0)
    80006b98:	07e9                	addi	a5,a5,26
    80006b9a:	078e                	slli	a5,a5,0x3
    80006b9c:	97a6                	add	a5,a5,s1
    80006b9e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006ba2:	fc042503          	lw	a0,-64(s0)
    80006ba6:	0569                	addi	a0,a0,26
    80006ba8:	050e                	slli	a0,a0,0x3
    80006baa:	9526                	add	a0,a0,s1
    80006bac:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006bb0:	fd043503          	ld	a0,-48(s0)
    80006bb4:	ffffe097          	auipc	ra,0xffffe
    80006bb8:	624080e7          	jalr	1572(ra) # 800051d8 <fileclose>
    fileclose(wf);
    80006bbc:	fc843503          	ld	a0,-56(s0)
    80006bc0:	ffffe097          	auipc	ra,0xffffe
    80006bc4:	618080e7          	jalr	1560(ra) # 800051d8 <fileclose>
    return -1;
    80006bc8:	57fd                	li	a5,-1
    80006bca:	a805                	j	80006bfa <sys_pipe+0x104>
    if(fd0 >= 0)
    80006bcc:	fc442783          	lw	a5,-60(s0)
    80006bd0:	0007c863          	bltz	a5,80006be0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006bd4:	01a78513          	addi	a0,a5,26
    80006bd8:	050e                	slli	a0,a0,0x3
    80006bda:	9526                	add	a0,a0,s1
    80006bdc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006be0:	fd043503          	ld	a0,-48(s0)
    80006be4:	ffffe097          	auipc	ra,0xffffe
    80006be8:	5f4080e7          	jalr	1524(ra) # 800051d8 <fileclose>
    fileclose(wf);
    80006bec:	fc843503          	ld	a0,-56(s0)
    80006bf0:	ffffe097          	auipc	ra,0xffffe
    80006bf4:	5e8080e7          	jalr	1512(ra) # 800051d8 <fileclose>
    return -1;
    80006bf8:	57fd                	li	a5,-1
}
    80006bfa:	853e                	mv	a0,a5
    80006bfc:	70e2                	ld	ra,56(sp)
    80006bfe:	7442                	ld	s0,48(sp)
    80006c00:	74a2                	ld	s1,40(sp)
    80006c02:	6121                	addi	sp,sp,64
    80006c04:	8082                	ret
	...

0000000080006c10 <kernelvec>:
    80006c10:	7111                	addi	sp,sp,-256
    80006c12:	e006                	sd	ra,0(sp)
    80006c14:	e40a                	sd	sp,8(sp)
    80006c16:	e80e                	sd	gp,16(sp)
    80006c18:	ec12                	sd	tp,24(sp)
    80006c1a:	f016                	sd	t0,32(sp)
    80006c1c:	f41a                	sd	t1,40(sp)
    80006c1e:	f81e                	sd	t2,48(sp)
    80006c20:	fc22                	sd	s0,56(sp)
    80006c22:	e0a6                	sd	s1,64(sp)
    80006c24:	e4aa                	sd	a0,72(sp)
    80006c26:	e8ae                	sd	a1,80(sp)
    80006c28:	ecb2                	sd	a2,88(sp)
    80006c2a:	f0b6                	sd	a3,96(sp)
    80006c2c:	f4ba                	sd	a4,104(sp)
    80006c2e:	f8be                	sd	a5,112(sp)
    80006c30:	fcc2                	sd	a6,120(sp)
    80006c32:	e146                	sd	a7,128(sp)
    80006c34:	e54a                	sd	s2,136(sp)
    80006c36:	e94e                	sd	s3,144(sp)
    80006c38:	ed52                	sd	s4,152(sp)
    80006c3a:	f156                	sd	s5,160(sp)
    80006c3c:	f55a                	sd	s6,168(sp)
    80006c3e:	f95e                	sd	s7,176(sp)
    80006c40:	fd62                	sd	s8,184(sp)
    80006c42:	e1e6                	sd	s9,192(sp)
    80006c44:	e5ea                	sd	s10,200(sp)
    80006c46:	e9ee                	sd	s11,208(sp)
    80006c48:	edf2                	sd	t3,216(sp)
    80006c4a:	f1f6                	sd	t4,224(sp)
    80006c4c:	f5fa                	sd	t5,232(sp)
    80006c4e:	f9fe                	sd	t6,240(sp)
    80006c50:	e7cfc0ef          	jal	ra,800032cc <kerneltrap>
    80006c54:	6082                	ld	ra,0(sp)
    80006c56:	6122                	ld	sp,8(sp)
    80006c58:	61c2                	ld	gp,16(sp)
    80006c5a:	7282                	ld	t0,32(sp)
    80006c5c:	7322                	ld	t1,40(sp)
    80006c5e:	73c2                	ld	t2,48(sp)
    80006c60:	7462                	ld	s0,56(sp)
    80006c62:	6486                	ld	s1,64(sp)
    80006c64:	6526                	ld	a0,72(sp)
    80006c66:	65c6                	ld	a1,80(sp)
    80006c68:	6666                	ld	a2,88(sp)
    80006c6a:	7686                	ld	a3,96(sp)
    80006c6c:	7726                	ld	a4,104(sp)
    80006c6e:	77c6                	ld	a5,112(sp)
    80006c70:	7866                	ld	a6,120(sp)
    80006c72:	688a                	ld	a7,128(sp)
    80006c74:	692a                	ld	s2,136(sp)
    80006c76:	69ca                	ld	s3,144(sp)
    80006c78:	6a6a                	ld	s4,152(sp)
    80006c7a:	7a8a                	ld	s5,160(sp)
    80006c7c:	7b2a                	ld	s6,168(sp)
    80006c7e:	7bca                	ld	s7,176(sp)
    80006c80:	7c6a                	ld	s8,184(sp)
    80006c82:	6c8e                	ld	s9,192(sp)
    80006c84:	6d2e                	ld	s10,200(sp)
    80006c86:	6dce                	ld	s11,208(sp)
    80006c88:	6e6e                	ld	t3,216(sp)
    80006c8a:	7e8e                	ld	t4,224(sp)
    80006c8c:	7f2e                	ld	t5,232(sp)
    80006c8e:	7fce                	ld	t6,240(sp)
    80006c90:	6111                	addi	sp,sp,256
    80006c92:	10200073          	sret
    80006c96:	00000013          	nop
    80006c9a:	00000013          	nop
    80006c9e:	0001                	nop

0000000080006ca0 <timervec>:
    80006ca0:	34051573          	csrrw	a0,mscratch,a0
    80006ca4:	e10c                	sd	a1,0(a0)
    80006ca6:	e510                	sd	a2,8(a0)
    80006ca8:	e914                	sd	a3,16(a0)
    80006caa:	6d0c                	ld	a1,24(a0)
    80006cac:	7110                	ld	a2,32(a0)
    80006cae:	6194                	ld	a3,0(a1)
    80006cb0:	96b2                	add	a3,a3,a2
    80006cb2:	e194                	sd	a3,0(a1)
    80006cb4:	4589                	li	a1,2
    80006cb6:	14459073          	csrw	sip,a1
    80006cba:	6914                	ld	a3,16(a0)
    80006cbc:	6510                	ld	a2,8(a0)
    80006cbe:	610c                	ld	a1,0(a0)
    80006cc0:	34051573          	csrrw	a0,mscratch,a0
    80006cc4:	30200073          	mret
	...

0000000080006cca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006cca:	1141                	addi	sp,sp,-16
    80006ccc:	e422                	sd	s0,8(sp)
    80006cce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006cd0:	0c0007b7          	lui	a5,0xc000
    80006cd4:	4705                	li	a4,1
    80006cd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006cd8:	c3d8                	sw	a4,4(a5)
}
    80006cda:	6422                	ld	s0,8(sp)
    80006cdc:	0141                	addi	sp,sp,16
    80006cde:	8082                	ret

0000000080006ce0 <plicinithart>:

void
plicinithart(void)
{
    80006ce0:	1141                	addi	sp,sp,-16
    80006ce2:	e406                	sd	ra,8(sp)
    80006ce4:	e022                	sd	s0,0(sp)
    80006ce6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006ce8:	ffffb097          	auipc	ra,0xffffb
    80006cec:	e54080e7          	jalr	-428(ra) # 80001b3c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006cf0:	0085171b          	slliw	a4,a0,0x8
    80006cf4:	0c0027b7          	lui	a5,0xc002
    80006cf8:	97ba                	add	a5,a5,a4
    80006cfa:	40200713          	li	a4,1026
    80006cfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006d02:	00d5151b          	slliw	a0,a0,0xd
    80006d06:	0c2017b7          	lui	a5,0xc201
    80006d0a:	953e                	add	a0,a0,a5
    80006d0c:	00052023          	sw	zero,0(a0)
}
    80006d10:	60a2                	ld	ra,8(sp)
    80006d12:	6402                	ld	s0,0(sp)
    80006d14:	0141                	addi	sp,sp,16
    80006d16:	8082                	ret

0000000080006d18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006d18:	1141                	addi	sp,sp,-16
    80006d1a:	e406                	sd	ra,8(sp)
    80006d1c:	e022                	sd	s0,0(sp)
    80006d1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d20:	ffffb097          	auipc	ra,0xffffb
    80006d24:	e1c080e7          	jalr	-484(ra) # 80001b3c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006d28:	00d5179b          	slliw	a5,a0,0xd
    80006d2c:	0c201537          	lui	a0,0xc201
    80006d30:	953e                	add	a0,a0,a5
  return irq;
}
    80006d32:	4148                	lw	a0,4(a0)
    80006d34:	60a2                	ld	ra,8(sp)
    80006d36:	6402                	ld	s0,0(sp)
    80006d38:	0141                	addi	sp,sp,16
    80006d3a:	8082                	ret

0000000080006d3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006d3c:	1101                	addi	sp,sp,-32
    80006d3e:	ec06                	sd	ra,24(sp)
    80006d40:	e822                	sd	s0,16(sp)
    80006d42:	e426                	sd	s1,8(sp)
    80006d44:	1000                	addi	s0,sp,32
    80006d46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006d48:	ffffb097          	auipc	ra,0xffffb
    80006d4c:	df4080e7          	jalr	-524(ra) # 80001b3c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006d50:	00d5151b          	slliw	a0,a0,0xd
    80006d54:	0c2017b7          	lui	a5,0xc201
    80006d58:	97aa                	add	a5,a5,a0
    80006d5a:	c3c4                	sw	s1,4(a5)
}
    80006d5c:	60e2                	ld	ra,24(sp)
    80006d5e:	6442                	ld	s0,16(sp)
    80006d60:	64a2                	ld	s1,8(sp)
    80006d62:	6105                	addi	sp,sp,32
    80006d64:	8082                	ret

0000000080006d66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006d66:	1141                	addi	sp,sp,-16
    80006d68:	e406                	sd	ra,8(sp)
    80006d6a:	e022                	sd	s0,0(sp)
    80006d6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006d6e:	479d                	li	a5,7
    80006d70:	06a7c963          	blt	a5,a0,80006de2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006d74:	00036797          	auipc	a5,0x36
    80006d78:	28c78793          	addi	a5,a5,652 # 8003d000 <disk>
    80006d7c:	00a78733          	add	a4,a5,a0
    80006d80:	6789                	lui	a5,0x2
    80006d82:	97ba                	add	a5,a5,a4
    80006d84:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006d88:	e7ad                	bnez	a5,80006df2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006d8a:	00451793          	slli	a5,a0,0x4
    80006d8e:	00038717          	auipc	a4,0x38
    80006d92:	27270713          	addi	a4,a4,626 # 8003f000 <disk+0x2000>
    80006d96:	6314                	ld	a3,0(a4)
    80006d98:	96be                	add	a3,a3,a5
    80006d9a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006d9e:	6314                	ld	a3,0(a4)
    80006da0:	96be                	add	a3,a3,a5
    80006da2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006da6:	6314                	ld	a3,0(a4)
    80006da8:	96be                	add	a3,a3,a5
    80006daa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006dae:	6318                	ld	a4,0(a4)
    80006db0:	97ba                	add	a5,a5,a4
    80006db2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006db6:	00036797          	auipc	a5,0x36
    80006dba:	24a78793          	addi	a5,a5,586 # 8003d000 <disk>
    80006dbe:	97aa                	add	a5,a5,a0
    80006dc0:	6509                	lui	a0,0x2
    80006dc2:	953e                	add	a0,a0,a5
    80006dc4:	4785                	li	a5,1
    80006dc6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006dca:	00038517          	auipc	a0,0x38
    80006dce:	24e50513          	addi	a0,a0,590 # 8003f018 <disk+0x2018>
    80006dd2:	ffffb097          	auipc	ra,0xffffb
    80006dd6:	1d2080e7          	jalr	466(ra) # 80001fa4 <wakeup>
}
    80006dda:	60a2                	ld	ra,8(sp)
    80006ddc:	6402                	ld	s0,0(sp)
    80006dde:	0141                	addi	sp,sp,16
    80006de0:	8082                	ret
    panic("free_desc 1");
    80006de2:	00003517          	auipc	a0,0x3
    80006de6:	c5650513          	addi	a0,a0,-938 # 80009a38 <syscalls+0x380>
    80006dea:	ffff9097          	auipc	ra,0xffff9
    80006dee:	740080e7          	jalr	1856(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006df2:	00003517          	auipc	a0,0x3
    80006df6:	c5650513          	addi	a0,a0,-938 # 80009a48 <syscalls+0x390>
    80006dfa:	ffff9097          	auipc	ra,0xffff9
    80006dfe:	730080e7          	jalr	1840(ra) # 8000052a <panic>

0000000080006e02 <virtio_disk_init>:
{
    80006e02:	1101                	addi	sp,sp,-32
    80006e04:	ec06                	sd	ra,24(sp)
    80006e06:	e822                	sd	s0,16(sp)
    80006e08:	e426                	sd	s1,8(sp)
    80006e0a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006e0c:	00003597          	auipc	a1,0x3
    80006e10:	c4c58593          	addi	a1,a1,-948 # 80009a58 <syscalls+0x3a0>
    80006e14:	00038517          	auipc	a0,0x38
    80006e18:	31450513          	addi	a0,a0,788 # 8003f128 <disk+0x2128>
    80006e1c:	ffffa097          	auipc	ra,0xffffa
    80006e20:	d16080e7          	jalr	-746(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e24:	100017b7          	lui	a5,0x10001
    80006e28:	4398                	lw	a4,0(a5)
    80006e2a:	2701                	sext.w	a4,a4
    80006e2c:	747277b7          	lui	a5,0x74727
    80006e30:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006e34:	0ef71163          	bne	a4,a5,80006f16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e38:	100017b7          	lui	a5,0x10001
    80006e3c:	43dc                	lw	a5,4(a5)
    80006e3e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e40:	4705                	li	a4,1
    80006e42:	0ce79a63          	bne	a5,a4,80006f16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e46:	100017b7          	lui	a5,0x10001
    80006e4a:	479c                	lw	a5,8(a5)
    80006e4c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e4e:	4709                	li	a4,2
    80006e50:	0ce79363          	bne	a5,a4,80006f16 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006e54:	100017b7          	lui	a5,0x10001
    80006e58:	47d8                	lw	a4,12(a5)
    80006e5a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e5c:	554d47b7          	lui	a5,0x554d4
    80006e60:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006e64:	0af71963          	bne	a4,a5,80006f16 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e68:	100017b7          	lui	a5,0x10001
    80006e6c:	4705                	li	a4,1
    80006e6e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e70:	470d                	li	a4,3
    80006e72:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006e74:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006e76:	c7ffe737          	lui	a4,0xc7ffe
    80006e7a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbe75f>
    80006e7e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006e80:	2701                	sext.w	a4,a4
    80006e82:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e84:	472d                	li	a4,11
    80006e86:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e88:	473d                	li	a4,15
    80006e8a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006e8c:	6705                	lui	a4,0x1
    80006e8e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006e90:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006e94:	5bdc                	lw	a5,52(a5)
    80006e96:	2781                	sext.w	a5,a5
  if(max == 0)
    80006e98:	c7d9                	beqz	a5,80006f26 <virtio_disk_init+0x124>
  if(max < NUM)
    80006e9a:	471d                	li	a4,7
    80006e9c:	08f77d63          	bgeu	a4,a5,80006f36 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006ea0:	100014b7          	lui	s1,0x10001
    80006ea4:	47a1                	li	a5,8
    80006ea6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006ea8:	6609                	lui	a2,0x2
    80006eaa:	4581                	li	a1,0
    80006eac:	00036517          	auipc	a0,0x36
    80006eb0:	15450513          	addi	a0,a0,340 # 8003d000 <disk>
    80006eb4:	ffffa097          	auipc	ra,0xffffa
    80006eb8:	e0a080e7          	jalr	-502(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006ebc:	00036717          	auipc	a4,0x36
    80006ec0:	14470713          	addi	a4,a4,324 # 8003d000 <disk>
    80006ec4:	00c75793          	srli	a5,a4,0xc
    80006ec8:	2781                	sext.w	a5,a5
    80006eca:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006ecc:	00038797          	auipc	a5,0x38
    80006ed0:	13478793          	addi	a5,a5,308 # 8003f000 <disk+0x2000>
    80006ed4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006ed6:	00036717          	auipc	a4,0x36
    80006eda:	1aa70713          	addi	a4,a4,426 # 8003d080 <disk+0x80>
    80006ede:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006ee0:	00037717          	auipc	a4,0x37
    80006ee4:	12070713          	addi	a4,a4,288 # 8003e000 <disk+0x1000>
    80006ee8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006eea:	4705                	li	a4,1
    80006eec:	00e78c23          	sb	a4,24(a5)
    80006ef0:	00e78ca3          	sb	a4,25(a5)
    80006ef4:	00e78d23          	sb	a4,26(a5)
    80006ef8:	00e78da3          	sb	a4,27(a5)
    80006efc:	00e78e23          	sb	a4,28(a5)
    80006f00:	00e78ea3          	sb	a4,29(a5)
    80006f04:	00e78f23          	sb	a4,30(a5)
    80006f08:	00e78fa3          	sb	a4,31(a5)
}
    80006f0c:	60e2                	ld	ra,24(sp)
    80006f0e:	6442                	ld	s0,16(sp)
    80006f10:	64a2                	ld	s1,8(sp)
    80006f12:	6105                	addi	sp,sp,32
    80006f14:	8082                	ret
    panic("could not find virtio disk");
    80006f16:	00003517          	auipc	a0,0x3
    80006f1a:	b5250513          	addi	a0,a0,-1198 # 80009a68 <syscalls+0x3b0>
    80006f1e:	ffff9097          	auipc	ra,0xffff9
    80006f22:	60c080e7          	jalr	1548(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006f26:	00003517          	auipc	a0,0x3
    80006f2a:	b6250513          	addi	a0,a0,-1182 # 80009a88 <syscalls+0x3d0>
    80006f2e:	ffff9097          	auipc	ra,0xffff9
    80006f32:	5fc080e7          	jalr	1532(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006f36:	00003517          	auipc	a0,0x3
    80006f3a:	b7250513          	addi	a0,a0,-1166 # 80009aa8 <syscalls+0x3f0>
    80006f3e:	ffff9097          	auipc	ra,0xffff9
    80006f42:	5ec080e7          	jalr	1516(ra) # 8000052a <panic>

0000000080006f46 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006f46:	7119                	addi	sp,sp,-128
    80006f48:	fc86                	sd	ra,120(sp)
    80006f4a:	f8a2                	sd	s0,112(sp)
    80006f4c:	f4a6                	sd	s1,104(sp)
    80006f4e:	f0ca                	sd	s2,96(sp)
    80006f50:	ecce                	sd	s3,88(sp)
    80006f52:	e8d2                	sd	s4,80(sp)
    80006f54:	e4d6                	sd	s5,72(sp)
    80006f56:	e0da                	sd	s6,64(sp)
    80006f58:	fc5e                	sd	s7,56(sp)
    80006f5a:	f862                	sd	s8,48(sp)
    80006f5c:	f466                	sd	s9,40(sp)
    80006f5e:	f06a                	sd	s10,32(sp)
    80006f60:	ec6e                	sd	s11,24(sp)
    80006f62:	0100                	addi	s0,sp,128
    80006f64:	8aaa                	mv	s5,a0
    80006f66:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006f68:	00c52c83          	lw	s9,12(a0)
    80006f6c:	001c9c9b          	slliw	s9,s9,0x1
    80006f70:	1c82                	slli	s9,s9,0x20
    80006f72:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006f76:	00038517          	auipc	a0,0x38
    80006f7a:	1b250513          	addi	a0,a0,434 # 8003f128 <disk+0x2128>
    80006f7e:	ffffa097          	auipc	ra,0xffffa
    80006f82:	c44080e7          	jalr	-956(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006f86:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006f88:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006f8a:	00036c17          	auipc	s8,0x36
    80006f8e:	076c0c13          	addi	s8,s8,118 # 8003d000 <disk>
    80006f92:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006f94:	4b0d                	li	s6,3
    80006f96:	a0ad                	j	80007000 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006f98:	00fc0733          	add	a4,s8,a5
    80006f9c:	975e                	add	a4,a4,s7
    80006f9e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006fa2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006fa4:	0207c563          	bltz	a5,80006fce <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006fa8:	2905                	addiw	s2,s2,1
    80006faa:	0611                	addi	a2,a2,4
    80006fac:	19690d63          	beq	s2,s6,80007146 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006fb0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006fb2:	00038717          	auipc	a4,0x38
    80006fb6:	06670713          	addi	a4,a4,102 # 8003f018 <disk+0x2018>
    80006fba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006fbc:	00074683          	lbu	a3,0(a4)
    80006fc0:	fee1                	bnez	a3,80006f98 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006fc2:	2785                	addiw	a5,a5,1
    80006fc4:	0705                	addi	a4,a4,1
    80006fc6:	fe979be3          	bne	a5,s1,80006fbc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006fca:	57fd                	li	a5,-1
    80006fcc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006fce:	01205d63          	blez	s2,80006fe8 <virtio_disk_rw+0xa2>
    80006fd2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006fd4:	000a2503          	lw	a0,0(s4)
    80006fd8:	00000097          	auipc	ra,0x0
    80006fdc:	d8e080e7          	jalr	-626(ra) # 80006d66 <free_desc>
      for(int j = 0; j < i; j++)
    80006fe0:	2d85                	addiw	s11,s11,1
    80006fe2:	0a11                	addi	s4,s4,4
    80006fe4:	ffb918e3          	bne	s2,s11,80006fd4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006fe8:	00038597          	auipc	a1,0x38
    80006fec:	14058593          	addi	a1,a1,320 # 8003f128 <disk+0x2128>
    80006ff0:	00038517          	auipc	a0,0x38
    80006ff4:	02850513          	addi	a0,a0,40 # 8003f018 <disk+0x2018>
    80006ff8:	ffffb097          	auipc	ra,0xffffb
    80006ffc:	f48080e7          	jalr	-184(ra) # 80001f40 <sleep>
  for(int i = 0; i < 3; i++){
    80007000:	f8040a13          	addi	s4,s0,-128
{
    80007004:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007006:	894e                	mv	s2,s3
    80007008:	b765                	j	80006fb0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000700a:	00038697          	auipc	a3,0x38
    8000700e:	ff66b683          	ld	a3,-10(a3) # 8003f000 <disk+0x2000>
    80007012:	96ba                	add	a3,a3,a4
    80007014:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007018:	00036817          	auipc	a6,0x36
    8000701c:	fe880813          	addi	a6,a6,-24 # 8003d000 <disk>
    80007020:	00038697          	auipc	a3,0x38
    80007024:	fe068693          	addi	a3,a3,-32 # 8003f000 <disk+0x2000>
    80007028:	6290                	ld	a2,0(a3)
    8000702a:	963a                	add	a2,a2,a4
    8000702c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80007030:	0015e593          	ori	a1,a1,1
    80007034:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007038:	f8842603          	lw	a2,-120(s0)
    8000703c:	628c                	ld	a1,0(a3)
    8000703e:	972e                	add	a4,a4,a1
    80007040:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007044:	20050593          	addi	a1,a0,512
    80007048:	0592                	slli	a1,a1,0x4
    8000704a:	95c2                	add	a1,a1,a6
    8000704c:	577d                	li	a4,-1
    8000704e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007052:	00461713          	slli	a4,a2,0x4
    80007056:	6290                	ld	a2,0(a3)
    80007058:	963a                	add	a2,a2,a4
    8000705a:	03078793          	addi	a5,a5,48
    8000705e:	97c2                	add	a5,a5,a6
    80007060:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007062:	629c                	ld	a5,0(a3)
    80007064:	97ba                	add	a5,a5,a4
    80007066:	4605                	li	a2,1
    80007068:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000706a:	629c                	ld	a5,0(a3)
    8000706c:	97ba                	add	a5,a5,a4
    8000706e:	4809                	li	a6,2
    80007070:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007074:	629c                	ld	a5,0(a3)
    80007076:	973e                	add	a4,a4,a5
    80007078:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000707c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007080:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007084:	6698                	ld	a4,8(a3)
    80007086:	00275783          	lhu	a5,2(a4)
    8000708a:	8b9d                	andi	a5,a5,7
    8000708c:	0786                	slli	a5,a5,0x1
    8000708e:	97ba                	add	a5,a5,a4
    80007090:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007094:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007098:	6698                	ld	a4,8(a3)
    8000709a:	00275783          	lhu	a5,2(a4)
    8000709e:	2785                	addiw	a5,a5,1
    800070a0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800070a4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800070a8:	100017b7          	lui	a5,0x10001
    800070ac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800070b0:	004aa783          	lw	a5,4(s5)
    800070b4:	02c79163          	bne	a5,a2,800070d6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800070b8:	00038917          	auipc	s2,0x38
    800070bc:	07090913          	addi	s2,s2,112 # 8003f128 <disk+0x2128>
  while(b->disk == 1) {
    800070c0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800070c2:	85ca                	mv	a1,s2
    800070c4:	8556                	mv	a0,s5
    800070c6:	ffffb097          	auipc	ra,0xffffb
    800070ca:	e7a080e7          	jalr	-390(ra) # 80001f40 <sleep>
  while(b->disk == 1) {
    800070ce:	004aa783          	lw	a5,4(s5)
    800070d2:	fe9788e3          	beq	a5,s1,800070c2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800070d6:	f8042903          	lw	s2,-128(s0)
    800070da:	20090793          	addi	a5,s2,512
    800070de:	00479713          	slli	a4,a5,0x4
    800070e2:	00036797          	auipc	a5,0x36
    800070e6:	f1e78793          	addi	a5,a5,-226 # 8003d000 <disk>
    800070ea:	97ba                	add	a5,a5,a4
    800070ec:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800070f0:	00038997          	auipc	s3,0x38
    800070f4:	f1098993          	addi	s3,s3,-240 # 8003f000 <disk+0x2000>
    800070f8:	00491713          	slli	a4,s2,0x4
    800070fc:	0009b783          	ld	a5,0(s3)
    80007100:	97ba                	add	a5,a5,a4
    80007102:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007106:	854a                	mv	a0,s2
    80007108:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000710c:	00000097          	auipc	ra,0x0
    80007110:	c5a080e7          	jalr	-934(ra) # 80006d66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007114:	8885                	andi	s1,s1,1
    80007116:	f0ed                	bnez	s1,800070f8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007118:	00038517          	auipc	a0,0x38
    8000711c:	01050513          	addi	a0,a0,16 # 8003f128 <disk+0x2128>
    80007120:	ffffa097          	auipc	ra,0xffffa
    80007124:	b56080e7          	jalr	-1194(ra) # 80000c76 <release>
}
    80007128:	70e6                	ld	ra,120(sp)
    8000712a:	7446                	ld	s0,112(sp)
    8000712c:	74a6                	ld	s1,104(sp)
    8000712e:	7906                	ld	s2,96(sp)
    80007130:	69e6                	ld	s3,88(sp)
    80007132:	6a46                	ld	s4,80(sp)
    80007134:	6aa6                	ld	s5,72(sp)
    80007136:	6b06                	ld	s6,64(sp)
    80007138:	7be2                	ld	s7,56(sp)
    8000713a:	7c42                	ld	s8,48(sp)
    8000713c:	7ca2                	ld	s9,40(sp)
    8000713e:	7d02                	ld	s10,32(sp)
    80007140:	6de2                	ld	s11,24(sp)
    80007142:	6109                	addi	sp,sp,128
    80007144:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007146:	f8042503          	lw	a0,-128(s0)
    8000714a:	20050793          	addi	a5,a0,512
    8000714e:	0792                	slli	a5,a5,0x4
  if(write)
    80007150:	00036817          	auipc	a6,0x36
    80007154:	eb080813          	addi	a6,a6,-336 # 8003d000 <disk>
    80007158:	00f80733          	add	a4,a6,a5
    8000715c:	01a036b3          	snez	a3,s10
    80007160:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007164:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007168:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000716c:	7679                	lui	a2,0xffffe
    8000716e:	963e                	add	a2,a2,a5
    80007170:	00038697          	auipc	a3,0x38
    80007174:	e9068693          	addi	a3,a3,-368 # 8003f000 <disk+0x2000>
    80007178:	6298                	ld	a4,0(a3)
    8000717a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000717c:	0a878593          	addi	a1,a5,168
    80007180:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007182:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007184:	6298                	ld	a4,0(a3)
    80007186:	9732                	add	a4,a4,a2
    80007188:	45c1                	li	a1,16
    8000718a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000718c:	6298                	ld	a4,0(a3)
    8000718e:	9732                	add	a4,a4,a2
    80007190:	4585                	li	a1,1
    80007192:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007196:	f8442703          	lw	a4,-124(s0)
    8000719a:	628c                	ld	a1,0(a3)
    8000719c:	962e                	add	a2,a2,a1
    8000719e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbe00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800071a2:	0712                	slli	a4,a4,0x4
    800071a4:	6290                	ld	a2,0(a3)
    800071a6:	963a                	add	a2,a2,a4
    800071a8:	058a8593          	addi	a1,s5,88
    800071ac:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800071ae:	6294                	ld	a3,0(a3)
    800071b0:	96ba                	add	a3,a3,a4
    800071b2:	40000613          	li	a2,1024
    800071b6:	c690                	sw	a2,8(a3)
  if(write)
    800071b8:	e40d19e3          	bnez	s10,8000700a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800071bc:	00038697          	auipc	a3,0x38
    800071c0:	e446b683          	ld	a3,-444(a3) # 8003f000 <disk+0x2000>
    800071c4:	96ba                	add	a3,a3,a4
    800071c6:	4609                	li	a2,2
    800071c8:	00c69623          	sh	a2,12(a3)
    800071cc:	b5b1                	j	80007018 <virtio_disk_rw+0xd2>

00000000800071ce <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800071ce:	1101                	addi	sp,sp,-32
    800071d0:	ec06                	sd	ra,24(sp)
    800071d2:	e822                	sd	s0,16(sp)
    800071d4:	e426                	sd	s1,8(sp)
    800071d6:	e04a                	sd	s2,0(sp)
    800071d8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800071da:	00038517          	auipc	a0,0x38
    800071de:	f4e50513          	addi	a0,a0,-178 # 8003f128 <disk+0x2128>
    800071e2:	ffffa097          	auipc	ra,0xffffa
    800071e6:	9e0080e7          	jalr	-1568(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800071ea:	10001737          	lui	a4,0x10001
    800071ee:	533c                	lw	a5,96(a4)
    800071f0:	8b8d                	andi	a5,a5,3
    800071f2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800071f4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800071f8:	00038797          	auipc	a5,0x38
    800071fc:	e0878793          	addi	a5,a5,-504 # 8003f000 <disk+0x2000>
    80007200:	6b94                	ld	a3,16(a5)
    80007202:	0207d703          	lhu	a4,32(a5)
    80007206:	0026d783          	lhu	a5,2(a3)
    8000720a:	06f70163          	beq	a4,a5,8000726c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000720e:	00036917          	auipc	s2,0x36
    80007212:	df290913          	addi	s2,s2,-526 # 8003d000 <disk>
    80007216:	00038497          	auipc	s1,0x38
    8000721a:	dea48493          	addi	s1,s1,-534 # 8003f000 <disk+0x2000>
    __sync_synchronize();
    8000721e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007222:	6898                	ld	a4,16(s1)
    80007224:	0204d783          	lhu	a5,32(s1)
    80007228:	8b9d                	andi	a5,a5,7
    8000722a:	078e                	slli	a5,a5,0x3
    8000722c:	97ba                	add	a5,a5,a4
    8000722e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007230:	20078713          	addi	a4,a5,512
    80007234:	0712                	slli	a4,a4,0x4
    80007236:	974a                	add	a4,a4,s2
    80007238:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000723c:	e731                	bnez	a4,80007288 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000723e:	20078793          	addi	a5,a5,512
    80007242:	0792                	slli	a5,a5,0x4
    80007244:	97ca                	add	a5,a5,s2
    80007246:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007248:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000724c:	ffffb097          	auipc	ra,0xffffb
    80007250:	d58080e7          	jalr	-680(ra) # 80001fa4 <wakeup>

    disk.used_idx += 1;
    80007254:	0204d783          	lhu	a5,32(s1)
    80007258:	2785                	addiw	a5,a5,1
    8000725a:	17c2                	slli	a5,a5,0x30
    8000725c:	93c1                	srli	a5,a5,0x30
    8000725e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007262:	6898                	ld	a4,16(s1)
    80007264:	00275703          	lhu	a4,2(a4)
    80007268:	faf71be3          	bne	a4,a5,8000721e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000726c:	00038517          	auipc	a0,0x38
    80007270:	ebc50513          	addi	a0,a0,-324 # 8003f128 <disk+0x2128>
    80007274:	ffffa097          	auipc	ra,0xffffa
    80007278:	a02080e7          	jalr	-1534(ra) # 80000c76 <release>
}
    8000727c:	60e2                	ld	ra,24(sp)
    8000727e:	6442                	ld	s0,16(sp)
    80007280:	64a2                	ld	s1,8(sp)
    80007282:	6902                	ld	s2,0(sp)
    80007284:	6105                	addi	sp,sp,32
    80007286:	8082                	ret
      panic("virtio_disk_intr status");
    80007288:	00003517          	auipc	a0,0x3
    8000728c:	84050513          	addi	a0,a0,-1984 # 80009ac8 <syscalls+0x410>
    80007290:	ffff9097          	auipc	ra,0xffff9
    80007294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
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
