import { useState } from 'react';
import { Link } from 'react-router-dom';
import {X} from "lucide-react";
import '../Css/DoctorsList.css';

export default function DoctorsList(){
const [isOpen, setIsOpen] = useState(false);
    return(
        <>
        {/* Overlay  */}
        {isOpen && <div className="overlay" onClick={() => setIsOpen(false)}>
            <div className="blog-review" onClick={(e) => e.stopPropagation()}>
                <div className="blog-top">
                    <div className="blog-top-x">
                        <X size={28} className='top-x' onClick={() => setIsOpen(false)} />
                        <p className="blog-title">تفاصيل عن الطالب</p>
                    </div>
                    <hr />
                    <div className="student-details">
                        <p className="student-info">عن الطالب</p>
                        <p className="student-info-details">طالب بالسنة الخامسة متخصص في جراحة وتجميل الأسنان. أقوم بالتدريب العملي تحت إشراف أساتذة الكلية. لدي خبرة جيدة في الحشوات التجميلية وخلع الأسنان البسيط.</p>
                    </div>
                    <div className="student-number-email">
                        <div className="flex-row1">
                            <div className="flex-col1">
                                <div className="icon-row">
                                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <path d="M17.8498 9.10168C17.999 9.03587 18.1256 8.92774 18.2139 8.79068C18.3023 8.65363 18.3485 8.49367 18.3468 8.33063C18.3451 8.16758 18.2956 8.00862 18.2045 7.87342C18.1133 7.73822 17.9845 7.63273 17.834 7.57001L10.6915 4.31668C10.4744 4.21764 10.2385 4.16638 9.99983 4.16638C9.76117 4.16638 9.5253 4.21764 9.30816 4.31668L2.1665 7.56668C2.01814 7.63166 1.89193 7.73846 1.8033 7.87403C1.71468 8.00959 1.66748 8.16805 1.66748 8.33001C1.66748 8.49198 1.71468 8.65043 1.8033 8.786C1.89193 8.92157 2.01814 9.02837 2.1665 9.09335L9.30816 12.35C9.5253 12.4491 9.76117 12.5003 9.99983 12.5003C10.2385 12.5003 10.4744 12.4491 10.6915 12.35L17.8498 9.10168Z" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                        <path d="M18.3335 8.33337V13.3334" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                        <path d="M5 10.4166V13.3333C5 13.9963 5.52678 14.6322 6.46447 15.1011C7.40215 15.5699 8.67392 15.8333 10 15.8333C11.3261 15.8333 12.5979 15.5699 13.5355 15.1011C14.4732 14.6322 15 13.9963 15 13.3333V10.4166" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                    </svg>
                                    <p className="collage">الكلية والسنة الدراسية</p> 
                                </div>
                                <p className="collage-info">كلية طب الأسنان - جامعة القاهرة</p>
                            </div>
                            <div className="flex-col1">
                                <div className="icon-row">
                                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <g clip-path="url(#clip0_423_2549)">
                                            <path d="M16.6668 8.33329C16.6668 12.4941 12.051 16.8275 10.501 18.1658C10.3566 18.2744 10.1808 18.3331 10.0002 18.3331C9.8195 18.3331 9.64373 18.2744 9.49933 18.1658C7.94933 16.8275 3.3335 12.4941 3.3335 8.33329C3.3335 6.56518 4.03588 4.86949 5.28612 3.61925C6.53636 2.36901 8.23205 1.66663 10.0002 1.66663C11.7683 1.66663 13.464 2.36901 14.7142 3.61925C15.9645 4.86949 16.6668 6.56518 16.6668 8.33329Z" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M10 10.8334C11.3807 10.8334 12.5 9.71409 12.5 8.33337C12.5 6.95266 11.3807 5.83337 10 5.83337C8.61929 5.83337 7.5 6.95266 7.5 8.33337C7.5 9.71409 8.61929 10.8334 10 10.8334Z" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </g>
                                        <defs>
                                            <clipPath id="clip0_423_2549">
                                                <rect width="20" height="20" fill="white"/>
                                            </clipPath>
                                        </defs>
                                    </svg>
                                    <p className="collage">العنوان</p>
                                </div>
                                <p className="collage-info">كلية طب الأسنان، جامعة القاهرة، المنيل</p>
                            </div>
                        </div>
                        <div className="flex-row1">
                            <div className="flex-col1">
                                <div className="icon-row">
                                <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <g clip-path="url(#clip0_423_2582)">
                                    <path d="M11.5265 13.8066C11.6986 13.8857 11.8925 13.9037 12.0762 13.8578C12.26 13.8119 12.4226 13.7048 12.5373 13.5541L12.8332 13.1666C12.9884 12.9596 13.1897 12.7916 13.4211 12.6759C13.6526 12.5602 13.9078 12.5 14.1665 12.5H16.6665C17.1085 12.5 17.5325 12.6756 17.845 12.9881C18.1576 13.3007 18.3332 13.7246 18.3332 14.1666V16.6666C18.3332 17.1087 18.1576 17.5326 17.845 17.8451C17.5325 18.1577 17.1085 18.3333 16.6665 18.3333C12.6883 18.3333 8.87295 16.7529 6.0599 13.9399C3.24686 11.1268 1.6665 7.31154 1.6665 3.33329C1.6665 2.89127 1.8421 2.46734 2.15466 2.15478C2.46722 1.84222 2.89114 1.66663 3.33317 1.66663H5.83317C6.2752 1.66663 6.69912 1.84222 7.01168 2.15478C7.32424 2.46734 7.49984 2.89127 7.49984 3.33329V5.83329C7.49984 6.09203 7.4396 6.34722 7.32388 6.57865C7.20817 6.81007 7.04016 7.01138 6.83317 7.16663L6.44317 7.45913C6.29018 7.57594 6.18235 7.74211 6.138 7.92942C6.09364 8.11672 6.11549 8.31361 6.19984 8.48663C7.33874 10.7998 9.21186 12.6706 11.5265 13.8066Z" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                    </g>
                                    <defs>
                                    <clipPath id="clip0_423_2582">
                                    <rect width="20" height="20" fill="white"/>
                                    </clipPath>
                                    </defs>
                                </svg>
                                <p className="collage">رقم الهاتف</p>
                                </div>
                                <p className="collage-info">01012345678</p>
                            </div>
                            <div className="flex-col1">
                                <div className="icon-row">
                                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M18.3332 5.83337L10.8407 10.6059C10.5864 10.7536 10.2976 10.8313 10.0036 10.8313C9.70956 10.8313 9.42076 10.7536 9.1665 10.6059L1.6665 5.83337" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M16.6665 3.33337H3.33317C2.4127 3.33337 1.6665 4.07957 1.6665 5.00004V15C1.6665 15.9205 2.4127 16.6667 3.33317 16.6667H16.6665C17.587 16.6667 18.3332 15.9205 18.3332 15V5.00004C18.3332 4.07957 17.587 3.33337 16.6665 3.33337Z" stroke="#84E5F3" stroke-width="1.66667" stroke-linecap="round" stroke-linejoin="round"/>
                                    </svg>

                                <p className="collage">البريد الإلكتروني</p>
                                </div>
                                <p className="collage-info">ahmed.mahmoud@dentistry.cu.edu.eg</p>
                            </div>
                        </div>
                    </div>
                    <div className="doctor-days-available">
                        <div className="doctor-days-title-available">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M8 2V6" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M16 2V6" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M19 4H5C3.89543 4 3 4.89543 3 6V20C3 21.1046 3.89543 22 5 22H19C20.1046 22 21 21.1046 21 20V6C21 4.89543 20.1046 4 19 4Z" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M3 10H21" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                            <span className="days-title">احجز موعدك</span>
                        </div>
                        <div className="doctor-days">
                            <div className="day1">
                                <p className="day1-title">الأحد</p>
                            </div>
                            <div className="day1">
                                <p className="day1-title">الأثنين</p>
                            </div>
                            <div className="day1">
                                <p className="day1-title">الثلاثاء</p>
                            </div>
                            <div className="day1">
                                <p className="day1-title">الأربعاء</p>
                            </div>
                            <div className="day1">
                                <p className="day1-title">الخميس</p>
                            </div>
                        </div>
                    </div>
                    <div className="doctor-time">
                        <div className="time1">
                            <p className="time1-title">10:00 صباحاً</p>
                        </div>
                        <div className="time1">
                            <p className="time1-title">11:00 صباحاً</p>
                        </div>
                        <div className="time1">
                            <p className="time1-title">12:00 صباحاً</p>
                        </div>
                        <div className="time1">
                            <p className="time1-title">1:00 مساءً</p>
                        </div>
                    </div>
                    <div className="important-info">
                        <p className="important-title">ℹ️ جميع الخدمات تتم تحت الإشراف المباشر لأعضاء هيئة التدريس بالكلية</p>
                    </div>
                    <Link to="/booking">
                    <div className="button-booking">
                        حجز
                    </div>
                    </Link>

                </div>
            </div>
            
            </div>}
        <div className="doctors-section">
            <div className="doctors-container">
                <p className="doctor-title">الاطباء الاقرب لك</p>
                <div className="filter-buttons">
                    <button className="button-countery">المناطق </button>
                    <button className="button-city">المدن</button>
                </div>
                <div className="doctors-list">
                    <div className="doctor-flex">
                        <div className="doctor-card" onClick={() => setIsOpen(!isOpen)}>
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                         <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                 <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="doctor-flex">
                        <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                         <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="doctor-flex">
                        <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                            <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>


                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                         <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="doctor-flex">
                        <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                         <div className="doctor-card">
                            <img src="./doctor.jpg" alt="" />
                                <div className="doctor-details">
                                <div className="doctor-name-case">
                                    <p className="doctor-name">د. ساره عبدالله</p>
                                    <p className="doctor-case">تقويم اسنان</p>
                                    <div className="doctor-icon">
                                        <div className="icon-star">
                                            <svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M7.01795 0.863344C7.04716 0.804318 7.09229 0.754632 7.14825 0.719894C7.2042 0.685156 7.26875 0.666748 7.33461 0.666748C7.40047 0.666748 7.46502 0.685156 7.52098 0.719894C7.57693 0.754632 7.62207 0.804318 7.65128 0.863344L9.19128 3.98268C9.29273 4.18799 9.44249 4.36562 9.6277 4.50031C9.81291 4.63501 10.028 4.72275 10.2546 4.75601L13.6986 5.26001C13.7639 5.26947 13.8252 5.29699 13.8756 5.33948C13.926 5.38196 13.9636 5.43771 13.984 5.50041C14.0044 5.56312 14.0068 5.63028 13.991 5.6943C13.9752 5.75832 13.9418 5.81665 13.8946 5.86268L11.4039 8.28801C11.2397 8.44808 11.1168 8.64567 11.0458 8.86376C10.9749 9.08186 10.958 9.31394 10.9966 9.54001L11.5846 12.9667C11.5961 13.0319 11.5891 13.0991 11.5643 13.1605C11.5395 13.2219 11.4979 13.2751 11.4443 13.314C11.3907 13.3529 11.3273 13.376 11.2612 13.3806C11.1951 13.3852 11.1291 13.3711 11.0706 13.34L7.99195 11.7213C7.78909 11.6148 7.5634 11.5592 7.33428 11.5592C7.10516 11.5592 6.87947 11.6148 6.67661 11.7213L3.59861 13.34C3.54017 13.371 3.47421 13.3849 3.40825 13.3802C3.34228 13.3755 3.27896 13.3524 3.22548 13.3135C3.172 13.2746 3.1305 13.2215 3.10572 13.1602C3.08093 13.0988 3.07385 13.0318 3.08528 12.9667L3.67261 9.54068C3.71141 9.3145 3.6946 9.08228 3.62364 8.86404C3.55268 8.64581 3.42969 8.44811 3.26528 8.28801L0.774615 5.86334C0.72701 5.81737 0.693277 5.75894 0.677256 5.69473C0.661236 5.63051 0.663572 5.56309 0.684 5.50014C0.704428 5.43719 0.742126 5.38124 0.792799 5.33867C0.843472 5.29609 0.905083 5.26861 0.970614 5.25934L4.41395 4.75601C4.64079 4.72301 4.85621 4.63538 5.04167 4.50067C5.22713 4.36596 5.37708 4.18819 5.47861 3.98268L7.01795 0.863344Z" fill="#FDC700" stroke="#FDC700" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                            <p className="number-star">4.9</p>
                                        </div>
                                        <div className="doctor-distance">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="distance-number">3.2 كم</p>

                                    </div>
                                </div>
                                </div>
                                <div className="doctor-location">
                                    <div className="doctor-location-icon">
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <g clip-path="url(#clip0_397_1266)">
                                            <path d="M13.3334 6.66659C13.3334 9.99525 9.64075 13.4619 8.40075 14.5326C8.28523 14.6194 8.14461 14.6664 8.00008 14.6664C7.85555 14.6664 7.71493 14.6194 7.59941 14.5326C6.35941 13.4619 2.66675 9.99525 2.66675 6.66659C2.66675 5.2521 3.22865 3.89554 4.22885 2.89535C5.22904 1.89516 6.58559 1.33325 8.00008 1.33325C9.41457 1.33325 10.7711 1.89516 11.7713 2.89535C12.7715 3.89554 13.3334 5.2521 13.3334 6.66659Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M8 8.66675C9.10457 8.66675 10 7.77132 10 6.66675C10 5.56218 9.10457 4.66675 8 4.66675C6.89543 4.66675 6 5.56218 6 6.66675C6 7.77132 6.89543 8.66675 8 8.66675Z" stroke="#858585" stroke-width="1.33333" stroke-linecap="round" stroke-linejoin="round"/>
                                            </g>
                                            <defs>
                                            <clipPath id="clip0_397_1266">
                                            <rect width="16" height="16" fill="white"/>
                                            </clipPath>
                                            </defs>
                                        </svg>
                                        <p className="location">الزمالك</p>
                                    </div>
                                    <div className="doctor-available">
                                        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M7 3.5V7L9.33333 8.16667" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M7.00008 12.8334C10.2217 12.8334 12.8334 10.2217 12.8334 7.00008C12.8334 3.77842 10.2217 1.16675 7.00008 1.16675C3.77842 1.16675 1.16675 3.77842 1.16675 7.00008C1.16675 10.2217 3.77842 12.8334 7.00008 12.8334Z" stroke="#00A63E" stroke-width="1.16667" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                        <p className="available-title">متاح الان</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </>
    )
}

