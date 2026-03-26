import { Link } from 'react-router-dom';
import '../Css/ComingSoon.css';
import { Helmet } from "react-helmet-async";

export default function ComingSoon() {
    return (
        <>
             <Helmet>
                <meta
                  name="description"
                  content="منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان لعلاج الحالات مجانًا تحت الإشراف المباشر لأعضاء هيئة التدريس بالكلية، مع فرصة تعليمية عملية للطلاب"
                />
              </Helmet>
        <div className="coming-soon-container">
            <div className="coming-soon-content">
                <div className="coming-soon-header">
                    <p className="coming-soon-label">قريباً</p>
                    <h1 className="coming-soon-title">منصة ثوثه</h1>
                    <p className="coming-soon-highlight">الربط الذكي بين طلاب الأسنان والمرضى</p>
                </div>

                <div className="coming-soon-description">
                    <h2 className="description-title">ماذا تقدم منصة ثوثه؟</h2>
                    
                    <div className="benefits-section">
                        <div className="benefit-card">
                            <h3>للطلاب</h3>
                            <p>فرصة ذهبية للحصول على حالات عملية متنوعة لاكتساب الخبرة والمهارات في الحالات الفعلية بإشراف متخصصين</p>
                        </div>
                        
                        <div className="benefit-card">
                            <h3>للمرضى</h3>
                            <p>علاج أسنانك بجودة عالية وبسعر مناسب أو حتى بالمجان تحت إشراف أفضل الأطباء والمتخصصين</p>
                        </div>
                    </div>

                    <div className="platform-mission">
                        <h3>رسالتنا</h3>
                        <p>ثوثه تربط بين طلاب الأسنان المتفانين والمرضى الذين يبحثون عن علاج بأسعار رمزية أو مجاني، لنخلق معاً خبرة تعليمية قيّمة وخدمة صحية موثوقة</p>
                    </div>
                </div>

                <div className="coming-soon-cta">
                    <p className="cta-text">انضم لثوثه وكن جزءاً منا في هذه الرحلة الطبية الرائعة</p>
                </div>

                <div className="coming-soon-actions">
                    <Link to="/sign" className="coming-soon-btn btn-primary">
                        إنشاء حساب
                    </Link>
                </div>

                <p className="copyright-text">جميع الحقوق محفوظة © 2026 ثوثه</p>
            </div>
        </div>
        </>
    );
}
