#ifndef POLICYKITLISTENER_H
#define POLICYKITLISTENER_H

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

#include <QPointer>
#include <QHash>
#include <QQuickView>
#include <QStringList>
#include <QObject>
#include <PolkitQt1/Agent/Listener>
#include <QString>

using namespace PolkitQt1::Agent;

class PolicyKitListener : public Listener
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.Polkit1AuthAgent")

public:
    explicit PolicyKitListener(QObject *parent = nullptr);
    ~PolicyKitListener() override;

    Q_INVOKABLE void dialogAccepted( const QString &passwd );

    Q_INVOKABLE QStringList getIdentities() const;
    //add by huanlele
    Q_INVOKABLE void invokeSendCancelSig();
    Q_INVOKABLE void invokeSendConfirmSig();
    Q_INVOKABLE void invokeSendErrorSig(int errorCode);

    Q_INVOKABLE QString getMessage();

    QString  errorMessage();

    Q_INVOKABLE void dialogCanceled();

signals:
    void sigCancel();
    void sigConfirm();
    void sigError(int errorCode);
    //end by huanlele
    void errorMessageChanged(QString errorStr);


public slots:
    void initiateAuthentication(const QString &actionId,
                                const QString &message,
                                const QString &iconName,
                                const PolkitQt1::Details &details,
                                const QString &cookie,
                                const PolkitQt1::Identity::List &identities,
                                PolkitQt1::Agent::AsyncResult* result) override;
    bool initiateAuthenticationFinish() override;
    void cancelAuthentication() override;
    void tryAgain();
    void finishObtainPrivilege();
    void completed(bool gainedAuthorization);
    void setWIdForAction(const QString &action, qulonglong wID);

private:
    QPointer<QQuickView> m_view;
    QPointer<Session> m_session;
    bool m_inProgress;
    bool m_gainedAuthorization;
    bool m_wasCancelled;
    int m_numTries;
    PolkitQt1::Identity::List m_identities;
    PolkitQt1::Agent::AsyncResult* m_result;
    QString m_cookie;
    PolkitQt1::Identity m_selectedUser;
    QHash< QString, qulonglong > m_actionsToWID;
    QString m_error;
    QString m_message;

    void setErrorMessage(const QString &errorMessage);

private slots:
    void userSelected(const PolkitQt1::Identity &identity);
    void userCancel();

};

#endif
