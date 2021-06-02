
user/_tests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <child_test>:

#define PRINT_TEST_START(TEST_NAME)   printf("\n----------------------\nstarting test - %s\n----------------------\n",TEST_NAME);
#define PRINT_TEST_END(TEST_NAME)   printf("\nfinished test - %s\n----------------------\n",TEST_NAME);


void child_test() {
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	1080                	addi	s0,sp,96
    PRINT_TEST_START("child test");
  18:	00001597          	auipc	a1,0x1
  1c:	f6858593          	addi	a1,a1,-152 # f80 <malloc+0xea>
  20:	00001517          	auipc	a0,0x1
  24:	f7050513          	addi	a0,a0,-144 # f90 <malloc+0xfa>
  28:	00001097          	auipc	ra,0x1
  2c:	db0080e7          	jalr	-592(ra) # dd8 <printf>
    if (!fork()) {
  30:	00001097          	auipc	ra,0x1
  34:	a20080e7          	jalr	-1504(ra) # a50 <fork>
  38:	cd15                	beqz	a0,74 <child_test+0x74>
            free(arr[i]);
            printf("arr[%d] avg = %d\n", i, sum);
        }
        exit(0);
    } else {
        wait(0);
  3a:	4501                	li	a0,0
  3c:	00001097          	auipc	ra,0x1
  40:	a24080e7          	jalr	-1500(ra) # a60 <wait>
    }
    PRINT_TEST_END("child test");
  44:	00001597          	auipc	a1,0x1
  48:	f3c58593          	addi	a1,a1,-196 # f80 <malloc+0xea>
  4c:	00001517          	auipc	a0,0x1
  50:	fa450513          	addi	a0,a0,-92 # ff0 <malloc+0x15a>
  54:	00001097          	auipc	ra,0x1
  58:	d84080e7          	jalr	-636(ra) # dd8 <printf>
}
  5c:	60e6                	ld	ra,88(sp)
  5e:	6446                	ld	s0,80(sp)
  60:	64a6                	ld	s1,72(sp)
  62:	6906                	ld	s2,64(sp)
  64:	79e2                	ld	s3,56(sp)
  66:	7a42                	ld	s4,48(sp)
  68:	7aa2                	ld	s5,40(sp)
  6a:	7b02                	ld	s6,32(sp)
  6c:	6be2                	ld	s7,24(sp)
  6e:	6c42                	ld	s8,16(sp)
  70:	6125                	addi	sp,sp,96
  72:	8082                	ret
  74:	84aa                	mv	s1,a0
            arr[i] = (int *) (malloc(MEM_SIZE * sizeof(int)));
  76:	6a29                	lui	s4,0xa
  78:	c40a0513          	addi	a0,s4,-960 # 9c40 <__global_pointer$+0x8257>
  7c:	00001097          	auipc	ra,0x1
  80:	e1a080e7          	jalr	-486(ra) # e96 <malloc>
  84:	892a                	mv	s2,a0
  86:	faa43023          	sd	a0,-96(s0)
            children[i] = fork();
  8a:	00001097          	auipc	ra,0x1
  8e:	9c6080e7          	jalr	-1594(ra) # a50 <fork>
  92:	86aa                	mv	a3,a0
        int ind = 0;
  94:	00153993          	seqz	s3,a0
            for (int j = 0; j < MEM_SIZE; ++j) {
  98:	87ca                	mv	a5,s2
  9a:	c40a0713          	addi	a4,s4,-960
  9e:	974a                	add	a4,a4,s2
                arr[i][j] = children[i];
  a0:	c394                	sw	a3,0(a5)
            for (int j = 0; j < MEM_SIZE; ++j) {
  a2:	0791                	addi	a5,a5,4
  a4:	fee79ee3          	bne	a5,a4,a0 <child_test+0xa0>
            arr[i] = (int *) (malloc(MEM_SIZE * sizeof(int)));
  a8:	6529                	lui	a0,0xa
  aa:	c4050513          	addi	a0,a0,-960 # 9c40 <__global_pointer$+0x8257>
  ae:	00001097          	auipc	ra,0x1
  b2:	de8080e7          	jalr	-536(ra) # e96 <malloc>
  b6:	892a                	mv	s2,a0
  b8:	faa43423          	sd	a0,-88(s0)
            children[i] = fork();
  bc:	00001097          	auipc	ra,0x1
  c0:	994080e7          	jalr	-1644(ra) # a50 <fork>
  c4:	86aa                	mv	a3,a0
            ind = children[i] ? ind : i + 1;
  c6:	e111                	bnez	a0,ca <child_test+0xca>
  c8:	4989                	li	s3,2
            for (int j = 0; j < MEM_SIZE; ++j) {
  ca:	87ca                	mv	a5,s2
  cc:	6729                	lui	a4,0xa
  ce:	c4070713          	addi	a4,a4,-960 # 9c40 <__global_pointer$+0x8257>
  d2:	974a                	add	a4,a4,s2
                arr[i][j] = children[i];
  d4:	c394                	sw	a3,0(a5)
            for (int j = 0; j < MEM_SIZE; ++j) {
  d6:	0791                	addi	a5,a5,4
  d8:	fee79ee3          	bne	a5,a4,d4 <child_test+0xd4>
        for (int i = ind; i < CHILD_NUM; ++i) {
  dc:	4785                	li	a5,1
  de:	0137cb63          	blt	a5,s3,f4 <child_test+0xf4>
  e2:	4909                	li	s2,2
            wait(0);
  e4:	4501                	li	a0,0
  e6:	00001097          	auipc	ra,0x1
  ea:	97a080e7          	jalr	-1670(ra) # a60 <wait>
        for (int i = ind; i < CHILD_NUM; ++i) {
  ee:	2985                	addiw	s3,s3,1
  f0:	ff299ae3          	bne	s3,s2,e4 <child_test+0xe4>
        for (int i = 0; i < CHILD_NUM; ++i) {
  f4:	fa040b13          	addi	s6,s0,-96
  f8:	89a6                	mv	s3,s1
  fa:	6aa9                	lui	s5,0xa
  fc:	c40a8a93          	addi	s5,s5,-960 # 9c40 <__global_pointer$+0x8257>
            sum = sum / MEM_SIZE;
 100:	6a09                	lui	s4,0x2
 102:	710a0a1b          	addiw	s4,s4,1808
            printf("arr[%d] avg = %d\n", i, sum);
 106:	00001c17          	auipc	s8,0x1
 10a:	ed2c0c13          	addi	s8,s8,-302 # fd8 <malloc+0x142>
        for (int i = 0; i < CHILD_NUM; ++i) {
 10e:	4b89                	li	s7,2
                sum = sum + arr[i][j];
 110:	000b3503          	ld	a0,0(s6)
 114:	87aa                	mv	a5,a0
 116:	015506b3          	add	a3,a0,s5
            int sum = 0;
 11a:	8926                	mv	s2,s1
                sum = sum + arr[i][j];
 11c:	4398                	lw	a4,0(a5)
 11e:	0127093b          	addw	s2,a4,s2
            for (int j = 0; j < MEM_SIZE; ++j) {
 122:	0791                	addi	a5,a5,4
 124:	fed79ce3          	bne	a5,a3,11c <child_test+0x11c>
            free(arr[i]);
 128:	00001097          	auipc	ra,0x1
 12c:	ce6080e7          	jalr	-794(ra) # e0e <free>
            printf("arr[%d] avg = %d\n", i, sum);
 130:	0349463b          	divw	a2,s2,s4
 134:	85ce                	mv	a1,s3
 136:	8562                	mv	a0,s8
 138:	00001097          	auipc	ra,0x1
 13c:	ca0080e7          	jalr	-864(ra) # dd8 <printf>
        for (int i = 0; i < CHILD_NUM; ++i) {
 140:	2985                	addiw	s3,s3,1
 142:	0b21                	addi	s6,s6,8
 144:	fd7996e3          	bne	s3,s7,110 <child_test+0x110>
        exit(0);
 148:	4501                	li	a0,0
 14a:	00001097          	auipc	ra,0x1
 14e:	90e080e7          	jalr	-1778(ra) # a58 <exit>

0000000000000152 <alloc_dealloc_test>:

void alloc_dealloc_test() {
 152:	7139                	addi	sp,sp,-64
 154:	fc06                	sd	ra,56(sp)
 156:	f822                	sd	s0,48(sp)
 158:	f426                	sd	s1,40(sp)
 15a:	f04a                	sd	s2,32(sp)
 15c:	ec4e                	sd	s3,24(sp)
 15e:	e852                	sd	s4,16(sp)
 160:	e456                	sd	s5,8(sp)
 162:	0080                	addi	s0,sp,64
    PRINT_TEST_START("alloc dealloc test");
 164:	00001597          	auipc	a1,0x1
 168:	ebc58593          	addi	a1,a1,-324 # 1020 <malloc+0x18a>
 16c:	00001517          	auipc	a0,0x1
 170:	e2450513          	addi	a0,a0,-476 # f90 <malloc+0xfa>
 174:	00001097          	auipc	ra,0x1
 178:	c64080e7          	jalr	-924(ra) # dd8 <printf>
    printf("alloc dealloc test\n");
 17c:	00001517          	auipc	a0,0x1
 180:	ebc50513          	addi	a0,a0,-324 # 1038 <malloc+0x1a2>
 184:	00001097          	auipc	ra,0x1
 188:	c54080e7          	jalr	-940(ra) # dd8 <printf>
    if (!fork()) {
 18c:	00001097          	auipc	ra,0x1
 190:	8c4080e7          	jalr	-1852(ra) # a50 <fork>
 194:	c91d                	beqz	a0,1ca <alloc_dealloc_test+0x78>
            }
        }
        sbrk(-PGSIZE * 20);
        exit(0);
    } else {
        wait(0);
 196:	4501                	li	a0,0
 198:	00001097          	auipc	ra,0x1
 19c:	8c8080e7          	jalr	-1848(ra) # a60 <wait>
    }
    PRINT_TEST_END("alloc dealloc test");
 1a0:	00001597          	auipc	a1,0x1
 1a4:	e8058593          	addi	a1,a1,-384 # 1020 <malloc+0x18a>
 1a8:	00001517          	auipc	a0,0x1
 1ac:	e4850513          	addi	a0,a0,-440 # ff0 <malloc+0x15a>
 1b0:	00001097          	auipc	ra,0x1
 1b4:	c28080e7          	jalr	-984(ra) # dd8 <printf>
}
 1b8:	70e2                	ld	ra,56(sp)
 1ba:	7442                	ld	s0,48(sp)
 1bc:	74a2                	ld	s1,40(sp)
 1be:	7902                	ld	s2,32(sp)
 1c0:	69e2                	ld	s3,24(sp)
 1c2:	6a42                	ld	s4,16(sp)
 1c4:	6aa2                	ld	s5,8(sp)
 1c6:	6121                	addi	sp,sp,64
 1c8:	8082                	ret
 1ca:	84aa                	mv	s1,a0
        int *arr = (int *) (sbrk(PGSIZE * 20));
 1cc:	6551                	lui	a0,0x14
 1ce:	00001097          	auipc	ra,0x1
 1d2:	912080e7          	jalr	-1774(ra) # ae0 <sbrk>
 1d6:	87aa                	mv	a5,a0
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 0; }
 1d8:	6751                	lui	a4,0x14
 1da:	972a                	add	a4,a4,a0
 1dc:	0007a023          	sw	zero,0(a5)
 1e0:	0791                	addi	a5,a5,4
 1e2:	fee79de3          	bne	a5,a4,1dc <alloc_dealloc_test+0x8a>
        sbrk(-PGSIZE * 20);
 1e6:	7531                	lui	a0,0xfffec
 1e8:	00001097          	auipc	ra,0x1
 1ec:	8f8080e7          	jalr	-1800(ra) # ae0 <sbrk>
        printf("dealloc complete\n");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	e6050513          	addi	a0,a0,-416 # 1050 <malloc+0x1ba>
 1f8:	00001097          	auipc	ra,0x1
 1fc:	be0080e7          	jalr	-1056(ra) # dd8 <printf>
        arr = (int *) (sbrk(PGSIZE * 20));
 200:	6551                	lui	a0,0x14
 202:	00001097          	auipc	ra,0x1
 206:	8de080e7          	jalr	-1826(ra) # ae0 <sbrk>
 20a:	892a                	mv	s2,a0
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 2; }
 20c:	6751                	lui	a4,0x14
 20e:	972a                	add	a4,a4,a0
        arr = (int *) (sbrk(PGSIZE * 20));
 210:	87aa                	mv	a5,a0
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 2; }
 212:	4689                	li	a3,2
 214:	c394                	sw	a3,0(a5)
 216:	0791                	addi	a5,a5,4
 218:	fef71ee3          	bne	a4,a5,214 <alloc_dealloc_test+0xc2>
            if (i % PGSIZE == 0) {
 21c:	6985                	lui	s3,0x1
 21e:	19fd                	addi	s3,s3,-1
                printf("arr[%d]=%d\n", i, arr[i]);
 220:	00001a97          	auipc	s5,0x1
 224:	e48a8a93          	addi	s5,s5,-440 # 1068 <malloc+0x1d2>
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) {
 228:	6a15                	lui	s4,0x5
 22a:	a029                	j	234 <alloc_dealloc_test+0xe2>
 22c:	2485                	addiw	s1,s1,1
 22e:	0911                	addi	s2,s2,4
 230:	01448f63          	beq	s1,s4,24e <alloc_dealloc_test+0xfc>
            if (i % PGSIZE == 0) {
 234:	0134f7b3          	and	a5,s1,s3
 238:	2781                	sext.w	a5,a5
 23a:	fbed                	bnez	a5,22c <alloc_dealloc_test+0xda>
                printf("arr[%d]=%d\n", i, arr[i]);
 23c:	00092603          	lw	a2,0(s2)
 240:	85a6                	mv	a1,s1
 242:	8556                	mv	a0,s5
 244:	00001097          	auipc	ra,0x1
 248:	b94080e7          	jalr	-1132(ra) # dd8 <printf>
 24c:	b7c5                	j	22c <alloc_dealloc_test+0xda>
        sbrk(-PGSIZE * 20);
 24e:	7531                	lui	a0,0xfffec
 250:	00001097          	auipc	ra,0x1
 254:	890080e7          	jalr	-1904(ra) # ae0 <sbrk>
        exit(0);
 258:	4501                	li	a0,0
 25a:	00000097          	auipc	ra,0x0
 25e:	7fe080e7          	jalr	2046(ra) # a58 <exit>

0000000000000262 <advance_alloc_dealloc_test>:

void advance_alloc_dealloc_test() {
 262:	7139                	addi	sp,sp,-64
 264:	fc06                	sd	ra,56(sp)
 266:	f822                	sd	s0,48(sp)
 268:	f426                	sd	s1,40(sp)
 26a:	f04a                	sd	s2,32(sp)
 26c:	ec4e                	sd	s3,24(sp)
 26e:	e852                	sd	s4,16(sp)
 270:	e456                	sd	s5,8(sp)
 272:	e05a                	sd	s6,0(sp)
 274:	0080                	addi	s0,sp,64
    PRINT_TEST_START("advanced alloc dealloc test");
 276:	00001597          	auipc	a1,0x1
 27a:	e0258593          	addi	a1,a1,-510 # 1078 <malloc+0x1e2>
 27e:	00001517          	auipc	a0,0x1
 282:	d1250513          	addi	a0,a0,-750 # f90 <malloc+0xfa>
 286:	00001097          	auipc	ra,0x1
 28a:	b52080e7          	jalr	-1198(ra) # dd8 <printf>
    if (!fork()) {
 28e:	00000097          	auipc	ra,0x0
 292:	7c2080e7          	jalr	1986(ra) # a50 <fork>
 296:	10051f63          	bnez	a0,3b4 <advance_alloc_dealloc_test+0x152>
 29a:	89aa                	mv	s3,a0
        int *arr = (int *) (sbrk(PGSIZE * 20));
 29c:	6551                	lui	a0,0x14
 29e:	00001097          	auipc	ra,0x1
 2a2:	842080e7          	jalr	-1982(ra) # ae0 <sbrk>
 2a6:	84aa                	mv	s1,a0
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 0; }
 2a8:	6951                	lui	s2,0x14
 2aa:	992a                	add	s2,s2,a0
        int *arr = (int *) (sbrk(PGSIZE * 20));
 2ac:	87aa                	mv	a5,a0
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 0; }
 2ae:	0007a023          	sw	zero,0(a5)
 2b2:	0791                	addi	a5,a5,4
 2b4:	ff279de3          	bne	a5,s2,2ae <advance_alloc_dealloc_test+0x4c>
        int pid = fork();
 2b8:	00000097          	auipc	ra,0x0
 2bc:	798080e7          	jalr	1944(ra) # a50 <fork>
        if (!pid) {
 2c0:	e921                	bnez	a0,310 <advance_alloc_dealloc_test+0xae>
            sbrk(-PGSIZE * 20);
 2c2:	7531                	lui	a0,0xfffec
 2c4:	00001097          	auipc	ra,0x1
 2c8:	81c080e7          	jalr	-2020(ra) # ae0 <sbrk>
            printf("dealloc complete\n");
 2cc:	00001517          	auipc	a0,0x1
 2d0:	d8450513          	addi	a0,a0,-636 # 1050 <malloc+0x1ba>
 2d4:	00001097          	auipc	ra,0x1
 2d8:	b04080e7          	jalr	-1276(ra) # dd8 <printf>
            printf("should cause segmentation fault\n");
 2dc:	00001517          	auipc	a0,0x1
 2e0:	dbc50513          	addi	a0,a0,-580 # 1098 <malloc+0x202>
 2e4:	00001097          	auipc	ra,0x1
 2e8:	af4080e7          	jalr	-1292(ra) # dd8 <printf>
            for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) {
                arr[i] = 1;
 2ec:	4785                	li	a5,1
 2ee:	c09c                	sw	a5,0(s1)
            for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) {
 2f0:	0491                	addi	s1,s1,4
 2f2:	ff249ee3          	bne	s1,s2,2ee <advance_alloc_dealloc_test+0x8c>
            }
            printf("test failed\n");
 2f6:	00001517          	auipc	a0,0x1
 2fa:	dca50513          	addi	a0,a0,-566 # 10c0 <malloc+0x22a>
 2fe:	00001097          	auipc	ra,0x1
 302:	ada080e7          	jalr	-1318(ra) # dd8 <printf>
            exit(0);
 306:	4501                	li	a0,0
 308:	00000097          	auipc	ra,0x0
 30c:	750080e7          	jalr	1872(ra) # a58 <exit>
        }
        wait(0);
 310:	4501                	li	a0,0
 312:	00000097          	auipc	ra,0x0
 316:	74e080e7          	jalr	1870(ra) # a60 <wait>
 31a:	6795                	lui	a5,0x5
        int sum = 0;
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { sum = sum + arr[i]; }
 31c:	37fd                	addiw	a5,a5,-1
 31e:	fffd                	bnez	a5,31c <advance_alloc_dealloc_test+0xba>
        sbrk(-PGSIZE * 20);
 320:	7531                	lui	a0,0xfffec
 322:	00000097          	auipc	ra,0x0
 326:	7be080e7          	jalr	1982(ra) # ae0 <sbrk>
        int father = 1;
        char *bytes;
        char *origStart = sbrk(0);
 32a:	4501                	li	a0,0
 32c:	00000097          	auipc	ra,0x0
 330:	7b4080e7          	jalr	1972(ra) # ae0 <sbrk>
 334:	8aaa                	mv	s5,a0
        int count = 0;
        int max_size = 0;
 336:	894e                	mv	s2,s3
        for (int i = 0; i < 20; ++i) {
            father = father && fork() > 0;
            if (!father) { break; }
            if (father) {
                bytes = (char *) (sbrk(PGSIZE));
                max_size = max_size + PGSIZE;
 338:	6b05                	lui	s6,0x1
                for (int i = 0; i < PGSIZE; ++i) { bytes[i] = 1; }
 33a:	4485                	li	s1,1
        for (int i = 0; i < 20; ++i) {
 33c:	6a51                	lui	s4,0x14
            father = father && fork() > 0;
 33e:	00000097          	auipc	ra,0x0
 342:	712080e7          	jalr	1810(ra) # a50 <fork>
 346:	0aa05263          	blez	a0,3ea <advance_alloc_dealloc_test+0x188>
                bytes = (char *) (sbrk(PGSIZE));
 34a:	6505                	lui	a0,0x1
 34c:	00000097          	auipc	ra,0x0
 350:	794080e7          	jalr	1940(ra) # ae0 <sbrk>
                max_size = max_size + PGSIZE;
 354:	012b093b          	addw	s2,s6,s2
                for (int i = 0; i < PGSIZE; ++i) { bytes[i] = 1; }
 358:	87aa                	mv	a5,a0
 35a:	6705                	lui	a4,0x1
 35c:	972a                	add	a4,a4,a0
 35e:	00978023          	sb	s1,0(a5) # 5000 <__global_pointer$+0x3617>
 362:	0785                	addi	a5,a5,1
 364:	fef71de3          	bne	a4,a5,35e <advance_alloc_dealloc_test+0xfc>
        for (int i = 0; i < 20; ++i) {
 368:	fd491be3          	bne	s2,s4,33e <advance_alloc_dealloc_test+0xdc>
 36c:	4485                	li	s1,1
            father = father && fork() > 0;
 36e:	4781                	li	a5,0
            }
        }
        for (int i = 0; i < max_size; ++i) {
            count = count + origStart[i];
 370:	00fa8733          	add	a4,s5,a5
 374:	00074703          	lbu	a4,0(a4) # 1000 <malloc+0x16a>
 378:	013709bb          	addw	s3,a4,s3
        for (int i = 0; i < max_size; ++i) {
 37c:	0785                	addi	a5,a5,1
 37e:	0007871b          	sext.w	a4,a5
 382:	ff2747e3          	blt	a4,s2,370 <advance_alloc_dealloc_test+0x10e>
        }
        printf("count:%d\n", count);
 386:	85ce                	mv	a1,s3
 388:	00001517          	auipc	a0,0x1
 38c:	d4850513          	addi	a0,a0,-696 # 10d0 <malloc+0x23a>
 390:	00001097          	auipc	ra,0x1
 394:	a48080e7          	jalr	-1464(ra) # dd8 <printf>
        if (father) {
 398:	c889                	beqz	s1,3aa <advance_alloc_dealloc_test+0x148>
 39a:	44d1                	li	s1,20
            for (int i = 0; i < 20; ++i) { wait(0); }
 39c:	4501                	li	a0,0
 39e:	00000097          	auipc	ra,0x0
 3a2:	6c2080e7          	jalr	1730(ra) # a60 <wait>
 3a6:	34fd                	addiw	s1,s1,-1
 3a8:	f8f5                	bnez	s1,39c <advance_alloc_dealloc_test+0x13a>
        }
        exit(0);
 3aa:	4501                	li	a0,0
 3ac:	00000097          	auipc	ra,0x0
 3b0:	6ac080e7          	jalr	1708(ra) # a58 <exit>
    } else {
        wait(0);
 3b4:	4501                	li	a0,0
 3b6:	00000097          	auipc	ra,0x0
 3ba:	6aa080e7          	jalr	1706(ra) # a60 <wait>
    }
    PRINT_TEST_END("advanced alloc dealloc test");
 3be:	00001597          	auipc	a1,0x1
 3c2:	cba58593          	addi	a1,a1,-838 # 1078 <malloc+0x1e2>
 3c6:	00001517          	auipc	a0,0x1
 3ca:	c2a50513          	addi	a0,a0,-982 # ff0 <malloc+0x15a>
 3ce:	00001097          	auipc	ra,0x1
 3d2:	a0a080e7          	jalr	-1526(ra) # dd8 <printf>
}
 3d6:	70e2                	ld	ra,56(sp)
 3d8:	7442                	ld	s0,48(sp)
 3da:	74a2                	ld	s1,40(sp)
 3dc:	7902                	ld	s2,32(sp)
 3de:	69e2                	ld	s3,24(sp)
 3e0:	6a42                	ld	s4,16(sp)
 3e2:	6aa2                	ld	s5,8(sp)
 3e4:	6b02                	ld	s6,0(sp)
 3e6:	6121                	addi	sp,sp,64
 3e8:	8082                	ret
            father = father && fork() > 0;
 3ea:	84ce                	mv	s1,s3
        for (int i = 0; i < max_size; ++i) {
 3ec:	f92041e3          	bgtz	s2,36e <advance_alloc_dealloc_test+0x10c>
        printf("count:%d\n", count);
 3f0:	4581                	li	a1,0
 3f2:	00001517          	auipc	a0,0x1
 3f6:	cde50513          	addi	a0,a0,-802 # 10d0 <malloc+0x23a>
 3fa:	00001097          	auipc	ra,0x1
 3fe:	9de080e7          	jalr	-1570(ra) # dd8 <printf>
        if (father) {
 402:	b765                	j	3aa <advance_alloc_dealloc_test+0x148>

0000000000000404 <exec_test>:

void exec_test() {
 404:	7179                	addi	sp,sp,-48
 406:	f406                	sd	ra,40(sp)
 408:	f022                	sd	s0,32(sp)
 40a:	1800                	addi	s0,sp,48
    PRINT_TEST_START("exec test");
 40c:	00001597          	auipc	a1,0x1
 410:	cd458593          	addi	a1,a1,-812 # 10e0 <malloc+0x24a>
 414:	00001517          	auipc	a0,0x1
 418:	b7c50513          	addi	a0,a0,-1156 # f90 <malloc+0xfa>
 41c:	00001097          	auipc	ra,0x1
 420:	9bc080e7          	jalr	-1604(ra) # dd8 <printf>
    if (!fork()) {
 424:	00000097          	auipc	ra,0x0
 428:	62c080e7          	jalr	1580(ra) # a50 <fork>
 42c:	c515                	beqz	a0,458 <exec_test+0x54>
        } else {
            wait(0);
        }
        exit(0);
    } else {
        wait(0);
 42e:	4501                	li	a0,0
 430:	00000097          	auipc	ra,0x0
 434:	630080e7          	jalr	1584(ra) # a60 <wait>
    }
    PRINT_TEST_END("exec test");
 438:	00001597          	auipc	a1,0x1
 43c:	ca858593          	addi	a1,a1,-856 # 10e0 <malloc+0x24a>
 440:	00001517          	auipc	a0,0x1
 444:	bb050513          	addi	a0,a0,-1104 # ff0 <malloc+0x15a>
 448:	00001097          	auipc	ra,0x1
 44c:	990080e7          	jalr	-1648(ra) # dd8 <printf>
}
 450:	70a2                	ld	ra,40(sp)
 452:	7402                	ld	s0,32(sp)
 454:	6145                	addi	sp,sp,48
 456:	8082                	ret
        printf("allocating pages\n");
 458:	00001517          	auipc	a0,0x1
 45c:	c9850513          	addi	a0,a0,-872 # 10f0 <malloc+0x25a>
 460:	00001097          	auipc	ra,0x1
 464:	978080e7          	jalr	-1672(ra) # dd8 <printf>
        int *arr = (int *) (malloc(sizeof(int) * 5 * PGSIZE));
 468:	6551                	lui	a0,0x14
 46a:	00001097          	auipc	ra,0x1
 46e:	a2c080e7          	jalr	-1492(ra) # e96 <malloc>
            arr[i] = i / PGSIZE;
 472:	00052023          	sw	zero,0(a0) # 14000 <__global_pointer$+0x12617>
 476:	6711                	lui	a4,0x4
 478:	972a                	add	a4,a4,a0
 47a:	4685                	li	a3,1
 47c:	c314                	sw	a3,0(a4)
 47e:	6721                	lui	a4,0x8
 480:	972a                	add	a4,a4,a0
 482:	4689                	li	a3,2
 484:	c314                	sw	a3,0(a4)
 486:	6731                	lui	a4,0xc
 488:	972a                	add	a4,a4,a0
 48a:	468d                	li	a3,3
 48c:	c314                	sw	a3,0(a4)
 48e:	6741                	lui	a4,0x10
 490:	00e507b3          	add	a5,a0,a4
 494:	4711                	li	a4,4
 496:	c398                	sw	a4,0(a5)
        printf("forking\n");
 498:	00001517          	auipc	a0,0x1
 49c:	c7050513          	addi	a0,a0,-912 # 1108 <malloc+0x272>
 4a0:	00001097          	auipc	ra,0x1
 4a4:	938080e7          	jalr	-1736(ra) # dd8 <printf>
        int pid = fork();
 4a8:	00000097          	auipc	ra,0x0
 4ac:	5a8080e7          	jalr	1448(ra) # a50 <fork>
        if (!pid) {
 4b0:	e915                	bnez	a0,4e4 <exec_test+0xe0>
            char *argv[] = {"myMemTest", "exectest", 0};
 4b2:	00001517          	auipc	a0,0x1
 4b6:	c6650513          	addi	a0,a0,-922 # 1118 <malloc+0x282>
 4ba:	fca43c23          	sd	a0,-40(s0)
 4be:	00001797          	auipc	a5,0x1
 4c2:	c6a78793          	addi	a5,a5,-918 # 1128 <malloc+0x292>
 4c6:	fef43023          	sd	a5,-32(s0)
 4ca:	fe043423          	sd	zero,-24(s0)
            exec(argv[0], argv);
 4ce:	fd840593          	addi	a1,s0,-40
 4d2:	00000097          	auipc	ra,0x0
 4d6:	5be080e7          	jalr	1470(ra) # a90 <exec>
        exit(0);
 4da:	4501                	li	a0,0
 4dc:	00000097          	auipc	ra,0x0
 4e0:	57c080e7          	jalr	1404(ra) # a58 <exit>
            wait(0);
 4e4:	4501                	li	a0,0
 4e6:	00000097          	auipc	ra,0x0
 4ea:	57a080e7          	jalr	1402(ra) # a60 <wait>
 4ee:	b7f5                	j	4da <exec_test+0xd6>

00000000000004f0 <exec_test_child>:

void exec_test_child() {
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e406                	sd	ra,8(sp)
 4f4:	e022                	sd	s0,0(sp)
 4f6:	0800                	addi	s0,sp,16
    printf("child allocating pages\n");
 4f8:	00001517          	auipc	a0,0x1
 4fc:	c4050513          	addi	a0,a0,-960 # 1138 <malloc+0x2a2>
 500:	00001097          	auipc	ra,0x1
 504:	8d8080e7          	jalr	-1832(ra) # dd8 <printf>
    int *arr = (int *) (malloc(sizeof(int) * 5 * PGSIZE));
 508:	6551                	lui	a0,0x14
 50a:	00001097          	auipc	ra,0x1
 50e:	98c080e7          	jalr	-1652(ra) # e96 <malloc>
    for (int i = 0; i < 5 * PGSIZE; i = i + PGSIZE) {
        arr[i] = i / PGSIZE;
 512:	00052023          	sw	zero,0(a0) # 14000 <__global_pointer$+0x12617>
 516:	6791                	lui	a5,0x4
 518:	97aa                	add	a5,a5,a0
 51a:	4705                	li	a4,1
 51c:	c398                	sw	a4,0(a5)
 51e:	67a1                	lui	a5,0x8
 520:	97aa                	add	a5,a5,a0
 522:	4709                	li	a4,2
 524:	c398                	sw	a4,0(a5)
 526:	67b1                	lui	a5,0xc
 528:	97aa                	add	a5,a5,a0
 52a:	470d                	li	a4,3
 52c:	c398                	sw	a4,0(a5)
 52e:	67c1                	lui	a5,0x10
 530:	953e                	add	a0,a0,a5
 532:	4791                	li	a5,4
 534:	c11c                	sw	a5,0(a0)
    }
    printf("child exiting\n");
 536:	00001517          	auipc	a0,0x1
 53a:	c1a50513          	addi	a0,a0,-998 # 1150 <malloc+0x2ba>
 53e:	00001097          	auipc	ra,0x1
 542:	89a080e7          	jalr	-1894(ra) # dd8 <printf>
}
 546:	60a2                	ld	ra,8(sp)
 548:	6402                	ld	s0,0(sp)
 54a:	0141                	addi	sp,sp,16
 54c:	8082                	ret

000000000000054e <priority_test>:

void priority_test() {
 54e:	715d                	addi	sp,sp,-80
 550:	e486                	sd	ra,72(sp)
 552:	e0a2                	sd	s0,64(sp)
 554:	fc26                	sd	s1,56(sp)
 556:	f84a                	sd	s2,48(sp)
 558:	f44e                	sd	s3,40(sp)
 55a:	f052                	sd	s4,32(sp)
 55c:	ec56                	sd	s5,24(sp)
 55e:	e85a                	sd	s6,16(sp)
 560:	e45e                	sd	s7,8(sp)
 562:	e062                	sd	s8,0(sp)
 564:	0880                	addi	s0,sp,80
    PRINT_TEST_START("priority test");
 566:	00001597          	auipc	a1,0x1
 56a:	bfa58593          	addi	a1,a1,-1030 # 1160 <malloc+0x2ca>
 56e:	00001517          	auipc	a0,0x1
 572:	a2250513          	addi	a0,a0,-1502 # f90 <malloc+0xfa>
 576:	00001097          	auipc	ra,0x1
 57a:	862080e7          	jalr	-1950(ra) # dd8 <printf>
    if (!fork()) {
 57e:	00000097          	auipc	ra,0x0
 582:	4d2080e7          	jalr	1234(ra) # a50 <fork>
 586:	cd15                	beqz	a0,5c2 <priority_test+0x74>
            }
            printf("sum %d = %d\n", i, sum);
        }
        exit(0);
    } else {
        wait(0);
 588:	4501                	li	a0,0
 58a:	00000097          	auipc	ra,0x0
 58e:	4d6080e7          	jalr	1238(ra) # a60 <wait>
    }
    PRINT_TEST_END("priority test");
 592:	00001597          	auipc	a1,0x1
 596:	bce58593          	addi	a1,a1,-1074 # 1160 <malloc+0x2ca>
 59a:	00001517          	auipc	a0,0x1
 59e:	a5650513          	addi	a0,a0,-1450 # ff0 <malloc+0x15a>
 5a2:	00001097          	auipc	ra,0x1
 5a6:	836080e7          	jalr	-1994(ra) # dd8 <printf>
}
 5aa:	60a6                	ld	ra,72(sp)
 5ac:	6406                	ld	s0,64(sp)
 5ae:	74e2                	ld	s1,56(sp)
 5b0:	7942                	ld	s2,48(sp)
 5b2:	79a2                	ld	s3,40(sp)
 5b4:	7a02                	ld	s4,32(sp)
 5b6:	6ae2                	ld	s5,24(sp)
 5b8:	6b42                	ld	s6,16(sp)
 5ba:	6ba2                	ld	s7,8(sp)
 5bc:	6c02                	ld	s8,0(sp)
 5be:	6161                	addi	sp,sp,80
 5c0:	8082                	ret
 5c2:	84aa                	mv	s1,a0
        int *arr = (int *) (malloc(sizeof(int) * PGSIZE * 6));
 5c4:	6561                	lui	a0,0x18
 5c6:	00001097          	auipc	ra,0x1
 5ca:	8d0080e7          	jalr	-1840(ra) # e96 <malloc>
 5ce:	89aa                	mv	s3,a0
        for (int i = 0; i < PGSIZE / sizeof(int); ++i) {
 5d0:	8926                	mv	s2,s1
        int *arr = (int *) (malloc(sizeof(int) * PGSIZE * 6));
 5d2:	4a05                	li	s4,1
            int accessed_index = i + ((i % 2 == 0) ? 0 : i % (6 * sizeof(int))) * (PGSIZE / sizeof(int));
 5d4:	4781                	li	a5,0
            arr[accessed_index] = 1;
 5d6:	4a85                	li	s5,1
            if (i % 10 == 0) { sleep(1); }
 5d8:	4ba9                	li	s7,10
        for (int i = 0; i < PGSIZE / sizeof(int); ++i) {
 5da:	40000b13          	li	s6,1024
            int accessed_index = i + ((i % 2 == 0) ? 0 : i % (6 * sizeof(int))) * (PGSIZE / sizeof(int));
 5de:	4c61                	li	s8,24
 5e0:	a011                	j	5e4 <priority_test+0x96>
 5e2:	0a05                	addi	s4,s4,1
            arr[accessed_index] = 1;
 5e4:	00f907bb          	addw	a5,s2,a5
 5e8:	078a                	slli	a5,a5,0x2
 5ea:	97ce                	add	a5,a5,s3
 5ec:	0157a023          	sw	s5,0(a5) # 10000 <__global_pointer$+0xe617>
            if (i % 10 == 0) { sleep(1); }
 5f0:	037967bb          	remw	a5,s2,s7
 5f4:	cf91                	beqz	a5,610 <priority_test+0xc2>
        for (int i = 0; i < PGSIZE / sizeof(int); ++i) {
 5f6:	0019079b          	addiw	a5,s2,1
 5fa:	0007891b          	sext.w	s2,a5
 5fe:	87ca                	mv	a5,s2
 600:	01690e63          	beq	s2,s6,61c <priority_test+0xce>
            int accessed_index = i + ((i % 2 == 0) ? 0 : i % (6 * sizeof(int))) * (PGSIZE / sizeof(int));
 604:	8b85                	andi	a5,a5,1
 606:	dff1                	beqz	a5,5e2 <priority_test+0x94>
 608:	038a77b3          	remu	a5,s4,s8
 60c:	07aa                	slli	a5,a5,0xa
 60e:	bfd1                	j	5e2 <priority_test+0x94>
            if (i % 10 == 0) { sleep(1); }
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	4d6080e7          	jalr	1238(ra) # ae8 <sleep>
 61a:	bff1                	j	5f6 <priority_test+0xa8>
 61c:	4901                	li	s2,0
 61e:	6a05                	lui	s4,0x1
 620:	9a4e                	add	s4,s4,s3
            printf("sum %d = %d\n", i, sum);
 622:	00001b17          	auipc	s6,0x1
 626:	b4eb0b13          	addi	s6,s6,-1202 # 1170 <malloc+0x2da>
        for (int i = 0; i < 6 * sizeof(int); ++i) {
 62a:	4ae1                	li	s5,24
 62c:	0009059b          	sext.w	a1,s2
            for (int j = 0; j < PGSIZE / sizeof(int); ++j) {
 630:	00c91693          	slli	a3,s2,0xc
 634:	00d987b3          	add	a5,s3,a3
 638:	96d2                	add	a3,a3,s4
            int sum = 0;
 63a:	8626                	mv	a2,s1
                sum = sum + arr[i * PGSIZE / sizeof(int) + j];
 63c:	4398                	lw	a4,0(a5)
 63e:	9e39                	addw	a2,a2,a4
            for (int j = 0; j < PGSIZE / sizeof(int); ++j) {
 640:	0791                	addi	a5,a5,4
 642:	fef69de3          	bne	a3,a5,63c <priority_test+0xee>
            printf("sum %d = %d\n", i, sum);
 646:	855a                	mv	a0,s6
 648:	00000097          	auipc	ra,0x0
 64c:	790080e7          	jalr	1936(ra) # dd8 <printf>
        for (int i = 0; i < 6 * sizeof(int); ++i) {
 650:	0905                	addi	s2,s2,1
 652:	fd591de3          	bne	s2,s5,62c <priority_test+0xde>
        exit(0);
 656:	4501                	li	a0,0
 658:	00000097          	auipc	ra,0x0
 65c:	400080e7          	jalr	1024(ra) # a58 <exit>

0000000000000660 <fork_test>:

void fork_test() {
 660:	7179                	addi	sp,sp,-48
 662:	f406                	sd	ra,40(sp)
 664:	f022                	sd	s0,32(sp)
 666:	ec26                	sd	s1,24(sp)
 668:	e84a                	sd	s2,16(sp)
 66a:	e44e                	sd	s3,8(sp)
 66c:	1800                	addi	s0,sp,48
    PRINT_TEST_START("fork test");
 66e:	00001597          	auipc	a1,0x1
 672:	b1258593          	addi	a1,a1,-1262 # 1180 <malloc+0x2ea>
 676:	00001517          	auipc	a0,0x1
 67a:	91a50513          	addi	a0,a0,-1766 # f90 <malloc+0xfa>
 67e:	00000097          	auipc	ra,0x0
 682:	75a080e7          	jalr	1882(ra) # dd8 <printf>
    if (!fork()) {
 686:	00000097          	auipc	ra,0x0
 68a:	3ca080e7          	jalr	970(ra) # a50 <fork>
 68e:	ed5d                	bnez	a0,74c <fork_test+0xec>
        char *arr = (char *) (malloc(sizeof(char) * PGSIZE * 24));
 690:	6561                	lui	a0,0x18
 692:	00001097          	auipc	ra,0x1
 696:	804080e7          	jalr	-2044(ra) # e96 <malloc>
 69a:	892a                	mv	s2,a0
        for (int i = PGSIZE * 1; i < PGSIZE * 2; ++i) {
 69c:	6985                	lui	s3,0x1
 69e:	99aa                	add	s3,s3,a0
 6a0:	6489                	lui	s1,0x2
 6a2:	94aa                	add	s1,s1,a0
        char *arr = (char *) (malloc(sizeof(char) * PGSIZE * 24));
 6a4:	87ce                	mv	a5,s3
            arr[i] = 1;
 6a6:	4705                	li	a4,1
 6a8:	00e78023          	sb	a4,0(a5)
        for (int i = PGSIZE * 1; i < PGSIZE * 2; ++i) {
 6ac:	0785                	addi	a5,a5,1
 6ae:	fe979de3          	bne	a5,s1,6a8 <fork_test+0x48>
        }
        printf("Creating first child. pid: %d\n", getpid());
 6b2:	00000097          	auipc	ra,0x0
 6b6:	426080e7          	jalr	1062(ra) # ad8 <getpid>
 6ba:	85aa                	mv	a1,a0
 6bc:	00001517          	auipc	a0,0x1
 6c0:	ad450513          	addi	a0,a0,-1324 # 1190 <malloc+0x2fa>
 6c4:	00000097          	auipc	ra,0x0
 6c8:	714080e7          	jalr	1812(ra) # dd8 <printf>
        if (!fork()) {
 6cc:	00000097          	auipc	ra,0x0
 6d0:	384080e7          	jalr	900(ra) # a50 <fork>
 6d4:	c539                	beqz	a0,722 <fork_test+0xc2>
            for (int i = PGSIZE * 1; i < PGSIZE * 2; ++i) {
                arr[i] = 1;
            }
            exit(0);
        } else {
            wait(0);
 6d6:	4501                	li	a0,0
 6d8:	00000097          	auipc	ra,0x0
 6dc:	388080e7          	jalr	904(ra) # a60 <wait>
        }
        printf("Creating second child. pid: %d\n", getpid());
 6e0:	00000097          	auipc	ra,0x0
 6e4:	3f8080e7          	jalr	1016(ra) # ad8 <getpid>
 6e8:	85aa                	mv	a1,a0
 6ea:	00001517          	auipc	a0,0x1
 6ee:	ac650513          	addi	a0,a0,-1338 # 11b0 <malloc+0x31a>
 6f2:	00000097          	auipc	ra,0x0
 6f6:	6e6080e7          	jalr	1766(ra) # dd8 <printf>
        if (!fork()) {
 6fa:	00000097          	auipc	ra,0x0
 6fe:	356080e7          	jalr	854(ra) # a50 <fork>
 702:	e91d                	bnez	a0,738 <fork_test+0xd8>
 704:	678d                	lui	a5,0x3
 706:	97ca                	add	a5,a5,s2
 708:	6711                	lui	a4,0x4
 70a:	974a                	add	a4,a4,s2
            for (int i = PGSIZE * 3; i < PGSIZE * 4; ++i) {
                arr[i] = 1;
 70c:	4685                	li	a3,1
 70e:	00d78023          	sb	a3,0(a5) # 3000 <__global_pointer$+0x1617>
            for (int i = PGSIZE * 3; i < PGSIZE * 4; ++i) {
 712:	0785                	addi	a5,a5,1
 714:	fee79de3          	bne	a5,a4,70e <fork_test+0xae>
            }
            exit(0);
 718:	4501                	li	a0,0
 71a:	00000097          	auipc	ra,0x0
 71e:	33e080e7          	jalr	830(ra) # a58 <exit>
                arr[i] = 1;
 722:	4785                	li	a5,1
 724:	00f98023          	sb	a5,0(s3) # 1000 <malloc+0x16a>
            for (int i = PGSIZE * 1; i < PGSIZE * 2; ++i) {
 728:	0985                	addi	s3,s3,1
 72a:	fe999de3          	bne	s3,s1,724 <fork_test+0xc4>
            exit(0);
 72e:	4501                	li	a0,0
 730:	00000097          	auipc	ra,0x0
 734:	328080e7          	jalr	808(ra) # a58 <exit>
        } else {
            wait(0);
 738:	4501                	li	a0,0
 73a:	00000097          	auipc	ra,0x0
 73e:	326080e7          	jalr	806(ra) # a60 <wait>
        }
        exit(0);
 742:	4501                	li	a0,0
 744:	00000097          	auipc	ra,0x0
 748:	314080e7          	jalr	788(ra) # a58 <exit>
    } else {
        wait(0);
 74c:	4501                	li	a0,0
 74e:	00000097          	auipc	ra,0x0
 752:	312080e7          	jalr	786(ra) # a60 <wait>
    }
    PRINT_TEST_END("fork test");
 756:	00001597          	auipc	a1,0x1
 75a:	a2a58593          	addi	a1,a1,-1494 # 1180 <malloc+0x2ea>
 75e:	00001517          	auipc	a0,0x1
 762:	89250513          	addi	a0,a0,-1902 # ff0 <malloc+0x15a>
 766:	00000097          	auipc	ra,0x0
 76a:	672080e7          	jalr	1650(ra) # dd8 <printf>
}
 76e:	70a2                	ld	ra,40(sp)
 770:	7402                	ld	s0,32(sp)
 772:	64e2                	ld	s1,24(sp)
 774:	6942                	ld	s2,16(sp)
 776:	69a2                	ld	s3,8(sp)
 778:	6145                	addi	sp,sp,48
 77a:	8082                	ret

000000000000077c <main>:

int main(int argc, char **argv) {
 77c:	1141                	addi	sp,sp,-16
 77e:	e406                	sd	ra,8(sp)
 780:	e022                	sd	s0,0(sp)
 782:	0800                	addi	s0,sp,16
    if (argc >= 1) {
 784:	00a05d63          	blez	a0,79e <main+0x22>
 788:	87ae                	mv	a5,a1
        if (strcmp(argv[1], "exectest") == 0) {
 78a:	00001597          	auipc	a1,0x1
 78e:	99e58593          	addi	a1,a1,-1634 # 1128 <malloc+0x292>
 792:	6788                	ld	a0,8(a5)
 794:	00000097          	auipc	ra,0x0
 798:	072080e7          	jalr	114(ra) # 806 <strcmp>
 79c:	cd15                	beqz	a0,7d8 <main+0x5c>
            exec_test_child();
            exit(0);
        }
    }
   fork_test();
 79e:	00000097          	auipc	ra,0x0
 7a2:	ec2080e7          	jalr	-318(ra) # 660 <fork_test>
   priority_test();
 7a6:	00000097          	auipc	ra,0x0
 7aa:	da8080e7          	jalr	-600(ra) # 54e <priority_test>
   exec_test();
 7ae:	00000097          	auipc	ra,0x0
 7b2:	c56080e7          	jalr	-938(ra) # 404 <exec_test>
   alloc_dealloc_test();
 7b6:	00000097          	auipc	ra,0x0
 7ba:	99c080e7          	jalr	-1636(ra) # 152 <alloc_dealloc_test>
   advance_alloc_dealloc_test();
 7be:	00000097          	auipc	ra,0x0
 7c2:	aa4080e7          	jalr	-1372(ra) # 262 <advance_alloc_dealloc_test>
    child_test(); // fails!!!
 7c6:	00000097          	auipc	ra,0x0
 7ca:	83a080e7          	jalr	-1990(ra) # 0 <child_test>
    exit(0);
 7ce:	4501                	li	a0,0
 7d0:	00000097          	auipc	ra,0x0
 7d4:	288080e7          	jalr	648(ra) # a58 <exit>
            exec_test_child();
 7d8:	00000097          	auipc	ra,0x0
 7dc:	d18080e7          	jalr	-744(ra) # 4f0 <exec_test_child>
            exit(0);
 7e0:	4501                	li	a0,0
 7e2:	00000097          	auipc	ra,0x0
 7e6:	276080e7          	jalr	630(ra) # a58 <exit>

00000000000007ea <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 7ea:	1141                	addi	sp,sp,-16
 7ec:	e422                	sd	s0,8(sp)
 7ee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 7f0:	87aa                	mv	a5,a0
 7f2:	0585                	addi	a1,a1,1
 7f4:	0785                	addi	a5,a5,1
 7f6:	fff5c703          	lbu	a4,-1(a1)
 7fa:	fee78fa3          	sb	a4,-1(a5)
 7fe:	fb75                	bnez	a4,7f2 <strcpy+0x8>
    ;
  return os;
}
 800:	6422                	ld	s0,8(sp)
 802:	0141                	addi	sp,sp,16
 804:	8082                	ret

0000000000000806 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 806:	1141                	addi	sp,sp,-16
 808:	e422                	sd	s0,8(sp)
 80a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 80c:	00054783          	lbu	a5,0(a0)
 810:	cb91                	beqz	a5,824 <strcmp+0x1e>
 812:	0005c703          	lbu	a4,0(a1)
 816:	00f71763          	bne	a4,a5,824 <strcmp+0x1e>
    p++, q++;
 81a:	0505                	addi	a0,a0,1
 81c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 81e:	00054783          	lbu	a5,0(a0)
 822:	fbe5                	bnez	a5,812 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 824:	0005c503          	lbu	a0,0(a1)
}
 828:	40a7853b          	subw	a0,a5,a0
 82c:	6422                	ld	s0,8(sp)
 82e:	0141                	addi	sp,sp,16
 830:	8082                	ret

0000000000000832 <strlen>:

uint
strlen(const char *s)
{
 832:	1141                	addi	sp,sp,-16
 834:	e422                	sd	s0,8(sp)
 836:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 838:	00054783          	lbu	a5,0(a0)
 83c:	cf91                	beqz	a5,858 <strlen+0x26>
 83e:	0505                	addi	a0,a0,1
 840:	87aa                	mv	a5,a0
 842:	4685                	li	a3,1
 844:	9e89                	subw	a3,a3,a0
 846:	00f6853b          	addw	a0,a3,a5
 84a:	0785                	addi	a5,a5,1
 84c:	fff7c703          	lbu	a4,-1(a5)
 850:	fb7d                	bnez	a4,846 <strlen+0x14>
    ;
  return n;
}
 852:	6422                	ld	s0,8(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret
  for(n = 0; s[n]; n++)
 858:	4501                	li	a0,0
 85a:	bfe5                	j	852 <strlen+0x20>

000000000000085c <memset>:

void*
memset(void *dst, int c, uint n)
{
 85c:	1141                	addi	sp,sp,-16
 85e:	e422                	sd	s0,8(sp)
 860:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 862:	ca19                	beqz	a2,878 <memset+0x1c>
 864:	87aa                	mv	a5,a0
 866:	1602                	slli	a2,a2,0x20
 868:	9201                	srli	a2,a2,0x20
 86a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 86e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 872:	0785                	addi	a5,a5,1
 874:	fee79de3          	bne	a5,a4,86e <memset+0x12>
  }
  return dst;
}
 878:	6422                	ld	s0,8(sp)
 87a:	0141                	addi	sp,sp,16
 87c:	8082                	ret

000000000000087e <strchr>:

char*
strchr(const char *s, char c)
{
 87e:	1141                	addi	sp,sp,-16
 880:	e422                	sd	s0,8(sp)
 882:	0800                	addi	s0,sp,16
  for(; *s; s++)
 884:	00054783          	lbu	a5,0(a0)
 888:	cb99                	beqz	a5,89e <strchr+0x20>
    if(*s == c)
 88a:	00f58763          	beq	a1,a5,898 <strchr+0x1a>
  for(; *s; s++)
 88e:	0505                	addi	a0,a0,1
 890:	00054783          	lbu	a5,0(a0)
 894:	fbfd                	bnez	a5,88a <strchr+0xc>
      return (char*)s;
  return 0;
 896:	4501                	li	a0,0
}
 898:	6422                	ld	s0,8(sp)
 89a:	0141                	addi	sp,sp,16
 89c:	8082                	ret
  return 0;
 89e:	4501                	li	a0,0
 8a0:	bfe5                	j	898 <strchr+0x1a>

00000000000008a2 <gets>:

char*
gets(char *buf, int max)
{
 8a2:	711d                	addi	sp,sp,-96
 8a4:	ec86                	sd	ra,88(sp)
 8a6:	e8a2                	sd	s0,80(sp)
 8a8:	e4a6                	sd	s1,72(sp)
 8aa:	e0ca                	sd	s2,64(sp)
 8ac:	fc4e                	sd	s3,56(sp)
 8ae:	f852                	sd	s4,48(sp)
 8b0:	f456                	sd	s5,40(sp)
 8b2:	f05a                	sd	s6,32(sp)
 8b4:	ec5e                	sd	s7,24(sp)
 8b6:	1080                	addi	s0,sp,96
 8b8:	8baa                	mv	s7,a0
 8ba:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8bc:	892a                	mv	s2,a0
 8be:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 8c0:	4aa9                	li	s5,10
 8c2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 8c4:	89a6                	mv	s3,s1
 8c6:	2485                	addiw	s1,s1,1
 8c8:	0344d863          	bge	s1,s4,8f8 <gets+0x56>
    cc = read(0, &c, 1);
 8cc:	4605                	li	a2,1
 8ce:	faf40593          	addi	a1,s0,-81
 8d2:	4501                	li	a0,0
 8d4:	00000097          	auipc	ra,0x0
 8d8:	19c080e7          	jalr	412(ra) # a70 <read>
    if(cc < 1)
 8dc:	00a05e63          	blez	a0,8f8 <gets+0x56>
    buf[i++] = c;
 8e0:	faf44783          	lbu	a5,-81(s0)
 8e4:	00f90023          	sb	a5,0(s2) # 14000 <__global_pointer$+0x12617>
    if(c == '\n' || c == '\r')
 8e8:	01578763          	beq	a5,s5,8f6 <gets+0x54>
 8ec:	0905                	addi	s2,s2,1
 8ee:	fd679be3          	bne	a5,s6,8c4 <gets+0x22>
  for(i=0; i+1 < max; ){
 8f2:	89a6                	mv	s3,s1
 8f4:	a011                	j	8f8 <gets+0x56>
 8f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 8f8:	99de                	add	s3,s3,s7
 8fa:	00098023          	sb	zero,0(s3)
  return buf;
}
 8fe:	855e                	mv	a0,s7
 900:	60e6                	ld	ra,88(sp)
 902:	6446                	ld	s0,80(sp)
 904:	64a6                	ld	s1,72(sp)
 906:	6906                	ld	s2,64(sp)
 908:	79e2                	ld	s3,56(sp)
 90a:	7a42                	ld	s4,48(sp)
 90c:	7aa2                	ld	s5,40(sp)
 90e:	7b02                	ld	s6,32(sp)
 910:	6be2                	ld	s7,24(sp)
 912:	6125                	addi	sp,sp,96
 914:	8082                	ret

0000000000000916 <stat>:

int
stat(const char *n, struct stat *st)
{
 916:	1101                	addi	sp,sp,-32
 918:	ec06                	sd	ra,24(sp)
 91a:	e822                	sd	s0,16(sp)
 91c:	e426                	sd	s1,8(sp)
 91e:	e04a                	sd	s2,0(sp)
 920:	1000                	addi	s0,sp,32
 922:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 924:	4581                	li	a1,0
 926:	00000097          	auipc	ra,0x0
 92a:	172080e7          	jalr	370(ra) # a98 <open>
  if(fd < 0)
 92e:	02054563          	bltz	a0,958 <stat+0x42>
 932:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 934:	85ca                	mv	a1,s2
 936:	00000097          	auipc	ra,0x0
 93a:	17a080e7          	jalr	378(ra) # ab0 <fstat>
 93e:	892a                	mv	s2,a0
  close(fd);
 940:	8526                	mv	a0,s1
 942:	00000097          	auipc	ra,0x0
 946:	13e080e7          	jalr	318(ra) # a80 <close>
  return r;
}
 94a:	854a                	mv	a0,s2
 94c:	60e2                	ld	ra,24(sp)
 94e:	6442                	ld	s0,16(sp)
 950:	64a2                	ld	s1,8(sp)
 952:	6902                	ld	s2,0(sp)
 954:	6105                	addi	sp,sp,32
 956:	8082                	ret
    return -1;
 958:	597d                	li	s2,-1
 95a:	bfc5                	j	94a <stat+0x34>

000000000000095c <atoi>:

int
atoi(const char *s)
{
 95c:	1141                	addi	sp,sp,-16
 95e:	e422                	sd	s0,8(sp)
 960:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 962:	00054603          	lbu	a2,0(a0)
 966:	fd06079b          	addiw	a5,a2,-48
 96a:	0ff7f793          	andi	a5,a5,255
 96e:	4725                	li	a4,9
 970:	02f76963          	bltu	a4,a5,9a2 <atoi+0x46>
 974:	86aa                	mv	a3,a0
  n = 0;
 976:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 978:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 97a:	0685                	addi	a3,a3,1
 97c:	0025179b          	slliw	a5,a0,0x2
 980:	9fa9                	addw	a5,a5,a0
 982:	0017979b          	slliw	a5,a5,0x1
 986:	9fb1                	addw	a5,a5,a2
 988:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 98c:	0006c603          	lbu	a2,0(a3)
 990:	fd06071b          	addiw	a4,a2,-48
 994:	0ff77713          	andi	a4,a4,255
 998:	fee5f1e3          	bgeu	a1,a4,97a <atoi+0x1e>
  return n;
}
 99c:	6422                	ld	s0,8(sp)
 99e:	0141                	addi	sp,sp,16
 9a0:	8082                	ret
  n = 0;
 9a2:	4501                	li	a0,0
 9a4:	bfe5                	j	99c <atoi+0x40>

00000000000009a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9a6:	1141                	addi	sp,sp,-16
 9a8:	e422                	sd	s0,8(sp)
 9aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9ac:	02b57463          	bgeu	a0,a1,9d4 <memmove+0x2e>
    while(n-- > 0)
 9b0:	00c05f63          	blez	a2,9ce <memmove+0x28>
 9b4:	1602                	slli	a2,a2,0x20
 9b6:	9201                	srli	a2,a2,0x20
 9b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 9bc:	872a                	mv	a4,a0
      *dst++ = *src++;
 9be:	0585                	addi	a1,a1,1
 9c0:	0705                	addi	a4,a4,1
 9c2:	fff5c683          	lbu	a3,-1(a1)
 9c6:	fed70fa3          	sb	a3,-1(a4) # 3fff <__global_pointer$+0x2616>
    while(n-- > 0)
 9ca:	fee79ae3          	bne	a5,a4,9be <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 9ce:	6422                	ld	s0,8(sp)
 9d0:	0141                	addi	sp,sp,16
 9d2:	8082                	ret
    dst += n;
 9d4:	00c50733          	add	a4,a0,a2
    src += n;
 9d8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 9da:	fec05ae3          	blez	a2,9ce <memmove+0x28>
 9de:	fff6079b          	addiw	a5,a2,-1
 9e2:	1782                	slli	a5,a5,0x20
 9e4:	9381                	srli	a5,a5,0x20
 9e6:	fff7c793          	not	a5,a5
 9ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 9ec:	15fd                	addi	a1,a1,-1
 9ee:	177d                	addi	a4,a4,-1
 9f0:	0005c683          	lbu	a3,0(a1)
 9f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 9f8:	fee79ae3          	bne	a5,a4,9ec <memmove+0x46>
 9fc:	bfc9                	j	9ce <memmove+0x28>

00000000000009fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 9fe:	1141                	addi	sp,sp,-16
 a00:	e422                	sd	s0,8(sp)
 a02:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a04:	ca05                	beqz	a2,a34 <memcmp+0x36>
 a06:	fff6069b          	addiw	a3,a2,-1
 a0a:	1682                	slli	a3,a3,0x20
 a0c:	9281                	srli	a3,a3,0x20
 a0e:	0685                	addi	a3,a3,1
 a10:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a12:	00054783          	lbu	a5,0(a0)
 a16:	0005c703          	lbu	a4,0(a1)
 a1a:	00e79863          	bne	a5,a4,a2a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a1e:	0505                	addi	a0,a0,1
    p2++;
 a20:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a22:	fed518e3          	bne	a0,a3,a12 <memcmp+0x14>
  }
  return 0;
 a26:	4501                	li	a0,0
 a28:	a019                	j	a2e <memcmp+0x30>
      return *p1 - *p2;
 a2a:	40e7853b          	subw	a0,a5,a4
}
 a2e:	6422                	ld	s0,8(sp)
 a30:	0141                	addi	sp,sp,16
 a32:	8082                	ret
  return 0;
 a34:	4501                	li	a0,0
 a36:	bfe5                	j	a2e <memcmp+0x30>

0000000000000a38 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a38:	1141                	addi	sp,sp,-16
 a3a:	e406                	sd	ra,8(sp)
 a3c:	e022                	sd	s0,0(sp)
 a3e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a40:	00000097          	auipc	ra,0x0
 a44:	f66080e7          	jalr	-154(ra) # 9a6 <memmove>
}
 a48:	60a2                	ld	ra,8(sp)
 a4a:	6402                	ld	s0,0(sp)
 a4c:	0141                	addi	sp,sp,16
 a4e:	8082                	ret

0000000000000a50 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a50:	4885                	li	a7,1
 ecall
 a52:	00000073          	ecall
 ret
 a56:	8082                	ret

0000000000000a58 <exit>:
.global exit
exit:
 li a7, SYS_exit
 a58:	4889                	li	a7,2
 ecall
 a5a:	00000073          	ecall
 ret
 a5e:	8082                	ret

0000000000000a60 <wait>:
.global wait
wait:
 li a7, SYS_wait
 a60:	488d                	li	a7,3
 ecall
 a62:	00000073          	ecall
 ret
 a66:	8082                	ret

0000000000000a68 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a68:	4891                	li	a7,4
 ecall
 a6a:	00000073          	ecall
 ret
 a6e:	8082                	ret

0000000000000a70 <read>:
.global read
read:
 li a7, SYS_read
 a70:	4895                	li	a7,5
 ecall
 a72:	00000073          	ecall
 ret
 a76:	8082                	ret

0000000000000a78 <write>:
.global write
write:
 li a7, SYS_write
 a78:	48c1                	li	a7,16
 ecall
 a7a:	00000073          	ecall
 ret
 a7e:	8082                	ret

0000000000000a80 <close>:
.global close
close:
 li a7, SYS_close
 a80:	48d5                	li	a7,21
 ecall
 a82:	00000073          	ecall
 ret
 a86:	8082                	ret

0000000000000a88 <kill>:
.global kill
kill:
 li a7, SYS_kill
 a88:	4899                	li	a7,6
 ecall
 a8a:	00000073          	ecall
 ret
 a8e:	8082                	ret

0000000000000a90 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a90:	489d                	li	a7,7
 ecall
 a92:	00000073          	ecall
 ret
 a96:	8082                	ret

0000000000000a98 <open>:
.global open
open:
 li a7, SYS_open
 a98:	48bd                	li	a7,15
 ecall
 a9a:	00000073          	ecall
 ret
 a9e:	8082                	ret

0000000000000aa0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 aa0:	48c5                	li	a7,17
 ecall
 aa2:	00000073          	ecall
 ret
 aa6:	8082                	ret

0000000000000aa8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 aa8:	48c9                	li	a7,18
 ecall
 aaa:	00000073          	ecall
 ret
 aae:	8082                	ret

0000000000000ab0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 ab0:	48a1                	li	a7,8
 ecall
 ab2:	00000073          	ecall
 ret
 ab6:	8082                	ret

0000000000000ab8 <link>:
.global link
link:
 li a7, SYS_link
 ab8:	48cd                	li	a7,19
 ecall
 aba:	00000073          	ecall
 ret
 abe:	8082                	ret

0000000000000ac0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 ac0:	48d1                	li	a7,20
 ecall
 ac2:	00000073          	ecall
 ret
 ac6:	8082                	ret

0000000000000ac8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 ac8:	48a5                	li	a7,9
 ecall
 aca:	00000073          	ecall
 ret
 ace:	8082                	ret

0000000000000ad0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 ad0:	48a9                	li	a7,10
 ecall
 ad2:	00000073          	ecall
 ret
 ad6:	8082                	ret

0000000000000ad8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 ad8:	48ad                	li	a7,11
 ecall
 ada:	00000073          	ecall
 ret
 ade:	8082                	ret

0000000000000ae0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 ae0:	48b1                	li	a7,12
 ecall
 ae2:	00000073          	ecall
 ret
 ae6:	8082                	ret

0000000000000ae8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 ae8:	48b5                	li	a7,13
 ecall
 aea:	00000073          	ecall
 ret
 aee:	8082                	ret

0000000000000af0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 af0:	48b9                	li	a7,14
 ecall
 af2:	00000073          	ecall
 ret
 af6:	8082                	ret

0000000000000af8 <printmem>:
.global printmem
printmem:
 li a7, SYS_printmem
 af8:	48d9                	li	a7,22
 ecall
 afa:	00000073          	ecall
 ret
 afe:	8082                	ret

0000000000000b00 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b00:	1101                	addi	sp,sp,-32
 b02:	ec06                	sd	ra,24(sp)
 b04:	e822                	sd	s0,16(sp)
 b06:	1000                	addi	s0,sp,32
 b08:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b0c:	4605                	li	a2,1
 b0e:	fef40593          	addi	a1,s0,-17
 b12:	00000097          	auipc	ra,0x0
 b16:	f66080e7          	jalr	-154(ra) # a78 <write>
}
 b1a:	60e2                	ld	ra,24(sp)
 b1c:	6442                	ld	s0,16(sp)
 b1e:	6105                	addi	sp,sp,32
 b20:	8082                	ret

0000000000000b22 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b22:	7139                	addi	sp,sp,-64
 b24:	fc06                	sd	ra,56(sp)
 b26:	f822                	sd	s0,48(sp)
 b28:	f426                	sd	s1,40(sp)
 b2a:	f04a                	sd	s2,32(sp)
 b2c:	ec4e                	sd	s3,24(sp)
 b2e:	0080                	addi	s0,sp,64
 b30:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b32:	c299                	beqz	a3,b38 <printint+0x16>
 b34:	0805c863          	bltz	a1,bc4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b38:	2581                	sext.w	a1,a1
  neg = 0;
 b3a:	4881                	li	a7,0
 b3c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b40:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b42:	2601                	sext.w	a2,a2
 b44:	00000517          	auipc	a0,0x0
 b48:	69450513          	addi	a0,a0,1684 # 11d8 <digits>
 b4c:	883a                	mv	a6,a4
 b4e:	2705                	addiw	a4,a4,1
 b50:	02c5f7bb          	remuw	a5,a1,a2
 b54:	1782                	slli	a5,a5,0x20
 b56:	9381                	srli	a5,a5,0x20
 b58:	97aa                	add	a5,a5,a0
 b5a:	0007c783          	lbu	a5,0(a5)
 b5e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b62:	0005879b          	sext.w	a5,a1
 b66:	02c5d5bb          	divuw	a1,a1,a2
 b6a:	0685                	addi	a3,a3,1
 b6c:	fec7f0e3          	bgeu	a5,a2,b4c <printint+0x2a>
  if(neg)
 b70:	00088b63          	beqz	a7,b86 <printint+0x64>
    buf[i++] = '-';
 b74:	fd040793          	addi	a5,s0,-48
 b78:	973e                	add	a4,a4,a5
 b7a:	02d00793          	li	a5,45
 b7e:	fef70823          	sb	a5,-16(a4)
 b82:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b86:	02e05863          	blez	a4,bb6 <printint+0x94>
 b8a:	fc040793          	addi	a5,s0,-64
 b8e:	00e78933          	add	s2,a5,a4
 b92:	fff78993          	addi	s3,a5,-1
 b96:	99ba                	add	s3,s3,a4
 b98:	377d                	addiw	a4,a4,-1
 b9a:	1702                	slli	a4,a4,0x20
 b9c:	9301                	srli	a4,a4,0x20
 b9e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 ba2:	fff94583          	lbu	a1,-1(s2)
 ba6:	8526                	mv	a0,s1
 ba8:	00000097          	auipc	ra,0x0
 bac:	f58080e7          	jalr	-168(ra) # b00 <putc>
  while(--i >= 0)
 bb0:	197d                	addi	s2,s2,-1
 bb2:	ff3918e3          	bne	s2,s3,ba2 <printint+0x80>
}
 bb6:	70e2                	ld	ra,56(sp)
 bb8:	7442                	ld	s0,48(sp)
 bba:	74a2                	ld	s1,40(sp)
 bbc:	7902                	ld	s2,32(sp)
 bbe:	69e2                	ld	s3,24(sp)
 bc0:	6121                	addi	sp,sp,64
 bc2:	8082                	ret
    x = -xx;
 bc4:	40b005bb          	negw	a1,a1
    neg = 1;
 bc8:	4885                	li	a7,1
    x = -xx;
 bca:	bf8d                	j	b3c <printint+0x1a>

0000000000000bcc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 bcc:	7119                	addi	sp,sp,-128
 bce:	fc86                	sd	ra,120(sp)
 bd0:	f8a2                	sd	s0,112(sp)
 bd2:	f4a6                	sd	s1,104(sp)
 bd4:	f0ca                	sd	s2,96(sp)
 bd6:	ecce                	sd	s3,88(sp)
 bd8:	e8d2                	sd	s4,80(sp)
 bda:	e4d6                	sd	s5,72(sp)
 bdc:	e0da                	sd	s6,64(sp)
 bde:	fc5e                	sd	s7,56(sp)
 be0:	f862                	sd	s8,48(sp)
 be2:	f466                	sd	s9,40(sp)
 be4:	f06a                	sd	s10,32(sp)
 be6:	ec6e                	sd	s11,24(sp)
 be8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 bea:	0005c903          	lbu	s2,0(a1)
 bee:	18090f63          	beqz	s2,d8c <vprintf+0x1c0>
 bf2:	8aaa                	mv	s5,a0
 bf4:	8b32                	mv	s6,a2
 bf6:	00158493          	addi	s1,a1,1
  state = 0;
 bfa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 bfc:	02500a13          	li	s4,37
      if(c == 'd'){
 c00:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c04:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c08:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c0c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c10:	00000b97          	auipc	s7,0x0
 c14:	5c8b8b93          	addi	s7,s7,1480 # 11d8 <digits>
 c18:	a839                	j	c36 <vprintf+0x6a>
        putc(fd, c);
 c1a:	85ca                	mv	a1,s2
 c1c:	8556                	mv	a0,s5
 c1e:	00000097          	auipc	ra,0x0
 c22:	ee2080e7          	jalr	-286(ra) # b00 <putc>
 c26:	a019                	j	c2c <vprintf+0x60>
    } else if(state == '%'){
 c28:	01498f63          	beq	s3,s4,c46 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c2c:	0485                	addi	s1,s1,1
 c2e:	fff4c903          	lbu	s2,-1(s1) # 1fff <__global_pointer$+0x616>
 c32:	14090d63          	beqz	s2,d8c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c36:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c3a:	fe0997e3          	bnez	s3,c28 <vprintf+0x5c>
      if(c == '%'){
 c3e:	fd479ee3          	bne	a5,s4,c1a <vprintf+0x4e>
        state = '%';
 c42:	89be                	mv	s3,a5
 c44:	b7e5                	j	c2c <vprintf+0x60>
      if(c == 'd'){
 c46:	05878063          	beq	a5,s8,c86 <vprintf+0xba>
      } else if(c == 'l') {
 c4a:	05978c63          	beq	a5,s9,ca2 <vprintf+0xd6>
      } else if(c == 'x') {
 c4e:	07a78863          	beq	a5,s10,cbe <vprintf+0xf2>
      } else if(c == 'p') {
 c52:	09b78463          	beq	a5,s11,cda <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c56:	07300713          	li	a4,115
 c5a:	0ce78663          	beq	a5,a4,d26 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c5e:	06300713          	li	a4,99
 c62:	0ee78e63          	beq	a5,a4,d5e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c66:	11478863          	beq	a5,s4,d76 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c6a:	85d2                	mv	a1,s4
 c6c:	8556                	mv	a0,s5
 c6e:	00000097          	auipc	ra,0x0
 c72:	e92080e7          	jalr	-366(ra) # b00 <putc>
        putc(fd, c);
 c76:	85ca                	mv	a1,s2
 c78:	8556                	mv	a0,s5
 c7a:	00000097          	auipc	ra,0x0
 c7e:	e86080e7          	jalr	-378(ra) # b00 <putc>
      }
      state = 0;
 c82:	4981                	li	s3,0
 c84:	b765                	j	c2c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c86:	008b0913          	addi	s2,s6,8
 c8a:	4685                	li	a3,1
 c8c:	4629                	li	a2,10
 c8e:	000b2583          	lw	a1,0(s6)
 c92:	8556                	mv	a0,s5
 c94:	00000097          	auipc	ra,0x0
 c98:	e8e080e7          	jalr	-370(ra) # b22 <printint>
 c9c:	8b4a                	mv	s6,s2
      state = 0;
 c9e:	4981                	li	s3,0
 ca0:	b771                	j	c2c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ca2:	008b0913          	addi	s2,s6,8
 ca6:	4681                	li	a3,0
 ca8:	4629                	li	a2,10
 caa:	000b2583          	lw	a1,0(s6)
 cae:	8556                	mv	a0,s5
 cb0:	00000097          	auipc	ra,0x0
 cb4:	e72080e7          	jalr	-398(ra) # b22 <printint>
 cb8:	8b4a                	mv	s6,s2
      state = 0;
 cba:	4981                	li	s3,0
 cbc:	bf85                	j	c2c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 cbe:	008b0913          	addi	s2,s6,8
 cc2:	4681                	li	a3,0
 cc4:	4641                	li	a2,16
 cc6:	000b2583          	lw	a1,0(s6)
 cca:	8556                	mv	a0,s5
 ccc:	00000097          	auipc	ra,0x0
 cd0:	e56080e7          	jalr	-426(ra) # b22 <printint>
 cd4:	8b4a                	mv	s6,s2
      state = 0;
 cd6:	4981                	li	s3,0
 cd8:	bf91                	j	c2c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 cda:	008b0793          	addi	a5,s6,8
 cde:	f8f43423          	sd	a5,-120(s0)
 ce2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 ce6:	03000593          	li	a1,48
 cea:	8556                	mv	a0,s5
 cec:	00000097          	auipc	ra,0x0
 cf0:	e14080e7          	jalr	-492(ra) # b00 <putc>
  putc(fd, 'x');
 cf4:	85ea                	mv	a1,s10
 cf6:	8556                	mv	a0,s5
 cf8:	00000097          	auipc	ra,0x0
 cfc:	e08080e7          	jalr	-504(ra) # b00 <putc>
 d00:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d02:	03c9d793          	srli	a5,s3,0x3c
 d06:	97de                	add	a5,a5,s7
 d08:	0007c583          	lbu	a1,0(a5)
 d0c:	8556                	mv	a0,s5
 d0e:	00000097          	auipc	ra,0x0
 d12:	df2080e7          	jalr	-526(ra) # b00 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d16:	0992                	slli	s3,s3,0x4
 d18:	397d                	addiw	s2,s2,-1
 d1a:	fe0914e3          	bnez	s2,d02 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d1e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d22:	4981                	li	s3,0
 d24:	b721                	j	c2c <vprintf+0x60>
        s = va_arg(ap, char*);
 d26:	008b0993          	addi	s3,s6,8
 d2a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d2e:	02090163          	beqz	s2,d50 <vprintf+0x184>
        while(*s != 0){
 d32:	00094583          	lbu	a1,0(s2)
 d36:	c9a1                	beqz	a1,d86 <vprintf+0x1ba>
          putc(fd, *s);
 d38:	8556                	mv	a0,s5
 d3a:	00000097          	auipc	ra,0x0
 d3e:	dc6080e7          	jalr	-570(ra) # b00 <putc>
          s++;
 d42:	0905                	addi	s2,s2,1
        while(*s != 0){
 d44:	00094583          	lbu	a1,0(s2)
 d48:	f9e5                	bnez	a1,d38 <vprintf+0x16c>
        s = va_arg(ap, char*);
 d4a:	8b4e                	mv	s6,s3
      state = 0;
 d4c:	4981                	li	s3,0
 d4e:	bdf9                	j	c2c <vprintf+0x60>
          s = "(null)";
 d50:	00000917          	auipc	s2,0x0
 d54:	48090913          	addi	s2,s2,1152 # 11d0 <malloc+0x33a>
        while(*s != 0){
 d58:	02800593          	li	a1,40
 d5c:	bff1                	j	d38 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d5e:	008b0913          	addi	s2,s6,8
 d62:	000b4583          	lbu	a1,0(s6)
 d66:	8556                	mv	a0,s5
 d68:	00000097          	auipc	ra,0x0
 d6c:	d98080e7          	jalr	-616(ra) # b00 <putc>
 d70:	8b4a                	mv	s6,s2
      state = 0;
 d72:	4981                	li	s3,0
 d74:	bd65                	j	c2c <vprintf+0x60>
        putc(fd, c);
 d76:	85d2                	mv	a1,s4
 d78:	8556                	mv	a0,s5
 d7a:	00000097          	auipc	ra,0x0
 d7e:	d86080e7          	jalr	-634(ra) # b00 <putc>
      state = 0;
 d82:	4981                	li	s3,0
 d84:	b565                	j	c2c <vprintf+0x60>
        s = va_arg(ap, char*);
 d86:	8b4e                	mv	s6,s3
      state = 0;
 d88:	4981                	li	s3,0
 d8a:	b54d                	j	c2c <vprintf+0x60>
    }
  }
}
 d8c:	70e6                	ld	ra,120(sp)
 d8e:	7446                	ld	s0,112(sp)
 d90:	74a6                	ld	s1,104(sp)
 d92:	7906                	ld	s2,96(sp)
 d94:	69e6                	ld	s3,88(sp)
 d96:	6a46                	ld	s4,80(sp)
 d98:	6aa6                	ld	s5,72(sp)
 d9a:	6b06                	ld	s6,64(sp)
 d9c:	7be2                	ld	s7,56(sp)
 d9e:	7c42                	ld	s8,48(sp)
 da0:	7ca2                	ld	s9,40(sp)
 da2:	7d02                	ld	s10,32(sp)
 da4:	6de2                	ld	s11,24(sp)
 da6:	6109                	addi	sp,sp,128
 da8:	8082                	ret

0000000000000daa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 daa:	715d                	addi	sp,sp,-80
 dac:	ec06                	sd	ra,24(sp)
 dae:	e822                	sd	s0,16(sp)
 db0:	1000                	addi	s0,sp,32
 db2:	e010                	sd	a2,0(s0)
 db4:	e414                	sd	a3,8(s0)
 db6:	e818                	sd	a4,16(s0)
 db8:	ec1c                	sd	a5,24(s0)
 dba:	03043023          	sd	a6,32(s0)
 dbe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 dc2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 dc6:	8622                	mv	a2,s0
 dc8:	00000097          	auipc	ra,0x0
 dcc:	e04080e7          	jalr	-508(ra) # bcc <vprintf>
}
 dd0:	60e2                	ld	ra,24(sp)
 dd2:	6442                	ld	s0,16(sp)
 dd4:	6161                	addi	sp,sp,80
 dd6:	8082                	ret

0000000000000dd8 <printf>:

void
printf(const char *fmt, ...)
{
 dd8:	711d                	addi	sp,sp,-96
 dda:	ec06                	sd	ra,24(sp)
 ddc:	e822                	sd	s0,16(sp)
 dde:	1000                	addi	s0,sp,32
 de0:	e40c                	sd	a1,8(s0)
 de2:	e810                	sd	a2,16(s0)
 de4:	ec14                	sd	a3,24(s0)
 de6:	f018                	sd	a4,32(s0)
 de8:	f41c                	sd	a5,40(s0)
 dea:	03043823          	sd	a6,48(s0)
 dee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 df2:	00840613          	addi	a2,s0,8
 df6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 dfa:	85aa                	mv	a1,a0
 dfc:	4505                	li	a0,1
 dfe:	00000097          	auipc	ra,0x0
 e02:	dce080e7          	jalr	-562(ra) # bcc <vprintf>
}
 e06:	60e2                	ld	ra,24(sp)
 e08:	6442                	ld	s0,16(sp)
 e0a:	6125                	addi	sp,sp,96
 e0c:	8082                	ret

0000000000000e0e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e0e:	1141                	addi	sp,sp,-16
 e10:	e422                	sd	s0,8(sp)
 e12:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e14:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e18:	00000797          	auipc	a5,0x0
 e1c:	3d87b783          	ld	a5,984(a5) # 11f0 <freep>
 e20:	a805                	j	e50 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e22:	4618                	lw	a4,8(a2)
 e24:	9db9                	addw	a1,a1,a4
 e26:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e2a:	6398                	ld	a4,0(a5)
 e2c:	6318                	ld	a4,0(a4)
 e2e:	fee53823          	sd	a4,-16(a0)
 e32:	a091                	j	e76 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e34:	ff852703          	lw	a4,-8(a0)
 e38:	9e39                	addw	a2,a2,a4
 e3a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e3c:	ff053703          	ld	a4,-16(a0)
 e40:	e398                	sd	a4,0(a5)
 e42:	a099                	j	e88 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e44:	6398                	ld	a4,0(a5)
 e46:	00e7e463          	bltu	a5,a4,e4e <free+0x40>
 e4a:	00e6ea63          	bltu	a3,a4,e5e <free+0x50>
{
 e4e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e50:	fed7fae3          	bgeu	a5,a3,e44 <free+0x36>
 e54:	6398                	ld	a4,0(a5)
 e56:	00e6e463          	bltu	a3,a4,e5e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e5a:	fee7eae3          	bltu	a5,a4,e4e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e5e:	ff852583          	lw	a1,-8(a0)
 e62:	6390                	ld	a2,0(a5)
 e64:	02059813          	slli	a6,a1,0x20
 e68:	01c85713          	srli	a4,a6,0x1c
 e6c:	9736                	add	a4,a4,a3
 e6e:	fae60ae3          	beq	a2,a4,e22 <free+0x14>
    bp->s.ptr = p->s.ptr;
 e72:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e76:	4790                	lw	a2,8(a5)
 e78:	02061593          	slli	a1,a2,0x20
 e7c:	01c5d713          	srli	a4,a1,0x1c
 e80:	973e                	add	a4,a4,a5
 e82:	fae689e3          	beq	a3,a4,e34 <free+0x26>
  } else
    p->s.ptr = bp;
 e86:	e394                	sd	a3,0(a5)
  freep = p;
 e88:	00000717          	auipc	a4,0x0
 e8c:	36f73423          	sd	a5,872(a4) # 11f0 <freep>
}
 e90:	6422                	ld	s0,8(sp)
 e92:	0141                	addi	sp,sp,16
 e94:	8082                	ret

0000000000000e96 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e96:	7139                	addi	sp,sp,-64
 e98:	fc06                	sd	ra,56(sp)
 e9a:	f822                	sd	s0,48(sp)
 e9c:	f426                	sd	s1,40(sp)
 e9e:	f04a                	sd	s2,32(sp)
 ea0:	ec4e                	sd	s3,24(sp)
 ea2:	e852                	sd	s4,16(sp)
 ea4:	e456                	sd	s5,8(sp)
 ea6:	e05a                	sd	s6,0(sp)
 ea8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 eaa:	02051493          	slli	s1,a0,0x20
 eae:	9081                	srli	s1,s1,0x20
 eb0:	04bd                	addi	s1,s1,15
 eb2:	8091                	srli	s1,s1,0x4
 eb4:	0014899b          	addiw	s3,s1,1
 eb8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 eba:	00000517          	auipc	a0,0x0
 ebe:	33653503          	ld	a0,822(a0) # 11f0 <freep>
 ec2:	c515                	beqz	a0,eee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ec4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ec6:	4798                	lw	a4,8(a5)
 ec8:	02977f63          	bgeu	a4,s1,f06 <malloc+0x70>
 ecc:	8a4e                	mv	s4,s3
 ece:	0009871b          	sext.w	a4,s3
 ed2:	6685                	lui	a3,0x1
 ed4:	00d77363          	bgeu	a4,a3,eda <malloc+0x44>
 ed8:	6a05                	lui	s4,0x1
 eda:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ede:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ee2:	00000917          	auipc	s2,0x0
 ee6:	30e90913          	addi	s2,s2,782 # 11f0 <freep>
  if(p == (char*)-1)
 eea:	5afd                	li	s5,-1
 eec:	a895                	j	f60 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 eee:	00000797          	auipc	a5,0x0
 ef2:	30a78793          	addi	a5,a5,778 # 11f8 <base>
 ef6:	00000717          	auipc	a4,0x0
 efa:	2ef73d23          	sd	a5,762(a4) # 11f0 <freep>
 efe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f00:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f04:	b7e1                	j	ecc <malloc+0x36>
      if(p->s.size == nunits)
 f06:	02e48c63          	beq	s1,a4,f3e <malloc+0xa8>
        p->s.size -= nunits;
 f0a:	4137073b          	subw	a4,a4,s3
 f0e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f10:	02071693          	slli	a3,a4,0x20
 f14:	01c6d713          	srli	a4,a3,0x1c
 f18:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f1a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f1e:	00000717          	auipc	a4,0x0
 f22:	2ca73923          	sd	a0,722(a4) # 11f0 <freep>
      return (void*)(p + 1);
 f26:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f2a:	70e2                	ld	ra,56(sp)
 f2c:	7442                	ld	s0,48(sp)
 f2e:	74a2                	ld	s1,40(sp)
 f30:	7902                	ld	s2,32(sp)
 f32:	69e2                	ld	s3,24(sp)
 f34:	6a42                	ld	s4,16(sp)
 f36:	6aa2                	ld	s5,8(sp)
 f38:	6b02                	ld	s6,0(sp)
 f3a:	6121                	addi	sp,sp,64
 f3c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f3e:	6398                	ld	a4,0(a5)
 f40:	e118                	sd	a4,0(a0)
 f42:	bff1                	j	f1e <malloc+0x88>
  hp->s.size = nu;
 f44:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f48:	0541                	addi	a0,a0,16
 f4a:	00000097          	auipc	ra,0x0
 f4e:	ec4080e7          	jalr	-316(ra) # e0e <free>
  return freep;
 f52:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f56:	d971                	beqz	a0,f2a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f58:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f5a:	4798                	lw	a4,8(a5)
 f5c:	fa9775e3          	bgeu	a4,s1,f06 <malloc+0x70>
    if(p == freep)
 f60:	00093703          	ld	a4,0(s2)
 f64:	853e                	mv	a0,a5
 f66:	fef719e3          	bne	a4,a5,f58 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 f6a:	8552                	mv	a0,s4
 f6c:	00000097          	auipc	ra,0x0
 f70:	b74080e7          	jalr	-1164(ra) # ae0 <sbrk>
  if(p == (char*)-1)
 f74:	fd5518e3          	bne	a0,s5,f44 <malloc+0xae>
        return 0;
 f78:	4501                	li	a0,0
 f7a:	bf45                	j	f2a <malloc+0x94>
