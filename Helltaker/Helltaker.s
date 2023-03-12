.text

# ====================================================================================================== # 
# 						TELA INICIAL						 #
# ====================================================================================================== #

TELA_INICIAL:

	la s2, Track1				# guardando em s2 o endereço da música
	
	# Imprimindo tela inicial - opcao 1 no frame 0
		la a0, tela_inicial_op_1		
		li a1, 0xFF000000		
		call PRINT_IMG	

	# Imprimindo tela inicial - opcao 2 no frame 1			
		la a0, tela_inicial_op_2		
		li a1, 0xFF100000		
		call PRINT_IMG		
	
	# Chamando o procedimento de Menu
		la a3, INICIO_JOGO		# se for selecionado a opcao 1 vai para o inicio do jogo
		la a4, TELA_INICIAL_FASES	# se for selecionado a opcao 2 vai para a seleção de capitulos
		call MENU
			
# --------------------------------------------------------------------------------------------------------

	# Carrega a parte do menu incial responsavel pela seleção de capítulos
	
	TELA_INICIAL_FASES:
		li t2, 1				# contador para as img do menu				
	
		TELA_INICIAL_FASES_DECISAO:
		
		# dependendo do valor de t2 uma fase vai ser carregada no menu
	
		la a0, seletor_fase_1
		li t0, 1
		beq t2, t0, TELA_INICIAL_FASES_IMG
	
		la a0, seletor_fase_2
		li t0, 2
		beq t2, t0, TELA_INICIAL_FASES_IMG
	
		la a0, seletor_fase_3
		li t0, 3
		beq t2, t0, TELA_INICIAL_FASES_IMG
	
		la a0, seletor_fase_4
		li t0, 4
		beq t2, t0, TELA_INICIAL_FASES_IMG
	
		la a0, seletor_fase_5
		li t0, 5
	
		TELA_INICIAL_FASES_IMG:
			# carrega a img que foi selecionada no frame 1
			li a1, 0xFF100000		
			call PRINT_IMG	
	
		TECLA_TELA_INICIAL_FASES:
			# espera uma tecla ser apertada	
			call MUSICA		
			call APERTAR_TECLA			
			beq a0,zero,TECLA_TELA_INICIAL_FASES	
		
			# verifica qual tecla foi apertada
			li t0, 0x00000061
			beq a0, t0, SELETOR_FASES_A		# tecla A foi apertada
			li t0, 0x00000064
			beq a0, t0, SELETOR_FASES_D		# tecla D foi apertada
			li t0, 0x0000000A
			beq a0, t0, SELETOR_FASES_ENTER		# tecla Enter foi apertada
		
			j TECLA_TELA_INICIAL_FASES		# nenhuma tecla acima foi apertada
		
			SELETOR_FASES_A:
				# se a tecla apertada foi A então t2 recebe -1, exceto se t2 for 1.
				li t0, 1
				beq t2, t0, TECLA_TELA_INICIAL_FASES
				addi t2, t2, -1
				j TELA_INICIAL_FASES_DECISAO
		
			SELETOR_FASES_D:
				# se a tecla apertada foi D então t2 recebe -1, exceto se t2 for 5.
				li t0, 5
				beq t2, t0, TECLA_TELA_INICIAL_FASES
				addi t2, t2, 1
				j TELA_INICIAL_FASES_DECISAO
			
			SELETOR_FASES_ENTER:
				# se a tecla apertada foi Enter, então será carregada a fase de numero t2
				add s8, t2, zero
				j SELETOR_FASES
	
# --------------------------------------------------------------------------------------------------------
	
	# Mostra a história inicial do jogo	
																																
	INICIO_JOGO:
	
		li t2, 0			# contador para as img da historia
	
		# imprimindo a intro_1 no frame 0
		la a0, intro_1	
		li a1, 0xFF000000		
		call PRINT_IMG
	
		# imprimindo a intro_1 no frame 1
		la a0, intro_2		
		li a1, 0xFF100000		
		call PRINT_IMG	
	
		INTRO_LOOP:
			call APERTAR_TECLA		# espera uma tecla ser apertada
			li t0, 10
			bne t0, a0, INTRO_LOOP		# se a tecla for diferente de Enter volta para o loop 
			beq t2, zero, INTRO_2		
			j INTRO_3
	
		INTRO_2:
			# troca o frame de 0 para 1
			li t0, 0xFF200604
			li t1, 1
			sw t1, 0(t0)
	
			# carrega a intro_3 no frame 0
			la a0, intro_3		
			li a1, 0xFF000000		
			call PRINT_IMG

			# incrementa t2 e volta para o loop
			li t2, 1			
			j INTRO_LOOP	
	
		INTRO_3:
			# troca o frame de 1 para 0
			li t0, 0xFF200604
			sw zero, 0(t0)
			
			# espera a tecla Enter ser apertada
			call APERTAR_TECLA
			li t0, 10
			bne t0, a0, INTRO_3

			li s8, 1			# selecionando a fase 1
		
# ====================================================================================================== # 
# 					TABELA DE REGISTRADORES						 #
# ====================================================================================================== #

	# s0 = coluna atual do personagem
	# s1 = linha atual do personagem
	# s3 = registrador que guarda o endereço de retorno para os controles	
	# s4 = guarda 1 se o personagem tiver a chave, 0 se não tiver
	# s5 = guarda o valor do pixel de vitoria da fase
	# s6 = guarda 1 se o personagem vai para um quadrante sem espinhos, 2 = com espinhos	
	# s7 = guarda 1 se o personagem não estiver em espinhos, 2 = se estiver		
	# s8 = guarda o numero da fase atual
	# s9 = guarda os movimentos restantes do personagem	
	# s10 = usado para determinar qual tecla foi apertada nos controles. 1 = S, 2 = W, 3 = A, 4 = D
	# s11 = orientação do personagem -> 0 = virado para a esquerda, 1 = virado para a direita

# ====================================================================================================== # 
# 					    SELEÇÂO DE FASES						 #
# ====================================================================================================== #

SELETOR_FASES:

	li s7, 1			# o personagem não estara em espinhos no começo da fase
	li s4, 0			# o personagem não terá chave no começo da fase
	li s11, 1			# o personagem sempre começara virado para a direita por padrão

	# verifica qual fase é para ser carregada de acordo com o valor de s8

	li t0, 1
	beq s8, t0, FASE_1
	addi t0, t0, 1
	beq s8, t0, FASE_2
	addi t0, t0, 1
	beq s8, t0, FASE_3
	addi t0, t0, 1
	beq s8, t0, FASE_4
	addi t0, t0, 1
	beq s8, t0, FASE_5
	
	FASE_1: 
		# Determinando a posição inicial do personagem
		li s0, 0x000000B9	# 185
		li s1, 0x00000035	# 53
		
		# a fase possui 23 movimentos
		li s9, 0x00000017
		
		# valor do pixel de vitoria
		li s5, 0xFFFFFFA5
		
		# Imprimindo fase 1 - frame 1
		la a0, fase_1_frame_1		
		li a1, 0xFF100000		
		call PRINT_IMG			
		
		# Imprimindo fase 1 - frame 0
		la a0, fase_1_frame_0
		li a1, 0xFF000000		
		call PRINT_IMG			
		
		j FIM_SELETOR_FASES
	
	FASE_2:
		# Determinando a posição inicial do personagem
		li s0, 0x00000066	# 102
		li s1, 0x0000008B	# 139
	
		# a fase possui 24 movimentos
		li s9, 0x00000018
		
		# valor do pixel de vitoria
		li s5, 0x0000005F
		
		# Imprimindo fase 2 - frame 1
		la a0, fase_2_frame_1		
		li a1, 0xFF100000		
		call PRINT_IMG			
		
		# Imprimindo fase 2 - frame 0
		la a0, fase_2_frame_0		
		li a1, 0xFF000000		
		call PRINT_IMG			
		
		j FIM_SELETOR_FASES
	
	FASE_3:
		# Determinando a posição inicial do personagem
		li s0, 0x000000D4	# 212  
		li s1, 0x00000050	# 80
		
		# a fase possui 32 movimentos
		li s9, 0x00000020
		
		# valor do pixel de vitoria
		li s5, 0x0000005E
		
		# Imprimindo fase 3 - frame 1
		la a0, fase_3_frame_1		
		li a1, 0xFF100000		
		call PRINT_IMG			
		
		# Imprimindo fase 3 - frame 0
		la a0, fase_3_frame_0		
		li a1, 0xFF000000		
		call PRINT_IMG			
		
		j FIM_SELETOR_FASES
		
	FASE_4:
		# Determinando a posição inicial do personagem
		li s0, 0x0000005D	# 93  
		li s1, 0x0000003B	# 59

		# a fase possui 23 movimentos
		li s9, 0x00000017
		
		# valor do pixel de vitoria
		li s5, 0xFFFFFFA5
		
		# Imprimindo fase 4 - frame 1
		la a0, fase_4_frame_1		
		li a1, 0xFF100000		
		call PRINT_IMG			
		
		# Imprimindo fase 4 - frame 0
		la a0, fase_4_frame_0		
		li a1, 0xFF000000		
		call PRINT_IMG			
		
		j FIM_SELETOR_FASES	
		
	FASE_5:
		# Determinando a posição inicial do personagem
		li s0, 0x00000067	# 103  
		li s1, 0x000000AD	# 173
		
		# a fase possui 33 movimentos
		li s9, 0x00000021
		
		# valor do pixel de vitoria
		li s5, 0x00000002
		
		# Imprimindo fase 4 - frame 1
		la a0, fase_5_frame_1		
		li a1, 0xFF100000		
		call PRINT_IMG			
		
		# Imprimindo fase 4 - frame 0
		la a0, fase_5_frame_0		
		li a1, 0xFF000000		
		call PRINT_IMG			
		
FIM_SELETOR_FASES:

	li s2, 0xFF000100

# ====================================================================================================== # 
# 					 LOOP PRINCIPAL DO JOGO						 #
# ====================================================================================================== #
	
# Parte responsável por realizar o loop de frames de acordo como a fase selecionada	

INICIO_LOOP_FASE:	
	# preparando loop de frames
		li t2, 0xFF200604		# t2 recebe o endereço para escolher frames 
		li t3, 0
	
	LOOP_FASE: 
		# realiza o loop de frames e detecta se alguma tecla foi pressionada	
		 
		xori t3,t3,0x001		# troca o valor de t3
		sw t3,0(t2)			# seleciona a Frame t2
	
		li a0,200			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall
	
		call APERTAR_TECLA		# ve se alguma tecla foi pressionada
		beq a0, zero, LOOP_FASE		# se nao tiver tecla volta para o loop
	
		# checagem de qual tecla foi pressionada
		li t0, 0x00000073
		beq a0, t0, TECLA_S			# verifica se a tecla apertada foi S
		li t0, 0x00000077
		beq a0, t0, TECLA_W			# verifica se a tecla apertada foi W
		li t0, 0x00000061
		beq a0, t0, TECLA_A			# verifica se a tecla apertada foi A
		li t0, 0x00000064
		beq a0, t0, TECLA_D			# verifica se a tecla apertada foi D
		li t0, 0x00000072
		beq a0, t0, TECLA_R			# verifica se a tecla apertada foi R
		li t0, 0x00000070
		beq a0, t0, TECLA_P			# verifica se a tecla apertada foi P
	
	j LOOP_FASE

# ====================================================================================================== # 
# 					 VITORIA DAS FASES						 #
# ====================================================================================================== #

VITORIA:	
	# checagem de qual fase é
		li t0, 1
		beq s8, t0, VITORIA_1
		li t0, 2
		beq s8, t0, VITORIA_2
		li t0, 3
		beq s8, t0, VITORIA_3
		li t0, 4
		beq s8, t0, VITORIA_4
		li t0, 5
		beq s8, t0, FINAL_JOGO
	
	# Determinando os argumentos do procedimento de vitoria dependendo de qual fase for escolhida 	
				
	VITORIA_1:

	la a5, vitoria_fase_1
	li a6, 2				# determina qual a opção que está certa
	j PROCEDIMENTO_VITORIA
	
	VITORIA_2:

	la a5, vitoria_fase_2
	li a6, 2				# determina qual a opção que está certa
	j PROCEDIMENTO_VITORIA
	
	VITORIA_3:

	la a5, vitoria_fase_3
	li a6, 1				# determina qual a opção que está certa
	j PROCEDIMENTO_VITORIA

	VITORIA_4:

	la a5, vitoria_fase_4
	li a6, 1				# determina qual a opção que está certa
	j PROCEDIMENTO_VITORIA

# --------------------------------------------------------------------------------------------------------

	FINAL_JOGO:
	# Determinando que o frame a ser mostrado é o 0
		li t0,0xFF200604	
		sw zero, 0(t0)	

	# Imprimindo a historia final do jogo
	
	li t2, 0 					# contador para as img da historia
	
	la a0, fim_1	
	li a1, 0xFF000000		
	call PRINT_IMG
	
	la a0, fim_2		
	li a1, 0xFF100000		
	call PRINT_IMG	
	
	FINAL_LOOP:
		call APERTAR_TECLA
		li t0, 10
		bne t0, a0, FINAL_LOOP 
		beq t2, zero, FINAL_2
		li t0, 1
		beq t2, t0, FINAL_3
		li t0, 2
		beq t2, t0, FINAL_4
		li t0, 3
		beq t2, t0, FINAL_5
		j FINAL_OPCOES
	
	FINAL_2:
		li t0, 0xFF200604
		li t1, 1
		sw t1, 0(t0)
	
		la a0, fim_3		
		li a1, 0xFF000000		
		call PRINT_IMG

		li t2, 1	
		j FINAL_LOOP	
	
	FINAL_3:
		li t0, 0xFF200604
		sw zero, 0(t0)
	
		la a0, fim_4		
		li a1, 0xFF100000		
		call PRINT_IMG

		li t2, 2	
		j FINAL_LOOP
		
	FINAL_4:
		li t0, 0xFF200604
		li t1, 1
		sw t1, 0(t0)
	
		la a0, fim_5		
		li a1, 0xFF000000		
		call PRINT_IMG

		li t2, 3	
		j FINAL_LOOP
	
	FINAL_5:
		li t0, 0xFF200604
		sw zero, 0(t0)

		la a0, fim_op_2	
		li a1, 0xFF100000		
		call PRINT_IMG

		li t2, 4	
		j FINAL_LOOP
		
	FINAL_OPCOES:
		li t0, 0xFF200604
		li t1, 1
		sw t1, 0(t0)
		
		la a0, fim_op_1
		li a1, 0xFF000000		
		call PRINT_IMG
	
		la a3, TELA_INICIAL
		la a4, FIM_JOGO
		call MENU
		
		FIM_JOGO:
		# encerra o jogo	
		
		# imprime uma img preta no frame 0
		li t0, 0x00012C00		# contador para o numero total de pixels
		li t1, 0
		li t2, 0xFF000000		# endereço do frame 0
		
		FIM_JOGO_LOOP:
		sw zero, 0(t2)			# coloca pixels pretos no bitmap
		
		addi t2, t2, 4			# # va para os próximos pixels do bitmap
		addi t1, t1, 1			# incrementando contador
		bne t1, t0, FIM_JOGO_LOOP 	
			
		# troca o frame para 0
		li t0, 0xFF200604	
		sw zero, 0(t0)																											
																																																																																			
		li a7, 10			# ecall 10 = exit do programa
		ecall

# ---------------------------------------------------------------------------------------------------------------	

.data

Track1: 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 31, 100, 31, 99, 43, 100, 43, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 38, 100, 38, 99, 50, 100, 50, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 48, 100, 48, 189, 43, 10, 43, 189, 39, 10, 39, 189, 39, 210, 39, 189, 43, 10, 43, 189, 48, 10, 48, 189, 47, 10, 47, 189, 43, 10, 43, 189, 47, 10, 47, 189, 50, 10, 50, 189, 47, 210, 47, 189, 50, 10, 50, 189, 55, 10, 55, 189, 50, 10, 50, 189, 48, 10, 48, 189, 51, 10, 51, 189, 55, 10, 55, 189, 51, 210, 51, 189, 55, 10, 55, 189, 60, 10, 60, 189, 41, 10, 41, 189, 43, 10, 43, 189, 46, 10, 46, 189, 48, 10, 48, 189, 50, 10, 50, 189, 51, 10, 51, 189, 55, 10, 55, 189, 59, 10, 59, 189, 60, 10, 60, 189, 36, 10, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 51, 300, 51, 99, 51, 300, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 43, 100, 43, 99, 55, 100, 55, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 39, 100, 39, 99, 51, 100, 51, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100, 36, 99, 48, 100, 48, 99, 36, 100

# MENU

.include "./Imagens/menu/tela_inicial_op_1.data"	
.include "./Imagens/menu/tela_inicial_op_2.data"
.include "./Imagens/menu/seletor_fase_1.data"
.include "./Imagens/menu/seletor_fase_2.data"	
.include "./Imagens/menu/seletor_fase_3.data"	
.include "./Imagens/menu/seletor_fase_4.data"	
.include "./Imagens/menu/seletor_fase_5.data"

# HISTÓRIA
.include "./Imagens/historia/intro_1.data"	
.include "./Imagens/historia/intro_2.data"	
.include "./Imagens/historia/intro_3.data"	
.include "./Imagens/historia/fim_1.data"
.include "./Imagens/historia/fim_2.data"
.include "./Imagens/historia/fim_3.data"
.include "./Imagens/historia/fim_4.data"
.include "./Imagens/historia/fim_5.data"
.include "./Imagens/historia/fim_op_1.data"
.include "./Imagens/historia/fim_op_2.data"
		
# FASE 1:
.include "./Imagens/fases/fase_1_frame_1.data"	
.include "./Imagens/fases/fase_1_frame_0.data"
.include "./Imagens/fases/vitoria_fase_1.data"

# FASE 2:
.include "./Imagens/fases/fase_2_frame_0.data"
.include "./Imagens/fases/fase_2_frame_1.data"
.include "./Imagens/fases/vitoria_fase_2.data"

# FASE 3:
.include "./Imagens/fases/fase_3_frame_1.data"	
.include "./Imagens/fases/fase_3_frame_0.data"
.include "./Imagens/fases/vitoria_fase_3.data"

# FASE 4:
.include "./Imagens/fases/fase_4_frame_1.data"	
.include "./Imagens/fases/fase_4_frame_0.data"
.include "./Imagens/fases/vitoria_fase_4.data"

# FASE 5:
.include "./Imagens/fases/fase_5_frame_1.data"	
.include "./Imagens/fases/fase_5_frame_0.data"

# TECLAS 
.include "./Imagens/teclas/tecla_s.data"	
.include "./Imagens/teclas/tecla_w.data"	
.include "./Imagens/teclas/tecla_a.data"	
.include "./Imagens/teclas/tecla_d.data"	
.include "./Imagens/teclas/tecla_r_acesa.data"	
.include "./Imagens/teclas/tecla_p_acesa.data"	

# PERSONAGEM
.include "./Imagens/personagem/personagem_esq_0.data"
.include "./Imagens/personagem/personagem_esq_1.data"
.include "./Imagens/personagem/personagem_drt_1.data"
.include "./Imagens/personagem/personagem_drt_0.data"
.include "./Imagens/personagem/personagem_esq_0_espinhos.data"
.include "./Imagens/personagem/personagem_esq_1_espinhos.data"
.include "./Imagens/personagem/personagem_drt_1_espinhos.data"
.include "./Imagens/personagem/personagem_drt_0_espinhos.data"
.include "./Imagens/personagem/personagem_chute_esq.data"	
.include "./Imagens/personagem/personagem_chute_drt.data"	
.include "./Imagens/personagem/personagem_chute_esq_espinhos.data"	
.include "./Imagens/personagem/personagem_chute_drt_espinhos.data"	
.include "./Imagens/personagem/personagem_esq_agachado.data"
.include "./Imagens/personagem/personagem_drt_agachado.data"
.include "./Imagens/personagem/personagem_drt_agachado_espinhos.data"
.include "./Imagens/personagem/personagem_esq_agachado_espinhos.data"

# OUTROS
.include "./Imagens/misc/movimentos.data"
.include "./Imagens/misc/tela_derrota.data"
.include "./Imagens/misc/explosao.data"	
.include "./Imagens/misc/explosao_espinho.data"
.include "./Imagens/misc/quadrante_vazio.data"	
.include "./Imagens/misc/esqueleto_0.data"
.include "./Imagens/misc/esqueleto_1.data"
.include "./Imagens/misc/bloco.data"
.include "./Imagens/misc/bloco_espinho.data"
.include "./Imagens/misc/poeira.data"
.include "./Imagens/misc/poeira_espinho.data"
.include "./Imagens/misc/espinhos.data"

# Códigos
.include "./Codigos/controles.s"	
.include "./Codigos/procedimentos.s"
.include "./Codigos/movimentos.s"




