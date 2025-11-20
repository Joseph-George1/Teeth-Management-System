import {useRef, useState} from "react"; 
import ChatBotIcon from "../Components/ChatBotIcon";
import '../Css/ChatBot.css';

export default function ChatBot({ setIsAuthenticated }) {
  const inputRef = useRef();
  const [chatHistory, setChatHistory] = useState([]);
  const [sessionId, setSessionId] = useState(null);

 const generateBotResponse = async (userMessage) => {
  try {
    const response = await fetch("http://16.16.218.118:5000/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ 
        message: userMessage, 
        session_id: sessionId 
      }),
    });

    const data = await response.json();
    console.log("Server response:", data);

    if (data.session_id) {
      setSessionId(data.session_id);
    }

    if (data.reply) {
      setChatHistory((prevHistory) => [
        ...prevHistory.filter((msg) => msg.text !== "يفكر....."),
        { role: "model", text: data.reply }
      ]);
    } else {
      throw new Error("No reply received from server");
    }

  } catch (error) {
    console.error("Error details:", error.message, error);
    setChatHistory((prevHistory) => [
      ...prevHistory.filter((msg) => msg.text !== "يفكر....."),
      { role: "model", text: "عذراً، حدث خطأ في الاتصال. حاول مرة أخرى." }
    ]);
  }
};


  const handleFormSubmit = async (e) => {
    e.preventDefault();
    const userMessage = inputRef.current.value.trim();
    if (!userMessage) return;
    inputRef.current.value = "";

    // Add user message and thinking indicator
    setChatHistory((prevHistory) => [
      ...prevHistory,
      { role: "user", text: userMessage },
      { role: "model", text: "يفكر....." }
    ]);

    // Short delay to ensure UI updates before API call
    await new Promise(resolve => setTimeout(resolve, 100));
    await generateBotResponse(userMessage);

  }
  return(
    <>
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
        <div className="chat-body">
          <div className="chatbot-flex">
            <div className="message bot-message">
              <p className="message-text">
               👋🏻 اهلا بك<br/> ازاى اقدر اساعدك؟
              </p>
              <ChatBotIcon/>
            </div> 
          </div>

          {chatHistory.map((chat, i) => (
            <div key={`chat-${i}`} className={`message ${chat.role === "model" ? "bot": "user"}-message`}>
              <p className="message-text">{chat.text}</p> 
              {chat.role === "model" && <ChatBotIcon/>}
            </div>
          ))}
        </div>
        {/* chatbot footer */}
        <div className="chat-footer">
          <form action="#" className="chat-form" onSubmit={handleFormSubmit}>
            <input 
            ref={inputRef}
            type="text"
            placeholder="اكتب رسالتك......"
            className="message-input"
            required />
            <button className="material-symbols-outlined">arrow_upward_alt</button>
          </form>
        </div>
      </div>
    </div>
    </div>
    </>
  )
}
