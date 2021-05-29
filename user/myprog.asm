
user/_myprog:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyin>:
#define O_CREATE  0x200
#define O_TRUNC   0x400

void
copyin(char *s)
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
  10:	4785                	li	a5,1
  12:	07fe                	slli	a5,a5,0x1f
  14:	fcf43023          	sd	a5,-64(s0)
  18:	57fd                	li	a5,-1
  1a:	fcf43423          	sd	a5,-56(s0)

  for(int ai = 0; ai < 2; ai++){
  1e:	fc040913          	addi	s2,s0,-64
    uint64 addr = addrs[ai];

    int fd = open("copyin1", O_CREATE|O_WRONLY);
  22:	00001a17          	auipc	s4,0x1
  26:	906a0a13          	addi	s4,s4,-1786 # 928 <malloc+0xe6>
    uint64 addr = addrs[ai];
  2a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
  2e:	20100593          	li	a1,513
  32:	8552                	mv	a0,s4
  34:	00000097          	auipc	ra,0x0
  38:	418080e7          	jalr	1048(ra) # 44c <open>
  3c:	84aa                	mv	s1,a0
    if(fd < 0){
  3e:	08054863          	bltz	a0,ce <copyin+0xce>
      printf("open(copyin1) failed\n");
      exit(1);
    }
    int n = write(fd, (void*)addr, 8192);
  42:	6609                	lui	a2,0x2
  44:	85ce                	mv	a1,s3
  46:	00000097          	auipc	ra,0x0
  4a:	3e6080e7          	jalr	998(ra) # 42c <write>
    if(n >= 0){
  4e:	08055d63          	bgez	a0,e8 <copyin+0xe8>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      exit(1);
    }
    close(fd);
  52:	8526                	mv	a0,s1
  54:	00000097          	auipc	ra,0x0
  58:	3e0080e7          	jalr	992(ra) # 434 <close>
    unlink("copyin1");
  5c:	8552                	mv	a0,s4
  5e:	00000097          	auipc	ra,0x0
  62:	3fe080e7          	jalr	1022(ra) # 45c <unlink>

    n = write(1, (char*)addr, 8192);
  66:	6609                	lui	a2,0x2
  68:	85ce                	mv	a1,s3
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	3c0080e7          	jalr	960(ra) # 42c <write>
    if(n > 0){
  74:	08a04963          	bgtz	a0,106 <copyin+0x106>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }

    int fds[2];
    if(pipe(fds) < 0){
  78:	fb840513          	addi	a0,s0,-72
  7c:	00000097          	auipc	ra,0x0
  80:	3a0080e7          	jalr	928(ra) # 41c <pipe>
  84:	0a054063          	bltz	a0,124 <copyin+0x124>
      printf("pipe() failed\n");
      exit(1);
    }
    n = write(fds[1], (char*)addr, 8192);
  88:	6609                	lui	a2,0x2
  8a:	85ce                	mv	a1,s3
  8c:	fbc42503          	lw	a0,-68(s0)
  90:	00000097          	auipc	ra,0x0
  94:	39c080e7          	jalr	924(ra) # 42c <write>
    if(n > 0){
  98:	0aa04363          	bgtz	a0,13e <copyin+0x13e>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    close(fds[0]);
  9c:	fb842503          	lw	a0,-72(s0)
  a0:	00000097          	auipc	ra,0x0
  a4:	394080e7          	jalr	916(ra) # 434 <close>
    close(fds[1]);
  a8:	fbc42503          	lw	a0,-68(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	388080e7          	jalr	904(ra) # 434 <close>
  for(int ai = 0; ai < 2; ai++){
  b4:	0921                	addi	s2,s2,8
  b6:	fd040793          	addi	a5,s0,-48
  ba:	f6f918e3          	bne	s2,a5,2a <copyin+0x2a>
  }
}
  be:	60a6                	ld	ra,72(sp)
  c0:	6406                	ld	s0,64(sp)
  c2:	74e2                	ld	s1,56(sp)
  c4:	7942                	ld	s2,48(sp)
  c6:	79a2                	ld	s3,40(sp)
  c8:	7a02                	ld	s4,32(sp)
  ca:	6161                	addi	sp,sp,80
  cc:	8082                	ret
      printf("open(copyin1) failed\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	86250513          	addi	a0,a0,-1950 # 930 <malloc+0xee>
  d6:	00000097          	auipc	ra,0x0
  da:	6ae080e7          	jalr	1710(ra) # 784 <printf>
      exit(1);
  de:	4505                	li	a0,1
  e0:	00000097          	auipc	ra,0x0
  e4:	32c080e7          	jalr	812(ra) # 40c <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
  e8:	862a                	mv	a2,a0
  ea:	85ce                	mv	a1,s3
  ec:	00001517          	auipc	a0,0x1
  f0:	85c50513          	addi	a0,a0,-1956 # 948 <malloc+0x106>
  f4:	00000097          	auipc	ra,0x0
  f8:	690080e7          	jalr	1680(ra) # 784 <printf>
      exit(1);
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	30e080e7          	jalr	782(ra) # 40c <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
 106:	862a                	mv	a2,a0
 108:	85ce                	mv	a1,s3
 10a:	00001517          	auipc	a0,0x1
 10e:	86e50513          	addi	a0,a0,-1938 # 978 <malloc+0x136>
 112:	00000097          	auipc	ra,0x0
 116:	672080e7          	jalr	1650(ra) # 784 <printf>
      exit(1);
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	2f0080e7          	jalr	752(ra) # 40c <exit>
      printf("pipe() failed\n");
 124:	00001517          	auipc	a0,0x1
 128:	88450513          	addi	a0,a0,-1916 # 9a8 <malloc+0x166>
 12c:	00000097          	auipc	ra,0x0
 130:	658080e7          	jalr	1624(ra) # 784 <printf>
      exit(1);
 134:	4505                	li	a0,1
 136:	00000097          	auipc	ra,0x0
 13a:	2d6080e7          	jalr	726(ra) # 40c <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
 13e:	862a                	mv	a2,a0
 140:	85ce                	mv	a1,s3
 142:	00001517          	auipc	a0,0x1
 146:	87650513          	addi	a0,a0,-1930 # 9b8 <malloc+0x176>
 14a:	00000097          	auipc	ra,0x0
 14e:	63a080e7          	jalr	1594(ra) # 784 <printf>
      exit(1);
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	2b8080e7          	jalr	696(ra) # 40c <exit>

000000000000015c <main>:

int main(int argc, char *argv[]){
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
    printf("hello from myprog!\n");
 164:	00001517          	auipc	a0,0x1
 168:	88450513          	addi	a0,a0,-1916 # 9e8 <malloc+0x1a6>
 16c:	00000097          	auipc	ra,0x0
 170:	618080e7          	jalr	1560(ra) # 784 <printf>
    copyin("hello");
 174:	00001517          	auipc	a0,0x1
 178:	88c50513          	addi	a0,a0,-1908 # a00 <malloc+0x1be>
 17c:	00000097          	auipc	ra,0x0
 180:	e84080e7          	jalr	-380(ra) # 0 <copyin>
    printf("after test\n");
 184:	00001517          	auipc	a0,0x1
 188:	88450513          	addi	a0,a0,-1916 # a08 <malloc+0x1c6>
 18c:	00000097          	auipc	ra,0x0
 190:	5f8080e7          	jalr	1528(ra) # 784 <printf>
    exit(0);
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	276080e7          	jalr	630(ra) # 40c <exit>

000000000000019e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a4:	87aa                	mv	a5,a0
 1a6:	0585                	addi	a1,a1,1
 1a8:	0785                	addi	a5,a5,1
 1aa:	fff5c703          	lbu	a4,-1(a1)
 1ae:	fee78fa3          	sb	a4,-1(a5)
 1b2:	fb75                	bnez	a4,1a6 <strcpy+0x8>
    ;
  return os;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb91                	beqz	a5,1d8 <strcmp+0x1e>
 1c6:	0005c703          	lbu	a4,0(a1)
 1ca:	00f71763          	bne	a4,a5,1d8 <strcmp+0x1e>
    p++, q++;
 1ce:	0505                	addi	a0,a0,1
 1d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	fbe5                	bnez	a5,1c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d8:	0005c503          	lbu	a0,0(a1)
}
 1dc:	40a7853b          	subw	a0,a5,a0
 1e0:	6422                	ld	s0,8(sp)
 1e2:	0141                	addi	sp,sp,16
 1e4:	8082                	ret

00000000000001e6 <strlen>:

uint
strlen(const char *s)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	cf91                	beqz	a5,20c <strlen+0x26>
 1f2:	0505                	addi	a0,a0,1
 1f4:	87aa                	mv	a5,a0
 1f6:	4685                	li	a3,1
 1f8:	9e89                	subw	a3,a3,a0
 1fa:	00f6853b          	addw	a0,a3,a5
 1fe:	0785                	addi	a5,a5,1
 200:	fff7c703          	lbu	a4,-1(a5)
 204:	fb7d                	bnez	a4,1fa <strlen+0x14>
    ;
  return n;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
  for(n = 0; s[n]; n++)
 20c:	4501                	li	a0,0
 20e:	bfe5                	j	206 <strlen+0x20>

0000000000000210 <memset>:

void*
memset(void *dst, int c, uint n)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 216:	ca19                	beqz	a2,22c <memset+0x1c>
 218:	87aa                	mv	a5,a0
 21a:	1602                	slli	a2,a2,0x20
 21c:	9201                	srli	a2,a2,0x20
 21e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 222:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 226:	0785                	addi	a5,a5,1
 228:	fee79de3          	bne	a5,a4,222 <memset+0x12>
  }
  return dst;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strchr>:

char*
strchr(const char *s, char c)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  for(; *s; s++)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cb99                	beqz	a5,252 <strchr+0x20>
    if(*s == c)
 23e:	00f58763          	beq	a1,a5,24c <strchr+0x1a>
  for(; *s; s++)
 242:	0505                	addi	a0,a0,1
 244:	00054783          	lbu	a5,0(a0)
 248:	fbfd                	bnez	a5,23e <strchr+0xc>
      return (char*)s;
  return 0;
 24a:	4501                	li	a0,0
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  return 0;
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <strchr+0x1a>

0000000000000256 <gets>:

char*
gets(char *buf, int max)
{
 256:	711d                	addi	sp,sp,-96
 258:	ec86                	sd	ra,88(sp)
 25a:	e8a2                	sd	s0,80(sp)
 25c:	e4a6                	sd	s1,72(sp)
 25e:	e0ca                	sd	s2,64(sp)
 260:	fc4e                	sd	s3,56(sp)
 262:	f852                	sd	s4,48(sp)
 264:	f456                	sd	s5,40(sp)
 266:	f05a                	sd	s6,32(sp)
 268:	ec5e                	sd	s7,24(sp)
 26a:	1080                	addi	s0,sp,96
 26c:	8baa                	mv	s7,a0
 26e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 270:	892a                	mv	s2,a0
 272:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 274:	4aa9                	li	s5,10
 276:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 278:	89a6                	mv	s3,s1
 27a:	2485                	addiw	s1,s1,1
 27c:	0344d863          	bge	s1,s4,2ac <gets+0x56>
    cc = read(0, &c, 1);
 280:	4605                	li	a2,1
 282:	faf40593          	addi	a1,s0,-81
 286:	4501                	li	a0,0
 288:	00000097          	auipc	ra,0x0
 28c:	19c080e7          	jalr	412(ra) # 424 <read>
    if(cc < 1)
 290:	00a05e63          	blez	a0,2ac <gets+0x56>
    buf[i++] = c;
 294:	faf44783          	lbu	a5,-81(s0)
 298:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 29c:	01578763          	beq	a5,s5,2aa <gets+0x54>
 2a0:	0905                	addi	s2,s2,1
 2a2:	fd679be3          	bne	a5,s6,278 <gets+0x22>
  for(i=0; i+1 < max; ){
 2a6:	89a6                	mv	s3,s1
 2a8:	a011                	j	2ac <gets+0x56>
 2aa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ac:	99de                	add	s3,s3,s7
 2ae:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b2:	855e                	mv	a0,s7
 2b4:	60e6                	ld	ra,88(sp)
 2b6:	6446                	ld	s0,80(sp)
 2b8:	64a6                	ld	s1,72(sp)
 2ba:	6906                	ld	s2,64(sp)
 2bc:	79e2                	ld	s3,56(sp)
 2be:	7a42                	ld	s4,48(sp)
 2c0:	7aa2                	ld	s5,40(sp)
 2c2:	7b02                	ld	s6,32(sp)
 2c4:	6be2                	ld	s7,24(sp)
 2c6:	6125                	addi	sp,sp,96
 2c8:	8082                	ret

00000000000002ca <stat>:

int
stat(const char *n, struct stat *st)
{
 2ca:	1101                	addi	sp,sp,-32
 2cc:	ec06                	sd	ra,24(sp)
 2ce:	e822                	sd	s0,16(sp)
 2d0:	e426                	sd	s1,8(sp)
 2d2:	e04a                	sd	s2,0(sp)
 2d4:	1000                	addi	s0,sp,32
 2d6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d8:	4581                	li	a1,0
 2da:	00000097          	auipc	ra,0x0
 2de:	172080e7          	jalr	370(ra) # 44c <open>
  if(fd < 0)
 2e2:	02054563          	bltz	a0,30c <stat+0x42>
 2e6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e8:	85ca                	mv	a1,s2
 2ea:	00000097          	auipc	ra,0x0
 2ee:	17a080e7          	jalr	378(ra) # 464 <fstat>
 2f2:	892a                	mv	s2,a0
  close(fd);
 2f4:	8526                	mv	a0,s1
 2f6:	00000097          	auipc	ra,0x0
 2fa:	13e080e7          	jalr	318(ra) # 434 <close>
  return r;
}
 2fe:	854a                	mv	a0,s2
 300:	60e2                	ld	ra,24(sp)
 302:	6442                	ld	s0,16(sp)
 304:	64a2                	ld	s1,8(sp)
 306:	6902                	ld	s2,0(sp)
 308:	6105                	addi	sp,sp,32
 30a:	8082                	ret
    return -1;
 30c:	597d                	li	s2,-1
 30e:	bfc5                	j	2fe <stat+0x34>

0000000000000310 <atoi>:

int
atoi(const char *s)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 316:	00054603          	lbu	a2,0(a0)
 31a:	fd06079b          	addiw	a5,a2,-48
 31e:	0ff7f793          	andi	a5,a5,255
 322:	4725                	li	a4,9
 324:	02f76963          	bltu	a4,a5,356 <atoi+0x46>
 328:	86aa                	mv	a3,a0
  n = 0;
 32a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 32c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 32e:	0685                	addi	a3,a3,1
 330:	0025179b          	slliw	a5,a0,0x2
 334:	9fa9                	addw	a5,a5,a0
 336:	0017979b          	slliw	a5,a5,0x1
 33a:	9fb1                	addw	a5,a5,a2
 33c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 340:	0006c603          	lbu	a2,0(a3)
 344:	fd06071b          	addiw	a4,a2,-48
 348:	0ff77713          	andi	a4,a4,255
 34c:	fee5f1e3          	bgeu	a1,a4,32e <atoi+0x1e>
  return n;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
  n = 0;
 356:	4501                	li	a0,0
 358:	bfe5                	j	350 <atoi+0x40>

000000000000035a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 360:	02b57463          	bgeu	a0,a1,388 <memmove+0x2e>
    while(n-- > 0)
 364:	00c05f63          	blez	a2,382 <memmove+0x28>
 368:	1602                	slli	a2,a2,0x20
 36a:	9201                	srli	a2,a2,0x20
 36c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 370:	872a                	mv	a4,a0
      *dst++ = *src++;
 372:	0585                	addi	a1,a1,1
 374:	0705                	addi	a4,a4,1
 376:	fff5c683          	lbu	a3,-1(a1)
 37a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 37e:	fee79ae3          	bne	a5,a4,372 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret
    dst += n;
 388:	00c50733          	add	a4,a0,a2
    src += n;
 38c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 38e:	fec05ae3          	blez	a2,382 <memmove+0x28>
 392:	fff6079b          	addiw	a5,a2,-1
 396:	1782                	slli	a5,a5,0x20
 398:	9381                	srli	a5,a5,0x20
 39a:	fff7c793          	not	a5,a5
 39e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a0:	15fd                	addi	a1,a1,-1
 3a2:	177d                	addi	a4,a4,-1
 3a4:	0005c683          	lbu	a3,0(a1)
 3a8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ac:	fee79ae3          	bne	a5,a4,3a0 <memmove+0x46>
 3b0:	bfc9                	j	382 <memmove+0x28>

00000000000003b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b8:	ca05                	beqz	a2,3e8 <memcmp+0x36>
 3ba:	fff6069b          	addiw	a3,a2,-1
 3be:	1682                	slli	a3,a3,0x20
 3c0:	9281                	srli	a3,a3,0x20
 3c2:	0685                	addi	a3,a3,1
 3c4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c6:	00054783          	lbu	a5,0(a0)
 3ca:	0005c703          	lbu	a4,0(a1)
 3ce:	00e79863          	bne	a5,a4,3de <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d2:	0505                	addi	a0,a0,1
    p2++;
 3d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d6:	fed518e3          	bne	a0,a3,3c6 <memcmp+0x14>
  }
  return 0;
 3da:	4501                	li	a0,0
 3dc:	a019                	j	3e2 <memcmp+0x30>
      return *p1 - *p2;
 3de:	40e7853b          	subw	a0,a5,a4
}
 3e2:	6422                	ld	s0,8(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
  return 0;
 3e8:	4501                	li	a0,0
 3ea:	bfe5                	j	3e2 <memcmp+0x30>

00000000000003ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e406                	sd	ra,8(sp)
 3f0:	e022                	sd	s0,0(sp)
 3f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f4:	00000097          	auipc	ra,0x0
 3f8:	f66080e7          	jalr	-154(ra) # 35a <memmove>
}
 3fc:	60a2                	ld	ra,8(sp)
 3fe:	6402                	ld	s0,0(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret

0000000000000404 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 404:	4885                	li	a7,1
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <exit>:
.global exit
exit:
 li a7, SYS_exit
 40c:	4889                	li	a7,2
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <wait>:
.global wait
wait:
 li a7, SYS_wait
 414:	488d                	li	a7,3
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 41c:	4891                	li	a7,4
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <read>:
.global read
read:
 li a7, SYS_read
 424:	4895                	li	a7,5
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <write>:
.global write
write:
 li a7, SYS_write
 42c:	48c1                	li	a7,16
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <close>:
.global close
close:
 li a7, SYS_close
 434:	48d5                	li	a7,21
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <kill>:
.global kill
kill:
 li a7, SYS_kill
 43c:	4899                	li	a7,6
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <exec>:
.global exec
exec:
 li a7, SYS_exec
 444:	489d                	li	a7,7
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <open>:
.global open
open:
 li a7, SYS_open
 44c:	48bd                	li	a7,15
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 454:	48c5                	li	a7,17
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 45c:	48c9                	li	a7,18
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 464:	48a1                	li	a7,8
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <link>:
.global link
link:
 li a7, SYS_link
 46c:	48cd                	li	a7,19
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 474:	48d1                	li	a7,20
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 47c:	48a5                	li	a7,9
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <dup>:
.global dup
dup:
 li a7, SYS_dup
 484:	48a9                	li	a7,10
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 48c:	48ad                	li	a7,11
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 494:	48b1                	li	a7,12
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 49c:	48b5                	li	a7,13
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a4:	48b9                	li	a7,14
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ac:	1101                	addi	sp,sp,-32
 4ae:	ec06                	sd	ra,24(sp)
 4b0:	e822                	sd	s0,16(sp)
 4b2:	1000                	addi	s0,sp,32
 4b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b8:	4605                	li	a2,1
 4ba:	fef40593          	addi	a1,s0,-17
 4be:	00000097          	auipc	ra,0x0
 4c2:	f6e080e7          	jalr	-146(ra) # 42c <write>
}
 4c6:	60e2                	ld	ra,24(sp)
 4c8:	6442                	ld	s0,16(sp)
 4ca:	6105                	addi	sp,sp,32
 4cc:	8082                	ret

00000000000004ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ce:	7139                	addi	sp,sp,-64
 4d0:	fc06                	sd	ra,56(sp)
 4d2:	f822                	sd	s0,48(sp)
 4d4:	f426                	sd	s1,40(sp)
 4d6:	f04a                	sd	s2,32(sp)
 4d8:	ec4e                	sd	s3,24(sp)
 4da:	0080                	addi	s0,sp,64
 4dc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4de:	c299                	beqz	a3,4e4 <printint+0x16>
 4e0:	0805c863          	bltz	a1,570 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e4:	2581                	sext.w	a1,a1
  neg = 0;
 4e6:	4881                	li	a7,0
 4e8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ee:	2601                	sext.w	a2,a2
 4f0:	00000517          	auipc	a0,0x0
 4f4:	53050513          	addi	a0,a0,1328 # a20 <digits>
 4f8:	883a                	mv	a6,a4
 4fa:	2705                	addiw	a4,a4,1
 4fc:	02c5f7bb          	remuw	a5,a1,a2
 500:	1782                	slli	a5,a5,0x20
 502:	9381                	srli	a5,a5,0x20
 504:	97aa                	add	a5,a5,a0
 506:	0007c783          	lbu	a5,0(a5)
 50a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 50e:	0005879b          	sext.w	a5,a1
 512:	02c5d5bb          	divuw	a1,a1,a2
 516:	0685                	addi	a3,a3,1
 518:	fec7f0e3          	bgeu	a5,a2,4f8 <printint+0x2a>
  if(neg)
 51c:	00088b63          	beqz	a7,532 <printint+0x64>
    buf[i++] = '-';
 520:	fd040793          	addi	a5,s0,-48
 524:	973e                	add	a4,a4,a5
 526:	02d00793          	li	a5,45
 52a:	fef70823          	sb	a5,-16(a4)
 52e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 532:	02e05863          	blez	a4,562 <printint+0x94>
 536:	fc040793          	addi	a5,s0,-64
 53a:	00e78933          	add	s2,a5,a4
 53e:	fff78993          	addi	s3,a5,-1
 542:	99ba                	add	s3,s3,a4
 544:	377d                	addiw	a4,a4,-1
 546:	1702                	slli	a4,a4,0x20
 548:	9301                	srli	a4,a4,0x20
 54a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54e:	fff94583          	lbu	a1,-1(s2)
 552:	8526                	mv	a0,s1
 554:	00000097          	auipc	ra,0x0
 558:	f58080e7          	jalr	-168(ra) # 4ac <putc>
  while(--i >= 0)
 55c:	197d                	addi	s2,s2,-1
 55e:	ff3918e3          	bne	s2,s3,54e <printint+0x80>
}
 562:	70e2                	ld	ra,56(sp)
 564:	7442                	ld	s0,48(sp)
 566:	74a2                	ld	s1,40(sp)
 568:	7902                	ld	s2,32(sp)
 56a:	69e2                	ld	s3,24(sp)
 56c:	6121                	addi	sp,sp,64
 56e:	8082                	ret
    x = -xx;
 570:	40b005bb          	negw	a1,a1
    neg = 1;
 574:	4885                	li	a7,1
    x = -xx;
 576:	bf8d                	j	4e8 <printint+0x1a>

0000000000000578 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 578:	7119                	addi	sp,sp,-128
 57a:	fc86                	sd	ra,120(sp)
 57c:	f8a2                	sd	s0,112(sp)
 57e:	f4a6                	sd	s1,104(sp)
 580:	f0ca                	sd	s2,96(sp)
 582:	ecce                	sd	s3,88(sp)
 584:	e8d2                	sd	s4,80(sp)
 586:	e4d6                	sd	s5,72(sp)
 588:	e0da                	sd	s6,64(sp)
 58a:	fc5e                	sd	s7,56(sp)
 58c:	f862                	sd	s8,48(sp)
 58e:	f466                	sd	s9,40(sp)
 590:	f06a                	sd	s10,32(sp)
 592:	ec6e                	sd	s11,24(sp)
 594:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 596:	0005c903          	lbu	s2,0(a1)
 59a:	18090f63          	beqz	s2,738 <vprintf+0x1c0>
 59e:	8aaa                	mv	s5,a0
 5a0:	8b32                	mv	s6,a2
 5a2:	00158493          	addi	s1,a1,1
  state = 0;
 5a6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a8:	02500a13          	li	s4,37
      if(c == 'd'){
 5ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5b0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5bc:	00000b97          	auipc	s7,0x0
 5c0:	464b8b93          	addi	s7,s7,1124 # a20 <digits>
 5c4:	a839                	j	5e2 <vprintf+0x6a>
        putc(fd, c);
 5c6:	85ca                	mv	a1,s2
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	ee2080e7          	jalr	-286(ra) # 4ac <putc>
 5d2:	a019                	j	5d8 <vprintf+0x60>
    } else if(state == '%'){
 5d4:	01498f63          	beq	s3,s4,5f2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d8:	0485                	addi	s1,s1,1
 5da:	fff4c903          	lbu	s2,-1(s1)
 5de:	14090d63          	beqz	s2,738 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e6:	fe0997e3          	bnez	s3,5d4 <vprintf+0x5c>
      if(c == '%'){
 5ea:	fd479ee3          	bne	a5,s4,5c6 <vprintf+0x4e>
        state = '%';
 5ee:	89be                	mv	s3,a5
 5f0:	b7e5                	j	5d8 <vprintf+0x60>
      if(c == 'd'){
 5f2:	05878063          	beq	a5,s8,632 <vprintf+0xba>
      } else if(c == 'l') {
 5f6:	05978c63          	beq	a5,s9,64e <vprintf+0xd6>
      } else if(c == 'x') {
 5fa:	07a78863          	beq	a5,s10,66a <vprintf+0xf2>
      } else if(c == 'p') {
 5fe:	09b78463          	beq	a5,s11,686 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 602:	07300713          	li	a4,115
 606:	0ce78663          	beq	a5,a4,6d2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 60a:	06300713          	li	a4,99
 60e:	0ee78e63          	beq	a5,a4,70a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 612:	11478863          	beq	a5,s4,722 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 616:	85d2                	mv	a1,s4
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e92080e7          	jalr	-366(ra) # 4ac <putc>
        putc(fd, c);
 622:	85ca                	mv	a1,s2
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e86080e7          	jalr	-378(ra) # 4ac <putc>
      }
      state = 0;
 62e:	4981                	li	s3,0
 630:	b765                	j	5d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 632:	008b0913          	addi	s2,s6,8
 636:	4685                	li	a3,1
 638:	4629                	li	a2,10
 63a:	000b2583          	lw	a1,0(s6)
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e8e080e7          	jalr	-370(ra) # 4ce <printint>
 648:	8b4a                	mv	s6,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	b771                	j	5d8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64e:	008b0913          	addi	s2,s6,8
 652:	4681                	li	a3,0
 654:	4629                	li	a2,10
 656:	000b2583          	lw	a1,0(s6)
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e72080e7          	jalr	-398(ra) # 4ce <printint>
 664:	8b4a                	mv	s6,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bf85                	j	5d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 66a:	008b0913          	addi	s2,s6,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000b2583          	lw	a1,0(s6)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e56080e7          	jalr	-426(ra) # 4ce <printint>
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	bf91                	j	5d8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 686:	008b0793          	addi	a5,s6,8
 68a:	f8f43423          	sd	a5,-120(s0)
 68e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 692:	03000593          	li	a1,48
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e14080e7          	jalr	-492(ra) # 4ac <putc>
  putc(fd, 'x');
 6a0:	85ea                	mv	a1,s10
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e08080e7          	jalr	-504(ra) # 4ac <putc>
 6ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ae:	03c9d793          	srli	a5,s3,0x3c
 6b2:	97de                	add	a5,a5,s7
 6b4:	0007c583          	lbu	a1,0(a5)
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	df2080e7          	jalr	-526(ra) # 4ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c2:	0992                	slli	s3,s3,0x4
 6c4:	397d                	addiw	s2,s2,-1
 6c6:	fe0914e3          	bnez	s2,6ae <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6ca:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b721                	j	5d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d2:	008b0993          	addi	s3,s6,8
 6d6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6da:	02090163          	beqz	s2,6fc <vprintf+0x184>
        while(*s != 0){
 6de:	00094583          	lbu	a1,0(s2)
 6e2:	c9a1                	beqz	a1,732 <vprintf+0x1ba>
          putc(fd, *s);
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	dc6080e7          	jalr	-570(ra) # 4ac <putc>
          s++;
 6ee:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f0:	00094583          	lbu	a1,0(s2)
 6f4:	f9e5                	bnez	a1,6e4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f6:	8b4e                	mv	s6,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bdf9                	j	5d8 <vprintf+0x60>
          s = "(null)";
 6fc:	00000917          	auipc	s2,0x0
 700:	31c90913          	addi	s2,s2,796 # a18 <malloc+0x1d6>
        while(*s != 0){
 704:	02800593          	li	a1,40
 708:	bff1                	j	6e4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 70a:	008b0913          	addi	s2,s6,8
 70e:	000b4583          	lbu	a1,0(s6)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	d98080e7          	jalr	-616(ra) # 4ac <putc>
 71c:	8b4a                	mv	s6,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bd65                	j	5d8 <vprintf+0x60>
        putc(fd, c);
 722:	85d2                	mv	a1,s4
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	d86080e7          	jalr	-634(ra) # 4ac <putc>
      state = 0;
 72e:	4981                	li	s3,0
 730:	b565                	j	5d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 732:	8b4e                	mv	s6,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	b54d                	j	5d8 <vprintf+0x60>
    }
  }
}
 738:	70e6                	ld	ra,120(sp)
 73a:	7446                	ld	s0,112(sp)
 73c:	74a6                	ld	s1,104(sp)
 73e:	7906                	ld	s2,96(sp)
 740:	69e6                	ld	s3,88(sp)
 742:	6a46                	ld	s4,80(sp)
 744:	6aa6                	ld	s5,72(sp)
 746:	6b06                	ld	s6,64(sp)
 748:	7be2                	ld	s7,56(sp)
 74a:	7c42                	ld	s8,48(sp)
 74c:	7ca2                	ld	s9,40(sp)
 74e:	7d02                	ld	s10,32(sp)
 750:	6de2                	ld	s11,24(sp)
 752:	6109                	addi	sp,sp,128
 754:	8082                	ret

0000000000000756 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 756:	715d                	addi	sp,sp,-80
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e010                	sd	a2,0(s0)
 760:	e414                	sd	a3,8(s0)
 762:	e818                	sd	a4,16(s0)
 764:	ec1c                	sd	a5,24(s0)
 766:	03043023          	sd	a6,32(s0)
 76a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 772:	8622                	mv	a2,s0
 774:	00000097          	auipc	ra,0x0
 778:	e04080e7          	jalr	-508(ra) # 578 <vprintf>
}
 77c:	60e2                	ld	ra,24(sp)
 77e:	6442                	ld	s0,16(sp)
 780:	6161                	addi	sp,sp,80
 782:	8082                	ret

0000000000000784 <printf>:

void
printf(const char *fmt, ...)
{
 784:	711d                	addi	sp,sp,-96
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	e40c                	sd	a1,8(s0)
 78e:	e810                	sd	a2,16(s0)
 790:	ec14                	sd	a3,24(s0)
 792:	f018                	sd	a4,32(s0)
 794:	f41c                	sd	a5,40(s0)
 796:	03043823          	sd	a6,48(s0)
 79a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	00840613          	addi	a2,s0,8
 7a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a6:	85aa                	mv	a1,a0
 7a8:	4505                	li	a0,1
 7aa:	00000097          	auipc	ra,0x0
 7ae:	dce080e7          	jalr	-562(ra) # 578 <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6125                	addi	sp,sp,96
 7b8:	8082                	ret

00000000000007ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ba:	1141                	addi	sp,sp,-16
 7bc:	e422                	sd	s0,8(sp)
 7be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	00000797          	auipc	a5,0x0
 7c8:	2747b783          	ld	a5,628(a5) # a38 <freep>
 7cc:	a805                	j	7fc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ce:	4618                	lw	a4,8(a2)
 7d0:	9db9                	addw	a1,a1,a4
 7d2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d6:	6398                	ld	a4,0(a5)
 7d8:	6318                	ld	a4,0(a4)
 7da:	fee53823          	sd	a4,-16(a0)
 7de:	a091                	j	822 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e0:	ff852703          	lw	a4,-8(a0)
 7e4:	9e39                	addw	a2,a2,a4
 7e6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e8:	ff053703          	ld	a4,-16(a0)
 7ec:	e398                	sd	a4,0(a5)
 7ee:	a099                	j	834 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e7e463          	bltu	a5,a4,7fa <free+0x40>
 7f6:	00e6ea63          	bltu	a3,a4,80a <free+0x50>
{
 7fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fc:	fed7fae3          	bgeu	a5,a3,7f0 <free+0x36>
 800:	6398                	ld	a4,0(a5)
 802:	00e6e463          	bltu	a3,a4,80a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	fee7eae3          	bltu	a5,a4,7fa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 80a:	ff852583          	lw	a1,-8(a0)
 80e:	6390                	ld	a2,0(a5)
 810:	02059813          	slli	a6,a1,0x20
 814:	01c85713          	srli	a4,a6,0x1c
 818:	9736                	add	a4,a4,a3
 81a:	fae60ae3          	beq	a2,a4,7ce <free+0x14>
    bp->s.ptr = p->s.ptr;
 81e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 822:	4790                	lw	a2,8(a5)
 824:	02061593          	slli	a1,a2,0x20
 828:	01c5d713          	srli	a4,a1,0x1c
 82c:	973e                	add	a4,a4,a5
 82e:	fae689e3          	beq	a3,a4,7e0 <free+0x26>
  } else
    p->s.ptr = bp;
 832:	e394                	sd	a3,0(a5)
  freep = p;
 834:	00000717          	auipc	a4,0x0
 838:	20f73223          	sd	a5,516(a4) # a38 <freep>
}
 83c:	6422                	ld	s0,8(sp)
 83e:	0141                	addi	sp,sp,16
 840:	8082                	ret

0000000000000842 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 842:	7139                	addi	sp,sp,-64
 844:	fc06                	sd	ra,56(sp)
 846:	f822                	sd	s0,48(sp)
 848:	f426                	sd	s1,40(sp)
 84a:	f04a                	sd	s2,32(sp)
 84c:	ec4e                	sd	s3,24(sp)
 84e:	e852                	sd	s4,16(sp)
 850:	e456                	sd	s5,8(sp)
 852:	e05a                	sd	s6,0(sp)
 854:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 856:	02051493          	slli	s1,a0,0x20
 85a:	9081                	srli	s1,s1,0x20
 85c:	04bd                	addi	s1,s1,15
 85e:	8091                	srli	s1,s1,0x4
 860:	0014899b          	addiw	s3,s1,1
 864:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 866:	00000517          	auipc	a0,0x0
 86a:	1d253503          	ld	a0,466(a0) # a38 <freep>
 86e:	c515                	beqz	a0,89a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	02977f63          	bgeu	a4,s1,8b2 <malloc+0x70>
 878:	8a4e                	mv	s4,s3
 87a:	0009871b          	sext.w	a4,s3
 87e:	6685                	lui	a3,0x1
 880:	00d77363          	bgeu	a4,a3,886 <malloc+0x44>
 884:	6a05                	lui	s4,0x1
 886:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88e:	00000917          	auipc	s2,0x0
 892:	1aa90913          	addi	s2,s2,426 # a38 <freep>
  if(p == (char*)-1)
 896:	5afd                	li	s5,-1
 898:	a895                	j	90c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 89a:	00000797          	auipc	a5,0x0
 89e:	1a678793          	addi	a5,a5,422 # a40 <base>
 8a2:	00000717          	auipc	a4,0x0
 8a6:	18f73b23          	sd	a5,406(a4) # a38 <freep>
 8aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b0:	b7e1                	j	878 <malloc+0x36>
      if(p->s.size == nunits)
 8b2:	02e48c63          	beq	s1,a4,8ea <malloc+0xa8>
        p->s.size -= nunits;
 8b6:	4137073b          	subw	a4,a4,s3
 8ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8bc:	02071693          	slli	a3,a4,0x20
 8c0:	01c6d713          	srli	a4,a3,0x1c
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	16a73723          	sd	a0,366(a4) # a38 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	bff1                	j	8ca <malloc+0x88>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	00000097          	auipc	ra,0x0
 8fa:	ec4080e7          	jalr	-316(ra) # 7ba <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	d971                	beqz	a0,8d6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	fa9775e3          	bgeu	a4,s1,8b2 <malloc+0x70>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	00000097          	auipc	ra,0x0
 91c:	b7c080e7          	jalr	-1156(ra) # 494 <sbrk>
  if(p == (char*)-1)
 920:	fd5518e3          	bne	a0,s5,8f0 <malloc+0xae>
        return 0;
 924:	4501                	li	a0,0
 926:	bf45                	j	8d6 <malloc+0x94>
