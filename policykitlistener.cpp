/*  This file is part of the KDE project
    Copyright (C) 2009 Jaroslav Reznik <jreznik@redhat.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include <QDBusConnection>
#include <QDebug>
#include <QQuickView>
#include <QQmlContext>
#include <QStringList>
#include <QQuickWindow>

#include <KWindowSystem>
// KF
#include <KAboutData>
#include <KLocalizedString>
#include <KCrash>
#include <KDBusService>
#include <KConfig>
#include <KLocalizedContext>


#include <PolkitQt1/Agent/Session>
#include <PolkitQt1/Subject>
#include <PolkitQt1/Identity>
#include <PolkitQt1/Details>

#include "policykitlistener.h"
#include "polkit1authagentadaptor.h"


PolicyKitListener::PolicyKitListener(QObject *parent)
        : Listener(parent)
        , m_inProgress(false)
        , m_selectedUser(nullptr)
{
    (void) new Polkit1AuthAgentAdaptor(this);

    if (!QDBusConnection::sessionBus().registerObject("/org/kde/Polkit1AuthAgent", this,
                                                     QDBusConnection::ExportScriptableSlots |
                                                     QDBusConnection::ExportAllSignals |      //add by huanlele
                                                     QDBusConnection::ExportScriptableProperties |
                                                     QDBusConnection::ExportAdaptors))
    {
        qWarning() << "Could not initiate DBus helper!";
    }

    qDebug() << "Listener online";
}

PolicyKitListener::~PolicyKitListener()
{

}

//add by huanlele
void PolicyKitListener::invokeSendCancelSig()
{
    QDBusMessage message = QDBusMessage::createSignal("/org/kde/Polkit1AuthAgent", "org.kde.Polkit1AuthAgent", "sigCancel");
    bool rv = QDBusConnection::sessionBus().send(message);
    if(rv == false) {
        qWarning() << Q_FUNC_INFO << " send dbus signal fail  path is /org/kde/Polkit1AuthAgent "
            << " interface is org.kde.Polkit1AuthAgent  signal is sigCancel";
    }
}

void PolicyKitListener::invokeSendConfirmSig()
{
    QDBusMessage message =QDBusMessage::createSignal("/org/kde/Polkit1AuthAgent", "org.kde.Polkit1AuthAgent", "sigConfirm");
    bool rv = QDBusConnection::sessionBus().send(message);
    if(rv == false) {
        qWarning() << Q_FUNC_INFO << " send dbus signal fail  path is /org/kde/Polkit1AuthAgent "
            << " interface is org.kde.Polkit1AuthAgent  signal is sigConfirm";
    }
}

void PolicyKitListener::invokeSendErrorSig(int errorCode)
{
    QDBusMessage message =QDBusMessage::createSignal("/org/kde/Polkit1AuthAgent", "org.kde.Polkit1AuthAgent", "sigError");
    message << errorCode;
    bool rv = QDBusConnection::sessionBus().send(message);
    if(rv == false) {
        qWarning() << Q_FUNC_INFO << " send dbus signal fail  path is /org/kde/Polkit1AuthAgent "
            << " interface is org.kde.Polkit1AuthAgent  signal is sigError";
    }
}
// end by huanlele
void PolicyKitListener::setWIdForAction(const QString& action, qulonglong wID)
{
    qDebug() << "On to the handshake";
    m_actionsToWID[action] = wID;
}

void PolicyKitListener::initiateAuthentication(const QString &actionId,
        const QString &message,
        const QString &iconName,
        const PolkitQt1::Details &details,
        const QString &cookie,
        const PolkitQt1::Identity::List &identities,
        PolkitQt1::Agent::AsyncResult* result)
{
    qDebug() << "Initiating authentication";

    if (m_inProgress) {
        result->setError(i18n("Another client is already authenticating, please try again later."));
        result->setCompleted();
        qDebug() << "Another client is already authenticating, please try again later.";
        return;
    }

    m_message = message;
    m_identities = identities;
    m_cookie = cookie;
    m_result = result;
    m_session.clear();

    m_inProgress = true;

    const WId parentId = m_actionsToWID.value(actionId, 0);

    if(!m_view) {
        m_view = new QQuickView;
        m_view->setFlags(Qt::FramelessWindowHint);
        m_view->setWindowState(Qt::WindowFullScreen);
        m_view->setWindowStates(Qt::WindowFullScreen);
        m_view->setColor(QColor(Qt::transparent));
        m_view->rootContext()->setContextProperty("policyKitListener", this);

        KLocalizedString::setApplicationDomain("polkit-kde-agent-1");
        m_view->rootContext()->setContextObject(new KLocalizedContext(m_view));

        m_view->setSource(QUrl::fromLocalFile("/usr/share/jingostest/systemui/org.jingtest.polkit-kde-authentication-agent-1/authdialog.qml"));
        m_view->showFullScreen();

        connect(m_view, &QQuickView::activeChanged, this, &PolicyKitListener::userCancel);
    }

    qDebug() << "WinId of the dialog is " << m_view->winId();
    KWindowSystem::forceActiveWindow(m_view->winId());

    qDebug() << "WinId of the shown dialog is " << m_view->winId();

    m_selectedUser = identities[0];
    m_numTries = 0;
    tryAgain();
}

void PolicyKitListener::tryAgain()
{
    qDebug() << "Trying again";
    m_wasCancelled = false;
    if (m_selectedUser.isValid()) {
        m_session = new Session(m_selectedUser, m_cookie, m_result);
        connect(m_session.data(), SIGNAL(completed(bool)), this, SLOT(completed(bool)));
        m_session.data()->initiate();
    }
}

void PolicyKitListener::finishObtainPrivilege()
{
    qDebug() << "Finishing obtaining privileges";

    if (m_selectedUser.isValid()) {
        m_numTries ++;
    }

    if (!m_gainedAuthorization && !m_wasCancelled && !m_view.isNull()) {
        m_error = i18n("Password input error, please try again");
        setErrorMessage(m_error);
        // if (m_numTries < 3) { //暂时不考虑调用次数的问题
        m_session.data()->deleteLater();
        tryAgain();
        return;
        // }
    }

    if (!m_session.isNull()) {
        m_session.data()->result()->setCompleted();
    } else {
        m_result->setCompleted();
    }

    m_session.data()->deleteLater();
    if (!m_view.isNull()) {
        m_view->hide();
        m_view->deleteLater();
        m_view = nullptr;
    }
    m_inProgress = false;
    qDebug() << "Finish obtain authorization:" << m_gainedAuthorization;
}

bool PolicyKitListener::initiateAuthenticationFinish()
{
    qDebug() << "Finishing authentication";
    return true;
}

void PolicyKitListener::cancelAuthentication()
{
    qDebug() << "Cancelling authentication, please try again";

    m_wasCancelled = true;
    finishObtainPrivilege();
}

void PolicyKitListener::completed(bool gainedAuthorization)
{
    qDebug() << "Completed: " << gainedAuthorization;

    m_gainedAuthorization = gainedAuthorization;

    if(m_gainedAuthorization) {
        invokeSendConfirmSig();
    }
    finishObtainPrivilege();
}
//request
void PolicyKitListener::dialogAccepted(const QString &passwd)
{
    qDebug() << "Dialog accepted";
    if (!m_view.isNull()) {
        m_session.data()->setResponse(passwd);
    }
}

void PolicyKitListener::dialogCanceled()
{
    qDebug() << "Dialog cancelled";

    m_wasCancelled = true;
    if (!m_session.isNull()) {
        m_session.data()->cancel();
    }
    finishObtainPrivilege();
}

void PolicyKitListener::userSelected(const PolkitQt1::Identity &identity)
{
    m_selectedUser = identity;
    // If some user is selected we must destroy existing session
    if (!m_session.isNull()) {
        m_session.data()->deleteLater();
    }
    tryAgain();
}

QStringList  PolicyKitListener::getIdentities() const
{
    QStringList  dentitylist;
    for(int i = 0; i < m_identities.size(); i++) {
        dentitylist << m_identities[i].toString();
    }
     return dentitylist;
}

void PolicyKitListener::setErrorMessage(const QString &errorMessage)
{
    m_error = errorMessage;
    emit errorMessageChanged(errorMessage);
}

QString PolicyKitListener::errorMessage()
{
    return m_error;
}

QString PolicyKitListener::getMessage()
{
    return m_message;
}

void PolicyKitListener::userCancel()
{
    qDebug() << "m_view->isActive()" << m_view->isActive();
    if (m_view == NULL) {
        return;
    }
    if (!m_view->isActive()) {
        dialogCanceled();
    }
}
