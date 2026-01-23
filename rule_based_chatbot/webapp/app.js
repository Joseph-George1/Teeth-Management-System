const API_BASE = 'http://localhost:5005/api';
let session = null;

const statusEl = document.getElementById('status');
const qArea = document.getElementById('question-area');
const qText = document.getElementById('question-text');
const optionsForm = document.getElementById('options-form');
const rawEl = document.getElementById('raw');
const sendBtn = document.getElementById('send-btn');
const resultArea = document.getElementById('result-area');
const categoryDisplay = document.getElementById('category-display');
const reasonDisplay = document.getElementById('reason-display');
const restartBtn = document.getElementById('restart-btn');

async function startSession(){
  statusEl.textContent = 'Starting session...';
  const res = await fetch(`${API_BASE}/session/start`, { method: 'POST' });
  const data = await res.json();
  session = data.session;
  rawEl.textContent = JSON.stringify(data, null, 2);
  renderQuestion(data.question);
}

function renderQuestion(q){
  if(!q){
    qArea.style.display = 'none';
    statusEl.textContent = 'No question';
    return;
  }
  qArea.style.display = 'block';
  qText.textContent = q.text;
  optionsForm.innerHTML = '';
  q.options.forEach(opt => {
    const id = `opt_${opt.id}`;
    const label = document.createElement('label');
    label.className = 'option';
    const input = document.createElement('input');
    input.type = 'radio';
    input.name = 'answer';
    input.value = opt.id;
    input.id = id;
    const span = document.createElement('span');
    span.textContent = opt.text;
    label.appendChild(input);
    label.appendChild(span);
    optionsForm.appendChild(label);
  });
  statusEl.textContent = `Question ${q.id}`;
}

async function sendAnswer(e){
  e.preventDefault();
  if(!session) return;
  const form = optionsForm;
  const selected = form.querySelector('input[name=answer]:checked');
  if(!selected){ alert('Please pick an option'); return; }
  const payload = {
    session_id: session.session_id,
    question_id: session.current_question_id,
    answer_id: selected.value
  };
  statusEl.textContent = 'Sending answer...';
  const res = await fetch(`${API_BASE}/session/answer`, {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify(payload)
  });
  const data = await res.json();
  rawEl.textContent = JSON.stringify(data, null, 2);
  // If result present
  if(data.result){
    qArea.style.display = 'none';
    resultArea.style.display = 'block';
    categoryDisplay.textContent = data.result.category;
    reasonDisplay.textContent = `Decision path: ${data.result.reason || ''}`;
    statusEl.textContent = 'Category determined';
    session = data.session;
  } else if(data.question){
    session = data.session;
    renderQuestion(data.question);
  } else if(data.session){
    session = data.session;
    qArea.style.display = 'none';
    statusEl.textContent = 'Session updated';
  }
}

function reset(){
  session = null;
  resultArea.style.display = 'none';
  qArea.style.display = 'none';
  startSession();
}

sendBtn.addEventListener('click', sendAnswer);
restartBtn.addEventListener('click', reset);

// auto-start
startSession();
