import { useEffect, useRef, useState } from "react"; 
import { useNavigate } from "react-router-dom";
import ChatBotIcon from "../Components/ChatBotIcon";
import '../Css/ChatBot.css';

// ── Helper Components ──
const BotMessage = ({ text }) => (
  <div className="chatbot-flex">
    <div className="message bot-message">
      <p className="message-text">{text}</p>
      <ChatBotIcon />
    </div>
  </div>
);

const UserMessage = ({ text }) => (
  <div className="message user-message">
    <p className="message-text">{text}</p>
  </div>
);

const QuickReplies = ({ question, disabled, isActive, onSelect }) => {
  if (!isActive) return null;
  return (
    <div className="quick-replies">
      {question.answers.map((answer) => (
        <button
          key={`${question.id}-${answer.id}`}
          type="button"
          className={`quick-reply-button ${/اخر|أخر|other/i.test(answer.text) ? "full" : ""}`}
          onClick={() => onSelect(question, answer)}
          disabled={disabled}
        >
          {answer.text}
        </button>
      ))}
    </div>
  );
};

const ResultButtons = ({ category, disabled, onOpen, onRestart }) => (
  <div className="quick-replies" style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
    <button
      type="button"
      className="quick-reply-button full result-button"
      onClick={onOpen}
      title={`الذهاب إلى صفحة ${category}`}
    >
      <span>عرض حالات</span>
      <strong>{category}</strong>
      <span style={{ marginLeft: '8px' }}>←</span>
    </button>
    <button
      type="button"
      className="quick-reply-button restart-button"
      onClick={onRestart}
      disabled={disabled}
      title="إعادة المحادثة من البداية"
    >
      <span>🔄</span>
      <span>إعادة المحادثة من البداية</span>
    </button>
  </div>
);

export default function ChatBot() {
  const navigate = useNavigate();
  const inputRef = useRef();
  const chatBodyRef = useRef(null);
  const sessionStartedRef = useRef(false);

  // ── State ──
  const [isLoading, setIsLoading] = useState(false);
  const [chatMode, setChatMode] = useState(false);
  const [sessionId, setSessionId] = useState(null);
  const [activeQuestionId, setActiveQuestionId] = useState(null);
  const [categories, setCategories] = useState([]);
  const [flowItems, setFlowItems] = useState([]);
  const [chatHistory, setChatHistory] = useState([]);
  const [inputText, setInputText] = useState("");

  const API_BASE = "https://thoutha.page/api";
  const API_HEADERS = { "Content-Type": "application/json" };
  const THINKING_TEXT = "يفكر.....";

  // ── Scroll to bottom ──
  const scrollToBottom = () => {
    setTimeout(() => {
      if (chatBodyRef.current) {
        chatBodyRef.current.scrollTop = chatBodyRef.current.scrollHeight;
      }
    }, 50);
  };

  // ── Life cycle ──
  useEffect(() => {
    if (!sessionStartedRef.current) {
      sessionStartedRef.current = true;
      loadCategories();
      startSession();
    }
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [flowItems, chatHistory]);

  // ── Load categories ──
  const loadCategories = async () => {
    try {
      const res = await fetch(`${API_BASE}/category/getCategories`, { method: "GET", headers: API_HEADERS });
      const data = await res.json();
      const raw = Array.isArray(data) ? data : (data?.categories || data?.data || []);
      if (Array.isArray(raw)) {
        setCategories(raw.map(c => ({ id: c.id, name: c.name || '', name_ar: c.name_ar || '' })));
      }
    } catch (err) {
      console.error("Failed to load categories:", err);
    }
  };

  // ── Start session ──
  const startSession = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: "ar" }) });
      const data = await res.json();
      if (data?.session_id) setSessionId(data.session_id);
      processResponse(data);
    } catch (err) {
      console.error("Error starting session:", err);
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  // ── Process response ──
  const processResponse = (data) => {
    if (data?.chatbot_activated === true) { setChatMode(true); return true; }
    if (data?.result?.category) {
      const category = data.result.category;
      const mappedCategory = mapToAppCategory(category);
      addFlowItem({ type: "result", text: `✅ تم تحديد الفئة: ${mappedCategory}`, category: mappedCategory });
      return true;
    }
    if (data?.question && data?.question?.id && data?.question?.text) {
      const question = data.question;
      setActiveQuestionId(question.id);
      addFlowItem({
        type: "question",
        id: question.id,
        text: question.text,
        question: { id: question.id, text: question.text, answers: (question.options || question.answers || []).map(a => ({ id: a.id, text: a.text })) }
      });
      return true;
    }
    setChatMode(true);
    return false;
  };

  // ── Submit answer ──
  const submitAnswer = async (question, answer) => {
    if (!sessionId) return;
    const isOther = /اخر|أخر|other/i.test(answer.text);
    setIsLoading(true);
    setActiveQuestionId(null);
    addFlowItem({ type: "answer", text: answer.text });
    if (isOther) {
      addFlowItem({ type: "result", text: "من فضلك اكتب رسالتك بالتفصيل عشان أقدر أساعدك بشكل أفضل:" });
      setChatMode(true);
      setIsLoading(false);
      return;
    }
    try {
      const res = await fetch(`${API_BASE}/session/answer`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ session_id: sessionId, question_id: question.id, answer_id: answer.id }) });
      const data = await res.json();
      if (!processResponse(data)) {
        addFlowItem({ type: "result", text: "عذراً، أحتاج المزيد من المعلومات. من فضلك اكتب رسالة بالتفصيل:" });
        setChatMode(true);
      }
    } catch (err) {
      console.error("Error submitting answer:", err);
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  // ── Send chat message ──
  const sendChatMessage = async () => {
    const msg = inputText.trim();
    if (!msg) return;
    setInputText("");
    inputRef.current?.focus();
    setChatHistory(prev => [...prev, { role: "user", text: msg }, { role: "model", text: THINKING_TEXT }]);
    const errorMsg = "عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.";
    try {
      const res = await fetch(`${API_BASE}/chat`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ message: msg, session_id: sessionId }) });
      const data = await res.json();
      if (data.error) { setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: errorMsg }]); return; }
      if (data.session_id) setSessionId(data.session_id);
      const reply = data.reply || errorMsg;
      setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: reply }]);
    } catch (err) {
      console.error("Chat error:", err);
      setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: errorMsg }]);
    }
  };

  // ── Restart session ──
  const restartSession = async () => {
    setFlowItems([]);
    setChatHistory([]);
    setActiveQuestionId(null);
    setChatMode(false);
    setIsLoading(true);
    try {
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: "ar" }) });
      const data = await res.json();
      if (data?.session_id) setSessionId(data.session_id);
      addFlowItem({ type: "result", text: "— بدء محادثة جديدة —" });
      processResponse(data);
    } catch (err) {
      console.error("Error restarting session:", err);
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  // ── Category helpers ──
  const normalize = (s) => s.replace(/[أإآ]/g, "ا").replace(/ة/g, "ه").replace(/ى/g, "ي").replace(/[^\u0621-\u064A0-9a-zA-Z]/g, "").toLowerCase();
  
  const CATEGORY_MAP = {
    "تبييض الأسنان": "تنظيف وتبييض الأسنان", "Teeth Whitening": "تنظيف وتبييض الأسنان", "تنظيف وتبييض الأسنان": "تنظيف وتبييض الأسنان",
    "زراعة الأسنان": "زراعة الأسنان", "Dental Implants": "زراعة الأسنان",
    "حشوات الأسنان": "حشو تجميلي", "Dental Fillings": "حشو تجميلي", "حشو تجميلي": "حشو تجميلي",
    "خلع الأسنان": "الجراحة والخلع", "Tooth Extraction": "الجراحة والخلع", "الجراحة والخلع": "الجراحة والخلع",
    "تيجان الأسنان / التركيبات": "تيجان وجسور", "Dental Crowns / Prosthodontics": "تيجان وجسور", "تيجان وجسور": "تيجان وجسور",
    "تقويم الأسنان": "تقويم الأسنان", "Braces": "تقويم الأسنان",
    "فحص شامل للأسنان": "فحص شامل", "Comprehensive Dental Examination": "فحص شامل", "فحص شامل": "فحص شامل",
    "حشو امالجم": "حشو امالجم", "حشو عصب": "حشو عصب", "تركيبات متحركة": "تركيبات متحركة",
    "الاطفال": "طب أسنان الأطفال", "Pediatric": "طب أسنان الأطفال", "Pediatric Dentistry": "طب أسنان الأطفال", "طب الأسنان للأطفال": "طب أسنان الأطفال", "طب أسنان الأطفال": "طب أسنان الأطفال",
    "تركيبات ثابتة (تيجان وجسور)": "تيجان وجسور", "Crowns and Bridges": "تيجان وجسور"
  };

  const mapToAppCategory = (raw) => CATEGORY_MAP[raw] ?? CATEGORY_MAP[raw?.trim()] ?? raw;

  const getCategoryIdByName = (name) => {
    const normalizedInput = normalize(name);
    for (const cat of categories) {
      if (normalize(cat.name ?? "") === normalizedInput || normalize(cat.name_ar ?? "") === normalizedInput) return cat.id;
    }
    return null;
  };

  const openCategory = (rawCategory) => {
    const mapped = mapToAppCategory(rawCategory);
    const pageRoute = getCategoryRoute(mapped);
    if (pageRoute) navigate(pageRoute);
  };

  const getCategoryRoute = (category) => {
    const routes = {
      "تنظيف وتبييض الأسنان": "/teeth-whitening", "زراعة الأسنان": "/dental-implant", "حشو تجميلي": "/dental-filling",
      "حشو امالجم": "/amalgam-filling", "حشو عصب": "/tooth-extraction", "الجراحة والخلع": "/surgery-extraction",
      "تيجان وجسور": "/crowns&bridges", "تركيبات متحركة": "/removable-prosthetics", "تقويم الأسنان": "/braces",
      "فحص شامل": "/dental-checkup", "طب أسنان الأطفال": "/pediatric-dentistry"
    };
    return routes[category];
  };

  const addFlowItem = (item) => setFlowItems(prev => [...prev, item]);

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendChatMessage(); }
  };

  // ── Render ──
  return (
    <div className="body">
      <div className="container">
        <div className="chatbot-popup">
          <div className="chat-header">
            <div className="header-info">
              <ChatBotIcon />
              <p className="logo-text">ثوثة الطبيب الذكي</p>
            </div>
          </div>

          <div className="chat-body" ref={chatBodyRef}>
            <BotMessage text="👋🏻 اهلا بك ازاى اقدر اساعدك؟ لو عايز تتكلم معايا اضغط على حاجه تانيه" />
            {isLoading && flowItems.length === 0 && <BotMessage text="...جاري تجهيز الأسئلة" />}
            
            {flowItems.map((item, i) => (
              <div key={i}>
                {item.type === "question" && (
                  <>
                    <BotMessage text={item.question.text} />
                    <QuickReplies question={item.question} disabled={isLoading} isActive={!chatMode && activeQuestionId === item.question.id && item.question.answers.length > 0} onSelect={submitAnswer} />
                  </>
                )}
                {item.type === "result" && (
                  <>
                    <BotMessage text={item.text} />
                    {item.category && <ResultButtons category={item.category} disabled={isLoading} onOpen={() => openCategory(item.category)} onRestart={restartSession} />}
                  </>
                )}
                {item.type === "answer" && <UserMessage text={item.text} />}
              </div>
            ))}

            {chatHistory.map((m, i) => m.role === "user" ? <UserMessage key={i} text={m.text} /> : <BotMessage key={i} text={m.text} />)}
          </div>

          {chatMode && (
            <div className="chat-footer">
              <form action="#" className="chat-form" onSubmit={(e) => { e.preventDefault(); sendChatMessage(); }}>
                <input ref={inputRef} type="text" placeholder="اكتب رسالتك.............................." className="message-input" value={inputText} onChange={(e) => setInputText(e.target.value)} onKeyDown={handleKeyDown} />
                <button type="submit" className="material-symbols-outlined" disabled={isLoading || !inputText.trim()}>arrow_upward_alt</button>
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}


