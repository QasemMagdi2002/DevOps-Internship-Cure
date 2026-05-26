import { useEffect, useState } from "react";
import api from "../api/client";

function Doctors() {
  const [doctors, setDoctors] = useState([]);
  const [selectedDoctorId, setSelectedDoctorId] = useState("");
  const [appointmentDate, setAppointmentDate] = useState("");
  const [reason, setReason] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loadingDoctors, setLoadingDoctors] = useState(true);
  const [booking, setBooking] = useState(false);

  const fetchDoctors = async () => {
    setLoadingDoctors(true);
    setError("");

    try {
      const response = await api.get("/doctors");
      setDoctors(response.data);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load doctors.");
    } finally {
      setLoadingDoctors(false);
    }
  };

  useEffect(() => {
    fetchDoctors();
  }, []);

  const handleBookAppointment = async (event) => {
    event.preventDefault();
    setMessage("");
    setError("");
    setBooking(true);

    try {
      await api.post("/appointments", {
        doctor_id: Number(selectedDoctorId),
        appointment_date: new Date(appointmentDate).toISOString(),
        reason,
      });

      setMessage("Appointment request submitted successfully.");
      setSelectedDoctorId("");
      setAppointmentDate("");
      setReason("");
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to book appointment.");
    } finally {
      setBooking(false);
    }
  };

  return (
    <main className="mx-auto w-full max-w-6xl px-6 py-10 text-left">
      <div className="mb-8">
        <p className="text-sm font-medium uppercase tracking-wide text-purple-700">
          Doctors
        </p>
        <h1 className="mt-2 text-3xl font-bold text-slate-900">
          Available healthcare providers
        </h1>
        <p className="mt-2 text-slate-500">
          Choose a doctor and submit an appointment request.
        </p>
      </div>

      {error && (
        <div className="mb-6 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
          {typeof error === "string" ? error : "Something went wrong."}
        </div>
      )}

      {message && (
        <div className="mb-6 rounded-xl bg-green-50 px-4 py-3 text-sm text-green-700">
          {message}
        </div>
      )}

      <section className="grid gap-6 lg:grid-cols-[1.3fr_0.7fr]">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-4 text-xl font-semibold text-slate-900">
            Doctor directory
          </h2>

          {loadingDoctors ? (
            <p className="text-slate-500">Loading doctors...</p>
          ) : doctors.length === 0 ? (
            <p className="text-slate-500">
              No doctors are available yet. Create doctors from the admin API.
            </p>
          ) : (
            <div className="grid gap-4 md:grid-cols-2">
              {doctors.map((doctor) => (
                <button
                  key={doctor.id}
                  type="button"
                  onClick={() => setSelectedDoctorId(String(doctor.id))}
                  className={`rounded-2xl border p-5 text-left transition hover:border-purple-500 ${
                    selectedDoctorId === String(doctor.id)
                      ? "border-purple-600 bg-purple-50"
                      : "border-slate-200 bg-white"
                  }`}
                >
                  <div className="flex items-center justify-between gap-3">
                    <h3 className="font-semibold text-slate-900">
                      {doctor.name}
                    </h3>
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-medium ${
                        doctor.available
                          ? "bg-green-50 text-green-700"
                          : "bg-slate-100 text-slate-500"
                      }`}
                    >
                      {doctor.available ? "Available" : "Unavailable"}
                    </span>
                  </div>

                  <p className="mt-2 text-sm text-purple-700">
                    {doctor.specialty}
                  </p>
                  <p className="mt-1 text-sm text-slate-500">
                    {doctor.location}
                  </p>
                </button>
              ))}
            </div>
          )}
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-4 text-xl font-semibold text-slate-900">
            Book appointment
          </h2>

          <form onSubmit={handleBookAppointment} className="space-y-4">
            <div>
              <label className="mb-1 block text-sm font-medium text-slate-700">
                Doctor
              </label>
              <select
                value={selectedDoctorId}
                onChange={(event) => setSelectedDoctorId(event.target.value)}
                className="w-full rounded-lg border border-slate-300 px-4 py-2 outline-none focus:border-purple-600"
                required
              >
                <option value="">Select doctor</option>
                {doctors.map((doctor) => (
                  <option key={doctor.id} value={doctor.id}>
                    {doctor.name} - {doctor.specialty}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="mb-1 block text-sm font-medium text-slate-700">
                Appointment date
              </label>
              <input
                type="datetime-local"
                value={appointmentDate}
                onChange={(event) => setAppointmentDate(event.target.value)}
                className="w-full rounded-lg border border-slate-300 px-4 py-2 outline-none focus:border-purple-600"
                required
              />
            </div>

            <div>
              <label className="mb-1 block text-sm font-medium text-slate-700">
                Reason
              </label>
              <textarea
                value={reason}
                onChange={(event) => setReason(event.target.value)}
                rows="4"
                className="w-full rounded-lg border border-slate-300 px-4 py-2 outline-none focus:border-purple-600"
                placeholder="Describe your appointment reason..."
                required
              />
            </div>

            <button
              disabled={booking}
              className="w-full rounded-lg bg-purple-700 px-4 py-2 font-medium text-white hover:bg-purple-800 disabled:opacity-60"
            >
              {booking ? "Submitting..." : "Book appointment"}
            </button>
          </form>
        </div>
      </section>
    </main>
  );
}

export default Doctors;