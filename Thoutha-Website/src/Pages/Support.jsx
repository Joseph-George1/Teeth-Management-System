import "../Css/Support.css";

export default function Support(){
  return (
    <div className="support-container">
      <h1 className="support-title">الدعم الفني – منصة ثوثة</h1>

      <section className="support-section">
        <p>
          لو واجهتك أي مشكلة تقنية أثناء استخدام منصة <strong>ثوثة</strong>،
          أو عندك استفسار بخصوص التسجيل أو الحساب، فريق الدعم الفني جاهز يساعدك.
        </p>
      </section>

      <section className="support-section">
        <h2>ملاحظات مهمة</h2>
        <ul>
          <li>
            الدعم الفني يقتصر فقط على المشاكل التقنية المتعلقة باستخدام الموقع.
          </li>
          <li>
            لا يتدخل فريق الدعم في أي نزاعات أو اتفاقات بين الطلاب والمرضى.
          </li>
          <li>
            المنصة دورها يقتصر على الربط فقط بين الطرفين.
          </li>
        </ul>
      </section>

      <section className="support-section">
        <h2>وسائل التواصل</h2>
        <p>
          يمكنك التواصل معنا عبر البريد الإلكتروني:
        </p>
        <p className="support-email">
          menna128492@gmail.com
        </p>
      </section>

      <section className="support-section">
        <h2>نموذج التواصل</h2>

        <form className="support-form">
          <input
            type="text"
            placeholder="الاسم"
            required
          />

          <input
            type="email"
            placeholder="البريد الإلكتروني"
            required
          />

          <textarea
            placeholder="اكتب رسالتك هنا"
            rows="5"
            required
          ></textarea>

          <button type="submit">إرسال</button>
        </form>
      </section>
    </div>
  );
};

