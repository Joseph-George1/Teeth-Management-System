import '../Css/TermsConditions.css';

export default function DeleteAccount() {
  return (
    <div className="terms-container">
      <h1 className="terms-title">حذف الحساب – منصة ثوثة</h1>

      <section className="terms-section">
        <h2>طريقة حذف الحساب</h2>
        <p>يمكنك حذف حسابك في منصة ثوثة بإحدى الطرق التالية:</p>
      </section>

      <section className="terms-section">
        <h2>1️⃣ من داخل التطبيق</h2>
        <ul>
          <li>الدخول إلى الإعدادات</li>
          <li>اختيار “حذف الحساب”</li>
          <li>تأكيد الطلب</li>
        </ul>
      </section>

      <section className="terms-section">
        <h2>2️⃣ عبر البريد الإلكتروني</h2>
        <p>يمكنك إرسال طلب حذف الحساب إلى:</p>
        <p>اكتب البريد الإلكتروني هنا</p>
        <p>مع توضيح:</p>
        <ul>
          <li>الاسم الكامل</li>
          <li>البريد الإلكتروني المسجل بالحساب</li>
          <li>طلب صريح بحذف الحساب</li>
        </ul>
      </section>

      <section className="terms-section">
        <h2>ماذا يحدث عند حذف الحساب؟</h2>
        <p>عند تأكيد طلب الحذف:</p>
        <ul>
          <li>سيتم حذف بيانات الحساب الشخصية (الاسم – البريد الإلكتروني – بيانات التسجيل).</li>
          <li>سيتم إلغاء أي مواعيد أو طلبات نشطة مرتبطة بالحساب.</li>
          <li>لن تتمكن من استعادة الحساب بعد الحذف.</li>
        </ul>
      </section>

      <section className="terms-section">
        <h2>مدة تنفيذ الطلب</h2>
        <p>يتم تنفيذ طلب حذف الحساب خلال مدة أقصاها ٢ أيام عمل من تاريخ استلام الطلب.</p>
      </section>

      <section className="terms-section">
        <h2>الاحتفاظ ببعض البيانات</h2>
        <p>قد نحتفظ ببعض البيانات لفترة محدودة في الحالات التالية:</p>
        <ul>
          <li>إذا كان الاحتفاظ مطلوبًا بموجب القانون.</li>
          <li>لأغراض الحماية ومنع إساءة الاستخدام.</li>
        </ul>
        <p>يتم حذف هذه البيانات بعد انتهاء المدة القانونية اللازمة.</p>
      </section>

      <section className="terms-section">
        <h2>ملاحظات مهمة</h2>
        <ul>
          <li>حذف التطبيق من جهازك لا يعني حذف الحساب.</li>
          <li>يجب تقديم طلب رسمي لحذف الحساب كما هو موضح أعلاه.</li>
        </ul>
      </section>
    </div>
  );
}