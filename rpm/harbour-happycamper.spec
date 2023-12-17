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

%build

%qmake5 

%make_build
%install

rm -rf %{buildroot}
# >> install pre
%__install -D -m 644 %{name}.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop
%__install -D -m 644 %{name}-open-url.desktop %{buildroot}%{_datadir}/applications/%{name}-open-url.desktop
%__install -D -m 644 50-%{name}.conf %{buildroot}%{_userunitdir}/user-session.target.d/50-%{name}.conf
for f in $(find dbus-1/ -type f -print); do
%__install -D -m 644 $f %{buildroot}%{_datadir}/${f}
done

%install
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
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_userunitdir}/user-session.target.d/50-%{name}.conf
%{_datadir}/dbus-1/services/*
