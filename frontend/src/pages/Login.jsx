import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api/client";

function Login() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    email: "",
    password: "",
  });

  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const updateField = (event) => {
    setForm({
      ...form,
      [event.target.name]: event.target.value,
    });
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");
    setLoading(true);

    try {
      const response = await api.post("/auth/login", form);

      localStorage.setItem("cure_token", response.data.access_token);
      localStorage.setItem(
        "cure_user",
        JSON.stringify({
          full_name: response.data.full_name,
          role: response.data.role,
        })
      );

      navigate("/");
    } catch (err) {
      setError(err.response?.data?.detail || "Login failed.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="flex min-h-[80vh] items-center justify-center px-6">
      <div className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
        <h1 className="mb-2 text-3xl font-bold text-slate-900">Welcome back</h1>
        <p className="mb-6 text-slate-500">
          Login to manage your appointments.
        </p>

        {error && (
          <div className="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4 text-left">
          <div>
            <label className="mb-1 block text-sm font-medium text-slate-700">
              Email
            </label>
            <input
              name="email"
              type="email"
              value={form.email}
              onChange={updateField}
              className="w-full rounded-lg border border-slate-300 px-4 py-2 outline-none focus:border-purple-600"
              required
            />
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-slate-700">
              Password
            </label>
            <input
              name="password"
              type="password"
              value={form.password}
              onChange={updateField}
              className="w-full rounded-lg border border-slate-300 px-4 py-2 outline-none focus:border-purple-600"
              required
            />
          </div>

          <button
            disabled={loading}
            className="w-full rounded-lg bg-purple-700 px-4 py-2 font-medium text-white hover:bg-purple-800 disabled:opacity-60"
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>

        <p className="mt-6 text-sm text-slate-500">
          No account yet?{" "}
          <Link to="/register" className="font-medium text-purple-700">
            Register
          </Link>
        </p>
      </div>
    </main>
  );
}

export default Login;