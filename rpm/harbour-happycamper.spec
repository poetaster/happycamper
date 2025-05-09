Name:       harbour-happycamper

# >> macros
%define _binary_payload w2.xzdio
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude ^libc|libdl|libm|libpthread|libpython3.8m|libpython3.8m|python|env|libutil.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Summary:    Happy Camper Bandcamp Downloader.
Version:    0.1.6
Release:    1
License:    GPLv3
BuildArch:  noarch
URL:        https://github.com/poetaster/happycamper
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libsailfishapp-launcher
Requires:    python3-urllib3
Requires:    python3-requests
Requires:    python3-mutagen
Requires:    pyotherside-qml-plugin-python3-qt5 >= 1.2

BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  python3-devel
BuildRequires:  python3-rpm-macros
BuildRequires:  python3-setuptools

%if "%{?vendor}" == "chum"
BuildRequires:  python3-setuptools_scm
%endif

%description
Happycamper is a utility for downloading your tracks from Bandcamp.

%if "%{?vendor}" == "chum"
PackageName: harbour-happycamper
Type: desktop-application
Categories:
 - Utility
DeveloperName: Mark Washeim (poetaster)
Custom:
 - Repo: https://github.com/poetaster/happycamper
Icon: https://raw.githubusercontent.com/poetaster/happycamper/main/icons/172x172/harbour-happycamper.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/happycamper/refs/heads/main/screen2.png
 - https://raw.githubusercontent.com/poetaster/happycamper/refs/heads/main/screen1.png
Url:
  Donation: https://www.paypal.me/poetasterFOSS
%endif

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

cd %{buildroot}/%{_datadir}/%{name}/lib/docopt
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/docopt

cd %{buildroot}/%{_datadir}/%{name}/lib/campdown
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/campdown

rm -rf %{buildroot}/%{_datadir}/%{name}/share
rm -rf %{buildroot}/%{_datadir}/%{name}/bin

cd %_builddir


%files
# >> files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/applications/%{name}*.desktop
#%{_datadir}/dbus-1/services/de.poetaster.happycamper.service
# << files
