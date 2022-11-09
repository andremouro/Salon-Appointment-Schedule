#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"
echo -e "How may I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Apresentar os serviços
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  
  #Selecionar o serviço
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #Verificar qual serviço foi escolhido
    SERVICE_SELECTED_CHECK=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    #Verificar se serviço foi escolhido corretamente
    if [[ -z $SERVICE_SELECTED_CHECK ]]
    then
      #voltar para MAIN MENU
      MAIN_MENU "I haven't found this option. Choose a valid service."
    fi
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    PROGRAMA
  fi
}

PROGRAMA() {
  #Entrar o telefone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #Checar se o telefone existe nas tabelas
  CUSTOMER_PHONE_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_PHONE_RESULT ]]
  then
    echo -e "You are a new customer. What's your name?"
    read CUSTOMER_NAME
    echo -e "Hello $CUSTOMER_NAME. What time would you like your $SERVICE_NAME?"
    read SERVICE_TIME
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    #Inserir o nome e o número do novo cliente na tabela customers
    CUSTOMER_NAME_PHONE_DB=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "Hello $CUSTOMER_NAME. What time would you like your $SERVICE_NAME?"
    read SERVICE_TIME
    echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

  #Pegar o CUSTOMER_ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  APPOINTMENT_CUSTID_SERVID_TIME_DB=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")  
}



MAIN_MENU
