#!/bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~"

PSQL="psql -X -U freecodecamp -d salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"
  echo "$($PSQL "select * from services")" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_AV=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AV ]]
    then
      MAIN_MENU "That service is not available"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      
      echo -e "\nWhat time would you like your $SERVICE_AV, $CUSTOMER_NAME?"
      read SERVICE_TIME
      
      APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      
      echo "I have put you down for a$SERVICE_AV at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
