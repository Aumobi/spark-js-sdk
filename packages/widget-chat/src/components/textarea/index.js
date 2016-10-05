import React, {PropTypes} from 'react';

export default function TextArea(props) {
  const {
    onChange,
    onKeyDown,
    onSubmit,
    placeholder,
    value
  } = props;

  return (
    <textarea
      onChange={onChange}
      onKeyDown={onKeyDown}
      onSubmit={onSubmit}
      placeholder={placeholder}
      value={value}
    />
  );
}

TextArea.propTypes = {
  onChange: PropTypes.func,
  onKeyDown: PropTypes.func,
  onSubmit: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  value: PropTypes.string
};
