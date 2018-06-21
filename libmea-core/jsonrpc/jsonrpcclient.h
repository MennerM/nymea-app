/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea.                                      *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef JSONRPCCLIENT_H
#define JSONRPCCLIENT_H

#include <QObject>
#include <QVariantMap>
#include <QPointer>
#include <QVersionNumber>

#include "nymeaconnection.h"
#include "jsonhandler.h"

class JsonRpcReply;
class Param;
class Params;

class JsonRpcClient : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(bool initialSetupRequired READ initialSetupRequired NOTIFY initialSetupRequiredChanged)
    Q_PROPERTY(bool authenticationRequired READ authenticationRequired NOTIFY authenticationRequiredChanged)
    Q_PROPERTY(bool pushButtonAuthAvailable READ pushButtonAuthAvailable NOTIFY pushButtonAuthAvailableChanged)
    Q_PROPERTY(QString serverVersion READ serverVersion NOTIFY handshakeReceived)
    Q_PROPERTY(QString jsonRpcVersion READ jsonRpcVersion NOTIFY handshakeReceived)
    Q_PROPERTY(QString serverUuid READ serverUuid NOTIFY handshakeReceived)

public:
    explicit JsonRpcClient(NymeaConnection *connection, QObject *parent = 0);

    QString nameSpace() const override;

    void registerNotificationHandler(JsonHandler *handler, const QString &method);

    void sendCommand(const QString &method, const QVariantMap &params, QObject *caller = nullptr, const QString &callbackMethod = QString());
    void sendCommand(const QString &method, QObject *caller = nullptr, const QString &callbackMethod = QString());

    void setConnection(NymeaConnection *connection);
    bool connected() const;
    bool initialSetupRequired() const;
    bool authenticationRequired() const;
    bool pushButtonAuthAvailable() const;

    QString serverVersion() const;
    QString jsonRpcVersion() const;
    QString serverUuid() const;

    // ui methods
    Q_INVOKABLE int createUser(const QString &username, const QString &password);
    Q_INVOKABLE int authenticate(const QString &username, const QString &password, const QString &deviceName);
    Q_INVOKABLE int requestPushButtonAuth(const QString &deviceName);

    Q_INVOKABLE bool ensureServerVersion(const QString &jsonRpcVersion);

signals:
    void handshakeReceived();
    void initialSetupRequiredChanged();
    void authenticationRequiredChanged();
    void pushButtonAuthAvailableChanged();
    void connectedChanged(bool connected);
    void tokenChanged();
    void invalidProtocolVersion(const QString &actualVersion, const QString &minimumVersion);
    void authenticationFailed();
    void pushButtonAuthFailed();
    void createUserFailed(const QString &error);

    void responseReceived(const int &commandId, const QVariantMap &response);

private slots:
    void onInterfaceConnectedChanged(bool connected);
    void dataReceived(const QByteArray &data);

private:
    int m_id;
    // < namespace, <Handler, method> >
    QHash<QString, QPair<JsonHandler*, QString> > m_notificationHandlers;
    QHash<int, JsonRpcReply *> m_replies;
    NymeaConnection *m_connection = nullptr;

    JsonRpcReply *createReply(const QString &method, const QVariantMap &params, QObject *caller, const QString &callback);

    bool m_connected = false;
    bool m_initialSetupRequired = false;
    bool m_authenticationRequired = false;
    bool m_pushButtonAuthAvailable = false;
    int m_pendingPushButtonTransaction = -1;
    QString m_serverUuid;
    QVersionNumber m_jsonRpcVersion;
    QString m_serverVersion;
    QByteArray m_token;
    QByteArray m_receiveBuffer;

    void setNotificationsEnabled(bool enabled);

    // json handler
    Q_INVOKABLE void processAuthenticate(const QVariantMap &data);
    Q_INVOKABLE void processCreateUser(const QVariantMap &data);
    Q_INVOKABLE void processRequestPushButtonAuth(const QVariantMap &data);

    Q_INVOKABLE void setNotificationsEnabledResponse(const QVariantMap &params);
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

    void sendRequest(const QVariantMap &request);

};


class JsonRpcReply : public QObject
{
    Q_OBJECT
public:
    explicit JsonRpcReply(int commandId, QString nameSpace, QString method, QVariantMap params = QVariantMap(), QPointer<QObject> caller = QPointer<QObject>(), const QString &callback = QString());
    ~JsonRpcReply();

    int commandId() const;
    QString nameSpace() const;
    QString method() const;
    QVariantMap params() const;
    QVariantMap requestMap();

    QPointer<QObject> caller() const;
    QString callback() const;

private:
    int m_commandId;
    QString m_nameSpace;
    QString m_method;
    QVariantMap m_params;

    QPointer<QObject> m_caller;
    QString m_callback;
};


#endif // JSONRPCCLIENT_H
