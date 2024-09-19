##################################################################
####----------------------------------------------------------####
####                   IN PHO TU CHUOI KY SO                  ####
####                       Nhom 35, L14                       ####
####----------------------------------------------------------####
##################################################################

#---- Note: Trong file STRING.TXT cuoi chuoi co xuong dong  ----#
.data
fileName: .asciiz "STRING.TXT"            # Luu ten file la "STRING.TXT".
string: .space 41                         # Cap phat khong gian cho 40 ky tu va null.
newline: .asciiz "\n"                     # Luu ky tu xuong dong.
space: .asciiz " "                        # Luu ky tu khoang trang.
star: .asciiz "*"                         # Luu ky tu dau sao (*).
str_loi: .asciiz "Mo file bi loi."
.text
	.globl main
		
main:
	jal xu_ly_file
	jal xu_ly_chuoi
	jal print_histogram
	jal kthuc
	
#----------------Buoc 0: Mo file va lay du lieu---------------#
xu_ly_file:
	# Mo File
	open_file:
    		la $a0,fileName     	
    		li $a1,0             	# a1=0 (che do chi doc)
    		li $v0,13           	# Su dung syscall voi ma 13 de mo file.
    		syscall
    		bltz $v0, baoloi 	#(bao loi neu $v0 < 0)
    		move $s0,$v0        	# Luu file descriptor vao $s0.

		# Doc file
	read_file:
		li $v0, 14		# Su dung syscall 14 de doc file.
		move $a0,$s0		# Su dung file descriptor tu $s0.
		la $a1,string    	# Doc noi dung file vao bo dem string.
		la $a2,41	
		syscall
	
		# In Noi Dung File
	print_string: 
		li $v0, 4		# Su dung syscall 4 de in chuoi.
		la $a0,string          # In noi dung tu bo dem string.
		syscall
	
		# Dong File	
	close_file:
    		li $v0, 16             # Su dung syscall 16 de dong file.
    		move $a0,$s0      	# Su dung file descriptor tu $s0.
    		syscall
	
	jr $ra
####----------------------Ket thuc buoc 0---------------------####

#----------------Buoc 1: Xu ly chuoi string---------------#
xu_ly_chuoi:
		# Load dia chi cua string
    		la $a0, string

   		 # Xac dinh chieu cao toi da cua bieu do Histogram
  	  	li $t1, 0       # Dat $t1 lam bien theo doi chieu cao toi da.
   	 	li $t0, 0       # Dat $t0 lam bo dem/index.
    	
 	       # Tim chieu cao ung voi so moi ky tu
	find_max_height:
   		lb $t2, string($t0)    # Dcc tung ky tu chuoi.
  	  	beq $t2, $zero, print_histogram   # Neu gap ky tu ket thuc chuoi, chuyen sang in bieu do
    		sub $t2, $t2, 48       # Chuyen ky tu ASCII sang so nguyen.
    		blt $t2, $zero, skip   # Neu ky tu la 0, bo qua.
   	 	bgt $t2, $t1, update_height  # Cap nhat chieu cao.
    	
 	   	# bo qua ky tu 0.
	skip:
    		addi $t0, $t0, 1       # Tang chi so $t0 len 1
    		j find_max_height      # Tro lai vong lap find height
    	
   	     # cap nhat chieu cao
	update_height:
   	 	move $t1, $t2          # Cap nhat chieu cao 
    		j skip                 # Tiep tuc voi ky tu tiep theo
    		
    	jr $ra
    	
#----------------Buoc 2: Tien hanh in bieu do---------------#
# in bieu do
print_histogram:
    		move $t3, $t1          # Su dung $t3 de theo doi muc chieu cao hien tai can in.
    		move $a0, $zero        # Reset $a0 duoc dung de in ky tu

	print_level:
   	 	li $t0, 0              # Dat $t0 ve 0 de bat dau tu dau chuoi cho moi muc.

	print_stars:
    		lb $t2, string($t0)    # Doc ky tu hien tai tu chuoi vao $t2.
    		beq $t2, $zero, done   # Neu ky tu la ky tu ket thuc chuoi (null-terminator), chuyen sang buoc done.
    		sub $t2, $t2, 48       # Chuyen ky tu ASCII sang so nguyen bang cach tru di 48.
    		blt $t2, $t3, print_space # Neu gia tri nho hon muc hien tai, in khoang trang (print_space).
    		bge $t2, $t3, print_star  # Neu gia tri lon hon hoac bang muc hien tai, in dau sao (print_star).

	print_space:
    		la $a0, space         # Tai dia chi cua ky tu khoang trang vao $a0.
    		li $v0, 4             # Su dung syscall 4 de in.
    		syscall              
    		j next_char        # Chuyen sang ky tu tiep theo (next_char).

	print_star:
    		la $a0, star        # Tai dia chi cua ky tu sao vao $a0.
    		li $v0, 4             # Su dung syscall 4 de in.
    		syscall

	next_char:
    		addi $t0, $t0, 1       # Tang chi so $t0 lon 1.
    		j print_stars          # Quay lai buoc print_stars de in tiep.

	done:
   		subi $t3, $t3, 1       # Giam muc $t3 di 1.
		beqz $t3, kthuc        # Neu $t3 bang 0 thi ket thuc
    		la $a0, newline        # Tai dia chi cua ky tu xuong dong vao $a0.
    		li $v0, 4                   # Su dung syscall 4 de in xuong dong.	
    		syscall
    		bgtz $t3, print_level  # Neu $t3 van con lon hon 0, quay lai print_level de in muc tiep theo.

	jr $ra
# Ket Thuc Chuong Trinh
kthuc:
        li $v0, 10                #Su dung syscall 10 de ket thuc chuong trinh.
    	syscall
baoloi: #---Xuat chuoi bao loi roi ket thuc---#
	la $a0, str_loi 
	li $v0, 4 
	syscall
	j kthuc

