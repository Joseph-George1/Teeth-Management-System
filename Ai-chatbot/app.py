import os
import streamlit as st
from dotenv import load_dotenv
import sqlite3
import traceback
import logging
import re

# Import ai_client in a way that works when running the file directly
try:
    # When the package is installed or run as a module
    from . import ai_client
except Exception:
    # When running as a script (e.g. `streamlit run app.py`) fall back to top-level import
    import ai_client


logging.getLogger("streamlit.runtime.scriptrunner.script_run_context").setLevel(logging.ERROR)

# Load Gemini API key from .env
load_dotenv()

st.set_page_config(page_title="المساعد الطبي / Medical Assistant Chatbot", page_icon="💬", layout="centered")
st.title("دكتوري🩺")
def get_doctor_recommendation(symptom_text):
    try:
        conn = sqlite3.connect(os.path.join(os.getcwd(), 'doctors.db'))
        c = conn.cursor()
        c.execute("SELECT name, specialty, services FROM doctors")
        doctors = c.fetchall()
        conn.close()
        for name, specialty, services in doctors:
            for keyword in services.split(","):
                if keyword.strip() and keyword.strip().lower() in symptom_text.lower():
                    return {"name": name, "specialty": specialty, "services": services}
        return None
    except Exception:
        return None


# --- Chat-like UI ---

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

for msg in st.session_state.chat_history:
    if msg["role"] == "user":
        st.chat_message("user").write(msg["content"])
    else:
        st.chat_message("assistant").write(msg["content"])

user_input = st.chat_input("Type your symptoms or question here... / اكتب الأعراض أو سؤالك هنا...")

if user_input:
    st.session_state.chat_history.append({"role": "user", "content": user_input})
    with st.spinner("Analyzing... / جاري التحليل..."):
        # Initialize Gemini client wrapper and generate a response. The client
        # will load the API key itself from the environment if not provided.
        try:
            client = ai_client.GeminiClient()
        except Exception:
            st.chat_message("assistant").error("Gemini client library is not installed or failed to initialize. Install 'google-generativeai' and set GEMINI_API_KEY.")
            st.chat_message("assistant").text(traceback.format_exc())
            st.stop()

        try:
            # For chat, optionally include previous exchanges in prompt
            history_text = "\n".join([
                f"User: {m['content']}" if m['role']=='user' else f"Assistant: {m['content']}"
                for m in st.session_state.chat_history if m['role'] != 'system'
            ])

            user_lang = 'ar' if ai_client.is_arabic(user_input) else 'en'

            if user_lang == 'ar':
                prompt = (
                    "أنت مساعد طبي. أجب باللغة العربية فقط. إذا كانت هناك علامات طارئة، قم بتضمين ملاحظة سلامة قصيرة.\n"
                    f"سجل المحادثة:\n{history_text}\n\n"
                    f"المستخدم: {user_input}\n"
                    "أجب بشكل موجز وواضح باللغة العربية."
                )
            else:
                prompt = (
                    "You are a medical assistant. Respond in English only. If emergency signs are present, include a short safety note.\n"
                    f"Chat history:\n{history_text}\n\n"
                    f"User: {user_input}\n"
                    "Respond briefly and clearly in English."
                )

            diagnosis_text = client.generate(prompt)


            # Build localized reply header
            if user_lang == 'ar':
                reply = "✅ \n\n" + diagnosis_text + "\n\n"
            else:
                reply = "✅\n\n" + diagnosis_text + "\n\n"

            # Suggest doctor with localized labels (only include section if a doctor is found)
            doctor = get_doctor_recommendation(user_input)
            if doctor:
                if user_lang == 'ar':
                    reply += f"👨‍⚕️ الطبيب المقترح\n"
                    reply += f"الاسم: {doctor['name']}\n"
                    reply += f"التخصص: {doctor['specialty']}\n"
                    reply += f"الخدمات: {doctor['services']}"
                else:
                    reply += f"👨‍⚕️ Recommended Doctor\n"
                    reply += f"Name: {doctor['name']}\n"
                    reply += f"Specialty: {doctor['specialty']}\n"
                    reply += f"Services: {doctor['services']}"

            st.session_state.chat_history.append({"role": "assistant", "content": reply})
            st.chat_message("assistant").write(reply)
        except Exception as e:
            st.chat_message("assistant").error("Error while calling Gemini API or processing response. See details below.")
            st.chat_message("assistant").text(traceback.format_exc())

st.markdown('---')
