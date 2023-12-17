Name:       harbour-happycamper

# >> macros
%define _binary_payload w2.xzdio
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude ^libc|libdl|libm|libpthread|libpython3.8m|libpython3.8m|python|env|libutil.*$
# << macros

Summary:    Happy Camper Bandcamp Downloader.
Version:    0.1.0
Release:    1
License:    GPLv3
BuildArch:  noarch
URL:        https://github.com/poetaster/happycamper
Source0:    %{name}-%{version}.tar.bz2
Source1:    harbour-happycamper-open-url.desktop
Source2:    50-harbour-happycamper.conf
Source3:    dbus-1/services/de.poetaster.happycamper.service
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libsailfishapp-launcher
Requires(pre): systemd
Requires(preun): systemd
Requires(post): systemd
Requires(postun): systemd
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  qt5-qttools-linguist

%if "%{?vendor}" == "chum"
BuildRequires:  python3-setuptools_scm
%endif

BuildRequires:  python3-rpm-macros
BuildRequires:  python3-setuptools
BuildRequires:  python3-base
BuildRequires:  python3-devel

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
 - https://raw.githubusercontent.com/poetaster/harbour-happycamper/main/screenshot-1.png
 - https://raw.githubusercontent.com/poetaster/harbour-happycamper/main/screenshot-2.png
 - https://raw.githubusercontent.com/poetaster/harbour-happycamper/main/screenshot-3.png
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


%qmake5

%make_build

%make_install
%install
rm -rf %{buildroot}
# >> install pre
install -D -m0644 %{SOURCE1}  %{_tmppath}/
install -D -m0644 %{SOURCE2}  %{_tmppath}/
install -D -m0644 %{SOURCE3}  %{_tmppath}/

install -p %{_tmppath}/%{name}-open-url.desktop %{buildroot}%{_datadir}/applications/%{name}-open-url.desktop
install -p %{_tmppath}/50-%{name}.conf %{buildroot}%{_userunitdir}/user-session.target.d/50-%{name}.conf
install -p %{_tmppath}/de.poetaster.happycamper.service %{buildroot}%{_datadir}/de.poetaster.happycamper.service
# << install pre
%qmake5_install


desktop-file-install --delete-original         --dir %{buildroot}%{_datadir}/applications                %{buildroot}%{_datadir}/applications/*.desktop

cd %{buildroot}%{_datadir}/%{name}/lib/requests
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf  %{buildroot}%{_datadir}/%{name}/lib/requests

cd %{buildroot}/%{_datadir}/%{name}/lib/docopt
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/docopt

cd %{buildroot}/%{_datadir}/%{name}/lib/mutagen
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/mutagen

cd %{buildroot}/%{_datadir}/%{name}/lib/campdown
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/campdown

rm -rf %{buildroot}/%{_datadir}/%{name}/share
rm -rf %{buildroot}/%{_datadir}/%{name}/bin

cd %_builddir

%preun
# >> preun
%systemd_preun booster-browser@%{name}.service
# << preun
%post
# >> post
%systemd_post booster-browser@%{name}.service
# << post
%postun
# >> postun
%systemd_postun booster-browser@%{name}.service
# << postun

%files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%dir %{_datadir}/%{name}
%{_datadir}/%{name}
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/dbus-1/services/*
%{_datadir}/applications/%{name}*.desktop
%{_datadir}/applications/%{name}-open-url.desktop
%{_userunitdir}/user-session.target.d/50-%{name}.conf
# >> files
# << files
