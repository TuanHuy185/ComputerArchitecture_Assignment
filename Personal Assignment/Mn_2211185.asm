##################################################################
####                                                          ####
####               IN 3 DANG SO LE VAO FILE SOLE.TXT          ####
####                                                          ####
##################################################################

.data
	buffer:  .space 32
	text: 	.asciiz " so le: "
	newline: .asciiz "\n"
	str_tc: .asciiz "Thanh cong." 
	str_loi: .asciiz "Mo file bi loi." 
	temp: .word 2		                # bien dem bat dau tu 2
	fdescr:	.word 0		                # gia tri khoi tao cua File Descriptor
	thousand: .float 1000.0
	fileName: .asciiz "SOLE.TXT"

.text

.globl main

main:
	la $a0,fileName 
 	li $a1,1 			         # a1=1 che do chi ghi file 
 	li $v0,13 
 	syscall 
 	bltz $v0,baoloi 		         # mo file that bai
 	sw $v0,fdescr			         # luu gia tri return duoc o $v0 vao bien fdescr
	
# Vong lap ghi 3 so

supLoop:
# Kiem tra dieu kien ghi '\n'
	li 	$t1, 2			         # so sanh bien dem
	lw 	$t2, temp		         # neu la vong lap dau tien, bo qua buoc ghi "\n" o dau dong
	beq 	$t1, $t2, mainLoop              # re nhanh den mainLoop

	la 	$a1, newline		
 	li 	$v0, 15
	lw 	$a0, fdescr
	li 	$a2,1
	syscall
	
mainLoop:
	la 	$a1, text
	sub	$a1,$a1,1		        # load dia chi cua text - 1 (text = " so le : ")
	lw 	$a2, temp		        # load bien dem (so chu so le sau dau phay)
	addi 	$a2, $a2, '0'		        # chuyen bien dem tu word thanh ki tu ASCII
	sb 	$a2, ($a1)		        # luu byte do vao dia chi cua text - 1 
					        # Vd: " so le : "  =>  "<bien dem> so le: " 
	li 	$v0, 15			        # ghi vao file 9 byte ki tu
	lw 	$a0, fdescr
	li	$a2,9				
	syscall
 	
	jal Random		                # nhay den Random
	move 	$a1, $v0	
	
	lw 	$a2, temp		        # load bien dem
	addi	$a2, $a2, 4		        # lay bien dem + 4 (fff.) 
 	li 	$v0, 15			        # de ra do dai cua so can in
	lw 	$a0, fdescr		        # VD: Bien dem = so le = 2, do dai cua chuoi
	syscall			         	# can in (fff.ff) la 2 + 4 = 6 byte ki tu
	
  	lw 	$t1, temp		        # tang bien dem them 1
  	addi 	$t1, $t1, 1
  	sw 	$t1, temp		
	li 	$t2, 5			
  	bne 	$t1, $t2, supLoop	        # bien dem != 5 thi chay lai vong lap

# Xuat ket qua (syscall) 
 	la $a0,str_tc 
	addi $v0,$zero,4 
	syscall 
	j end 
baoloi:
	la 	$a0,str_loi 
	addi 	$v0,$zero,4 
	syscall 

end:
	lw	$a0, fdescr		    # dong file
	li	$v0, 16
	syscall
	li	$v0, 10			    # ket thuc
	syscall

#Random va xu li
Random:				
	li 	$v0, 30			    # Syscall 30
	syscall				    # $a0 chua 32 bit thap cua thoi gian he thong
	move 	$t2, $a0		    # luu gia tri cua $a0 vao $t2 

	li 	$v0, 40			    # Syscall 40: Random seed
	li 	$a0, 0			    # cho RNG ID bang 0
	move 	$a1, $t2		    # luu gia tri tren syscall 30 vao random seed $a1
	syscall
	
	li	$v0, 43			    # Syscall 43, tao float ngau nhien tu 0 -> 1.0
	li 	$a0, 0			    # RNG ID bang 0
	syscall

	lwc1 	$f1, thousand           # load so 1000.0
	mul.s 	$f0, $f0, $f1	        # nhan so vua random voi 1000.0 
					# de duoc so tu 0 -> 1000.0 (goi la F)
	li 	$t1, 10000		# load so 10000
	mtc1 	$t1, $f1		# chuyen qua thanh ghi $f1
	cvt.s.w $f1, $f1		# doi sang so float chinh xac don (10000.0)
	mul.s 	$f0, $f0, $f1		# nhan F voi 10000.0, duoc fffffff.fffff
	trunc.w.s $f0, $f0		# lay phan nguyen fffffff
	mfc1 	$a0, $f0		# chuyen sang thanh ghi $a0

  	la 	$t0, buffer+30 	        # load dia chi cua buffer + 30 byte
  	sb 	$0, 1($t0)  		# luu ky tu ket thuc chuoi vao vi tri cuoi + 1
  	li 	$t1, '0' 		# load '0'
  	li 	$t3, 10  	        # load 10 vao $t3
	sub 	$t2, $t0, 4		# luu dia chi cua dia chi ($t0 - 4) de ghi dau "."
	sub	$t6, $t0, 8

# Vong lap bien so fffffff thanh chuoi "fff.ffff"
loop:					
	beq 	$t0, $t2, InsertDot    # neu dia chi la $t0 - 4 thi ghi dau "." 
  	div 	$a0, $t3  		# neu khong thi a/10
  	mflo 	$a0
  	mfhi 	$t4   			# lay phan du
  	add 	$t4, $t4, $t1 		# chuyen sang ki tu ASCII
  	sb 	$t4, ($t0)  		# luu vao dia chi cua buffer
  	sub 	$t0, $t0, 1 		# tru pointer den buffer di 1
  	bne 	$t0, $t6, loop 		# neu do dai chua du 8 ("fff.ffff"), loop tiep
  					# Vd truong hop 6.ffff, tiep tuc loop de duoc ket qua 006.ffff
  	addi 	$t0, $t0, 1 		# neu bang 0, dieu chinh nguoc lai pointer (khong tru 1 nua)
  	move 	$v0, $t0  		# chuyen dia chi buffer vao $v0
  	jr 	$ra   			# return
  
# Them '.' vao chuoi
InsertDot:			
	li 	$t5, '.'		# load ki tu '.'
	sb 	$t5, ($t0)  		# luu vao chuoi
	sub 	$t0, $t0, 1 		# tru pointer den buffer di 1
	j loop 				# loop tiep de ghi cac ki tu tiep theo
