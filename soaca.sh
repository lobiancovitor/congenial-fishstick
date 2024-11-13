#!/bin/bash

# Definindo cores
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AZUL='\033[0;34m'
BRANCO='\033[47m'
INCOLOR='\033[0m'

# Função de inicio com o menu completo
draw_menu() {
	trap '' SIGINT
	clear
	dia=$(date +%d)
	mes=$(date +%B)
	ano=$(date +%Y)

	texto_data="# Rio de Janeiro, ${AZUL}$dia${INCOLOR} de ${AZUL}$mes${INCOLOR} de ${AZUL}$ano${INCOLOR}"
	formatacao_data=$(printf "%-59s" "$texto_data")

	echo "############################################################"
	echo "# IBMEC                                                    #"
	echo -e "# Sistemas Operacionais                 Semestre ${AZUL}2${INCOLOR} de ${AZUL}2024${INCOLOR} #"
	echo "# Código IBM8940                        Turma 8001         #"
	echo "# Professor: Luiz Fernando T. de Farias                    #"
	echo "#----------------------------------------------------------#"
	echo "# Equipe Desenvolvedora:                                   #"
	echo -e "#   Aluno: ${VERDE}Gabriel Martinez${INCOLOR}                                #"
	echo -e "#   Aluno: ${VERDE}Vitor Lobianco${INCOLOR}                                  #"
	echo "#----------------------------------------------------------#"
	echo -e "$formatacao_data                   #"
	echo -e "# Hora do Sistema: ${AZUL}$(date +%H)${INCOLOR} Horas e ${AZUL}$(date +%M)${INCOLOR} Minutos                   #"
	echo "############################################################"
	echo
	echo "Menu de Escolhas:"
	echo -e "   1) Gerenciar senha"
	echo -e "   2) Fazer uma busca no Google"
	echo -e "   3) Agenda de contatos"
	echo -e "   4) Bloco de notas"
	echo -e "   5) commitar um codigo"
    echo -e "   6) Finalizar o programa."
	echo
}

# Função para criptografar e salvar a senha
encrypt_and_save_password() {
    while true; do
        read -sp "Insira a senha que deseja criptografar (mínimo 5 caracteres): " password
        echo

        # Verifica se a senha tem pelo menos 5 caracteres
        if [ ${#password} -ge 5 ]; then
            break
        else
            echo "Erro: A senha deve ter pelo menos 5 caracteres. Tente novamente."
        fi
    done

    # Criptografar a senha usando openssl
    encrypted_password=$(echo -n "$password" | openssl enc -aes-256-cbc -a -salt -pass pass:$(whoami))

    # Define o diretório e o nome do arquivo
    dir="./pass"
    filename="$dir/$(whoami).txt"

    # Criar diretório se não existir
    mkdir -p "$dir"

    # Salva a senha criptografada no arquivo
    echo "user: $(whoami)" > "$filename"
    echo "password: $encrypted_password" >> "$filename"

    echo "Senha criptografada e salva em $filename"
    sleep 2
}


# Função para descriptografar a senha
decrypt_password() {
	read -p "Insira o nome do usuário: " username
	filename="./pass/$username.txt"

	if [[ -f "$filename" ]]; then
		encrypted_password=$(grep "password:" "$filename" | cut -d ' ' -f2)
		decrypted_password=$(echo "$encrypted_password" | openssl enc -aes-256-cbc -a -d -salt -pass pass:"$username" 2>/dev/null)

		if [[ $? -eq 0 ]]; then
			echo "Senha descriptografada: $decrypted_password"
		else
			echo "Erro ao descriptografar a senha. Verifique o usuário e tente novamente."
		fi
	else
		echo "Arquivo não encontrado para o usuário '$username'."
	fi
	sleep 2
}

# Função para gerenciar a opção de senha
manage_password() {
	clear
	echo "Escolha uma opção:"
	echo -e "   1) Criptografar senha"
	echo -e "   2) Descriptografar senha"
	echo -e "   3) Voltar"

	read -p "Digite sua escolha (1-3): " choice

	case $choice in
	1)
		encrypt_and_save_password
		;;
	2)
		decrypt_password
		;;
	3)
		;;
	*)
		echo "Opção inválida!"
		sleep 1
		;;
	esac
}

# Função para realizar uma busca no Google
search_google() {
    read -p "Digite sua pesquisa: " search_query
    # Codificando a pesquisa para URL (substituindo espaços e caracteres especiais)
    encoded_query=$(echo "$search_query" | sed 's/ /+/g' | sed 's/[^a-zA-Z0-9+&@#/%?=~_|!.,;/-]/\\&/g')
    url="https://www.google.com/search?q=$encoded_query"  # URL de busca no Google
    echo "Abrindo o navegador para buscar '$search_query' no Google..."
    open "$url"  # Abre o navegador com a URL de pesquisa no macOS
    sleep 2
}


# Funções para gerenciar a agenda de contatos
add_contact() {
    echo "Digite o nome do contato:"
    read name
    echo "Digite o telefone do contato:"
    read phone
    echo "Digite o email do contato:"
    read email

    echo "Nome: $name, Telefone: $phone, Email: $email" >> agenda.txt
    echo "Contato salvo com sucesso!"
    sleep 2
}

list_contacts() {
    echo "Contatos Salvos:"
    if [ -f agenda.txt ]; then
        cat agenda.txt
    else
        echo "Nenhum contato encontrado."
    fi
    sleep 2
}

search_contact() {
    echo "Digite o nome do contato para procurar:"
    read search_name
    echo "Resultado da busca:"
    grep -i "Nome: $search_name" agenda.txt || echo "Contato não encontrado."
    sleep 2
}

manage_contacts() {
    clear
    echo "Escolha uma opção:"
    echo -e "   1) Adicionar contato"
    echo -e "   2) Listar contatos"
    echo -e "   3) Procurar contato"
    echo -e "   4) Voltar"

    read -p "Digite sua escolha (1-4): " choice

    case $choice in
        1) add_contact ;;
        2) list_contacts ;;
        3) search_contact ;;
        4) ;;
        *) echo "Opção inválida!"; sleep 2 ;;
    esac
}

# Funções para gerenciar notas rápidas
create_note() {
    mkdir -p notas
    echo "Digite sua nota (pressione Ctrl+D para salvar):"
    note=$(</dev/stdin)
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    echo "$note" > "notas/nota_$timestamp.txt"
    echo "Nota salva como notas/nota_$timestamp.txt"
    sleep 2
}

list_notes() {
    echo "Notas Salvas:"
    if ls notas/*.txt 1> /dev/null 2>&1; then
        for file in notas/*.txt; do
            echo "-----------------------------------"
            echo "Arquivo: $file"
            cat "$file"
            echo "-----------------------------------"
        done
    else
        echo "Nenhuma nota encontrada."
    fi
    sleep 5
}

manage_notes() {
    clear
    echo "Escolha uma opção:"
    echo -e "   1) Criar nova nota"
    echo -e "   2) Listar todas as notas"
    echo -e "   3) Voltar"

    read -p "Digite sua escolha (1-3): " choice

    case $choice in
        1) create_note ;;
        2) list_notes ;;
        3) ;;
        *) echo "Opção inválida!"; sleep 2 ;;
    esac
}


commit_git(){
    # Verifica se o Git está instalado
    if ! command -v git &> /dev/null
    then
        echo "Git não está instalado. Deseja instalá-lo agora? (s/n)"
        read instalar_git
        if [ "$instalar_git" == "s" ] || [ "$instalar_git" == "S" ]
        then
            # Instala o Git
            if [ "$(uname)" == "Linux" ]; then
                if [ -f /etc/debian_version ]; then
                    sudo apt update && sudo apt install git -y
                elif [ -f /etc/redhat-release ]; then
                    sudo yum install git -y
                else
                    echo "Distribuição Linux não suportada para instalação automática."
                    exit 1
                fi
            else
                echo "Sistema operacional não suportado para instalação automática."
                exit 1
            fi
        else
            echo "Erro: Git não está instalado. Por favor, instale o Git para continuar."
            exit 1
        fi
    fi

    # Solicita o caminho do diretório do repositório ao usuário
    while true; do
        echo "Digite o caminho do diretório do repositório: "
        read repo_path

        # Verifica se o caminho do diretório existe
        if [ -d "$repo_path" ]
        then
            break
        else
            echo "Erro: O caminho do diretório fornecido não existe. Por favor, tente novamente."
        fi
    done

    # Navega até o diretório do repositório
    cd "$repo_path" || { echo "Erro ao acessar o diretório fornecido."; exit 1; }

    # Verifica se o diretório é um repositório Git
    if [ ! -d .git ]
    then
        echo "Erro: O diretório fornecido não é um repositório Git."
        exit 1
    fi

    # Solicita uma mensagem de commit ao usuário
    echo "Digite a mensagem do commit: "
    read commit_message

    # Verifica se uma mensagem de commit foi fornecida
    while [ -z "$commit_message" ]
    do
        echo "Erro: Mensagem de commit não pode estar vazia. Digite a mensagem do commit: "
        read commit_message
    done

    # Adiciona todos os arquivos alterados ao staging
    if ! git add .
    then
        echo "Erro ao adicionar arquivos ao staging."
        exit 1
    fi

    # Faz o commit com a mensagem fornecida
    if ! git commit -m "$commit_message"
    then
        echo "Erro ao fazer o commit. Verifique se há algo para commitar."
        exit 1
    fi

    # Faz o push para o repositório remoto
    if ! git push origin main
    then
        echo "Erro ao fazer o push para o repositório remoto. Verifique sua conexão ou permissões."
        exit 1
    fi

}

# Função do menu de opções
menu() {
	while true; do
		draw_menu

		read -p "Selecione uma opção: " option

		case $option in
		1)
			manage_password
			;;
		2)
			search_google
			;;
		3)
			manage_contacts
			;;
		4)
			manage_notes
			;;
        5)
            commit_git
            ;;
		6)
			clear
			exit 0
			;;
		*)
			echo "Opção inválida!"
			sleep 2
			;;
		esac
	done
}

# Chamada do menu
menu
