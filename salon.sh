#! /bin/bash

# Access to DB
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function for the main menu
MAIN_MENU() {
  # If an argument is passed, print it as a secondary title
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"

  # Get available services from the database
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  if [[ -z $AVAILABLE_SERVICES ]]; then
    # If no services are available, display an error message and call MAIN_MENU again
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # If services are available, display them
    echo "$AVAILABLE_SERVICES" | sed 's/ |/ /' | while read SERVICE_ID NAME;
    do
      echo "$SERVICE_ID) $NAME"
    done

    # Read user's service selection
    read SERVICE_ID_SELECTED
    SERVICE_ID_SELECTED_VALID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    SERVICE_NAME_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ $SERVICE_ID_SELECTED_VALID ]];
     then
      # If the selected service ID is valid, prompt for the customer's phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_PHONE_VALID=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")
        if [[ -z $CUSTOMER_PHONE_VALID ]]
          then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME';")
        fi
        else
        MAIN_MENU "I could not find that service. What would you like today?"
        return
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
    echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_SERVICE=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED_VALID, $CUSTOMER_ID, '$SERVICE_TIME');")
    echo -e "\nI have put you down for a cut at $SERVICE_TIME,$CUSTOMER_NAME.\n"
  fi
}

# Call the MAIN_MENU function to start the program
MAIN_MENU
