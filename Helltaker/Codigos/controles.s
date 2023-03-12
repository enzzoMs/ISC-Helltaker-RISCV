.text

# ====================================================================================================== # 
# 					      CONTROLES 						 #
# ====================================================================================================== #

TECLA_S: 
	
	# selecionar frame 0
		li t0, 0xFF200604
		sw zero, 0(t0)
	
	# acendendo a tecla S
		li a0,0xFF01136B		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_s			# img para acender ou apagar a tecla
		call ACENDER_DESLIGAR_TECLAS	

	# calculando o pixel central do quadrante abaixo 
		add a1, s0, zero
		add a2, s1, zero	
		call CALCULAR_ENDEREÇO_FRAME_0
		
		li t0, 0x00002A88
		add a0, a0, t0
		lb a0, 0(a0)

		li s10, 1			# tecla apertada foi S
		
		jal s3, PIXEL_CENTRAL_DECISAO

		li a0,0xFF01136B		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_s			# img para acender ou apaga a tecla
		addi a1, a1, 288 
		call ACENDER_DESLIGAR_TECLAS	
		
		j INICIO_LOOP_FASE
		
# ====================================================================================================== #

TECLA_W: 			
	
	# selecionar frame 0
		li t0, 0xFF200604
		sw zero, 0(t0)
	
	# acendendo a tecla W
		li a0,0xFF00FBAB		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_w			# img para acender ou apaga a tecla
		call ACENDER_DESLIGAR_TECLAS	

	# calculando o pixel central do quadrante acima 
		add a1, s0, zero
		add a2, s1, zero	
		call CALCULAR_ENDEREÇO_FRAME_0
		
		li t0, -0x00000EF8
		add a0, a0, t0
		lb a0, 0(a0)

		li s10, 2			# tecla apertada foi W

		jal s3, PIXEL_CENTRAL_DECISAO

		li a0,0xFF00FBAB		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_w			# img para acender ou apaga a tecla
		addi a1, a1, 288 
		call ACENDER_DESLIGAR_TECLAS	
		
		j INICIO_LOOP_FASE

# ====================================================================================================== #

TECLA_A: 

	# selecionar frame 0
		li t0, 0xFF200604
		sw zero, 0(t0)	
		
	# acendendo a tecla A
		li a0,0xFF011359		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_a			# img para acender ou apaga a tecla
		call ACENDER_DESLIGAR_TECLAS	

	# calculando o pixel central do quadrante esquerdo 
		add a1, s0, zero
		add a2, s1, zero	
		call CALCULAR_ENDEREÇO_FRAME_0
		
		li t0, 0x00000DB7
		add a0, a0, t0
		lb a0, 0(a0)

		li s10, 3			# tecla apertada foi A
		
		jal s3, PIXEL_CENTRAL_DECISAO
	
		li a0,0xFF011359		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_a			# img para acender ou apaga a tecla
		addi a1, a1, 288 		
		call ACENDER_DESLIGAR_TECLAS	
		
		j INICIO_LOOP_FASE


# ====================================================================================================== #

TECLA_D: 
	
	# selecionar frame 0
		li t0, 0xFF200604
		sw zero, 0(t0)	
	
	# acendendo a tecla D
		li a0,0xFF01137D		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_d			# img para acender ou apaga a tecla
		call ACENDER_DESLIGAR_TECLAS	

	# calculando o pixel central do quadrante direito 
		add a1, s0, zero
		add a2, s1, zero	
		call CALCULAR_ENDEREÇO_FRAME_0
		
		li t0, 0x00000DD9
		add a0, a0, t0
		lb a0, 0(a0)

		li s10, 4			# tecla apertada foi D
		
		jal s3, PIXEL_CENTRAL_DECISAO

		li a0,0xFF01137D		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_d			# img para acender ou apaga a tecla
		addi a1, a1, 288 	
		call ACENDER_DESLIGAR_TECLAS	
		
		j INICIO_LOOP_FASE


# ====================================================================================================== #

TECLA_R: 

	# selecionar frame 0
		li t0, 0xFF200604
		sw zero, 0(t0)
		
	# acendendo a tecla R
		li a0,0xFF0114DF		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_r_acesa		# img para acender ou apaga a tecla
		call ACENDER_DESLIGAR_TECLAS	# acende tecla 

		li a0,50			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall
	
	# recarrega a fase atual
		j SELETOR_FASES


# ====================================================================================================== #

TECLA_P: 

	# selecionar frame 1
		li t0, 0xFF200604
		sw zero, 0(t0)
		
	# acendendo a tecla P
		li a0,0xFF01150E		# argumento para acender ou desligar tecla - endereço
		la a1,tecla_p_acesa		# img para acender ou apaga a tecla
		call ACENDER_DESLIGAR_TECLAS	# acende tecla 

		li a0,250			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall
	
	# vai direto para a vitoria da fase
		j VITORIA
