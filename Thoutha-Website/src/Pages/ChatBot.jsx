import {useEffect, useRef, useState} from "react"; 
import {useNavigate} from "react-router-dom";
import ChatBotIcon from "../Components/ChatBotIcon";
import '../Css/ChatBot.css';

export default function ChatBot() {
  const navigate = useNavigate();
  const inputRef = useRef();
  const chatBodyRef = useRef(null);
  const sessionStartedRef = useRef(false);
  const [chatHistory, setChatHistory] = useState([]);
  const [sessionId, setSessionId] = useState(null);
  const [flowItems, setFlowItems] = useState([]);
  const [activeQuestionId, setActiveQuestionId] = useState(null);
  const [chatMode, setChatMode] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const API_BASE = "https://thoutha.page/api";
  const API_HEADERS = { "Content-Type": "application/json" };

  // Map categories to their page routes
  const categoryPageMap = {
    "تبييض الأسنان": "/teeth-whitening",
    "Teeth Whitening": "/teeth-whitening",
    "زراعة الأسنان": "/dental-implant",
    "Dental Implants": "/dental-implant",
    "حشوات الأسنان": "/dental-filling",
    "Dental Fillings": "/dental-filling",
    "خلع الأسنان": "/tooth-extraction",
    "Tooth Extraction": "/tooth-extraction",
    "تيجان الأسنان / التركيبات": "/crowns&bridges",
    "Dental Crowns / Prosthodontics": "/crowns&bridges",
    "تقويم الأسنان": "/braces",
    "Braces": "/braces",
    "فحص شامل للأسنان": "/dental-checkup",
    "Comprehensive Dental Examination": "/dental-checkup",
  };

  const addFlowItem = (item) => setFlowItems(prev => [...prev, item]);

  const handleResult = (data) => {
    const category = data?.result?.category || data?.result?.category_en;
    if (!category) return false;
    
    addFlowItem({ 
      type: "result", 
      text: `✅ تم تحديد الفئة: ${category}`,
      category,
      pageRoute: categoryPageMap[category]
    });
    return true;
  };

  const normalizeQuestion = (data) => {
    const q = data?.question || {};
    const id = data?.question_id || data?.questionId || q?.id || q?.question_id || q?.questionId;
    const text = data?.question_text || (typeof data?.question === 'string' ? data.question : null) || q?.text || q?.question_text;
    const answers = (data?.answers || data?.options || q?.answers || q?.options || [])
      .map(a => ({ id: a?.id || a?.answer_id || a?.value, text: a?.text || a?.label || a?.answer_text || a?.title }))
      .filter(a => a.id && a.text);

    return (id && text) ? { id, text, answers } : null;
  };

  const processResponse = (data) => {
    const nextStep = data?.next_step || data?.next || data?.mode || data?.state;
    if (data?.chatbot_mode || ["chat", "chatbot", "ai"].includes(nextStep)) {
      setChatMode(true);
      return true;
    }

    if (handleResult(data)) return true;

    const question = normalizeQuestion(data);
    if (question) {
      addFlowItem({ type: "question", ...question });
      setActiveQuestionId(question.id);
      return true;
    }

    setChatMode(true);
    return false;
  };

  const startSession = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(`${API_BASE}/session/start`, {
        method: "POST",
        headers: API_HEADERS,
        body: JSON.stringify({ language: "ar" })
      });
      const data = await res.json();
      if (data?.session_id) setSessionId(data.session_id);
      processResponse(data);
    } catch {
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  const submitAnswer = async (questionId, answer) => {
    if (!sessionId || !questionId || !answer?.id) return;
    setIsLoading(true);
    setActiveQuestionId(null);
    addFlowItem({ type: "answer", text: answer.text });
    
    if (/اخر|أخر|other/i.test(answer.text)) {
      addFlowItem({ type: "result", text: "من فضلك اكتب رسالتك بالتفصيل عشان أقدر أساعدك بشكل أفضل:" });
      setChatMode(true);
      setIsLoading(false);
      return;
    }

    try {
      const res = await fetch(`${API_BASE}/session/answer`, {
        method: "POST",
        headers: API_HEADERS,
        body: JSON.stringify({ session_id: sessionId, question_id: questionId, answer_id: answer.id })
      });
      const data = await res.json();
      if (!processResponse(data)) {
        addFlowItem({ type: "result", text: "عذراً، أحتاج المزيد من المعلومات. من فضلك اكتب رسالة بالتفصيل عشان أقدر أفهم احتياجك بشكل أفضل:" });
      }
    } catch {
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  const generateBotResponse = async (msg) => {
    const errorMsg = "عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.";
    try {
      const res = await fetch(`${API_BASE}/chat`, {
        method: "POST",
        headers: API_HEADERS,
        body: JSON.stringify({ message: msg, session_id: sessionId })
      });
      const data = await res.json();
      if (data.session_id) setSessionId(data.session_id);
      setChatHistory(prev => [...prev.filter(m => m.text !== "يفكر....."), { role: "model", text: data.reply || errorMsg }]);
    } catch {
      setChatHistory(prev => [...prev.filter(m => m.text !== "يفكر....."), { role: "model", text: errorMsg }]);
    }
  };


  const handleFormSubmit = async (e) => {
    e.preventDefault();
    const msg = inputRef.current.value.trim();
    if (!msg) return;
    inputRef.current.value = "";
    setChatHistory(prev => [...prev, { role: "user", text: msg }, { role: "model", text: "يفكر....." }]);
    await generateBotResponse(msg);
  };

  useEffect(() => {
    if (!sessionStartedRef.current) {
      sessionStartedRef.current = true;
      startSession();
    }
  }, []);

  useEffect(() => {
    chatBodyRef.current?.scrollTo(0, chatBodyRef.current.scrollHeight);
  }, [chatHistory, flowItems, isLoading]);

  return(
    <div className="body">
    <div className="container">
      <div className="chatbot-popup">
        {/* chatbot header */}
        <div className="chat-header">
          <div className="header-info">
            <ChatBotIcon/>
            <p className="logo-text">ثوثة الطبيب الذكي</p>
          </div>
        </div>

        {/* chatbot body */}
        <div className="chat-body" ref={chatBodyRef}>
          <div className="chatbot-flex">
            <div className="message bot-message">
              <p className="message-text">
               👋🏻 اهلا بك<br/> ازاى اقدر اساعدك؟
              </p>
              <ChatBotIcon/>
            </div> 
          </div>

          {isLoading && flowItems.length === 0 && (
            <div className="message bot-message">
              <p className="message-text">...جاري تجهيز الأسئلة</p>
              <ChatBotIcon/>
            </div>
          )}

          {flowItems.map((item, i) => {
            if (item.type === "question") {
              const isActive = item.id === activeQuestionId && !chatMode;
              return (
                <div key={`flow-${i}`} className="flow-block">
                  <div className="message bot-message">
                    <p className="message-text">{item.text}</p>
                    <ChatBotIcon/>
                  </div>
                  {isActive && item.answers?.length > 0 && (
                    <div className="quick-replies">
                      {item.answers.map((answer) => (
                        <button
                          key={`${item.id}-${answer.id}`}
                          type="button"
                          className={`quick-reply-button ${/اخر|أخر|other/i.test(answer.text) ? "full" : ""}`}
                          onClick={() => submitAnswer(item.id, answer)}
                          disabled={isLoading}
                        >
                          {answer.text}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              );
            }

            if (item.type === "result") {
              return (
                <div key={`flow-${i}`} className="flow-block">
                  <div className="message bot-message">
                    <p className="message-text">{item.text}</p>
                    <ChatBotIcon/>
                  </div>
                  {item.pageRoute && (
                    <div className="quick-replies">
                      <button
                        type="button"
                        className="quick-reply-button full result-button"
                        onClick={() => navigate(item.pageRoute)}
                      >
                        📍 اضغط هنا للذهاب إلى صفحة {item.category}
                      </button>
                    </div>
                  )}
                </div>
              );
            }

            return (
              <div key={`flow-${i}`} className="message user-message">
                <p className="message-text">{item.text}</p>
              </div>
            );
          })}

          {chatHistory.map((chat, i) => (
            <div key={`chat-${i}`} className={`message ${chat.role === "model" ? "bot": "user"}-message`}>
              <p className="message-text">{chat.text}</p> 
              {chat.role === "model" && <ChatBotIcon/>}
            </div>
          ))}
        </div>
        {/* chatbot footer */}
        {chatMode && (
          <div className="chat-footer">
            <form action="#" className="chat-form" onSubmit={handleFormSubmit}>
              <input 
              ref={inputRef}
              type="text"
              placeholder="اكتب رسالتك.............................."
              className="message-input"
              required />
              <button className="material-symbols-outlined">arrow_upward_alt</button>
            </form>
          </div>
        )}
      </div>
    </div>
    </div>
  )
}


