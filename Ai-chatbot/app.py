import os
import streamlit as st
from dotenv import load_dotenv
import sqlite3
import traceback
import logging

# Import the updated ai_client
try:
    from . import ai_client
except ImportError:
    import ai_client

# Configure logging to reduce console noise from Streamlit
logging.getLogger("streamlit.runtime.scriptrunner.script_run_context").setLevel(logging.ERROR)

# Load Gemini API key from .env file
load_dotenv()

# --- Page and UI Configuration ---
st.set_page_config(page_title="المساعد الطبي / Thoutha", page_icon="🦷", layout="centered")
st.title("ثوثة 🦷 - المساعد الذكي لطبيب الأسنان")

def get_doctor_recommendation(symptom_text):
    """Searches the database for a doctor based on keywords in the text."""
    try:
        db_path = os.path.join(os.path.dirname(__file__), 'doctors.db')
        conn = sqlite3.connect(db_path)
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

# --- Main Chat Application Logic ---

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

for msg in st.session_state.chat_history:
    st.chat_message(msg["role"]).write(msg["content"])

user_input = st.chat_input("Ask about your dental concerns... / اسأل عن مشاكل أسنانك...")

if user_input:
    st.session_state.chat_history.append({"role": "user", "content": user_input})
    st.chat_message("user").write(user_input)

    try:
        client = ai_client.Thoutha()
        user_lang = 'ar' if ai_client.is_arabic(user_input) else 'en'

        # --- DENTAL RELEVANCE CHECK (Hybrid Guard Clause) ---
        with st.spinner("Checking relevance... / جاري التحقق..."):
            is_dental = client.is_query_dental(user_input)

        if not is_dental:
            if user_lang == 'ar':
                refusal_message = "عذراً، يمكنني فقط الإجابة على الأسئلة المتعلقة بصحة الأسنان والفم. كيف يمكنني مساعدتك في هذا الخصوص؟"
            else:
                refusal_message = "I can only answer questions about dental and oral health. How can I assist you with a dental matter?"

            st.session_state.chat_history.append({"role": "assistant", "content": refusal_message})
            st.chat_message("assistant").write(refusal_message)
            st.stop()

        # --- MAIN CHAT LOGIC ---
        with st.spinner("Analyzing... / جاري التحليل..."):
            if user_lang == 'ar':
                system_prompt = (
                    "أنت 'ثوثة'، مساعد ذكاء اصطناعي متخصص في طب الأسنان. دورك هو مناقشة الأعراض وطرح أسئلة توضيحية. "
                    "يجب أن ترفض بأدب الإجابة على أي أسئلة غير متعلقة بالأسنان. لا تقدم تشخيصًا طبيًا نهائيًا أبدًا. "
                    "هدفك هو تشجيع المستخدم على استشارة طبيب أسنان بشري."
                )
            else:
                system_prompt = (
                    "You are 'Thoutha', a specialized dental AI assistant. Your role is to discuss symptoms and ask clarifying questions. "
                    "You must politely refuse to answer any non-dental questions. Never provide a definitive medical diagnosis. "
                    "Your goal is to encourage the user to consult a human dentist."
                )

            conversation_for_api = [
                {'role': 'user', 'parts': [system_prompt]},
                {'role': 'model', 'parts': ["Understood. I am Thoutha, ready to assist with dental inquiries."]}
            ]
            for msg in st.session_state.chat_history:
                role = "user" if msg["role"] == "user" else "model"
                conversation_for_api.append({'role': role, 'parts': [msg["content"]]})

            diagnosis_text = client.generate_response(conversation_for_api)

            reply = " \n\n" + diagnosis_text + "\n\n"
            doctor = get_doctor_recommendation(user_input + " " + diagnosis_text)
            if doctor:
                if user_lang == 'ar':
                    reply += f"👨‍⚕️ **الطبيب المقترح:**\n"
                    reply += f"- **الاسم:** {doctor['name']}\n"
                    reply += f"- **التخصص:** {doctor['specialty']}\n"
                    reply += f"- **الخدمات:** {doctor['services']}"
                else:
                    reply += f"👨‍⚕️ **Recommended Doctor:**\n"
                    reply += f"- **Name:** {doctor['name']}\n"
                    reply += f"- **Specialty:** {doctor['specialty']}\n"
                    reply += f"- **Services:** {doctor['services']}"

            st.session_state.chat_history.append({"role": "assistant", "content": reply})
            st.chat_message("assistant").write(reply)

    except Exception:
        st.chat_message("assistant").error("An error occurred. See details below.")
        st.chat_message("assistant").text(traceback.format_exc())

st.markdown('---')
