#!/bin/bash

# Define color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define paths
core_path="$HOME/Teeth-Management-System/Ai-chatbot"
Source_path="/venv/bin/activate"

#To run the full AI chatbot with web interface
AI_chatbot_with_web(){
    cd
    cd $core_path
    source $Source_path
    streamlit run app.py
}
#To run only the API without the web interface
AI_chatbot_api_only(){
    cd
    cd $core_path
    source $Source_path
    python3 api.py
}

while getopts ":ca" option; do
    case $option in
        c)
            echo -e "${GREEN}Starting AI Chatbot with Web Interface...${NC}"
            AI_chatbot_with_web
            ;;
        a)
            echo -e "${GREEN}Starting AI Chatbot API Only...${NC}"
            AI_chatbot_api_only
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
done
if [ $OPTIND -eq 1 ]; then
    echo -e "${RED}No options were passed. Use -c for Chatbot with Web Interface or -a for API Only.${NC}"
fi

