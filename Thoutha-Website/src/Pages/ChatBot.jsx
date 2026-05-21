import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import ChatBotIcon from "../Components/ChatBotIcon";
import '../Css/ChatBot.css';

const CHAT_STORAGE_KEY = "thoutha_chat_state";

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

const QuickReplies = ({ question, disabled, isActive, onSelect, onOtherClick }) => {
  if (!isActive) return null;
  return (
    <div className="quick-replies">
      {question.answers.map((answer) => {
        const isOther = /اخر|أخر|other/i.test(answer.text);
        return (
          <button
            key={`${question.id}-${answer.id}`}
            type="button"
            className={`quick-reply-button ${isOther ? "full other-button" : ""}`}
            onClick={() => isOther ? onOtherClick(question, answer) : onSelect(question, answer)}
            disabled={disabled}
          >
            {answer.text}
          </button>
        );
      })}
    </div>
  );
};

const ErrorBlock = ({ onNewChat }) => (
  <div className="chatbot-flex">
    <div className="message bot-message error-message">
      <p className="message-text"> حدث خطأ في الاتصال بالسيرفر. يمكنك بدء محادثة جديدة.</p>
      <ChatBotIcon />
    </div>
    <button
      type="button"
      className="quick-reply-button restart-button inline-restart"
      onClick={onNewChat}
      title="بدء محادثة جديدة"
    >
      <span>بدء محادثة جديدة</span>
    </button>
  </div>
);

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
      <span>إعادة المحادثة من البداية</span>
    </button>
  </div>
);

export default function ChatBot() {
  const navigate = useNavigate();
  const inputRef = useRef();
  const chatBodyRef = useRef(null);
  const sessionStartedRef = useRef(false);

  const [isLoading, setIsLoading] = useState(false);
  const [chatMode, setChatMode] = useState(false);
  const [sessionId, setSessionId] = useState(null);
  const [activeQuestionId, setActiveQuestionId] = useState(null);
  const [flowItems, setFlowItems] = useState([]);
  const [chatHistory, setChatHistory] = useState([]);
  const [inputText, setInputText] = useState("");
  const [hasServerError, setHasServerError] = useState(false);
  const [allSessions, setAllSessions] = useState([]);

  const API_BASE = "https://thoutha.page/api";
  const API_HEADERS = { "Content-Type": "application/json" };
  const THINKING_TEXT = "يفكر.....";

  const scrollToBottom = () => {
    setTimeout(() => {
      if (chatBodyRef.current) {
        chatBodyRef.current.scrollTop = chatBodyRef.current.scrollHeight;
      }
    }, 50);
  };

  const saveChatState = (state) => {
    try {
      localStorage.setItem(CHAT_STORAGE_KEY, JSON.stringify(state));
    } catch {
      void 0;
    }
  };

  const loadChatState = () => {
    try {
      const raw = localStorage.getItem(CHAT_STORAGE_KEY);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch {
      return null;
    }
  };

  useEffect(() => {
    if (!sessionStartedRef.current) {
      sessionStartedRef.current = true;

      const saved = loadChatState();
      if (saved) {
        setAllSessions(saved.allSessions || []);
        setFlowItems(saved.flowItems || []);
        setChatHistory(saved.chatHistory || []);
        setChatMode(saved.chatMode || false);
        setSessionId(saved.sessionId || null);
        setActiveQuestionId(saved.activeQuestionId || null);
        setHasServerError(saved.hasServerError || false);

        if (!saved.sessionId && ((saved.flowItems?.length) || (saved.chatHistory?.length))) {
          startSession();
        }
      } else {
        startSession();
      }
    }
  }, []);

  useEffect(() => {
    if (flowItems.length === 0 && chatHistory.length === 0 && allSessions.length === 0) return;
    saveChatState({
      allSessions,
      flowItems,
      chatHistory,
      chatMode,
      sessionId,
      activeQuestionId,
      hasServerError,
    });
  }, [flowItems, chatHistory, chatMode, sessionId, activeQuestionId, hasServerError, allSessions]);

  useEffect(() => {
    scrollToBottom();
  }, [flowItems, chatHistory, allSessions]);

  async function startSession() {
    setIsLoading(true);
    setHasServerError(false);
    try {
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: "ar" }) });
      if (!res.ok && res.status >= 500) {
        setHasServerError(true);
        setIsLoading(false);
        return;
      }
      const data = await res.json();
      if (data?.session_id) setSessionId(data.session_id);
      processResponse(data);
    } catch {
      setHasServerError(true);
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  }

  const processResponse = (data) => {
    if (data?.chatbot_activated === true) { setChatMode(true); return true; }
    if (data?.result?.category) {
      const category = data.result.category;
      const mappedCategory = mapToAppCategory(category);
      addFlowItem({ type: "result", text: ` تم تحديد الفئة: ${mappedCategory}`, category: mappedCategory });
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

  const handleOtherClick = (question, answer) => {
    setActiveQuestionId(null);
    addFlowItem({ type: "answer", text: answer.text });
    addFlowItem({ type: "bot_prompt", text: "اتفضل اتكلم، قولي حاسس بإيه بالظبط؟ 😊" });
    setChatMode(true);
  };

  const submitAnswer = async (question, answer) => {
    if (!sessionId) return;
    setIsLoading(true);
    setActiveQuestionId(null);
    addFlowItem({ type: "answer", text: answer.text });
    try {
      const res = await fetch(`${API_BASE}/session/answer`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ session_id: sessionId, question_id: question.id, answer_id: answer.id }) });
      if (!res.ok && res.status >= 500) {
        addFlowItem({ type: "server_error" });
        setIsLoading(false);
        return;
      }
      const data = await res.json();
      if (!processResponse(data)) {
        addFlowItem({ type: "result", text: "عذراً، أحتاج المزيد من المعلومات. من فضلك اكتب رسالة بالتفصيل:" });
        setChatMode(true);
      }
    } catch {
      addFlowItem({ type: "server_error" });
    } finally {
      setIsLoading(false);
    }
  };

  const sendChatMessage = async () => {
    const msg = inputText.trim();
    if (!msg) return;
    setInputText("");
    inputRef.current?.focus();
    setHasServerError(false);
    setChatHistory(prev => [...prev, { role: "user", text: msg }, { role: "model", text: THINKING_TEXT }]);

    try {
      const res = await fetch(`${API_BASE}/chat`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ message: msg, session_id: sessionId }) });

      if (!res.ok && res.status >= 500) {
        setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: "__SERVER_ERROR__" }]);
        return;
      }

      const data = await res.json();

      if (data?.result?.category) {
        const category = data.result.category;
        const mappedCategory = mapToAppCategory(category);
        setChatHistory(prev => prev.filter(m => m.text !== THINKING_TEXT));
        addFlowItem({ type: "result", text: ` تم تحديد الفئة: ${mappedCategory}`, category: mappedCategory });
        if (data.session_id) setSessionId(data.session_id);
        return;
      }

      if (processResponse(data)) {
        setChatHistory(prev => prev.filter(m => m.text !== THINKING_TEXT));
        if (data.session_id) setSessionId(data.session_id);
        return;
      }
      if (data.error) {
        setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: "عذراً، حدث خطأ في الاتصال. حاول مرة أخرى." }]);
        return;
      }
      if (data.session_id) setSessionId(data.session_id);
      const reply = data.reply || "عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.";
      setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: reply }]);
    } catch {
      setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: "__SERVER_ERROR__" }]);
    }
  };

  const startNewChat = async () => {
    if (flowItems.length > 0 || chatHistory.length > 0) {
      setAllSessions(prev => [...prev, { flowItems, chatHistory }]);
    }
    setFlowItems([]);
    setChatHistory([]);
    setActiveQuestionId(null);
    setChatMode(false);
    setHasServerError(false);
    setIsLoading(true);
    try {
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: "ar" }) });
      if (!res.ok && res.status >= 500) {
        setHasServerError(true);
        setIsLoading(false);
        return;
      }
      const data = await res.json();
      if (data?.session_id) setSessionId(data.session_id);
      processResponse(data);
    } catch {
      setHasServerError(true);
      setChatMode(true);
    } finally {
      setIsLoading(false);
    }
  };

  const clearAllChats = () => {
    try {
      localStorage.removeItem(CHAT_STORAGE_KEY);
    } catch {
      void 0;
    }
    setAllSessions([]);
    setFlowItems([]);
    setChatHistory([]);
    setActiveQuestionId(null);
    setChatMode(false);
    setHasServerError(false);
    setSessionId(null);
    sessionStartedRef.current = false;
    startSession();
  };

  const restartSession = () => startNewChat();

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

  const getCategoryRoute = (category) => {
    const routes = {
      "تنظيف وتبييض الأسنان": "/teeth-whitening", "زراعة الأسنان": "/dental-implant", "حشو تجميلي": "/dental-filling",
      "حشو امالجم": "/amalgam-filling", "حشو عصب": "/tooth-extraction", "الجراحة والخلع": "/surgery-extraction",
      "تيجان وجسور": "/crowns&bridges", "تركيبات متحركة": "/removable-prosthetics", "تقويم الأسنان": "/braces",
      "فحص شامل": "/", "طب أسنان الأطفال": "/pediatric-dentistry"
    };
    return routes[category];
  };

  const openCategory = (rawCategory) => {
    const mapped = mapToAppCategory(rawCategory);
    const pageRoute = getCategoryRoute(mapped);
    if (pageRoute) navigate(pageRoute);
  };

  const addFlowItem = (item) => setFlowItems(prev => [...prev, item]);

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendChatMessage(); }
  };

  const renderSession = (session, index) => (
    <div key={`old-session-${index}`} className="old-session">
      <div className="session-divider">
        <span>── محادثة سابقة ──</span>
      </div>
      {session.flowItems.map((item, i) => (
        <div key={`old-${index}-flow-${i}`}>
          {item.type === "question" && <BotMessage text={item.question.text} />}
          {item.type === "bot_prompt" && <BotMessage text={item.text} />}
          {item.type === "result" && (
            <>
              <BotMessage text={item.text} />
              {item.category && (
                <div className="quick-replies">
                  <button
                    type="button"
                    className="quick-reply-button full result-button"
                    onClick={() => openCategory(item.category)}
                    title={`الذهاب إلى صفحة ${item.category}`}
                  >
                    <span>عرض حالات</span>
                    <strong>{item.category}</strong>
                    <span style={{ marginLeft: '8px' }}>←</span>
                  </button>
                </div>
              )}
            </>
          )}
          {item.type === "answer" && <UserMessage text={item.text} />}
        </div>
      ))}
      {session.chatHistory.map((m, i) =>
        m.role === "user"
          ? <UserMessage key={`old-${index}-chat-${i}`} text={m.text} />
          : m.text === "__SERVER_ERROR__"
            ? <ErrorBlock key={`old-${index}-err-${i}`} onNewChat={startNewChat} />
            : <BotMessage key={`old-${index}-chat-${i}`} text={m.text} />
      )}
    </div>
  );

  return (
    <div className="body">
      <div className="container">
        <div className="chatbot-popup">
          <div className="chat-header">
            <div className="header-info">
              <ChatBotIcon />
              <p className="logo-text">ثوثة الطبيب الذكي</p>
            </div>
            <div className="header-actions">
              <button
                type="button"
                className="clear-all-btn"
                onClick={clearAllChats}
                disabled={isLoading}
                title="حذف جميع المحادثات"
              >
                <span className="btn-label">حذف الكل</span>
              </button>
              <button
                type="button"
                className="new-chat-btn"
                onClick={startNewChat}
                disabled={isLoading}
                title="بدء محادثة جديدة (المحادثات القديمة تُحفظ)"
              >
                <span>محادثة جديدة</span>
              </button>
            </div>
          </div>

          <div className="chat-body" ref={chatBodyRef}>
            <BotMessage text="👋🏻 اهلا بك ازاى اقدر اساعدك؟ لو عايز تتكلم معايا اضغط على حاجه تانيه" />

            {allSessions.map((session, i) => renderSession(session, i))}

            {allSessions.length > 0 && (
              <div className="session-divider current-session">
                <span>── المحادثة الحالية ──</span>
              </div>
            )}

            {isLoading && flowItems.length === 0 && <BotMessage text="...جاري تجهيز الأسئلة" />}

            {hasServerError && flowItems.length === 0 && (
              <ErrorBlock onNewChat={startNewChat} />
            )}

            {flowItems.map((item, i) => (
              <div key={i}>
                {item.type === "question" && (
                  <>
                    <BotMessage text={item.question.text} />
                    <QuickReplies
                      question={item.question}
                      disabled={isLoading}
                      isActive={!chatMode && activeQuestionId === item.question.id && item.question.answers.length > 0}
                      onSelect={submitAnswer}
                      onOtherClick={handleOtherClick}
                    />
                  </>
                )}

                {item.type === "bot_prompt" && <BotMessage text={item.text} />}
                {item.type === "result" && (
                  <>
                    <BotMessage text={item.text} />
                    {item.category && (
                      <ResultButtons
                        category={item.category}
                        disabled={isLoading}
                        onOpen={() => openCategory(item.category)}
                        onRestart={restartSession}
                      />
                    )}
                  </>
                )}
                {item.type === "answer" && <UserMessage text={item.text} />}
                {item.type === "server_error" && <ErrorBlock onNewChat={startNewChat} />}
              </div>
            ))}

            {chatHistory.map((m, i) =>
              m.role === "user"
                ? <UserMessage key={i} text={m.text} />
                : m.text === "__SERVER_ERROR__"
                  ? <ErrorBlock key={i} onNewChat={startNewChat} />
                  : <BotMessage key={i} text={m.text} />
            )}
          </div>

          {chatMode && (
            <div className="chat-footer">
              <form action="#" className="chat-form" onSubmit={(e) => { e.preventDefault(); sendChatMessage(); }}>
                <input
                  ref={inputRef}
                  type="text"
                  placeholder="اكتب رسالتك.............................."
                  className="message-input"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  onKeyDown={handleKeyDown}
                />
                <button
                  type="submit"
                  className="material-symbols-outlined"
                  disabled={isLoading || !inputText.trim()}
                >
                  arrow_upward_alt
                </button>
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}