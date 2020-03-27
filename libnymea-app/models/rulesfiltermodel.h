/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef RULESFILTERMODEL_H
#define RULESFILTERMODEL_H

#include <QSortFilterProxyModel>
#include <QUuid>

class Rules;
class Rule;

class RulesFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Rules* rules READ rules WRITE setRules NOTIFY rulesChanged)
    Q_PROPERTY(QString filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)
    Q_PROPERTY(bool filterExecutable READ filterExecutable WRITE setFilterExecutable NOTIFY filterExecutableChanged)

public:
    explicit RulesFilterModel(QObject *parent = nullptr);

    Rules* rules() const;
    void setRules(Rules* rules);

    QString filterDeviceId() const;
    void setFilterDeviceId(const QString &filterDeviceId);

    bool filterExecutable() const;
    void setFilterExecutable(bool filterExecutable);

    Q_INVOKABLE Rule* get(int index) const;

signals:
    void rulesChanged();
    void filterDeviceIdChanged();
    void filterExecutableChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    Rules *m_rules = nullptr;
    QString m_filterDeviceId;
    bool m_filterExecutable = false;
};

#endif // RULESFILTERMODEL_H