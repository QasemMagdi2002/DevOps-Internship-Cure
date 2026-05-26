import { Link } from "react-router-dom";

function Dashboard() {
  const user = JSON.parse(localStorage.getItem("cure_user") || "null");

  return (
    <main className="mx-auto w-full max-w-6xl px-6 py-10 text-left">
      <section className="rounded-3xl bg-gradient-to-r from-purple-700 to-indigo-700 p-8 text-white shadow-sm">
        <p className="mb-2 text-sm font-medium uppercase tracking-wide text-purple-100">
          CURE Patient Portal
        </p>

        <h1 className="mb-4 text-4xl font-bold">
          Welcome{user?.full_name ? `, ${user.full_name}` : ""}.
        </h1>

        <p className="max-w-2xl text-purple-100">
          Book appointments, view doctors, and manage your healthcare requests
          through a secure cloud-native portal.
        </p>

        <div className="mt-6 flex flex-wrap gap-3">
          <Link
            to="/doctors"
            className="rounded-xl bg-white px-5 py-3 font-medium text-purple-700 hover:bg-purple-50"
          >
            View Doctors
          </Link>

          <Link
            to="/appointments"
            className="rounded-xl border border-white/40 px-5 py-3 font-medium text-white hover:bg-white/10"
          >
            My Appointments
          </Link>
        </div>
      </section>

      <section className="mt-8 grid gap-6 md:grid-cols-3">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-2 text-xl font-semibold text-slate-900">
            Secure API
          </h2>
          <p className="text-sm text-slate-500">
            Backend protected with JWT authentication and role-based access.
          </p>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-2 text-xl font-semibold text-slate-900">
            PostgreSQL
          </h2>
          <p className="text-sm text-slate-500">
            Appointment and user data stored in a relational database.
          </p>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-2 text-xl font-semibold text-slate-900">
            Cloud Ready
          </h2>
          <p className="text-sm text-slate-500">
            Designed for Docker, EKS, RDS, CI/CD, and AWS production deployment.
          </p>
        </div>
      </section>
    </main>
  );
}

export default Dashboard;