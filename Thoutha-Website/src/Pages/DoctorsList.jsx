import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { X } from "lucide-react";
import "../Css/DoctorsList.css";

const API_URL = "https://thoutha.page/api/request/getRequestsByCategoryId";

const normalizeDoctorsResponse = (payload) => {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content)) return payload.content;
  return [];
};

const getDoctorName = (doctor) => {
  const fullName = `${doctor?.firstName || ""} ${doctor?.lastName || ""}`.trim();
  return fullName || doctor?.fullName || doctor?.name || "طبيب أسنان";
};

const getDoctorCategory = (doctor, fallbackCategory) => {
  return (
    doctor?.categoryName ||
    doctor?.specialization ||
    doctor?.specialty ||
    fallbackCategory ||
    "تخصص أسنان"
  );
};

const getCity = (doctor) => {
  return doctor?.cityName || doctor?.city?.name || doctor?.city || "غير محدد";
};

const getPhone = (doctor) => {
  return doctor?.phoneNumber || doctor?.phone || doctor?.mobile || "غير متاح";
};

const getEmail = (doctor) => {
  return doctor?.email || "غير متاح";
};

const getImage = (doctor) => {
  return doctor?.image || doctor?.imageUrl || doctor?.profileImage || "/doctor.jpg";
};

const mapDoctorsRows = (doctors) => {
  const rows = [];
  for (let index = 0; index < doctors.length; index += 2) {
    rows.push(doctors.slice(index, index + 2));
  }
  return rows;
};

export default function DoctorsList({ categoryName }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [doctors, setDoctors] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedDoctor, setSelectedDoctor] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    const fetchDoctors = async () => {
      setLoading(true);
      setError("");

      try {
        const requestBody = {
          categoryName,
          category: categoryName,
          serviceName: categoryName,
        };

        let response = await fetch(API_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(requestBody),
          signal: controller.signal,
        });

        if (!response.ok) {
          const query = new URLSearchParams({ categoryName: categoryName || "" }).toString();
          response = await fetch(`${API_URL}?${query}`, {
            method: "GET",
            signal: controller.signal,
          });
        }

        if (!response.ok) {
          throw new Error("فشل تحميل الدكاترة لهذه الخدمة");
        }

        const payload = await response.json();
        const normalizedDoctors = normalizeDoctorsResponse(payload);
        setDoctors(normalizedDoctors);
      } catch (fetchError) {
        if (fetchError.name !== "AbortError") {
          setError(fetchError.message || "حدث خطأ أثناء تحميل الدكاترة");
          setDoctors([]);
        }
      } finally {
        if (!controller.signal.aborted) {
          setLoading(false);
        }
      }
    };

    fetchDoctors();

    return () => controller.abort();
  }, [categoryName]);

  const doctorsRows = useMemo(() => mapDoctorsRows(doctors), [doctors]);

  const openDoctorDetails = (doctor) => {
    setSelectedDoctor(doctor);
    setIsOpen(true);
  };

  return (
    <>
      {isOpen && selectedDoctor && (
        <div className="overlay" onClick={() => setIsOpen(false)}>
          <div className="blog-review" onClick={(event) => event.stopPropagation()}>
            <div className="blog-top">
              <div className="blog-top-x">
                <X size={28} className="top-x" onClick={() => setIsOpen(false)} />
                <p className="blog-title">تفاصيل الطبيب</p>
              </div>
              <hr />

              <div className="student-details">
                <p className="student-info">عن الطبيب</p>
                <p className="student-info-details">
                  {selectedDoctor?.bio || "لا توجد تفاصيل إضافية متاحة حالياً"}
                </p>
              </div>

              <div className="student-number-email">
                <div className="flex-row1">
                  <div className="flex-col1">
                    <div className="icon-row">
                      <p className="collage">التخصص</p>
                    </div>
                    <p className="collage-info">{getDoctorCategory(selectedDoctor, categoryName)}</p>
                  </div>
                  <div className="flex-col1">
                    <div className="icon-row">
                      <p className="collage">المدينة</p>
                    </div>
                    <p className="collage-info">{getCity(selectedDoctor)}</p>
                  </div>
                </div>
                <div className="flex-row1">
                  <div className="flex-col1">
                    <div className="icon-row">
                      <p className="collage">رقم الهاتف</p>
                    </div>
                    <p className="collage-info">{getPhone(selectedDoctor)}</p>
                  </div>
                  <div className="flex-col1">
                    <div className="icon-row">
                      <p className="collage">البريد الإلكتروني</p>
                    </div>
                    <p className="collage-info">{getEmail(selectedDoctor)}</p>
                  </div>
                </div>
              </div>

              <Link to="/booking">
                <div className="button-booking">حجز</div>
              </Link>
            </div>
          </div>
        </div>
      )}

      <div className="doctors-section">
        <div className="doctors-container">
          <p className="doctor-title">الاطباء الاقرب لك</p>

          {loading && <p className="doctor-case">جاري تحميل الأطباء...</p>}

          {!loading && error && <p className="doctor-case">{error}</p>}

          {!loading && !error && doctors.length === 0 && (
            <p className="doctor-case">لا يوجد أطباء متاحين في هذه الخدمة حالياً</p>
          )}

          {!loading && !error && doctors.length > 0 && (
            <div className="doctors-list">
              {doctorsRows.map((row, rowIndex) => (
                <div className="doctor-flex" key={`row-${rowIndex}`}>
                  {row.map((doctor, cardIndex) => (
                    <div
                      className="doctor-card"
                      key={doctor?.id || doctor?.doctorId || `${rowIndex}-${cardIndex}`}
                      onClick={() => openDoctorDetails(doctor)}
                      role="button"
                      tabIndex={0}
                      onKeyDown={(event) => {
                        if (event.key === "Enter" || event.key === " ") {
                          openDoctorDetails(doctor);
                        }
                      }}
                    >
                      <img
                        src={getImage(doctor)}
                        alt={getDoctorName(doctor)}
                        onError={(event) => {
                          event.currentTarget.src = "/doctor.jpg";
                        }}
                      />

                      <div className="doctor-details">
                        <div className="doctor-name-case">
                          <p className="doctor-name">{getDoctorName(doctor)}</p>
                          <p className="doctor-case">{getDoctorCategory(doctor, categoryName)}</p>

                          <div className="doctor-icon">
                            <div className="icon-star">
                              <p className="number-star">{doctor?.rating || doctor?.rate || "-"}</p>
                            </div>
                          </div>
                        </div>

                        <div className="doctor-location">
                          <div className="doctor-location-icon">
                            <p className="location">{getCity(doctor)}</p>
                          </div>
                          <div className="doctor-available">
                            <p className="available-title">
                              {doctor?.availableNow === false ? "غير متاح" : "متاح الان"}
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </>
  );
}
