\
@echo off
REM Activate conda environment named medbot (user should create it)
echo Starting Streamlit Medical Chatbot (Gemini)...
call conda activate medbot
streamlit run app.py
pause
