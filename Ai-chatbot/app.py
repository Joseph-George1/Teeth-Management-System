import os
import streamlit as st
from dotenv import load_dotenv
import sqlite3
import traceback
import logging
import re


logging.getLogger("streamlit.runtime.scriptrunner.script_run_context").setLevel(logging.ERROR)

# Load Gemini API key from .env
load_dotenv()
GEMINI_KEY = os.getenv("GEMINI_API_KEY", "")

st.set_page_config(page_title="Medical Chatbot (EN/AR) - Gemini", page_icon="💬", layout="centered")
st.title("🩺 Medical Assistant Chatbot (English / العربية) — Gemini")
st.write("Enter symptoms in English or Arabic. The app will return a short diagnosis in BOTH languages and suggest a doctor from the local database.")

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
st.markdown("## Chat with Medical Assistant / الدردشة مع المساعد الطبي")

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
        try:
            import google.generativeai as genai
        except Exception as e:
            st.chat_message("assistant").error("Gemini client library is not installed or failed to import. Install 'google-generativeai'. See terminal for details.")
            st.chat_message("assistant").text(traceback.format_exc())
            st.stop()

        if not GEMINI_KEY:
            st.chat_message("assistant").error("GEMINI_API_KEY is not set. Please add it to the .env file and restart the app.")
            st.stop()

        try:
            genai.configure(api_key=GEMINI_KEY)
            model = genai.GenerativeModel("gemini-2.5-flash")
            # For chat, optionally include previous exchanges in prompt
            history_text = "\n".join([
                f"User: {m['content']}" if m['role']=='user' else f"Assistant: {m['content']}"
                for m in st.session_state.chat_history if m['role'] != 'system'
            ])

            # Detect if user input contains Arabic characters
            def is_arabic(text):
                return bool(re.search(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]", text))

            user_lang = 'ar' if is_arabic(user_input) else 'en'

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

            response = model.generate_content(prompt)
            if hasattr(response, 'text'):
                diagnosis_text = response.text.strip()
            else:
                diagnosis_text = str(response).strip()


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
