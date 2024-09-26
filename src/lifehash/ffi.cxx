#include <lifehash/lifehash.hpp>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

PYBIND11_MODULE(ffi, ffi) {
  namespace py = ::pybind11;

  py::enum_<::LifeHash::Version>(ffi, "Version")
      .value("version1", ::LifeHash::Version::version1)
      .value("version2", ::LifeHash::Version::version2)
      .value("detailed", ::LifeHash::Version::detailed)
      .value("fiducial", ::LifeHash::Version::fiducial)
      .value("grayscale_fiducial", ::LifeHash::Version::grayscale_fiducial);

  py::class_<::LifeHash::Image>(ffi, "Image")
      .def_readonly("width", &::LifeHash::Image::width)
      .def_readonly("height", &::LifeHash::Image::height)
      .def_readonly("colors", &::LifeHash::Image::colors);

  ffi.def("make_from_data", &::LifeHash::make_from_data);
  ffi.def("make_from_digest", &::LifeHash::make_from_digest);
  ffi.def("make_from_utf8", &::LifeHash::make_from_utf8);
}
