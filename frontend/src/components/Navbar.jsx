import { Link, useNavigate } from "react-router-dom";

function Navbar() {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("cure_user") || "null");

  const handleLogout = () => {
    localStorage.removeItem("cure_token");
    localStorage.removeItem("cure_user");
    navigate("/login");
  };

  return (
    <nav className="w-full border-b border-slate-200 bg-white">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <Link to="/" className="text-xl font-bold text-purple-700">
          CURE Portal
        </Link>

        <div className="flex items-center gap-4 text-sm">
          {user ? (
            <>
              <Link to="/doctors" className="text-slate-700 hover:text-purple-700">
                Doctors
              </Link>
              <Link to="/appointments" className="text-slate-700 hover:text-purple-700">
                Appointments
              </Link>
              <span className="rounded-full bg-purple-50 px-3 py-1 text-purple-700">
                {user.full_name}
              </span>
              <button
                onClick={handleLogout}
                className="rounded-lg bg-slate-900 px-4 py-2 text-white hover:bg-slate-700"
              >
                Logout
              </button>
            </>
          ) : (
            <>
              <Link to="/login" className="text-slate-700 hover:text-purple-700">
                Login
              </Link>
              <Link
                to="/register"
                className="rounded-lg bg-purple-700 px-4 py-2 text-white hover:bg-purple-800"
              >
                Register
              </Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}

export default Navbar;