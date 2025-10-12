import os
import streamlit as st
from dotenv import load_dotenv
import sqlite3
import traceback

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

st.markdown("## Describe symptoms / اكتب الأعراض")
symptoms = st.text_area("Symptoms / الأعراض", height=180, placeholder="e.g. tooth pain and swelling\nمثال: عندي ألم في الأسنان وانتفاخ في الخد")

col1, col2 = st.columns([1,1])
with col1:
    run_btn = st.button("🔍 Diagnose / تشخيص")
with col2:
    clear_btn = st.button("Clear")

if clear_btn:
    st.experimental_rerun()

if run_btn:
    if not symptoms.strip():
        st.warning("Please enter symptoms first. / من فضلك اكتب الأعراض أولاً.")
    else:
        with st.spinner("Analyzing... / جاري التحليل..."):
            try:
                import google.generativeai as genai
            except Exception as e:
                st.error("Gemini client library is not installed or failed to import. Install 'google-generativeai'. See terminal for details.")
                st.text(traceback.format_exc())
                st.stop()

            if not GEMINI_KEY:
                st.error("GEMINI_API_KEY is not set. Please add it to the .env file and restart the app.")
                st.stop()

            try:
                genai.configure(api_key=GEMINI_KEY)
                model = genai.GenerativeModel("gemini-2.5-flash")
                prompt = (
                    f"Analyze the following symptoms and provide a brief initial medical impression in BOTH Arabic and English, clearly labeled.\n"
                    f"Symptoms: {symptoms}\n\n"
                    "Respond exactly like:\nArabic: <your diagnosis in Arabic>\nEnglish: <your diagnosis in English>\nInclude a short safety note if emergency signs are present."
                )

                response = model.generate_content(prompt)
                if hasattr(response, 'text'):
                    diagnosis_text = response.text.strip()
                else:
                    diagnosis_text = str(response).strip()

                st.success("✅ Diagnosis generated / تم التوليد")
                st.subheader("🧠 Diagnosis (Arabic + English)")
                st.code(diagnosis_text, language='text')

                # Suggest doctor
                doctor = get_doctor_recommendation(symptoms)
                if doctor:
                    st.subheader("👨‍⚕️ Recommended Doctor / الطبيب المقترح")
                    st.write(f"**Name / الاسم:** {doctor['name']}")
                    st.write(f"**Specialty / التخصص:** {doctor['specialty']}")
                    st.write(f"**Services / الخدمات:** {doctor['services']}")
                else:
                    st.info("No matching doctor found in the local DB. / لم يتم العثور على طبيب مطابق في قاعدة البيانات.")

            except Exception as e:
                st.error("Error while calling Gemini API or processing response. See details below.")
                st.text(traceback.format_exc())

st.markdown('---')
st.markdown('**Note:** This app calls Gemini API when you press Diagnose. Add your key to `.env` as GEMINI_API_KEY=YOUR_KEY')
