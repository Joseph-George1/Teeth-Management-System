import '../Css/TermsConditions.css';

export default function DeleteAccount() {
  return (
    <div className="terms-container">
      <h1 className="terms-title">حذف الحساب – منصة ثوثة</h1>

      <section className="terms-section">
        <h2>طلب حذف الحساب</h2>
        <p>
          يمكنك طلب حذف حسابك في منصة ثوثة في أي وقت من خلال الإعدادات داخل التطبيق أو عن طريق التواصل معنا عبر البريد الإلكتروني.
        </p>
      </section>

      <section className="terms-section">
        <h2>ماذا يحدث عند حذف الحساب؟</h2>
        <p>عند تأكيد طلب الحذف:</p>
        <ul>
          <li>سيتم حذف بيانات حسابك الشخصية من المنصة.</li>
          <li>لن تتمكن من تسجيل الدخول مرة أخرى بنفس الحساب.</li>
          <li>سيتم إلغاء أي طلبات أو مواعيد مرتبطة بالحساب.</li>
        </ul>
      </section>

      <section className="terms-section">
        <h2>مدة تنفيذ الطلب</h2>
        <p>يتم تنفيذ طلب حذف الحساب خلال مدة أقصاها (٢ أيام عمل) من تاريخ استلام الطلب.</p>
      </section>

      <section className="terms-section">
        <h2>استثناءات</h2>
        <p>قد نحتفظ ببعض البيانات لفترة محددة إذا كان ذلك مطلوبًا قانونيًا أو لحماية حقوق المنصة.</p>
      </section>

      <section className="terms-section">
        <h2>التواصل لطلب الحذف</h2>
        <p>يمكنك إرسال طلب حذف الحساب عبر البريد الإلكتروني التالي:</p>
        <p>menna@thoutha.page</p>
        <p>joseph@thoutha.page</p>
        <p>مع توضيح:</p>
        <ul>
          <li>الاسم</li>
          <li>البريد الإلكتروني المسجل بالحساب</li>
          <li>طلب صريح بحذف الحساب</li>
        </ul>
      </section>
    </div>
  );
}