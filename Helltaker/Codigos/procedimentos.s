.text

# ====================================================================================================== # 
# 					      PROCEDIMENTOS 						 #
# ====================================================================================================== #

PRINT_IMG: 
	# procedimento que imprime uma img de 320 x 240 no bitmap no frame desejado
	# a0 = endereço da img		
	# a1 = frame (0, 1)	
	
	li t0, 0x12C00		# area total da imagem - 320 x 240 = 76800
	addi a0,a0,8		# pula para onde começa os pixels
	li t1, 0		# contador 

	IMPRIME: 
		beq t0, t1, FIM_PRINT_IMG	# verifica se todos os pixels foram colocados
		lw t3, 0(a0)			# pega 4 pixels e coloca em t5
		sw t3, 0(a1)			# pega os pixels de t5 e coloca no bitmap
		addi a0, a0, 4			# vai para os próximos pixels da imagem
		addi a1, a1, 4			# va para os próximos pixels do bitmap
		addi t1, t1, 4			# incrementa contador
		j IMPRIME

	FIM_PRINT_IMG:
		ret 

# ====================================================================================================== #

APERTAR_TECLA:
	# Procedimento que verifica se alguma tecla foi apertada
	# Retorna a0 com o valor da tecla		
	
	li a0, 0 
	 
	li t0, 0xFF200000		# carrega o endereço de controle do KDMMIO
 	lw t1,0(t0)			# carrega em t1 o valor do endereço do controle
   	andi t1,t1,0x0001		# 0 = não tem tecla, 1 = tem tecla. Deixa em t0 somente o bit necessario
   	
    	beq t1,zero, FIM_TECLA		# não tem tecla pressionada então vai para fim
   	lw a0,4(t0)			# le o valor da tecla no endereço 0xFF200004
   		 	
	FIM_TECLA:					
		ret

# ====================================================================================================== #


CALCULAR_ENDEREÇO_FRAME_0:
	# procedimento que calcula um endereço no frame 0
	# a0 = retorno com o endereço
	# a1 = argumento com colunas
	# a2 = argumento com linhas
	
	li a0, 0xFF000000		# endereço do bitmap 
	li t0, 0x00000140		# 320

	mul t1, a2, t0			# linha x 320	
	add a0, a0, t1			# enderço base + (linha x 320)
	add a0, a0, a1			# enderço base + (linha x 320) + coluna
	
	ret 
	
# ====================================================================================================== #

ACENDER_DESLIGAR_TECLAS:
	# acende ou desliga uma tecla
	# a0 = endereço do pixel onde começa a tecla - t0
	# a1 = endereço da imagem a ser trocada - t1

	TROCA_PIXELS_TECLAS:
		addi a1, a1, 8			# pula para onde começa os pixels
 		li t0, 0			# contador para linhas
		li t1, 0x00000012		# contador para linhas totais
	
		LINHAS_TECLAS:
			li t2, 0			# contador para colunas
			li t3, 0x00000010		# contador para colunas totais
			addi  t4, a0, 0			# copia do endereço para usar no loop colunas
			
			COLUNAS_TECLAS:
			lb t5, 0(a1)			# pega o pixel da img
			sb t5, 0(t4)			# coloca o pixel no endereço
	
			addi t2, t2, 1			# incrementando
			addi t4, t4, 1
			addi a1, a1, 1
			bne t2, t3, COLUNAS_TECLAS
			
		addi t0, t0, 1
		addi a0, a0, 320				# passa o endereço para a prox linha
		beq t0,t1, FIM_ACENDER_DESLIGAR_TECLAS
		
		j LINHAS_TECLAS
		
	FIM_ACENDER_DESLIGAR_TECLAS:
		ret

# ====================================================================================================== #

TROCAR_QUADRANTES_IMG:
	# procedimento que troca um quadrante por uma img escolhida 
	# a0 = endereço do quadrante no frame 0 - depois do processo é revertido para o valor inicial
	# a1 = endereço da img para realizar troca
	# a2 = frame 0 ou 1

	add t1, a0, zero				# salvando o endereço

	beq a2, zero, QUADRANTES_IMG_INICIO		# troca o frame se for necessário
		li t0, 0x00100000
		add a0, a0, t0 

	QUADRANTES_IMG_INICIO:
	
	addi a1, a1, 8			# pula para onde começa os pixels
	
	LINHAS_QUADRANTES_IMG:
		li t2, 0			# contador de linhas
		li t3, 0x00000016		# limite de linhas para trocar -> 22
		
		COLUNAS_QUADRANTES_IMG:
			li t0, 0		# contador de colunas
			li t4, 0x00000011	# limite de colunas para trocar -> 17
			addi t5, a0, 0		# guardando o endereço no registrador que vai ser usados no loop
			
		COLUNAS_2_QUADRANTES_IMG:	
			lb t6, 0(a1)		# pega o valor do pixel e coloca em t6
			sb t6, 0(t5)		# pega o valor do pixel e coloca em t5
			
			addi t5, t5, 1
			addi a1, a1, 1
			addi t0, t0,1		# incrementando
			bne t0,t4, COLUNAS_2_QUADRANTES_IMG				
											
		addi t2, t2, 1		# incrementando
		addi a0, a0, 320
		bne t2,t3,COLUNAS_QUADRANTES_IMG 			
	
	add a0, t1, zero						
	ret
	
# ====================================================================================================== #

DESCONTAR_MOVIMENTO:
	# procedimento que desconta -1 ou -2 movimentos do jogador
	# usa s9 (registrador que guarda o numero de movimentos restantes)
	# constante = 644 ou 0x00000284, ou seja a quantidade de pixels para passar para o prox. numero na img movimentos
	

	li a0, 0xFF00D855		# a0 possui o endereço do bitmap onde vai ser colocado o novo movimento
	
	li t0, -1			# por padrão desconta -1 movimentos
	
	# se o personagem estiver em espinhos ou vai para espinhos ele leva o dobro de dano de acordo com s6 ou s7
	bne s6, zero, PERSONAGEM_VAI_ESPINHO
		mul t0, t0, s7	
		j INICIO_DESCONTAR_MOV		
	
	PERSONAGEM_VAI_ESPINHO:
		mul t0, t0, s6			
	
	# se o personagem tiver só um 1 movimento restante ele leva só 1 de dano
	INICIO_DESCONTAR_MOV:
		li t1, 1
		bne s9, t1, DESCONTAR_MOV
		li t0, -1
		
	DESCONTAR_MOV:
	add s9, s9, t0			# desconta o movimento feito
	
	li t0, 0x00000021		# guarda em t0 o numero 33 (quantidade maxima de movimentos no jogo)
	sub t1, t0, s9			# guarda em t1 a diferença em 33 e a quantidade de mov atuais 
	
	li t0, 0x00000022 		# se o numero de movimentos for 34 é porque acabaram os movimentos
	bge t1, t0, FIM_MOVIMENTOS
	
	li t2, 0x00000284		# constante
	mul t3, t1, t2 			# multiplicação para achar o endereço do num do mov atual.
	
	la t0, movimentos		# guarda em t0 o endereço da img de movimentos
	add t0, t0, t3			# coloca em t0 o endereço do mov atual
	
	# t0 possui o endereço do mov a ser colocado na tela
	
	#------------------------------------------------------------------------------------------------------

	# realizar a troca 

	li t1, 0xFF000000		# selecionando o endereço do frame 0
	li t2, 0xFF100000		# registrador para comparação
	
	addi a1, a0, 0 			# guardando os valores dos endereços
	addi a2, t0, 0
	
	li a3, 0x00100000		# valor para trocar de frame
	
	j LINHAS_MOV
	
	LOOP_FRAME_MOV:
		addi a0, a1, 0			# resetando os endereços 
		addi t0, a2, 0
	
		add a0, a0, a3			# troca de frame
	
	LINHAS_MOV:
		li t3, 0		# contador de linhas
		li t4, 0x00000017	# limite de linhas para trocar -> 23
		COLUNAS_MOV:
			li t5, 0		# contador de colunas
			li t6, 0x0000001C	# limite de colunas para trocar -> 28
			addi a4, a0, 0		# guardando nos registradores que vão ser usados no loop
		COLUNAS_2_MOV:	
			lb a5, 0(t0)		# pega o valor do pixel e coloca em a5
			sb a5, 0(a4)		# bota o pixel no bitmap
			
			addi a4, a4, 1		# incrementando
			addi t0, t0, 1
			addi t5, t5,1		
			bne t5,t6, COLUNAS_2_MOV				
											
		addi t3, t3, 1		# incrementando
		addi a0, a0, 320
		bne t3,t4,COLUNAS_MOV 			
			
	beq t1, t2, FIM_MOV		# verifica se já foram os dois frames
	li t1, 0xFF100000		# selecionando o frame 1
	j LOOP_FRAME_MOV
	
	FIM_MOV:
		ret 
	#------------------------------------------------------------------------------------------------------
	# é executado se acabarem os movimentos
	
	FIM_MOVIMENTOS:
	
	# apaga as teclas
	
	li t0, 1
	beq s10, t0, MOV_S
	li t0, 2
	beq s10, t0, MOV_W
	li t0, 3
	beq s10, t0, MOV_A
	j MOV_D
	
	MOV_S:
	li a0,0xFF01136B		# argumento para acender ou desligar tecla - endereço
	la a1,tecla_s			# img para acender ou apaga a tecla
	j INICIO_FIM_MOVIMENTOS
	
	MOV_W:
	li a0,0xFF00FBAB		# argumento para acender ou desligar tecla - endereço
	la a1,tecla_w			# img para acender ou apaga a tecla
	j INICIO_FIM_MOVIMENTOS
	
	MOV_A:
	li a0,0xFF011359		# argumento para acender ou desligar tecla - endereço
	la a1,tecla_a			# img para acender ou apaga a tecla
	j INICIO_FIM_MOVIMENTOS
	
	MOV_D:
	li a0,0xFF01137D		# argumento para acender ou desligar tecla - endereço
	la a1,tecla_d			# img para acender ou apaga a tecla
	
	INICIO_FIM_MOVIMENTOS:
	
	addi a1, a1, 288 
	call ACENDER_DESLIGAR_TECLAS	# desliga tecla 	
	
	li a0, 0xFF00D855		# a0 possui o endereço do bitmap onde vai ser colocado o novo movimento
	
	# selecionar frame 1
		li t0, 0xFF200604
		li t1, 1
		sw t1, 0(t0)

	# coloca uma img preta no outro frame para ficar piscando
	LINHAS_FIM_MOV:
		li t3, 0		# contador de linhas
		li t4, 0x00000017	# limite de linhas para trocar -> 23
		COLUNAS_FIM_MOV:
			li t5, 0		# contador de colunas
			li t6, 0x0000001C	# limite de colunas para trocar -> 28
			addi a4, a0, 0		# guardando nos registradores que vão ser usados no loop
		COLUNAS_2_FIM_MOV:	
			sb zero, 0(a4)		# bota o pixel no bitmap
			
			addi a4, a4, 1		# incrementando
			addi t5, t5,1		
			bne t5,t6, COLUNAS_2_FIM_MOV				
											
		addi t3, t3, 1		# incrementando
		addi a0, a0, 320
		bne t3,t4,COLUNAS_FIM_MOV
	
	# preparando loop de frames
		li t2, 0xFF200604		# t2 recebe o endereço para escolher frames 
		li t3, 0

		li t0, 12
		li t1, 0 
			
	LOOP_FRAMES_MOV:	
			beq t1, t0, FIM_LOOP_FRAMES_MOV
			xori t3,t3,0x001		# escolhe a outra frame
			sw t3,0(t2)			
	
			li a0,200			# pausa de a0 milisegundos
			li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
			ecall
			addi t1, t1, 1
			j LOOP_FRAMES_MOV
			
	FIM_LOOP_FRAMES_MOV:
	
		j SELETOR_FASES
	
# ====================================================================================================== #

MENU:
	# procedimento que gera o menu inicial e o menu final
	# O frame 0 e o 1 já devem ter sido impressos no bitmap
	# a3 = para onde ir quando selecionar a opcao 1
	# a4 = para onde ir quando selecionar a opcao 2
			
	MENU_LOOP:
		# frame 0 = opcao 1, frame 1 = opcao 2
	
		call APERTAR_TECLA
		call MUSICA
		beq a0, zero, MENU_LOOP 
		
		li t0, 0xFF200604
		lw t1, 0(t0)
		beq t1, zero, MENU_OP_1	
		j MENU_OP_2
		
		MENU_OP_1:
			call MUSICA
			li t1, 0x00000073
			beq a0, t1, OP_1_S
			li t1, 0x0000000A
			beq a0, t1, OP_1_ENTER
			j MENU_LOOP			
		
			OP_1_S:
				li t1, 1
				sw t1, 0(t0)
				j MENU_LOOP
			
			OP_1_ENTER:
				jr a3
				
		MENU_OP_2:
			call MUSICA
			li t1, 0x00000077
			beq a0, t1, OP_2_W
			li t1, 0x0000000A
			beq a0, t1, OP_2_ENTER
			j MENU_LOOP			
		
			OP_2_W:
				sw zero, 0(t0)
				j MENU_LOOP
				
			OP_2_ENTER:
				jr a4

# ====================================================================================================== #

PROCEDIMENTO_VITORIA:
	# procedimento que gera a parte de dialogo com as personagens
	# a5 = possui o endereço com as imagens de vitoria da fase
	# a6 = qual opcao esta certa
	
	# Determinando que o frame a ser mostrado é o 1
		li t0,0xFF200604
		li t1, 1	
		sw t1, 0(t0)		 	

	# Imprimindo a tela inicial de vitoria no frame 1
		add a0, a5, zero
		li a1, 0xFF100000
		call PRINT_IMG
		
	# Imprimindo a opcao 1 no frame 0
		li t0, 0x00012C00
		add a0, a5, t0
		li a1, 0xFF000000
		call PRINT_IMG
		
	VITORIA_TECLA_INICIAL:

		# espera uma tecla ser apertada
			call APERTAR_TECLA
			li t0, 10					# valor do ENTER
			bne a0, t0, VITORIA_TECLA_INICIAL
		
	# Determinando que o frame a ser mostrado é o 0
		li t0,0xFF200604
		sw zero, 0(t0)
			
	# Imprimindo a opcao 2 no frame 1
		li t0, 0x00025800
		add a0, a5, t0
		li a1, 0xFF100000
		call PRINT_IMG	
	
	# determinando qual opcao esta correta
	li t0, 1
	bne a6, t0, OPCAO_2				
		la a3, OPCAO_VITORIA
		la a4, OPCAO_DERROTA
		li t5, 0xFF100000		# frame de derrota
		li t6, 0xFF000000		# frame de vitoria
		call MENU
	OPCAO_2:						
		la a3, OPCAO_DERROTA
		la a4, OPCAO_VITORIA
		li t5, 0xFF000000		# frame de derrota
		li t6, 0xFF100000		# frame de vitoria												
		call MENU														
																									

	OPCAO_DERROTA:	
					
		# imprimindo a tela de derrota da fase
			li t0, 0x00038400
			add a0, a5, t0
			add a1, t5, zero
			call PRINT_IMG
		
		OPCAO_DERROTA_LOOP:

			# espera uma tecla ser apertada
			call APERTAR_TECLA
			li t0, 10				# valor do ENTER
			bne a0, t0, OPCAO_DERROTA_LOOP
		
			la a0, tela_derrota
			add a1, t5, zero
			call PRINT_IMG
		
			li a0,2000			# pausa de a0 milisegundos
			li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
			ecall
		
			j SELETOR_FASES
					
	OPCAO_VITORIA:			
		# imprimindo a tela de vitoria da fase
			li t0, 0x0004B000
			add a0, a5, t0
			add a1, t6, zero
			call PRINT_IMG
		
		OPCAO_VITORIA_LOOP:
		
			# espera uma tecla ser apertada
			call APERTAR_TECLA
			li t0, 10				# valor do ENTER
			bne a0, t0, OPCAO_VITORIA_LOOP
			
			addi s8, s8, 1
			j SELETOR_FASES
	
# ====================================================================================================== #

PIXEL_CENTRAL_DECISAO:
	# procedimento que decide qual movimento realizar
	# a0 = registrador com o valor do pixel central do quadrante
	
	# Quadrante VITORIA
		beq s5, a0, VITORIA
			
	# Quadrante CHAVE
		li t0, 0x00000064		
		bne t0, a0, QUADRANTE_PORTA		
		li s4,1				# como o personagem coletou a chave, então s4 = 1
		li s6, 1			# se o personagem for para um quadrante com chave, s6 = 1, ou seja, ele não vai para espinhos
		j MOVIMENTO_QUADRANTE_VAZIO	# pula para o procedimento de quadrante VAZIO
		
	QUADRANTE_PORTA:
		li t0, 0x00000065			
		bne t0, a0, QUADRANTE_VAZIO
		li t0, 1
		beq s4, t0, MOVIMENTO_QUADRANTE_VAZIO	# se o personagem tiver a chave o portao abre

		call DESCONTAR_MOVIMENTO		# se não tiver a chave, ele chuta o portao
		call COLOCAR_CHUTE
		
		#pausa
		li a0, 250
		li a7, 32
		ecall
		
		call RETIRAR_CHUTE
					
	QUADRANTE_VAZIO:
		li t0, 0x0000004C 
		bne t0, a0, QUADRANTE_ESQUELETO
		li s6,1						# o personagem vai para um quadrante sem espinhos
		j MOVIMENTO_QUADRANTE_VAZIO			# pula para o procedimento de quadrante VAZIO
					
	QUADRANTE_ESQUELETO:
		li t0, 0xFFFFFFF6 
		beq t0, a0, MOVIMENTO_QUADRANTE_ESQUELETO	# inicia o procedimento de quadrante ESQUELETO
	
	QUADRANTE_BLOCO:		
		li t0, 0x00000055
		beq t0, a0, MOVIMENTO_QUADRANTE_BLOCO		# inicia o procedimento de quadrante BLOCO
		
	QUADRANTE_ESPINHOS:
		li t0, 0x00000054
		bne t0, a0, QUADRANTE_BLOCO_ESPNHOS		
		li s6, 2					# o personagem vai para um quadrante com espinhos
		j MOVIMENTO_QUADRANTE_VAZIO			# inicia o procedimento de quadrante VAZIO
	
	QUADRANTE_BLOCO_ESPNHOS:		
		li t0, 0x0000004B
		bne t0, a0, FIM_PIXEL_CENTRAL_DECISAO		
		li a7, 1					# usado para sinalizar que o bloco esta em espinhos
		j MOVIMENTO_QUADRANTE_BLOCO			# inicia o procedimento de quadrante BLOCO
	
	FIM_PIXEL_CENTRAL_DECISAO:		
							
	# Nemhuma condição atendida
		li a0,50			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall
		
		jr s3

# ====================================================================================================== #

MUSICA:
	lw t3, 0(s2)
	bne zero, t3, TOCAR_MUSICA
	ret
	
TOCAR_MUSICA:
	add t6, a3, zero
	add t5, a0, zero


	li a2, 5		# instrumento
	li a3, 100		# volume
	
	li t4, 0x10011A30
	bne s2, t4, PLAY			
	
	# reseta valores
	la s2, Track1
		
PLAY:	
	li a1, 150
	lw a0,0(s2)		# le o valor da nota
	#lw a1,4(s2)		# le a duracao da nota
	li a7,31		# define a chamada de syscall
	ecall			# toca a nota
	
	addi s2,s2,8		# incrementa para o endereço da próxima nota
	
	li a0, 160
	li a7, 32
	ecall
	
	add a0, t5, zero
	add a3, t6, zero
	ret			# volta ao main loop
# ====================================================================================================== #

