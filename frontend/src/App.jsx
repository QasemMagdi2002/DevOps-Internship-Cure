import { Navigate, Route, Routes } from "react-router-dom";

import Navbar from "./components/Navbar";
import Appointments from "./pages/Appointments";
import Dashboard from "./pages/Dashboard";
import Doctors from "./pages/Doctors";
import Login from "./pages/Login";
import Register from "./pages/Register";

function ProtectedRoute({ children }) {
  const token = localStorage.getItem("cure_token");

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

function PublicRoute({ children }) {
  const token = localStorage.getItem("cure_token");

  if (token) {
    return <Navigate to="/" replace />;
  }

  return children;
}

function App() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <Navbar />

      <Routes>
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />

        <Route
          path="/doctors"
          element={
            <ProtectedRoute>
              <Doctors />
            </ProtectedRoute>
          }
        />

        <Route
          path="/appointments"
          element={
            <ProtectedRoute>
              <Appointments />
            </ProtectedRoute>
          }
        />

        <Route
          path="/login"
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          }
        />

        <Route
          path="/register"
          element={
            <PublicRoute>
              <Register />
            </PublicRoute>
          }
        />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  );
}

export default App;