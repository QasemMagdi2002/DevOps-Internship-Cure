import { useEffect, useState } from "react";
import api from "../api/client";

function Appointments() {
  const [appointments, setAppointments] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  const fetchAppointments = async () => {
    setLoading(true);
    setError("");

    try {
      const response = await api.get("/appointments/my");
      setAppointments(response.data);
    } catch (err) {
      setError(err.response?.data?.detail || "Failed to load appointments.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAppointments();
  }, []);

  const getStatusClass = (status) => {
    if (status === "confirmed") return "bg-green-50 text-green-700";
    if (status === "cancelled") return "bg-red-50 text-red-700";
    if (status === "completed") return "bg-blue-50 text-blue-700";
    return "bg-yellow-50 text-yellow-700";
  };

  return (
    <main className="mx-auto w-full max-w-6xl px-6 py-10 text-left">
      <div className="mb-8">
        <p className="text-sm font-medium uppercase tracking-wide text-purple-700">
          Appointments
        </p>
        <h1 className="mt-2 text-3xl font-bold text-slate-900">
          My appointment requests
        </h1>
        <p className="mt-2 text-slate-500">
          Track submitted appointments and approval status.
        </p>
      </div>

      {error && (
        <div className="mb-6 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
          {typeof error === "string" ? error : "Something went wrong."}
        </div>
      )}

      <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        {loading ? (
          <p className="text-slate-500">Loading appointments...</p>
        ) : appointments.length === 0 ? (
          <p className="text-slate-500">
            You have not booked any appointments yet.
          </p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="border-b border-slate-200 text-left text-slate-500">
                  <th className="py-3 pr-4 font-medium">ID</th>
                  <th className="py-3 pr-4 font-medium">Doctor ID</th>
                  <th className="py-3 pr-4 font-medium">Date</th>
                  <th className="py-3 pr-4 font-medium">Reason</th>
                  <th className="py-3 pr-4 font-medium">Status</th>
                </tr>
              </thead>

              <tbody>
                {appointments.map((appointment) => (
                  <tr
                    key={appointment.id}
                    className="border-b border-slate-100 text-slate-700"
                  >
                    <td className="py-4 pr-4">{appointment.id}</td>
                    <td className="py-4 pr-4">{appointment.doctor_id}</td>
                    <td className="py-4 pr-4">
                      {new Date(appointment.appointment_date).toLocaleString()}
                    </td>
                    <td className="max-w-xs py-4 pr-4">
                      {appointment.reason}
                    </td>
                    <td className="py-4 pr-4">
                      <span
                        className={`rounded-full px-3 py-1 text-xs font-medium ${getStatusClass(
                          appointment.status
                        )}`}
                      >
                        {appointment.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </main>
  );
}

export default Appointments;