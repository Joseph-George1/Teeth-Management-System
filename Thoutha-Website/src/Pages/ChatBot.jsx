import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import ChatBotIcon from "../Components/ChatBotIcon";
import '../Css/ChatBot.css';

const CHAT_STORAGE_KEY = "thoutha_chat_state";
const DEFAULT_LANGUAGE = "ar";

const CATEGORY_LABELS = {
  "Cosmetic Filling": { ar: "حشو تجميلي", en: "Cosmetic Filling" },
  "Amalgam Filling": { ar: "حشو امالجم", en: "Amalgam Filling" },
  "Endodontic Fillings (Root Canal)": { ar: "حشو عصب", en: "Endodontic Fillings (Root Canal)" },
  "Fixed Prosthetics (Crowns and Bridges)": { ar: "تيجان وجسور", en: "Fixed Prosthetics (Crowns and Bridges)" },
  "Removable Prosthetics": { ar: "تركيبات متحركة", en: "Removable Prosthetics" },
  "Dental Implants": { ar: "زراعة الأسنان", en: "Dental Implants" },
  "Cleaning and Whitening": { ar: "تنظيف وتبييض الأسنان", en: "Cleaning and Whitening" },
  "Orthodontics": { ar: "تقويم الأسنان", en: "Orthodontics" },
  "Surgery and Extraction": { ar: "الجراحة والخلع", en: "Surgery and Extraction" },
  "Pediatric Dentistry": { ar: "طب أسنان الأطفال", en: "Pediatric Dentistry" },
};

const CATEGORY_ALIASES = {
  "حشو تجميلي": "Cosmetic Filling",
  "حشوات الأسنان": "Cosmetic Filling",
  "Cosmetic Filling": "Cosmetic Filling",

  "حشو امالجم": "Amalgam Filling",
  "Amalgam Filling": "Amalgam Filling",

  "حشو عصب": "Endodontic Fillings (Root Canal)",
  "Endodontic Fillings (Root Canal)": "Endodontic Fillings (Root Canal)",

  "تيجان وجسور": "Fixed Prosthetics (Crowns and Bridges)",
  "تيجان الأسنان / التركيبات": "Fixed Prosthetics (Crowns and Bridges)",
  "Crowns and Bridges": "Fixed Prosthetics (Crowns and Bridges)",
  "Dental Crowns / Prosthodontics": "Fixed Prosthetics (Crowns and Bridges)",
  "Fixed Prosthetics (Crowns and Bridges)": "Fixed Prosthetics (Crowns and Bridges)",

  "تركيبات متحركة": "Removable Prosthetics",
  "Removable Prosthetics": "Removable Prosthetics",

  "زراعة الأسنان": "Dental Implants",
  "Dental Implants": "Dental Implants",

  "تنظيف وتبييض الأسنان": "Cleaning and Whitening",
  "Cleaning and Whitening": "Cleaning and Whitening",
  "تبييض الأسنان": "Cleaning and Whitening",
  "Teeth Whitening": "Cleaning and Whitening",

  "تقويم الأسنان": "Orthodontics",
  "Orthodontics": "Orthodontics",

  "الجراحة والخلع": "Surgery and Extraction",
  "خلع الأسنان": "Surgery and Extraction",
  "Tooth Extraction": "Surgery and Extraction",
  "Surgery and Extraction": "Surgery and Extraction",

  "طب أسنان الأطفال": "Pediatric Dentistry",
  "Pediatric Dentistry": "Pediatric Dentistry",
  "Pediatric": "Pediatric Dentistry",
  "الاطفال": "Pediatric Dentistry",
};

const CATEGORY_ROUTES = {
  "Cosmetic Filling": "/dental-filling",
  "Amalgam Filling": "/amalgam-filling",
  "Endodontic Fillings (Root Canal)": "/tooth-extraction",
  "Fixed Prosthetics (Crowns and Bridges)": "/crowns&bridges",
  "Removable Prosthetics": "/removable-prosthetics",
  "Dental Implants": "/dental-implant",
  "Cleaning and Whitening": "/teeth-whitening",
  "Orthodontics": "/braces",
  "Surgery and Extraction": "/surgery-extraction",
  "Pediatric Dentistry": "/pediatric-dentistry",
};

const normalizeCategory = (raw) => CATEGORY_ALIASES[raw?.trim?.() ? raw.trim() : raw] || raw;

const getCategoryLabel = (rawCategory, language = DEFAULT_LANGUAGE) => {
  const category = normalizeCategory(rawCategory);
  return CATEGORY_LABELS[category]?.[language] || category || "";
};

const getCategoryRoute = (rawCategory) => CATEGORY_ROUTES[normalizeCategory(rawCategory)];

const normalizeQuestion = (question) => ({
  id: question?.id,
  text_en: question?.text_en || question?.text || "",
  text_ar: question?.text_ar || question?.text || "",
  answers: (question?.options || question?.answers || []).map((answer) => ({
    id: answer?.id,
    text_en: answer?.text_en || answer?.text || "",
    text_ar: answer?.text_ar || answer?.text || "",
  })),
});

const getLocalizedText = (value, language = DEFAULT_LANGUAGE) => {
  if (!value) return "";
  if (typeof value === "string") return value;

  if (language === "en") {
    return value.text_en || value.text || value.text_ar || "";
  }

  return value.text_ar || value.text || value.text_en || "";
};

const normalizeText = (value) => (value || "").toString().trim().toLowerCase().replace(/\s+/g, " ");

const isOtherAnswer = (answer) => {
  const candidates = [answer?.id, answer?.text_en, answer?.text_ar, answer?.text]
    .map(normalizeText)
    .filter(Boolean);

  return candidates.some((candidate) =>
    [
      "something else",
      "other",
      "حاجة تانيه",
      "حاجة تانية",
      "حاجه تانيه",
      "حاجه تانية",
      "اخرى",
      "أخرى",
    ].includes(candidate)
  );
};

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

const QuickReplies = ({ question, disabled, isActive, language = DEFAULT_LANGUAGE, onSelect }) => {
  if (!isActive) return null;
  return (
    <div className={`quick-replies ${question.answers.length === 3 ? "quick-replies--three" : ""}`}>
      {question.answers.map((answer) => {
        return (
          <button
            key={`${question.id}-${answer.id}`}
            type="button"
            className="quick-reply-button"
            onClick={() => onSelect(question, answer)}
            disabled={disabled}
          >
            {getLocalizedText(answer, language)}
          </button>
        );
      })}
    </div>
  );
};

const ErrorBlock = ({ onNewChat, language = DEFAULT_LANGUAGE }) => (
  <div className="chatbot-flex">
    <div className="message bot-message error-message">
      <p className="message-text">
        {language === "en"
          ? "There was a connection error with the server. You can start a new chat."
          : "حدث خطأ في الاتصال بالسيرفر. يمكنك بدء محادثة جديدة."}
      </p>
      <ChatBotIcon />
    </div>
    <button
      type="button"
      className="quick-reply-button restart-button inline-restart"
      onClick={onNewChat}
      title={language === "en" ? "Start a new chat" : "بدء محادثة جديدة"}
    >
      <span>{language === "en" ? "Start a new chat" : "بدء محادثة جديدة"}</span>
    </button>
  </div>
);

const ResultButtons = ({ category, language = DEFAULT_LANGUAGE, onOpen }) => (
  <div className="quick-replies" style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
    <button
      type="button"
      className="quick-reply-button full result-button"
      onClick={onOpen}
      title={language === "en" ? `Go to ${category} page` : `الذهاب إلى صفحة ${category}`}
    >
      <span style={{ marginRight: '8px', fontSize: '1.1em' }}>→</span>
      <span>{language === "en" ? `View ${category} cases` : `عرض حالات ${category}`}</span>
    </button>
  </div>
);

const OTHER_PROMPTS = {
  ar: "اتفضل قولى حاسس بأيه عشان اقدر اساعدك",
  en: "Please tell me how you're feeling so I can help you.",
};

const getResponseCategory = (data) => data?.result?.category || data?.recommended_category || data?.category || null;

const detectCategoryFromText = (text) => {
  if (!text) return null;
  const normalized = text.trim().toLowerCase();
  const sortedAliases = Object.keys(CATEGORY_ALIASES).sort((a, b) => b.length - a.length);
  for (const alias of sortedAliases) {
    if (normalized.includes(alias.toLowerCase())) {
      return CATEGORY_ALIASES[alias];
    }
  }
  return null;
};

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
  const [chatLanguage, setChatLanguage] = useState(DEFAULT_LANGUAGE);

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
        setChatLanguage(saved.chatLanguage || DEFAULT_LANGUAGE);

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
      chatLanguage,
    });
  }, [flowItems, chatHistory, chatMode, sessionId, activeQuestionId, hasServerError, allSessions, chatLanguage]);

  useEffect(() => {
    scrollToBottom();
  }, [flowItems, chatHistory, allSessions]);

  async function startSession() {
    setIsLoading(true);
    setHasServerError(false);
    try {
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: chatLanguage }) });
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
    const responseCategory = getResponseCategory(data);
    if (responseCategory) {
      const category = normalizeCategory(responseCategory);
      const categoryLabel = getCategoryLabel(category, chatLanguage);
      addFlowItem({
        type: "result",
        category,
        categoryLabel,
        text_ar: ` تم تحديد الفئة: ${categoryLabel}`,
        text_en: `Category identified: ${categoryLabel}`,
      });
      return true;
    }
    if (data?.question && data?.question?.id && (data?.question?.text || data?.question?.text_en || data?.question?.text_ar)) {
      const question = data.question;
      setActiveQuestionId(question.id);
      addFlowItem({
        type: "question",
        id: question.id,
        question: normalizeQuestion(question),
      });
      return true;
    }
    setChatMode(true);
    return false;
  };

  const submitAnswer = async (question, answer) => {
    if (isOtherAnswer(answer)) {
      setActiveQuestionId(null);
      addFlowItem({ type: "answer", text_en: answer.text_en, text_ar: answer.text_ar });
      addFlowItem({
        type: "bot_prompt",
        text_en: OTHER_PROMPTS.en,
        text_ar: OTHER_PROMPTS.ar,
      });
      setChatMode(true);
      return;
    }

    if (!sessionId) return;
    setIsLoading(true);
    setActiveQuestionId(null);
    if (question.id === "Q0") {
      setChatLanguage(answer.id === "EN" ? "en" : "ar");
    }
    addFlowItem({ type: "answer", text_en: answer.text_en, text_ar: answer.text_ar });
    try {
      const res = await fetch(`${API_BASE}/session/answer`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ session_id: sessionId, question_id: question.id, answer_id: answer.id }) });
      if (!res.ok && res.status >= 500) {
        addFlowItem({ type: "server_error" });
        setIsLoading(false);
        return;
      }
      const data = await res.json();
      if (!processResponse(data)) {
        addFlowItem({
          type: "result",
          text_ar: "عذراً، أحتاج المزيد من المعلومات. من فضلك اكتب رسالة بالتفصيل:",
          text_en: "Sorry, I need a bit more information. Please type your message in detail:",
        });
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

      const responseCategory = getResponseCategory(data);
      if (responseCategory) {
        const category = normalizeCategory(responseCategory);
        const categoryLabel = getCategoryLabel(category, chatLanguage);
        setChatHistory(prev => prev.filter(m => m.text !== THINKING_TEXT));
        addFlowItem({
          type: "result",
          category,
          categoryLabel,
          text_ar: ` تم تحديد الفئة: ${categoryLabel}`,
          text_en: `Category identified: ${categoryLabel}`,
        });
        setChatMode(false);
        if (data.session_id) setSessionId(data.session_id);
        return;
      }

      const replyText = data.reply || "";
      const detectedCategory = detectCategoryFromText(replyText);
      if (detectedCategory && replyText) {
        const category = normalizeCategory(detectedCategory);
        const categoryLabel = getCategoryLabel(category, chatLanguage);
        setChatHistory(prev => [...prev.filter(m => m.text !== THINKING_TEXT), { role: "model", text: replyText, detectedCategory: category, categoryLabel }]);
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
      const res = await fetch(`${API_BASE}/session/start`, { method: "POST", headers: API_HEADERS, body: JSON.stringify({ language: chatLanguage }) });
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

  const openCategory = (rawCategory) => {
    const pageRoute = getCategoryRoute(rawCategory);
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
          {item.type === "question" && <BotMessage text={getLocalizedText(item.question, chatLanguage)} />}
          {item.type === "bot_prompt" && <BotMessage text={getLocalizedText(item, chatLanguage)} />}
          {item.type === "result" && (
            <>
              <BotMessage text={getLocalizedText(item, chatLanguage)} />
              {item.category && (
                <div className="quick-replies">
                  <button
                    type="button"
                    className="quick-reply-button full result-button"
                    onClick={() => openCategory(item.category)}
                    title={`الذهاب إلى صفحة ${getCategoryLabel(item.category, chatLanguage)}`}
                  >
                    <span>{chatLanguage === "en" ? "View cases" : "عرض الحالات"}</span>
                    <strong>{getCategoryLabel(item.category, chatLanguage)}</strong>
                    <span style={{ marginLeft: '8px' }}>←</span>
                  </button>
                </div>
              )}
            </>
          )}
          {item.type === "answer" && <UserMessage text={getLocalizedText(item, chatLanguage)} />}
        </div>
      ))}
      {session.chatHistory.map((m, i) =>
        m.role === "user"
          ? <UserMessage key={`old-${index}-chat-${i}`} text={m.text} />
          : m.text === "__SERVER_ERROR__"
            ? <ErrorBlock key={`old-${index}-err-${i}`} onNewChat={startNewChat} language={chatLanguage} />
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

            {isLoading && flowItems.length === 0 && <BotMessage text={chatLanguage === "en" ? "...Preparing questions" : "...جاري تجهيز الأسئلة"} />}

            {hasServerError && flowItems.length === 0 && (
              <ErrorBlock onNewChat={startNewChat} language={chatLanguage} />
            )}

            {flowItems.map((item, i) => (
              <div key={i}>
                {item.type === "question" && (
                  <>
                    <BotMessage text={getLocalizedText(item.question, chatLanguage)} />
                    <QuickReplies
                      question={item.question}
                      language={chatLanguage}
                      disabled={isLoading}
                      isActive={!chatMode && activeQuestionId === item.question.id && item.question.answers.length > 0}
                      onSelect={submitAnswer}
                    />
                  </>
                )}

                {item.type === "bot_prompt" && <BotMessage text={getLocalizedText(item, chatLanguage)} />}
                {item.type === "result" && (
                  <>
                    <BotMessage text={getLocalizedText(item, chatLanguage)} />
                    {item.category && (
                      <ResultButtons
                        category={getCategoryLabel(item.category, chatLanguage)}
                        language={chatLanguage}
                        disabled={isLoading}
                        onOpen={() => openCategory(item.category)}
                        onRestart={restartSession}
                      />
                    )}
                  </>
                )}
                {item.type === "answer" && <UserMessage text={getLocalizedText(item, chatLanguage)} />}
                {item.type === "server_error" && <ErrorBlock onNewChat={startNewChat} language={chatLanguage} />}
              </div>
            ))}

            {chatHistory.map((m, i) =>
              m.role === "user"
                ? <UserMessage key={i} text={m.text} />
                : m.text === "__SERVER_ERROR__"
                  ? <ErrorBlock key={i} onNewChat={startNewChat} language={chatLanguage} />
                  : <div key={i}>
                      <BotMessage text={m.text} />
                      {m.detectedCategory && (
                        <ResultButtons
                          category={getCategoryLabel(m.detectedCategory, chatLanguage)}
                          language={chatLanguage}
                          onOpen={() => openCategory(m.detectedCategory)}
                        />
                      )}
                    </div>
            )}
          </div>

          {chatMode && (
            <div className="chat-footer">
              <form action="#" className="chat-form" onSubmit={(e) => { e.preventDefault(); sendChatMessage(); }}>
                <input
                  ref={inputRef}
                  type="text"
                  placeholder={chatLanguage === "en" ? "Type your message.............................." : "اكتب رسالتك.............................."}
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