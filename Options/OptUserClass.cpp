/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 *
 * released under GNU GPL v2 licence
 *
 */

#include "DHCPConst.h"
#include "OptUserClass.h"
#include "Portable.h"
#include "hex.h"
#include <string.h>

TOptUserClass::TOptUserClass(uint16_t type, const char* buf, unsigned short buf_len, TMsg* parent)
    :TOpt(type, parent) {
    Valid = parseUserData(buf, buf_len);
}

TOptUserClass::TOptUserClass(uint16_t type, TMsg* parent)
    :TOpt(type, parent) {
    Valid = true;
}

TOptUserClass::TOptUserClass(const TOptUserClass& copy)
    :TOpt(copy.OptType, NULL) {
    Valid = true;
    this->userClassData_ = copy.userClassData_;
    this->Plain_ = copy.Plain_;
}

size_t TOptUserClass::getSize() {
    size_t len = 4;
    for (std::vector<UserClassData>::const_iterator data = userClassData_.begin();
	 data != userClassData_.end(); ++data) {
	len += 2; // len field
	len += data->opaqueData_.size();
    }
    return len;
}

char * TOptUserClass::storeSelf(char* buf) {
    buf = writeUint16(buf, OptType);
    buf = writeUint16(buf, getSize() - 4);
    return storeUserData(buf);
}

char * TOptUserClass::storeUserData(char* buf) {
    for (std::vector<UserClassData>::const_iterator data = userClassData_.begin();
	 data != userClassData_.end(); ++data) {
	buf = writeUint16(buf, data->opaqueData_.size());
	memcpy(buf, &data->opaqueData_[0], data->opaqueData_.size());
	buf += data->opaqueData_.size();
    }

    return buf;
}

/// @brief parses UserData field
///
/// @return true if parsing was successful, false otherwise
bool TOptUserClass::parseUserData(const char* buf, unsigned short buf_len) {
    int pos = 0;
    while (buf_len > 2) {
	uint16_t len = readUint16(buf + pos);
	buf_len -= sizeof(uint16_t);
	pos += sizeof(uint16_t);
	
	if (len > buf_len) {
	    // truncated user-data
	    return false;
	}
	UserClassData data;
	data.opaqueData_.resize(len);
	memcpy(&data.opaqueData_[0], buf + pos, len);
	userClassData_.push_back(data);
	Plain_ += hexToText((uint8_t*)(buf + pos), len);

	pos += len;
	buf_len -= len;
    }

    if (buf_len) {
	return false;
    }

    return true;
}

bool TOptUserClass::isValid() const {
    return true;
}

std::ostream & operator<<(std::ostream & out, TOptUserClass &x) {
    out << "    <option 15>" << x.Plain_ << "</option>" << std::endl;
    return out;
}
