.text

# ====================================================================================================== # 
# 					     MOVIMENTOS 	 					 #
# ====================================================================================================== #

MOVIMENTO_QUADRANTE_VAZIO:
	
	# descontar o movimento que será feito
	call DESCONTAR_MOVIMENTO
	
	# colocar poeira no quadrante do personagem
	
		# calcula endereço do personagem
			add a1, s0, zero
			add a2, s1, zero
			call CALCULAR_ENDEREÇO_FRAME_0	
		
		# determinar se o personagem esta em espinho ou não
			li t0, 2
			beq s7, t0, POEIRA_ESPINHO
			
			# caso normal - colocar a img de poeira 
				la a1, poeira
				li a2, 0
				call TROCAR_QUADRANTES_IMG
				j FIM_POEIRA
		
			# caso espinhos - colocar a img de poeira
			POEIRA_ESPINHO:	
				la a1, poeira_espinho
				li a2, 0
				call TROCAR_QUADRANTES_IMG
				
	FIM_POEIRA:
	
	add a3, a0, zero	# guardando endereço do quadrante onde o personagem está	
	
	# colocar a img do personagem se movendo no quadrante respectivo
		
		# verificar qual tecla foi apertada
		li t0, 1
		beq s10, t0, S_VAZIO
		li t0, 2
		beq s10, t0, W_VAZIO
		li t0, 3
		beq s10, t0, A_VAZIO
		j D_VAZIO
		
		S_VAZIO:
			addi s1, s1, 0x00000017		# atualizando a posição da linha do personagem
							# a posição da coluna continua a mesma
			li t0, 0x00001CC0
			add a0, a0, t0			# a0 para o endereço do quadrante abaixo
			j PERSONAGEM_MOVIMENTO			
																								
		W_VAZIO:
			addi s1, s1, -0x00000017	# atualizando a posição da linha do personagem
							# a posição da coluna continua a mesma
			li t0, -0x00001CC0
			add a0, a0, t0			# a0 para o endereço do quadrante acima
			j PERSONAGEM_MOVIMENTO		
		
		A_VAZIO:
							# a posição da linha continua a mesma
			addi s0, s0, -0x00000011	# atualizando a posição da coluna do personagem
			addi a0, a0, -17		# a0 para o endereço do quadrante esquerdo
			li s11, 0			# personagem vira para a esquerda
			j PERSONAGEM_MOVIMENTO				
		
		D_VAZIO:
							# a posição da linha continua a mesma
			addi s0, s0, 0x00000011		# atualizando a posição da coluna do personagem
			addi a0, a0, 17			# a0 para o endereço do quadrante direito
			li s11, 1			# personagem vira para a direita

		PERSONAGEM_MOVIMENTO:
		
			# determinar se o personagem vai para espinho ou não
			li t0, 2
			beq s6, t0, VAI_ESPINHO
			
				# caso normal - determinando qual imagem colocar dependendo da orientação
				beq s11, zero, AGACHADO_VAZIO_ESQ
			
				la a1, personagem_drt_agachado
				li a2, 0
				call TROCAR_QUADRANTES_IMG
				j FIM_PERSONAGEM_MOVIMENTO

				AGACHADO_VAZIO_ESQ:
				la a1, personagem_esq_agachado
				li a2, 0
				call TROCAR_QUADRANTES_IMG
				j FIM_PERSONAGEM_MOVIMENTO
			
				# caso espinho - determinando qual imagem colocar dependendo da orientação
				VAI_ESPINHO:
				beq s11, zero, AGACHADO_ESPINHO_ESQ
				
				la a1, personagem_drt_agachado_espinhos
				li a2, 0
				call TROCAR_QUADRANTES_IMG
				j FIM_PERSONAGEM_MOVIMENTO

				AGACHADO_ESPINHO_ESQ:
				la a1, personagem_esq_agachado_espinhos
				li a2, 0
				call TROCAR_QUADRANTES_IMG
	
		FIM_PERSONAGEM_MOVIMENTO:
		
		add a4, a0, zero	# guardando endereço do quadrante onde o personagem está	
		
		# pausa
			li a0,150			# pausa de a0 milisegundos
			li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
			ecall
	
	# retirar a img de poeira
		add a0, a3, zero
	
		# determinar se o personagem estava em espinho ou não
			li t0, 2
			beq s7, t0, RETIRAR_POEIRA_ESPINHO	
		
			# colocar a img de quadrante vazio 
				la a1, quadrante_vazio
				li a2, 0
				call TROCAR_QUADRANTES_IMG
			
			# colocar a img de quadrante vazio 
				la a1, quadrante_vazio
				li a2, 1
				call TROCAR_QUADRANTES_IMG
			
				j RETIRAR_AGACHADO
			
			RETIRAR_POEIRA_ESPINHO:
		
			# colocar a img de quadrante espinho 
				la a1, espinhos
				li a2, 0
				call TROCAR_QUADRANTES_IMG
			
			# colocar a img de quadrante espinho 
				la a1, espinhos
				li a2, 1
				call TROCAR_QUADRANTES_IMG	
		
	
	RETIRAR_AGACHADO:		
	# retirar a img do personagem agachado 
		add a0, a4, zero
								
	# determinar se o personagem vai para espinho ou não
		li t0, 2
		beq s6, t0, RETIRAR_AGACHADO_ESPINHO
			
		# caso normal - determinando qual imagem colocar dependendo da orientação
			beq s11, zero, RETIRAR_AGACHADO_ESQ
			
			la a1, personagem_drt_0
			li a2, 0
			call TROCAR_QUADRANTES_IMG
	
			la a1, personagem_drt_1
			li a2, 1
			call TROCAR_QUADRANTES_IMG
			
			li s7, 1 		# o personagem não estará em espinhos

			jr s3

		RETIRAR_AGACHADO_ESQ:
			la a1, personagem_esq_0
			li a2, 0
			call TROCAR_QUADRANTES_IMG

			la a1, personagem_esq_1
			li a2, 1
			call TROCAR_QUADRANTES_IMG
			
			li s7, 1 		# o personagem não estará em espinhos
			
			jr s3
		
		RETIRAR_AGACHADO_ESPINHO:	
		# caso espinho - determinando qual imagem colocar dependendo da orientação
			beq s11, zero, RETIRAR_AGACHADO_ESPINHO_ESQ
			
			la a1, personagem_drt_0_espinhos
			li a2, 0
			call TROCAR_QUADRANTES_IMG
	
			la a1, personagem_drt_1_espinhos
			li a2, 1
			call TROCAR_QUADRANTES_IMG
			
			li s7, 2 		# o personagem estará em espinhos			

			jr s3

		RETIRAR_AGACHADO_ESPINHO_ESQ:
			la a1, personagem_esq_0_espinhos
			li a2, 0
			call TROCAR_QUADRANTES_IMG

			la a1, personagem_esq_1_espinhos
			li a2, 1
			call TROCAR_QUADRANTES_IMG

			li s7, 2 		# o personagem estará em espinhos
	
			jr s3
	
# ====================================================================================================== #

MOVIMENTO_QUADRANTE_ESQUELETO:
	
	# descontar o movimento que será feito
	call DESCONTAR_MOVIMENTO
			
	call COLOCAR_CHUTE
		
	# seleciona o que fazer baseado no pixel central
		# quadrante espinho 
		li t0, 0x00000054
		beq a6, t0, ESPINHO_ESQUELETO	
		# quadrante vazio 
		li t0, 0x0000004C
		beq a6, t0, VAZIO_ESQUELETO
		
		# senão destroi o esqueleto
			# colocar explosao
			add a0, a4, zero	
			la a1, explosao
			li a2, 0
			call TROCAR_QUADRANTES_IMG
			
			# pausa
			li a0,250			# pausa de a0 milisegundos
			li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
			ecall

		
			# colocar quadrante vazio no lugar onde estava o esqueleto	
			add a0, a4, zero		
			la a1, quadrante_vazio
			li a2, 0
			call TROCAR_QUADRANTES_IMG
		
			la a1, quadrante_vazio
			li a2, 1
			call TROCAR_QUADRANTES_IMG
			
			j RETIRAR_CHUTE
		
	ESPINHO_ESQUELETO:
		# colocar quadrante vazio no lugar onde esta o esqueleto	
		add a0, a4, zero		
		la a1, quadrante_vazio
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, quadrante_vazio
		li a2, 1
		call TROCAR_QUADRANTES_IMG						
															
		# colocar a explosao no lugar para onde o esqueleto vai																							
				
		add a0, a5, zero																					
		la a1, explosao_espinho
		li a2, 0
		call TROCAR_QUADRANTES_IMG																																		
																																											
		# pausa
		li a0,250			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall																																															

																																																																																																																
		# colocar a quadrante espinhos no lugar para onde o esqueleto vai																																																																																							
		add a0, a5, zero		
		la a1, espinhos
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		j RETIRAR_CHUTE
																																																																														
	VAZIO_ESQUELETO:
		# colocar quadrante vazio no lugar onde esta o esqueleto	
		add a0, a4, zero		
		la a1, quadrante_vazio
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, quadrante_vazio
		li a2, 1
		call TROCAR_QUADRANTES_IMG																																																																																					
						
		# colocar o esqueleto no lugar para onde ele vai																																																																																																																																																																																			
		add a0, a5, zero																																																																																																														
		la a1, esqueleto_0
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, esqueleto_1
		li a2, 1
		call TROCAR_QUADRANTES_IMG
		
	# pausa
		li a0,250			# pausa de a0 milisegundos
		li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
		ecall		
		
		j RETIRAR_CHUTE

# ====================================================================================================== #
					
MOVIMENTO_QUADRANTE_BLOCO:

	# descontar o movimento que será feito
	call DESCONTAR_MOVIMENTO
			
	# carregar a animação de chute	
	call COLOCAR_CHUTE
	
	# seleciona o que fazer baseado no pixel central
		# quadrante espinho 
		li t0, 0x00000054
		beq a6, t0, MOVER_BLOCO	
		# quadrante vazio 
		li t0, 0x0000004C
		beq a6, t0, MOVER_BLOCO
		
		BLOCO_NADA:
		# senão nada acontece, o bloco fica no mesmo lugar.
			li a0,250			# pausa de a0 milisegundos
			li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
			ecall

			j RETIRAR_CHUTE
			
	MOVER_BLOCO:
		li t0, 1
		beq a7, t0, ESPINHO_BLOCO
	
		# colocar quadrante vazio no lugar onde esta o bloco	
		add a0, a4, zero		
		la a1, quadrante_vazio
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, quadrante_vazio
		li a2, 1
		call TROCAR_QUADRANTES_IMG
		
		j MOVER_BLOCO_DECISAO
		
		ESPINHO_BLOCO:
		# colocar quadrante espinhos no lugar onde esta o bloco	
		add a0, a4, zero		
		la a1, espinhos
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, espinhos
		li a2, 1
		call TROCAR_QUADRANTES_IMG	
		
		MOVER_BLOCO_DECISAO:
		# seleciona o que fazer baseado no pixel central
			# quadrante espinho 
			li t0, 0x00000054
			beq a6, t0, MOVER_BLOCO_ESPINHO	
			
			# quadrante vazio 
				# colocar o bloco no lugar para onde ele vai
				add a0, a5, zero		
				la a1, bloco
				li a2, 0
				call TROCAR_QUADRANTES_IMG
		
				la a1, bloco
				li a2, 1
				call TROCAR_QUADRANTES_IMG	
							
				# pausa
				li a0,250			# pausa de a0 milisegundos
				li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
				ecall
		
				j RETIRAR_CHUTE
		
			MOVER_BLOCO_ESPINHO:
				# colocar o bloco no lugar para onde ele vai
				add a0, a5, zero		
				la a1, bloco_espinho
				li a2, 0
				call TROCAR_QUADRANTES_IMG
		
				la a1, bloco_espinho
				li a2, 1
				call TROCAR_QUADRANTES_IMG	

				# pausa
				li a0,250			# pausa de a0 milisegundos
				li a7,32			# escolhendo a syscall 32 - sleep por a0 milisegundos
				ecall
				
				j RETIRAR_CHUTE

# ====================================================================================================== # 
# 			      PROCEDIMENTOS AUXILIARES - COLOCAR/RETIRAR CHUTE	 		         #
# ====================================================================================================== #					
								

COLOCAR_CHUTE:
	# Esse procedimento carrega a animação de chute
	# Retorna a5, a4 e a3 com endereços de quadrantes e a6 com o pixel central
	
	add a3, ra, zero				# salvando o endereço de retorno
	
	# calcula endereço do personagem
		add a1, s0, zero
		add a2, s1, zero
		call CALCULAR_ENDEREÇO_FRAME_0

		
	# verificar qual tecla foi apertada
		
		li t0, 1
		beq s10, t0, S_CHUTE
		li t0, 2
		beq s10, t0, W_CHUTE
		li t0, 3
		beq s10, t0, A_CHUTE
		j D_CHUTE
		
	S_CHUTE:
		li t0, 0x00004748
		add a6, a0, t0			# passa a6 para o endereço do pixel central abaixo do esqueleto/bloco
		li t0, 0x00001CC0
		add a4, a0, t0			# passa a4 para o endereço do quadrante abaixo 	
		li t0, 0x00003980
		add a5, a0, t0			# passa a5 para o endereço do quadrante abaixo * 2 				
		j PERSONAGEM_CHUTE			
																								
	W_CHUTE:
		li t0, -0x00002BB8
		add a6, a0, t0			# passa a6 para o endereço do pixel central abaixo do esqueleto/bloco
		li t0, -0x00001CC0
		add a4, a0, t0			# passa a4 para o endereço do quadrante abaixo 	
		li t0, -0x00003980
		add a5, a0, t0			# passa a5 para o endereço do quadrante abaixo * 2 				
		j PERSONAGEM_CHUTE				
		
	A_CHUTE:
		li t0, 0x00000DA6
		add a6, a0, t0			# passa a6 para o endereço do pixel central abaixo do esqueleto/bloco
		li t0, -0x00000011
		add a4, a0, t0			# passa a4 para o endereço do quadrante abaixo 	
		li t0, -0x00000022
		add a5, a0, t0			# passa a5 para o endereço do quadrante abaixo * 2 							
		li s11, 0			# personagem vira para a esquerda
		j PERSONAGEM_CHUTE				
		
	D_CHUTE:
		li t0, 0x00000DEA
		add a6, a0, t0			# passa a6 para o endereço do pixel central abaixo do esqueleto/bloco
		li t0, 0x00000011
		add a4, a0, t0			# passa a4 para o endereço do quadrante abaixo 	
		li t0, 0x00000022
		add a5, a0, t0			# passa a5 para o endereço do quadrante abaixo * 2 							
		li s11, 1			# personagem vira para a esquerda
		j PERSONAGEM_CHUTE
	
	PERSONAGEM_CHUTE:	
		# determinar se o personagem esta em espinho ou não
		li t0, 2
		beq s7, t0, CHUTE_ESPINHOS
		
		# caso normal - colocar a img de chute 
			beq s11, zero, CHUTE_ESQ
			la a1,personagem_chute_drt
			li a2, 0
			call TROCAR_QUADRANTES_IMG
			j FIM_CHUTE
				
		CHUTE_ESQ:
			la a1,personagem_chute_esq
			li a2, 0
			call TROCAR_QUADRANTES_IMG
			j FIM_CHUTE
		
		# caso espinhos - colocar a img de chute 
		CHUTE_ESPINHOS:
			beq s11, zero, CHUTE_ESQ_ESPINHOS
			la a1,personagem_chute_drt_espinhos
			li a2, 0
			call TROCAR_QUADRANTES_IMG
			j FIM_CHUTE
				
		CHUTE_ESQ_ESPINHOS:
			la a1,personagem_chute_esq_espinhos
			li a2, 0
			call TROCAR_QUADRANTES_IMG
	
	FIM_CHUTE:
	# calcular pixel central do quadrante respectivo	
		lb a6, 0(a6)		# a6 tem o valor do pixel central
		
		add ra, a3, zero
		add a3, a0, zero			# salvando o endereço do personagem	
		
		ret 

# ====================================================================================================== #
		
RETIRAR_CHUTE:

		add a0, a3, zero
	
		# verifica se o personagem esta em espinhos
		li t0, 2
		beq s7, t0, RETIRAR_CHUTE_ESPINHO
		
		# caso normal - colocar a img dependendo da orientação
		beq s11, zero, RETIRAR_CHUTE_ESQ
		la a1, personagem_drt_0
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, personagem_drt_1
		li a2, 1
		call TROCAR_QUADRANTES_IMG
				
		jr s3
		
		RETIRAR_CHUTE_ESQ:
		la a1, personagem_esq_0
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, personagem_esq_1
		li a2, 1
		call TROCAR_QUADRANTES_IMG		
		
		jr s3
		
		# caso espinho - colocar a img dependendo da orientação
		RETIRAR_CHUTE_ESPINHO:
		beq s11, zero, RETIRAR_CHUTE_ESQ_ESPINHO
		la a1, personagem_drt_0_espinhos
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, personagem_drt_1_espinhos
		li a2, 1
		call TROCAR_QUADRANTES_IMG
				
		jr s3
		
		RETIRAR_CHUTE_ESQ_ESPINHO:
		la a1, personagem_esq_0_espinhos
		li a2, 0
		call TROCAR_QUADRANTES_IMG
		
		la a1, personagem_esq_1_espinhos
		li a2, 1
		call TROCAR_QUADRANTES_IMG
		
		jr s3

# ====================================================================================================== #				
												
